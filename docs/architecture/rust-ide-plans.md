# Rust Architecture Context
## CLI-Driven IDE Development Session Summary

**Date:** 2025-10-27
**Session Focus:** Architecture Documentation for LLM-Driven Development
**Status:** Architecture Complete, Ready for Implementation

---

## Overview

This document provides context for the comprehensive architecture work completed for a Rust-based CLI-driven IDE with integrated tiling window management and shared LLM context. Three complementary architecture documents have been created, each building upon the previous to form a complete implementation blueprint.

---

## Document Hierarchy

### 1. ARCHITECTURE.md (Base - 988 lines)
**Purpose:** Foundational architecture and requirements
**Status:** Complete
**Created:** 2025-10-26

**Key Sections:**
- Problem statement & success criteria
- System context & stakeholders
- Functional & non-functional requirements
- Component design (Terminal Manager, LLM Context Daemon, Editor Core, AI Assistant)
- Data architecture (SQLite schema for context store)
- Security architecture (STRIDE analysis, 5 security controls)
- Privacy architecture (GDPR/CCPA compliance)
- Performance architecture (targets and optimizations)
- Technology stack (Rust, ratatui, tower-lsp, SQLite+sqlcipher)
- 12-week development roadmap (6 phases)
- 5 Architecture Decision Records

**Core Innovations:**
1. **CLI-First Experience** - 11 integrated CLI tools with intelligent auto-start
2. **Shared LLM Context** - Persistent context layer enabling seamless AI tool handoffs
3. **Security by Design** - Zero-trust, local-first, automatic secret redaction
4. **Privacy by Design** - GDPR-compliant, user-controlled data, local storage

**Technology Decisions:**
- **Language:** Rust (ADR-001) - Memory safety, performance, ecosystem
- **Architecture:** Local-first (ADR-002) - Privacy, offline support, user trust
- **Database:** SQLite + sqlcipher (ADR-003) - Embedded, encrypted, ACID
- **IPC:** Unix sockets (ADR-004) - Low-latency, secure, bidirectional
- **Security:** Regex-based secret redaction (ADR-005) - 50+ patterns

### 2. ARCHITECTURE_ENHANCED.md (Enhanced - 900+ lines)
**Purpose:** Implementation patterns from VS Code, Cursor AI integration, AI-assisted development workflow
**Status:** Complete
**Created:** 2025-10-26

**Key Additions:**

#### VS Code-Inspired Implementation Patterns
Extracted from analyzing VS Code source code:

**Dependency Injection (instantiation.ts:110-127)**
```rust
pub struct ServiceContainer {
    services: HashMap<TypeId, Arc<dyn Any + Send + Sync>>,
    parent: Option<Arc<ServiceContainer>>,
}

// Type-safe service identifiers
pub const CONFIG_SERVICE: ServiceId<dyn IConfigurationService> =
    ServiceId::new("configurationService");
```

**Event System (event.ts:19-28)**
```rust
pub struct Event<T: Clone + Send + 'static> {
    sender: broadcast::Sender<T>,
}

// Composable transformations
impl Event<T> {
    pub fn map<U, F>(self, f: F) -> Event<U> { /* ... */ }
    pub fn filter<F>(self, predicate: F) -> Event<T> { /* ... */ }
    pub fn debounce(self, duration: Duration) -> Event<T> { /* ... */ }
}
```

**IPC Layer (ipc.ts:25-38)**
```rust
pub struct IpcChannel {
    stream: UnixStream,
}

impl IpcChannel {
    pub async fn call<T, R>(&mut self, command: &str, arg: &T) -> Result<R, String>
    // Length-prefixed JSON protocol over Unix socket
}
```

**Extension System (extensions.ts:122-140)**
```rust
pub trait Plugin: Send + Sync {
    fn activate(&mut self, context: &PluginContext) -> Result<(), String>;
    fn deactivate(&mut self) -> Result<(), String>;
}

// Dynamic library loading with libloading
pub struct PluginHost {
    plugins: Vec<Box<dyn Plugin>>,
    libraries: Vec<Library>,
}
```

**Configuration Registry (configuration.ts:38-47)**
```rust
pub enum ConfigurationScope {
    Application,
    User,
    Workspace,
    WorkspaceFolder,
}

// Multi-scope configuration with precedence
pub struct ConfigurationService {
    registry: HashMap<String, PropertySchema>,
    values: HashMap<ConfigurationScope, HashMap<String, serde_json::Value>>,
}
```

#### Cursor-Inspired AI Integration

**Autonomy Control Slider**
```rust
pub enum AutonomyLevel {
    Suggestion,  // Low: Inline suggestions only
    Edit,        // Medium: Multi-line edits with preview
    Agent,       // High: Autonomous changes across files
}
```

**Codebase Indexing**
```rust
pub struct CodebaseIndexer {
    index: tantivy::Index,  // Full-text search
    schema: Schema,
}

// Semantic search over entire project
pub fn search(&self, query: &str, limit: usize) -> Vec<SearchResult>
```

**Multi-LLM Provider**
```rust
#[async_trait]
pub trait LlmProvider: Send + Sync {
    async fn complete(&self, prompt: &str) -> Result<String, String>;
    async fn stream_complete(&self, prompt: &str) -> Result<Stream<String>, String>;
}

// Supports Claude, GPT-4, Gemini, local models
pub struct LlmManager {
    providers: HashMap<String, Arc<dyn LlmProvider>>,
}
```

#### AI-Assisted Development Workflow

From provided PDFs (AI-Assisted Code Development Guidelines, Code Review Process):

**Code Review Integration**
```rust
pub struct AiCodeReviewIntegration {
    // Mark AI-generated code for mandatory human review
    pub fn mark_ai_generated(&self, file_path: &str, range: Range);

    // Generate git commit with co-author attribution
    pub fn generate_commit_message(&self, ai_tool: &str) -> String;
}
```

**Security Scanning**
```rust
pub struct SecurityScanner {
    // Run Gitleaks (secrets), Semgrep (patterns), cargo audit (deps)
    pub async fn run_full_scan(&self, codebase_path: &str) -> ScanResult;
}
```

**Test Generation**
```rust
pub struct TestGenerator {
    // Generate tests using LLM, mark for human review
    pub async fn generate_tests(&self, function_code: &str) -> Result<String, String>;

    // Run and verify tests pass
    pub async fn verify_tests(&self, test_file: &str) -> Result<TestResult, String>;
}
```

**New ADRs:**
- ADR-006: Adopt VS Code's Layered Architecture
- ADR-007: Use Trait Objects for Service DI
- ADR-008: tokio::broadcast for Event System
- ADR-009: Dynamic Library Loading for Plugins
- ADR-010: Tantivy for Codebase Indexing

### 3. ARCHITECTURE_TILING.md (Tiling WM - 1,100+ lines)
**Purpose:** Integrated tiling window manager within TUI application
**Status:** Complete
**Created:** 2025-10-27
**Inspiration:** Omarchy - "A beautiful system is a motivating system"

**Key Innovations:**

#### Window Abstraction Layer
```rust
#[async_trait]
pub trait Window: Send + Sync {
    fn id(&self) -> WindowId;
    fn window_type(&self) -> WindowType;
    fn render(&mut self, area: Rect, buf: &mut Buffer);
    async fn handle_input(&mut self, event: KeyEvent) -> Result<InputResult, Error>;
    fn title(&self) -> String;
    fn get_context(&self) -> Option<WindowContext>;  // For LLM context
}

pub enum WindowType {
    Editor,           // Code editor with LSP
    Terminal,         // Shell or CLI tool
    AiChat,          // Chat interface with LLM
    Documentation,   // Man pages, docs viewer
    FileExplorer,    // File browser
    GitDiff,         // Git diff viewer
    Diagnostics,     // LSP diagnostics panel
    FloatingOverlay, // Floating window (command palette)
}
```

#### Layout Algorithms (i3/sway-inspired)
```rust
pub enum LayoutType {
    HSplit,     // Horizontal split (side-by-side)
    VSplit,     // Vertical split (top-bottom)
    Tabbed,     // Tabs (only one visible)
    Stacked,    // Stack with headers (all visible, minimized)
    Floating,   // Floating overlay
}

pub struct LayoutEngine {
    root: LayoutNode,
    focused_node: NodeId,
}

// Recursive layout calculation
pub fn calculate_layout(&self, area: Rect) -> HashMap<WindowId, Rect>
```

#### Workspace Management
```rust
pub struct Workspace {
    id: WorkspaceId,
    name: String,
    layout_engine: LayoutEngine,
    windows: HashMap<WindowId, WindowContainer>,
    metadata: WorkspaceMetadata,  // Project path, git branch, tags
}

pub struct WorkspaceManager {
    workspaces: Vec<Workspace>,  // 9 workspaces by default
    active_workspace: usize,
}
```

#### Focus & Navigation
```rust
pub struct FocusManager {
    focus_stack: Vec<WindowId>,
    current_focus: Option<WindowId>,
    focus_mode: FocusMode,  // Normal, Zen, Presentation
}

pub enum Direction { Left, Right, Up, Down }

// Directional navigation algorithm
pub fn find_nearest_window_in_direction(&self, from_rect: Rect, direction: Direction)
    -> Result<WindowId, Error>
```

#### Aesthetic System
```rust
pub struct CatppuccinTheme {
    flavor: Flavor,  // Latte, Frappe, Macchiato, Mocha
    palette: Palette,
}

pub struct Palette {
    // 26 named colors: rosewater, flamingo, pink, mauve, red...
    // Base colors: text, surface0, base, mantle, crust
}

// Different styles for focused vs unfocused
pub fn window_border_style(&self, focused: bool) -> Style
```

#### Keybinding System (i3-style)
```rust
pub enum Command {
    // Focus navigation
    FocusLeft, FocusRight, FocusUp, FocusDown,

    // Window management
    SplitHorizontal, SplitVertical, CloseWindow, ToggleFullscreen,

    // Layout
    LayoutHSplit, LayoutVSplit, LayoutTabbed, LayoutStacked,

    // Workspace
    SwitchWorkspace(u8), MoveToWorkspace(u8),

    // Mode
    ToggleZenMode,
}

// Default bindings: Super+h/j/k/l for focus, Super+1-9 for workspaces
```

**New ADRs:**
- ADR-011: TUI Tiling (not OS-level) - Portability, semantic awareness
- ADR-012: i3-Style Keybindings (not tmux) - No prefix key, faster
- ADR-013: Semantic Window Types (not generic panes) - Rich LLM context

---

## Architecture Layers

The complete system has the following layers:

```
┌─────────────────────────────────────────────────────────────┐
│                  NEW: Tiling WM Layer                       │
│  ┌────────────┬──────────────┬──────────────────────┐      │
│  │ Workspace  │ Layout Engine│ Focus Manager        │      │
│  │ Manager    │              │                      │      │
│  └─────┬──────┴──────┬───────┴──────┬───────────────┘      │
├────────┼─────────────┼──────────────┼──────────────────────┤
│        │             │              │                      │
│  ┌─────▼─────────────▼──────────────▼─────────────┐       │
│  │       Window Abstraction Layer                  │       │
│  │  (Editor, Terminal, AI windows implement Window)│       │
│  └─────┬─────────────┬──────────────┬─────────────┘       │
├────────┼─────────────┼──────────────┼──────────────────────┤
│        │             │              │                      │
│  ┌─────▼─────┐  ┌────▼──────┐  ┌───▼────────────┐        │
│  │ Editor    │  │ Terminal  │  │ AI Assistant   │        │
│  │ Core      │  │ Manager   │  │                │        │
│  │(ENHANCED) │  │(ENHANCED) │  │(ENHANCED)      │        │
│  └─────┬─────┘  └────┬──────┘  └───┬────────────┘        │
│        └─────────────┴──────────────┘                     │
│                      │                                     │
│              ┌───────▼──────────┐                         │
│              │ LLM Context      │                         │
│              │ Daemon           │                         │
│              │(ENHANCED)        │                         │
│              └──────────────────┘                         │
├─────────────────────────────────────────────────────────────┤
│              Platform Layer (DI, Config, Events)          │
│  ┌──────────────┬────────────────┬────────────────────┐   │
│  │ Service      │ Configuration  │ Event System       │   │
│  │ Container    │ Service        │                    │   │
│  └──────────────┴────────────────┴────────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│                   Base Layer (Primitives)                 │
│  ┌──────────────┬────────────────┬────────────────────┐   │
│  │ IPC Protocol │ Lifecycle      │ Error Handling     │   │
│  │              │ Management     │                    │   │
│  └──────────────┴────────────────┴────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Crate Structure

Recommended Cargo workspace structure:

```
cli-ide/
├── Cargo.toml                      # Workspace root
├── crates/
│   ├── cli-ide-base/               # Base layer
│   │   ├── src/
│   │   │   ├── event.rs           # Event<T> system
│   │   │   ├── ipc/
│   │   │   │   ├── protocol.rs    # IPC protocol
│   │   │   │   └── channel.rs     # IpcChannel
│   │   │   ├── lifecycle.rs       # Disposable, lifecycle
│   │   │   └── error.rs           # Error types
│   │   └── Cargo.toml
│   │
│   ├── cli-ide-platform/           # Platform layer
│   │   ├── src/
│   │   │   ├── di/
│   │   │   │   └── service_container.rs  # DI system
│   │   │   ├── config/
│   │   │   │   ├── configuration_service.rs
│   │   │   │   └── registry.rs
│   │   │   └── log/
│   │   │       └── logging_service.rs
│   │   └── Cargo.toml
│   │
│   ├── cli-ide-workbench/          # Workbench layer
│   │   ├── src/
│   │   │   ├── window/
│   │   │   │   ├── mod.rs         # Window trait
│   │   │   │   ├── container.rs   # WindowContainer
│   │   │   │   ├── editor_window.rs
│   │   │   │   ├── terminal_window.rs
│   │   │   │   └── ai_chat_window.rs
│   │   │   ├── layout/
│   │   │   │   ├── engine.rs      # LayoutEngine
│   │   │   │   ├── algorithms.rs  # HSplit, VSplit, etc.
│   │   │   │   └── persistence.rs
│   │   │   ├── workspace/
│   │   │   │   ├── workspace.rs   # Workspace
│   │   │   │   └── manager.rs     # WorkspaceManager
│   │   │   ├── focus/
│   │   │   │   ├── manager.rs     # FocusManager
│   │   │   │   └── navigation.rs  # Directional navigation
│   │   │   ├── editor/
│   │   │   │   ├── buffer.rs      # Text buffer (ropey)
│   │   │   │   ├── syntax.rs      # Syntax highlighting
│   │   │   │   └── lsp_client.rs  # LSP integration
│   │   │   ├── terminal/
│   │   │   │   ├── spawner.rs     # PTY allocation
│   │   │   │   └── output_capturer.rs
│   │   │   ├── ai/
│   │   │   │   ├── llm_provider.rs
│   │   │   │   ├── autonomy_controller.rs
│   │   │   │   ├── codebase_indexer.rs
│   │   │   │   └── completion_provider.rs
│   │   │   ├── theme/
│   │   │   │   ├── catppuccin.rs  # Theme system
│   │   │   │   ├── borders.rs     # Border rendering
│   │   │   │   └── animations.rs  # Transitions
│   │   │   ├── input/
│   │   │   │   └── keybindings.rs # Keybinding system
│   │   │   └── security/
│   │   │       └── scanner.rs     # Security scanning
│   │   └── Cargo.toml
│   │
│   ├── cli-ide-extensions/         # Extension system
│   │   ├── src/
│   │   │   ├── plugin_host.rs     # Plugin host
│   │   │   ├── plugin_api.rs      # Plugin trait
│   │   │   └── registry.rs        # Extension registry
│   │   └── Cargo.toml
│   │
│   └── cli-ide-daemon/             # LLM context daemon
│       ├── src/
│       │   ├── main.rs            # Daemon entry point
│       │   ├── ipc_server.rs      # IPC server
│       │   ├── context_store.rs   # SQLite storage
│       │   ├── context_synthesizer.rs  # LLM integration
│       │   └── secret_redactor.rs # Secret redaction
│       └── Cargo.toml
│
├── docs/
│   ├── ARCHITECTURE.md             # Base architecture
│   ├── ARCHITECTURE_ENHANCED.md    # Enhanced with patterns
│   ├── ARCHITECTURE_TILING.md      # Tiling WM architecture
│   └── adr/                        # Architecture Decision Records
│       ├── 001-rust-for-core.md
│       ├── 002-local-first.md
│       └── ...
│
└── tests/
    ├── integration/
    └── performance/
```

---

## Key Technologies

| Category | Technology | Rationale |
|----------|-----------|-----------|
| **Language** | Rust | Memory safety, performance, rich ecosystem |
| **TUI Framework** | ratatui | Mature, active community, good docs |
| **Async Runtime** | Tokio | De facto standard, well-tested |
| **LSP** | tower-lsp | Standard LSP implementation |
| **Text Buffer** | ropey | Efficient rope data structure |
| **Parsing** | tree-sitter | Incremental, error-tolerant |
| **Database** | SQLite + sqlcipher | Embedded, encrypted, zero-config |
| **IPC** | Unix sockets | Low-latency, secure (local only) |
| **HTTP Client** | reqwest | Ergonomic, TLS support |
| **Crypto** | ring | Audited, FIPS-compliant |
| **Search** | tantivy | Fast full-text search |
| **PTY** | portable-pty | Cross-platform PTY handling |
| **Terminal** | crossterm | Terminal I/O abstraction |

---

## Implementation Roadmap

### Combined 18-Week Roadmap

#### Phase 1: Foundation (Weeks 1-2)
**From ENHANCED:**
- Event system with transformations
- Service container (DI)
- Text buffer with rope data structure

**From TILING:**
- Window trait and base containers
- EditorWindow, TerminalWindow wrappers
- Basic rendering pipeline

**Milestone:** Single EditorWindow and TerminalWindow side-by-side

#### Phase 2: Core Services (Weeks 3-4)
**From ENHANCED:**
- Terminal spawner (PTY allocation)
- Window manager (floating terminals)
- Keybinding router

**From TILING:**
- LayoutNode tree structure
- HSplit/VSplit algorithms
- Resize operations

**Milestone:** 2x2 grid of windows with manual resizing

#### Phase 3: IPC & Daemon (Weeks 5-6)
**From ENHANCED:**
- Unix socket IPC protocol
- Context store (SQLite + encryption)
- Daemon lifecycle management

**From TILING:**
- Workspace struct and manager
- Workspace switching logic
- Session persistence

**Milestone:** 3 workspaces with different layouts, daemon captures output

#### Phase 4: LLM Integration (Weeks 7-8)
**From ENHANCED:**
- LLM provider abstraction
- Context synthesis with Claude API
- Secret redaction (50+ patterns)

**From TILING:**
- Focus manager
- Directional navigation (hjkl)
- Focus history and indicators

**Milestone:** Context handoff demo, navigate with Super+hjkl

#### Phase 5: Configuration & Extensions (Weeks 9-10)
**From ENHANCED:**
- Configuration service with multi-scope
- Configuration TUI
- Plugin host (dynamic loading)

**From TILING:**
- Tabbed layout algorithm
- Stacked layout algorithm
- Floating window manager

**Milestone:** All 5 layout types working, dynamic CLI tool config

#### Phase 6: AI Features (Weeks 11-12)
**From ENHANCED:**
- Autonomy controller (Suggestion/Edit/Agent)
- Codebase indexer (tantivy)
- Security scanner integration

**From TILING:**
- Catppuccin theme system
- Border rendering with focus indicators
- Transition animations

**Milestone:** Inline completions, semantic search, beautiful UI

#### Phase 7: Polish & Testing (Weeks 13-14)
- Performance testing (k6)
- Memory leak detection (heaptrack)
- Security audit (Gitleaks, Semgrep)
- Documentation and user guides

**Milestone:** Production-ready, all tests passing

#### Phase 8: Advanced Features (Weeks 15-18)
- Multi-LLM support (GPT-4, Gemini)
- Advanced codebase understanding (semantic embeddings)
- Collaborative features (CRDTs for future P2P)
- Plugin marketplace

**Milestone:** Feature parity with Cursor + Omarchy aesthetic

---

## Comparison with Existing Tools

| Feature | VS Code | Cursor | Omarchy | Warp | tmux | **Our System** |
|---------|---------|--------|---------|------|------|----------------|
| **Platform** | Electron GUI | Electron GUI | Wayland WM | Native GUI | TUI | TUI |
| **Tiling** | ❌ | ❌ | ✅ Advanced | ❌ | ✅ Simple | ✅ Advanced |
| **AI Integration** | Extensions | ✅ Native | ❌ | ✅ Native | ❌ | ✅ Native |
| **LSP** | ✅ | ✅ | ✅ (via editor) | ✅ | ❌ | ✅ |
| **Shared Context** | ❌ | ✅ (proprietary) | ❌ | ✅ (limited) | ❌ | ✅ (open) |
| **Local-First** | ❌ | ❌ | ✅ | ❌ | ✅ | ✅ |
| **Workspaces** | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| **Aesthetics** | Good | Good | Excellent | Good | Basic | Excellent |
| **Performance** | Medium | Medium | High | High | Very High | High |
| **Privacy** | Medium | Low | High | Low | High | High |
| **Extensibility** | ✅ Extensions | Limited | ✅ Config | Limited | Limited | ✅ Plugins |

---

## Key Differentiators

### 1. Semantic Window Management
Unlike tmux (generic panes) or Omarchy (generic X11 windows):
- **Type Awareness:** Knows if window is editor, terminal, AI chat, docs
- **Rich Metadata:** Tracks file path, cursor position, exit codes, conversation history
- **Smart Context:** Each window contributes relevant data to LLM context

### 2. Unified LLM Context
Unlike Cursor (proprietary) or Warp (siloed):
- **Cross-Tool Context:** Claude Code → Aider → Codex seamless handoff
- **Persistent History:** Conversations survive tool restarts
- **Privacy Controls:** User approves what gets shared, local storage only

### 3. TUI-Level Tiling
Unlike Omarchy (OS-level) or tmux (limited):
- **Portable:** Works on any OS, any terminal
- **Advanced Layouts:** i3-style tiling with 5 layout modes
- **Session Persistence:** Save exact window positions, restore on startup

### 4. Beautiful by Default
Unlike traditional TUIs:
- **Catppuccin Themes:** Professional, consistent color palette
- **Smooth Transitions:** Animated window resizing and focus changes
- **Thoughtful Borders:** Clear focus indicators, minimalist design
- **"Beautiful = Motivating":** Omarchy's philosophy baked in

### 5. AI-Assisted Development Workflow
Unlike generic AI tools:
- **Review Gates:** Mandatory human review of AI-generated code
- **Co-Authorship:** Git commits attribute AI contributions
- **Security Scanning:** Gitleaks, Semgrep, cargo audit integrated
- **Test Generation:** LLM-generated tests with verification

---

## Critical Success Factors

### Technical
1. **Performance:** Startup < 1s, terminal toggle < 200ms, context injection < 300ms
2. **Reliability:** Daemon uptime > 99.5%, graceful degradation, auto-recovery
3. **Security:** Zero secrets leaked, all secrets redacted, encrypted storage
4. **Privacy:** GDPR-compliant, local-first, user controls data

### User Experience
1. **Keyboard-Driven:** No mouse required, vim-like bindings, fast navigation
2. **Beautiful:** Catppuccin themes, smooth animations, clear focus indicators
3. **Discoverable:** Command palette, help system, sensible defaults
4. **Flexible:** 9 workspaces, 5 layout modes, configurable keybindings

### Development
1. **LLM-Consumable:** Clear architecture docs, code examples, implementation checklist
2. **Incremental:** 6-phase roadmap, clear milestones, testable at each phase
3. **AI-Assisted:** 100% code review, co-authorship tracking, security scanning
4. **Quality:** ADRs for decisions, comprehensive tests, performance benchmarks

---

## Open Questions & Future Work

### Short-Term (Pre-MVP)
- [ ] Which LLM for context synthesis? (Claude 3.5 Sonnet vs GPT-4)
- [ ] Terminal emulator compatibility testing (wezterm, kitty, alacritty)
- [ ] Optimal default workspace count? (9 vs 5 vs customizable)
- [ ] Plugin API stability guarantees? (semver, versioning strategy)

### Medium-Term (Post-MVP)
- [ ] Windows/WSL support? (Named pipes vs Unix sockets)
- [ ] GUI mode? (iced or egui for GUI alternative to TUI)
- [ ] Cloud sync? (Optional encrypted backup to S3/B2)
- [ ] Collaborative editing? (CRDTs for real-time collaboration)

### Long-Term (Phase 7+)
- [ ] OS-level WM integration? (Complement rather than compete with Hyprland)
- [ ] Language server plugin? (Extend LSP with AI-powered features)
- [ ] Web frontend? (wasm-based web client for remote access)
- [ ] Mobile companion? (View context, approve AI suggestions on phone)

---

## Getting Started (Implementation)

### Prerequisites
```bash
# Install Rust toolchain
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install required tools
cargo install cargo-watch cargo-nextest cargo-audit

# Install security scanners
brew install gitleaks semgrep
```

### Create Workspace
```bash
# Create workspace structure
cargo new --name cli-ide .
mkdir -p crates/{cli-ide-base,cli-ide-platform,cli-ide-workbench,cli-ide-extensions,cli-ide-daemon}

# Initialize each crate
for crate in base platform workbench extensions daemon; do
  cargo new --lib crates/cli-ide-$crate
done

# Configure workspace Cargo.toml
# (See crate structure above)
```

### Phase 1 Checklist
- [ ] Set up Cargo workspace
- [ ] Implement Event<T> system (cli-ide-base/src/event.rs)
- [ ] Implement ServiceContainer (cli-ide-platform/src/di/service_container.rs)
- [ ] Create Window trait (cli-ide-workbench/src/window/mod.rs)
- [ ] Implement EditorWindow (cli-ide-workbench/src/window/editor_window.rs)
- [ ] Implement TerminalWindow (cli-ide-workbench/src/window/terminal_window.rs)
- [ ] Basic rendering loop with ratatui
- [ ] Demo: Single editor + terminal side-by-side

---

## References

### Architecture Documents
- [ARCHITECTURE.md](./ARCHITECTURE.md) - Base architecture (988 lines)
- [ARCHITECTURE_ENHANCED.md](./ARCHITECTURE_ENHANCED.md) - Enhanced patterns (900+ lines)
- [ARCHITECTURE_TILING.md](./ARCHITECTURE_TILING.md) - Tiling WM (1,100+ lines)

### External Inspiration
- **VS Code:** [github.com/microsoft/vscode](https://github.com/microsoft/vscode)
  - `src/vs/platform/instantiation/` - DI system
  - `src/vs/base/common/event.ts` - Event system
  - `src/vs/base/parts/ipc/` - IPC layer
- **Omarchy:** [omarchy.org](https://omarchy.org/), [learn.omacom.io](https://learn.omacom.io/)
  - Beautiful system = motivating system
  - Keyboard-driven workflow
  - Hyprland tiling patterns
- **Cursor:** [cursor.com](https://cursor.com/)
  - Autonomy control (suggestion → edit → agent)
  - Codebase indexing
  - Multi-LLM support

### Rust Ecosystem
- **ratatui:** [ratatui.rs](https://ratatui.rs/) - TUI framework
- **tokio:** [tokio.rs](https://tokio.rs/) - Async runtime
- **tower-lsp:** [github.com/ebkalderon/tower-lsp](https://github.com/ebkalderon/tower-lsp) - LSP
- **tantivy:** [github.com/quickwit-oss/tantivy](https://github.com/quickwit-oss/tantivy) - Search
- **tree-sitter:** [tree-sitter.github.io](https://tree-sitter.github.io/) - Parsing

---

## Contact & Collaboration

**Author:** Christopher Manahan
**Email:** cmanahan@chanzuckerberg.com
**Repository:** [github.com/christophermanahan/paradiddle](https://github.com/christophermanahan/paradiddle)
**Slack:** #cli-ide-dev

---

## Document End

This context document captures the complete state of architecture work for the Rust-based CLI IDE with integrated tiling window management. All patterns, code examples, and implementation guidance are ready for LLM-driven iterative development.

**Status:** ✅ Architecture Complete - Ready to begin Phase 1 implementation
