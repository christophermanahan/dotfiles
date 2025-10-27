# Technical and Security Architecture Document
## CLI-Driven IDE with Shared LLM Context

**Document Version:** 1.0
**Date:** 2025-10-26
**Author:** Christopher Manahan
**Status:** Draft - For LLM-Driven Iterative Development
**Related Documents:**
- [AI-Assisted Code Development Guidelines](./docs/AI-Assisted_Code_Development_Guidelines.pdf)
- [AI-Assisted Code Review Process](./docs/AI-Assisted_Code_Review_Process.pdf)
- [0 → 1 AI Driven Application Development](./docs/0_to_1_AI_Driven_Development.pdf)
- [Prototyping With Rust](./docs/Prototyping_With_Rust.pdf)
- [SESSION_CONTEXT.md](./SESSION_CONTEXT.md)

---

## Executive Summary

This document defines the technical and security architecture for a next-generation CLI-driven IDE that integrates shared LLM context at its core. The application builds upon the proven patterns from **Paradiddle** (a CLI-first Neovim configuration) while incorporating advanced features inspired by modern AI-assisted IDEs like Warp and Cursor. The architecture prioritizes:

1. **CLI-First Experience** - Terminal tools as first-class citizens with intelligent auto-start
2. **Shared LLM Context** - Persistent, privacy-preserving context layer enabling seamless handoffs between AI tools
3. **Security & Privacy by Design** - Zero-trust architecture, local-first data, automatic secret redaction
4. **Performance & Reliability** - Built in Rust for safety, speed, and correctness
5. **Developer Velocity** - AI-assisted development with human oversight at every gate

The system will be developed iteratively following the "0 → 1 AI driven application development" methodology, ensuring quality gates, ADRs for key decisions, and comprehensive observability from day one.

---

## Table of Contents

1. [Problem Statement & Success Criteria](#1-problem-statement--success-criteria)
2. [System Context & Stakeholders](#2-system-context--stakeholders)
3. [Requirements](#3-requirements)
4. [Architecture Overview](#4-architecture-overview)
5. [Component Design](#5-component-design)
6. [Data Architecture](#6-data-architecture)
7. [Security Architecture](#7-security-architecture)
8. [Privacy Architecture](#8-privacy-architecture)
9. [Performance Architecture](#9-performance-architecture)
10. [Observability & Operations](#10-observability--operations)
11. [Technology Stack](#11-technology-stack)
12. [Development Roadmap](#12-development-roadmap)
13. [Architecture Decision Records](#13-architecture-decision-records)
14. [Risk Analysis](#14-risk-analysis)
15. [Appendix](#15-appendix)

---

## 1. Problem Statement & Success Criteria

### 1.1 Problem Statement

Modern developers face fragmentation in their AI-assisted workflows:

- **Context Loss**: Switching between AI tools (Claude Code, Cursor, Copilot) loses conversation history and intent
- **Manual Integration**: Developers manually copy-paste context between tools, introducing errors and friction
- **Terminal Overhead**: Traditional IDEs treat CLI tools as afterthoughts, requiring context switching and window management
- **Privacy Concerns**: Cloud-based AI tools raise data residency and compliance questions
- **Slow Prototyping**: Python's dependency management and incidental bugs slow AI/ML experimentation

### 1.2 Definition of Success

**Leading Metrics:**
- Time-to-first-prototype < 1 week for new AI/ML experiments (vs 2-3 weeks with Python)
- Context retention rate > 90% when switching between LLM tools
- Terminal tool access time < 200ms (single keystroke)
- Zero secrets leaked via LLM context sharing

**Lagging Metrics:**
- Developer adoption: 80% of team using within 6 months
- Productivity gain: 30% reduction in time spent on environment setup/debugging
- Security posture: Zero CVEs introduced via AI-generated code (human review gate)
- User satisfaction: NPS > 50 from daily active users

### 1.3 Non-Goals

- **Not a cloud IDE**: This is a local-first, desktop/terminal application
- **Not a general-purpose text editor**: Focus is on AI-assisted development workflows
- **Not a replacement for specialized tools**: Complements, doesn't replace IDEs like IntelliJ for Java
- **Not a training platform**: Assumes users have baseline terminal proficiency

---

## 2. System Context & Stakeholders

### 2.1 System Context Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Developer's Machine                      │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │               CLI-First IDE (Rust)                      │    │
│  │                                                          │    │
│  │  ┌──────────────┐    ┌──────────────┐    ┌──────────┐│    │
│  │  │ Terminal     │    │ LLM Context  │    │  Editor  ││    │
│  │  │ Manager      │◄───┤    Daemon    │◄───┤  Core    ││    │
│  │  │ (11+ tools)  │    │  (Go/Rust)   │    │  (Rust)  ││    │
│  │  └──────┬───────┘    └───────┬──────┘    └────┬─────┘│    │
│  │         │                    │                 │       │    │
│  │         │                    │                 │       │    │
│  │  ┌──────▼─────────────────────▼────────────────▼───┐  │    │
│  │  │       Local Context Store (~/.nvim_context/)    │  │    │
│  │  │    (SQLite + JSON, encrypted at rest)          │  │    │
│  │  └────────────────────────────────────────────────┘  │    │
│  └────────────────────────────────────────────────────────┘    │
│                            │                                     │
│                            │ Unix Sockets / IPC                 │
│                            │                                     │
│  ┌──────────────────────────▼─────────────────────────────┐    │
│  │    External LLM APIs (Claude, GPT-4, etc)              │    │
│  │    (HTTPS, rate-limited, API key management)           │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │    Terminal Tools (Integrated)                          │    │
│  │  • Claude Code • k9s • Lazygit • e1s/e2s • Aider etc.  │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │    Source Code Repositories (Git)                       │    │
│  │    Project Files, Build Systems, CI/CD                  │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
           │                                  │
           │ Pull/Push                        │ Telemetry (Opt-in)
           ▼                                  ▼
    ┌────────────┐                    ┌──────────────┐
    │   GitHub   │                    │  Observability│
    │   GitLab   │                    │   Platform    │
    │   Bitbucket│                    │  (Prometheus) │
    └────────────┘                    └──────────────┘
```

### 2.2 Stakeholders

| Role | Responsibilities | Success Criteria |
|------|-----------------|------------------|
| **Staff Engineers** | Primary users; prototype AI/ML systems; provide architecture feedback | Can spin up new experiments in < 1 week; Context sharing "just works" |
| **Engineering Leads** | Approve technology choices; ensure team adoption; manage tech debt | Team velocity increases 30%; No security incidents from AI code |
| **Security Team** | Threat modeling; pen testing; compliance reviews | Zero secrets leaked; All AI-generated code reviewed; Audit logs complete |
| **DevOps/SRE** | CI/CD integration; observability setup; production support | SLOs met (99.5% uptime for daemon); Runbooks clear; Incidents resolved < 1hr |
| **Product Team** | Prioritization; user research; release planning | Feature adoption > 80%; User satisfaction high; Roadmap aligned with needs |
| **Compliance/Legal** | Data privacy; licensing; regulatory requirements | GDPR/CCPA compliant; OSS licenses vetted; Terms of service clear |

---

## 3. Requirements

### 3.1 Functional Requirements

#### FR-1: Terminal Tool Management
- **FR-1.1**: Support 11+ CLI tools as floating terminals with cascading window positions
- **FR-1.2**: One-keystroke access (ALT+key) to any integrated tool
- **FR-1.3**: Intelligent auto-start with contextual defaults (e.g., k9s cluster selection)
- **FR-1.4**: Unified kill command (ALT+p) to reset all terminal states

#### FR-2: LLM Context Daemon
- **FR-2.1**: Background service captures terminal output from LLM-enabled tools
- **FR-2.2**: Synthesize context using Claude API (or configured LLM)
- **FR-2.3**: Inject context invisibly when launching new LLM tools
- **FR-2.4**: Support context handoff: Claude Code → Aider → Codex → etc.
- **FR-2.5**: Maintain conversation history across sessions (encrypted at rest)

#### FR-3: Dynamic CLI Configuration
- **FR-3.1**: TUI (`:CLIToolsConfig`) for adding/editing/removing CLI integrations
- **FR-3.2**: JSON-based configuration storage (`~/.config/nvim/lua/cli_tools.json`)
- **FR-3.3**: Keybinding conflict detection and validation
- **FR-3.4**: Test launch functionality directly from UI
- **FR-3.5**: Hot-reload configuration without restart

#### FR-4: Editor Core
- **FR-4.1**: Syntax highlighting for 50+ languages (via tree-sitter)
- **FR-4.2**: LSP integration for autocomplete, go-to-definition, diagnostics
- **FR-4.3**: Multi-cursor editing, vim keybindings (default), fuzzy finder
- **FR-4.4**: Git integration (blame, diff, staging)
- **FR-4.5**: Split panes, tabs, buffer management

#### FR-5: AI-Assisted Features
- **FR-5.1**: Inline code completion (Copilot-style)
- **FR-5.2**: Chat sidebar (Cursor-style) with codebase context
- **FR-5.3**: Command palette for AI actions (explain, refactor, generate tests)
- **FR-5.4**: Diff preview before accepting AI suggestions
- **FR-5.5**: Co-author attribution in commit messages

### 3.2 Non-Functional Requirements

#### NFR-1: Performance
- **NFR-1.1**: Startup time < 1s for editor core
- **NFR-1.2**: Terminal toggle latency < 200ms (p95)
- **NFR-1.3**: LLM context injection < 300ms (p95)
- **NFR-1.4**: Support codebases up to 1M LOC without degradation
- **NFR-1.5**: Memory footprint < 500MB idle, < 2GB under heavy use

#### NFR-2: Security
- **NFR-2.1**: Zero secrets in LLM context (automatic redaction)
- **NFR-2.2**: All LLM API calls over HTTPS with certificate pinning
- **NFR-2.3**: Local context store encrypted at rest (AES-256)
- **NFR-2.4**: No code execution without explicit user consent
- **NFR-2.5**: Audit log for all LLM interactions (opt-in)

#### NFR-3: Privacy
- **NFR-3.1**: Local-first architecture; no cloud dependencies for core features
- **NFR-3.2**: User controls which files/directories are indexable
- **NFR-3.3**: Telemetry opt-in only; clear privacy policy
- **NFR-3.4**: GDPR-compliant data subject rights (export, delete)
- **NFR-3.5**: No PII sent to LLM APIs without user confirmation

#### NFR-4: Reliability
- **NFR-4.1**: Daemon uptime > 99.5% (measured over 30-day window)
- **NFR-4.2**: Graceful degradation if LLM APIs unavailable
- **NFR-4.3**: Auto-recovery from crashes (daemon restarts, context preserved)
- **NFR-4.4**: Data loss < 5 minutes of work in worst-case failure
- **NFR-4.5**: Rollback mechanism for configuration changes

#### NFR-5: Accessibility
- **NFR-5.1**: Keyboard-only navigation (no mouse required)
- **NFR-5.2**: Screen reader support (macOS VoiceOver, Linux Orca)
- **NFR-5.3**: High-contrast themes, customizable font sizes
- **NFR-5.4**: Colorblind-friendly status indicators
- **NFR-5.5**: WCAG 2.1 AA compliance for UI components

#### NFR-6: Operability
- **NFR-6.1**: SLOs defined and monitored (latency, uptime, error rate)
- **NFR-6.2**: Runbooks for common incidents (daemon crash, context corruption)
- **NFR-6.3**: Structured logging (JSON) with correlation IDs
- **NFR-6.4**: Metrics exported to Prometheus-compatible endpoint
- **NFR-6.5**: Health check endpoint (/health) returns in < 50ms

---

## 4. Architecture Overview

### 4.1 High-Level Architecture

The system comprises four primary layers:

1. **Presentation Layer** (Rust + TUI frameworks)
   - Editor UI (text buffer, syntax highlighting, LSP client)
   - Terminal manager (floating windows, keybindings)
   - Configuration UI (TUI for CLI tools management)

2. **Application Layer** (Rust + Go)
   - LLM Context Daemon (Go for concurrency, daemon lifecycle)
   - CLI tool orchestration (spawn, monitor, auto-start logic)
   - AI assistant integration (API clients, prompt engineering)

3. **Data Layer** (SQLite + JSON + Encrypted FS)
   - Context store (conversation history, synthesized summaries)
   - Configuration store (CLI tool definitions, keybindings)
   - Session state (open files, cursor positions, terminal states)

4. **Integration Layer** (REST/gRPC/Unix Sockets)
   - LLM APIs (Claude, GPT-4, local models via llama.cpp)
   - LSP servers (rust-analyzer, typescript-language-server, etc.)
   - Build tools (Cargo, npm, Docker, k8s)

### 4.2 Key Architectural Patterns

- **Event-Driven Architecture**: Terminal events, file changes, LSP notifications flow via pub/sub
- **Plugin System**: Extensibility via Rust traits + dynamic loading (for CLI tools)
- **Local-First**: Core functionality works offline; LLM features gracefully degrade
- **Zero-Trust**: Every LLM interaction is auditable, redactable, and user-controlled
- **Actor Model**: Concurrent tasks (context synthesis, LSP, terminal I/O) run as isolated actors

### 4.3 Deployment Model

- **Single-Binary Distribution**: Rust compiles to native executable (macOS, Linux, Windows)
- **Bundled Dependencies**: Tree-sitter parsers, LSP binaries embedded (minimize setup friction)
- **Daemon as Systemd/Launchd Service**: LLM context daemon runs as user-space service
- **Configuration in `~/.config/`**: XDG Base Directory Specification compliance

---

## 5. Component Design

### 5.1 Terminal Manager

**Responsibilities:**
- Spawn and manage subprocess lifecycle for CLI tools (k9s, lazygit, Claude Code, etc.)
- Render floating terminal windows with cascading offsets
- Capture terminal output for LLM context extraction
- Handle keybindings and route to appropriate tool

**Key Modules:**
- `terminal_spawner.rs`: Fork/exec subprocess, PTY allocation
- `window_manager.rs`: Render loop, window positioning, focus management
- `keybinding_router.rs`: Event loop for keyboard input, dispatch to handlers
- `output_capturer.rs`: Buffer terminal output, send to context daemon

**Technologies:**
- `ratatui` (Rust TUI framework)
- `portable-pty` (cross-platform PTY handling)
- `crossterm` (terminal I/O abstraction)

**Configuration Example:**
```json
{
  "id": "claude_code",
  "name": "Claude Code",
  "keybinding": "k",
  "command": "claude",
  "window": {
    "title": "Claude Code 🤖",
    "width": 0.85,
    "height": 0.85,
    "offset": 0.02
  },
  "auto_start": {
    "enabled": true,
    "delay_ms": 200,
    "pre_command": "clear"
  },
  "llm_enabled": true
}
```

### 5.2 LLM Context Daemon

**Responsibilities:**
- Long-running background service (survives editor restarts)
- Capture terminal output from LLM-enabled tools via Unix socket
- Synthesize context using Claude API (configurable)
- Store context in encrypted SQLite database
- Inject context when launching new LLM tool

**Key Modules:**
- `daemon_server.rs`: Unix socket server, IPC protocol
- `context_synthesizer.rs`: LLM API client, prompt engineering
- `context_store.rs`: SQLite abstraction, encryption layer
- `secret_redactor.rs`: Regex-based secret detection (API keys, tokens, passwords)

**IPC Protocol (Unix Socket):**
```rust
enum DaemonMessage {
    CaptureOutput { tool_id: String, content: String },
    RequestContext { target_tool_id: String },
    UpdateConfig { config: ContextConfig },
    HealthCheck,
}

enum DaemonResponse {
    ContextInjection { summary: String, history: Vec<Message> },
    Ack,
    Error { code: ErrorCode, message: String },
}
```

**Context Synthesis Prompt Template:**
```
You are a context summarizer for an IDE. The user has been working with the following terminal output:

---
{terminal_output}
---

Current file: {current_file}
Recent git branch: {git_branch}
LSP diagnostics: {diagnostics}

Summarize the user's current task, intent, and any blockers in 2-3 sentences. Focus on "why" over "what". Extract key decisions, errors encountered, and next steps.
```

### 5.3 Editor Core

**Responsibilities:**
- Text buffer management (rope data structure for efficient edits)
- Syntax highlighting (tree-sitter)
- LSP client (autocomplete, diagnostics, go-to-definition)
- File system watcher (detect external changes)

**Key Modules:**
- `buffer.rs`: Rope-based text buffer, undo/redo stack
- `syntax.rs`: Tree-sitter parser integration, highlight queries
- `lsp_client.rs`: JSON-RPC client for LSP protocol
- `file_watcher.rs`: Notify-based file system events

**Technologies:**
- `ropey` (efficient rope data structure)
- `tree-sitter` (parsing library)
- `tower-lsp` (LSP framework)
- `notify` (file system watcher)

### 5.4 AI Assistant Integration

**Responsibilities:**
- Inline code completion (Copilot-style)
- Chat sidebar with codebase awareness
- Command palette for AI actions (refactor, explain, generate tests)
- Diff preview for AI suggestions

**Key Modules:**
- `completion_provider.rs`: Streaming completions from LLM APIs
- `chat_ui.rs`: Sidebar UI, message rendering
- `codebase_indexer.rs`: Semantic search over project files
- `diff_viewer.rs`: Side-by-side or unified diff rendering

**Codebase Indexing Strategy:**
- **Phase 1**: Full-text search via `tantivy` (Rust search library)
- **Phase 2**: Semantic embeddings via `sentence-transformers` (Python service, gRPC API)
- **Phase 3**: Graph-based code understanding (LSP + dependency graph)

---

## 6. Data Architecture

### 6.1 Context Store Schema

**Database:** SQLite (encrypted with `sqlcipher`)

**Tables:**

```sql
CREATE TABLE sessions (
    id TEXT PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    codebase_path TEXT NOT NULL,
    git_branch TEXT,
    active_file TEXT
);

CREATE TABLE conversations (
    id TEXT PRIMARY KEY,
    session_id TEXT REFERENCES sessions(id) ON DELETE CASCADE,
    tool_id TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_session_tool (session_id, tool_id)
);

CREATE TABLE messages (
    id TEXT PRIMARY KEY,
    conversation_id TEXT REFERENCES conversations(id) ON DELETE CASCADE,
    role TEXT CHECK(role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSON,
    INDEX idx_conversation_time (conversation_id, created_at)
);

CREATE TABLE context_summaries (
    id TEXT PRIMARY KEY,
    conversation_id TEXT REFERENCES conversations(id) ON DELETE CASCADE,
    summary TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    token_count INTEGER,
    llm_model TEXT
);

CREATE TABLE redacted_secrets (
    id TEXT PRIMARY KEY,
    conversation_id TEXT REFERENCES conversations(id) ON DELETE CASCADE,
    secret_hash TEXT NOT NULL,  -- HMAC(secret, user_key) for auditing
    redacted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    secret_type TEXT  -- 'api_key', 'token', 'password', etc.
);
```

### 6.2 Configuration Files

**Location:** `~/.config/cli-ide/`

**Files:**
- `cli_tools.json`: Dynamic CLI tool definitions
- `keybindings.json`: Custom keybinding overrides
- `settings.json`: Editor preferences (theme, font, LSP configs)
- `llm_config.json`: API keys (encrypted), model preferences

**Encryption:** User-specific key derived from system keychain (macOS Keychain, Linux Secret Service)

### 6.3 Session State

**Location:** `~/.local/state/cli-ide/`

**Files:**
- `session.json`: Open files, cursor positions, terminal states
- `undo_history.bin`: Undo/redo stacks (binary format for compactness)
- `lsp_cache/`: LSP server state, diagnostics cache

**Persistence Strategy:**
- Auto-save every 30s (debounced)
- Atomic writes (write to temp, fsync, rename)
- Crash recovery: Restore from last valid snapshot

---

## 7. Security Architecture

### 7.1 Threat Model

**Assets:**
- Source code (proprietary, sensitive)
- LLM conversation history (may contain business logic, credentials)
- API keys (Claude, GPT-4, GitHub)
- User credentials (SSH keys, tokens)

**Threat Actors:**
- Malicious LLM API response (code injection, prompt injection)
- Compromised dependencies (supply chain attack)
- Local attacker (physical access, malware)
- External attacker (network-based, phishing)

**STRIDE Analysis:**

| Threat | Component | Mitigation |
|--------|-----------|------------|
| **Spoofing** | LLM API | Certificate pinning, API key rotation |
| **Tampering** | Context Store | Encryption at rest, integrity checks (HMAC) |
| **Repudiation** | LLM Interactions | Audit logs, signed requests |
| **Information Disclosure** | Terminal Output | Secret redaction, PII filtering |
| **Denial of Service** | Daemon | Rate limiting, resource quotas |
| **Elevation of Privilege** | CLI Tools | Sandboxing (seccomp, AppArmor), least privilege |

### 7.2 Security Controls

#### Control 1: Secret Redaction
- **Regex-based detection** for common secret patterns (AWS keys, GitHub tokens, JWT, etc.)
- **Automatic redaction** before sending to LLM API
- **Audit trail** of redacted secrets (hashed for compliance)

**Implementation:**
```rust
fn redact_secrets(content: &str) -> (String, Vec<SecretMatch>) {
    let patterns = [
        (r"AKIA[0-9A-Z]{16}", "AWS_ACCESS_KEY"),
        (r"ghp_[a-zA-Z0-9]{36}", "GITHUB_TOKEN"),
        (r"sk-[a-zA-Z0-9]{48}", "OPENAI_API_KEY"),
        // ... 50+ patterns
    ];

    let mut redacted = content.to_string();
    let mut matches = Vec::new();

    for (pattern, secret_type) in &patterns {
        for capture in Regex::new(pattern).unwrap().find_iter(content) {
            let secret = capture.as_str();
            let hash = hmac_sha256(secret, user_key);
            redacted = redacted.replace(secret, format!("[REDACTED_{}]", secret_type));
            matches.push(SecretMatch { hash, secret_type: secret_type.to_string() });
        }
    }

    (redacted, matches)
}
```

#### Control 2: Encrypted Context Store
- **Database encryption** using `sqlcipher` with AES-256
- **Key management** via OS keychain (secure, user-scoped)
- **Automatic decryption** on daemon start (user authentication required on macOS)

#### Control 3: LLM API Security
- **TLS 1.3** with certificate pinning
- **Rate limiting** (10 requests/minute per user)
- **Request signing** (HMAC signature for non-repudiation)
- **Timeout enforcement** (30s max per request)

#### Control 4: Sandboxed CLI Tools
- **Process isolation** via Unix process groups
- **Resource limits** (ulimit: CPU, memory, file descriptors)
- **Filesystem restrictions** (read-only mount for system dirs)
- **Network filtering** (optional: restrict outbound connections)

#### Control 5: Code Review Gate
- **Human review required** for all AI-generated code before commit
- **Co-author attribution** in git commits
- **Audit log** of accepted vs. rejected suggestions

---

## 8. Privacy Architecture

### 8.1 Privacy Principles

1. **Local-First**: Core functionality works offline; no mandatory cloud dependency
2. **User Control**: Explicit consent for every LLM API call (configurable per file/directory)
3. **Minimal Data Collection**: Telemetry opt-in only; no PII without consent
4. **Transparency**: Clear privacy policy; open-source redaction logic
5. **Right to Forget**: Export and delete all user data on demand

### 8.2 Data Minimization

**What We Collect:**
- LLM conversation history (local only, encrypted)
- Telemetry (opt-in): Usage metrics (feature adoption, error rates)
- Crash reports (opt-in): Stack traces, system info

**What We Don't Collect:**
- Source code (never sent to our servers)
- File paths (sanitized before LLM API calls)
- User credentials (stored in OS keychain only)

### 8.3 GDPR/CCPA Compliance

| Right | Implementation |
|-------|----------------|
| **Right to Access** | Export tool: `cli-ide export-data --output ~/my_data.zip` |
| **Right to Deletion** | Delete tool: `cli-ide delete-data --confirm` (wipes context store) |
| **Right to Rectification** | User can edit/delete individual messages in context history via UI |
| **Right to Portability** | Export format: JSON (machine-readable) |
| **Right to Object** | Opt-out of telemetry: `cli-ide config set telemetry.enabled false` |

### 8.4 PII Handling

**PII Detection:**
- Email addresses, phone numbers, SSNs, credit cards (regex-based)
- Names (NER model via `spaCy` or similar)
- IP addresses, MAC addresses

**PII Filtering:**
- **Before LLM API**: Redact PII similar to secrets
- **User Notification**: Show "PII detected" warning, require explicit confirmation
- **Audit Trail**: Log PII redaction events

---

## 9. Performance Architecture

### 9.1 Performance Targets

| Metric | Target (p95) | Measurement Method |
|--------|--------------|-------------------|
| Startup time | < 1s | Time from process start to UI render |
| Terminal toggle | < 200ms | Keystroke to terminal visible |
| LLM context injection | < 300ms | Request to context summary ready |
| LSP autocomplete | < 100ms | Keystroke to suggestion shown |
| File open (1MB) | < 50ms | Load and render complete |
| Codebase index (100k LOC) | < 10s | Initial indexing time |

### 9.2 Performance Optimizations

#### Optimization 1: Lazy Loading
- Tree-sitter parsers loaded on-demand (only when file type opened)
- LSP servers spawned per-workspace (shared across files)
- Context summaries cached (TTL: 5 minutes)

#### Optimization 2: Incremental Updates
- Terminal output captured in 4KB chunks (reduce IPC overhead)
- LSP diagnostics updated incrementally (not full re-parse)
- File watcher debounced (500ms) to avoid thrashing

#### Optimization 3: Parallel Processing
- Context synthesis runs concurrently with terminal rendering (non-blocking)
- Multiple LSP servers (one per language) run in parallel
- File indexing uses thread pool (N-1 cores)

#### Optimization 4: Memory Management
- Rope data structure for text buffers (O(log n) edits)
- Streaming LLM responses (no buffering full response)
- Terminal scrollback limited (10k lines, configurable)

### 9.3 Load Testing

**Tool:** k6 (load testing framework)

**Scenarios:**
1. **Heavy Editing**: 100 edits/second for 10 minutes
2. **Concurrent Terminals**: 11 terminals open, 10 req/sec per terminal
3. **LLM Burst**: 50 context requests in 1 second (rate limit triggers)
4. **Large Codebase**: Index 1M LOC project, measure time

**Acceptance Criteria:**
- No memory leaks (RSS stable over 1 hour)
- CPU usage < 80% average
- All p95 targets met under load

---

## 10. Observability & Operations

### 10.1 SLOs (Service Level Objectives)

| SLI | SLO | Error Budget | Measurement |
|-----|-----|--------------|-------------|
| Daemon Uptime | 99.5% | 3.6 hours/month | Process uptime metric |
| LLM API Success Rate | 99% | 1% of requests | HTTP status codes |
| Terminal Toggle Latency | < 200ms (p95) | 5% budget | Histogram |
| Context Injection Latency | < 300ms (p95) | 5% budget | Histogram |

### 10.2 Logging

**Format:** Structured JSON logs

**Example:**
```json
{
  "timestamp": "2025-10-26T10:30:15Z",
  "level": "INFO",
  "correlation_id": "abc123",
  "component": "context_daemon",
  "message": "Context synthesis complete",
  "metadata": {
    "tool_id": "claude_code",
    "token_count": 1234,
    "latency_ms": 245
  }
}
```

**Log Levels:**
- ERROR: Unrecoverable failures (daemon crash, API 500)
- WARN: Recoverable issues (rate limit, timeout)
- INFO: Normal operations (context synthesis, tool launch)
- DEBUG: Verbose (IPC messages, buffer edits)

### 10.3 Metrics

**Prometheus-compatible endpoint:** `http://localhost:9090/metrics`

**Key Metrics:**
- `cli_ide_daemon_uptime_seconds`: Process uptime
- `cli_ide_llm_requests_total`: Counter of LLM API calls
- `cli_ide_llm_latency_seconds`: Histogram of API latency
- `cli_ide_terminal_toggle_latency_seconds`: Histogram of toggle latency
- `cli_ide_memory_bytes`: Gauge of memory usage
- `cli_ide_redacted_secrets_total`: Counter of redacted secrets

### 10.4 Alerting

**Alertmanager Rules:**
1. **Daemon Down**: Alert if uptime < 1 minute (likely crashed)
2. **High Latency**: Alert if p95 > 500ms for 5 minutes
3. **Error Rate**: Alert if error rate > 5% for 10 minutes
4. **Memory Leak**: Alert if RSS increases > 100MB/hour

### 10.5 Runbooks

**Runbook 1: Daemon Crash**
1. Check logs: `journalctl -u cli-ide-daemon --since "1 hour ago"`
2. Restart: `systemctl --user restart cli-ide-daemon`
3. Verify health: `curl http://localhost:9090/health`
4. If context corrupted: Restore from backup (`~/.local/backup/cli-ide/`)

**Runbook 2: Context Injection Slow**
1. Check LLM API status: `cli-ide diagnostics llm-api`
2. Verify rate limit not hit: Check `cli_ide_llm_requests_total`
3. If cache stale: Clear cache (`rm -rf ~/.cache/cli-ide/context/`)

**Runbook 3: Secret Leaked**
1. Review audit log: `cli-ide audit-log --filter secret_redaction`
2. Rotate affected secret immediately
3. Notify security team
4. Update redaction regex if new pattern detected

---

## 11. Technology Stack

### 11.1 Core Technologies

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| **Language** | Rust | Memory safety, performance, rich ecosystem |
| **TUI Framework** | `ratatui` | Mature, active community, good docs |
| **LSP Client** | `tower-lsp` | Standard LSP implementation, async support |
| **Database** | SQLite + `sqlcipher` | Embedded, encrypted, zero-config |
| **Daemon Runtime** | Tokio | Async runtime, battle-tested |
| **IPC** | Unix sockets | Low-latency, secure (local only) |
| **Text Buffer** | `ropey` | Efficient rope data structure |
| **Parsing** | `tree-sitter` | Incremental, error-tolerant |
| **HTTP Client** | `reqwest` | Ergonomic, TLS support |
| **Crypto** | `ring` | Audited, FIPS-compliant |

### 11.2 LLM APIs

- **Primary:** Claude 3.5 Sonnet (Anthropic) - Best for context synthesis
- **Secondary:** GPT-4 (OpenAI) - Fallback option
- **Local:** llama.cpp - Offline mode (optional)

### 11.3 Build & CI/CD

- **Build Tool:** Cargo (Rust)
- **CI:** GitHub Actions
- **Linting:** clippy, rustfmt
- **Testing:** `cargo test`, `nextest` (parallel test runner)
- **Security Scanning:** `cargo audit`, Dependabot
- **Performance Profiling:** `flamegraph`, `perf`

### 11.4 Documentation

- **Architecture:** This document (Markdown)
- **API Docs:** `rustdoc` (auto-generated)
- **User Guide:** mdBook (Rust documentation tool)
- **ADRs:** Markdown files in `docs/adr/`

---

## 12. Development Roadmap

**Total Duration:** 12 weeks (3 months)

### Phase 1: Foundation (Weeks 1-2)
- Set up Rust project structure (Cargo workspaces)
- Implement basic editor core (text buffer, syntax highlighting)
- Terminal manager MVP (spawn 3 CLI tools: Claude Code, k9s, lazygit)
- Basic keybinding system (ALT+k, ALT+j, ALT+h)
- **Milestone:** Demo video showing 3 terminals toggling

### Phase 2: JSON Configuration (Weeks 3-4)
- CLI tools defined in JSON (`cli_tools.json`)
- Dynamic loading and keybinding registration
- Validation (keybinding conflicts, missing commands)
- **Milestone:** Add new CLI tool via JSON, no code changes needed

### Phase 3: Context Daemon Core (Weeks 5-6)
- Go/Rust daemon with Unix socket server
- Capture terminal output from LLM-enabled tools
- Store output in SQLite (encrypted)
- **Milestone:** Daemon captures 1 hour of Claude Code session, survives restart

### Phase 4: LLM Integration (Weeks 7-8)
- Anthropic API client (Claude 3.5 Sonnet)
- Context synthesis (prompt engineering)
- Context injection on tool launch
- **Milestone:** Context handoff demo (Claude Code → Aider)

### Phase 5: TUI Configuration (Weeks 9-10)
- `:CLIToolsConfig` command
- Add/edit/delete CLI tools via TUI
- Test launch, keybinding validation
- **Milestone:** Non-developer adds custom tool via UI

### Phase 6: Polish & Production Readiness (Weeks 11-12)
- Security hardening (secret redaction, encrypted store)
- Performance testing (k6 load tests)
- Observability (metrics, logging, runbooks)
- User documentation (installation, quickstart)
- **Milestone:** Internal dogfooding (5 developers using daily)

**Post-MVP Features (Phase 7+):**
- AI-assisted code completion (inline, sidebar chat)
- Codebase semantic search
- Multi-CLI context sharing (3+ tools)
- Windows support (currently macOS/Linux only)
- Plugin marketplace

---

## 13. Architecture Decision Records

### ADR-001: Use Rust for Editor Core

**Status:** Accepted
**Date:** 2025-10-26

**Context:**
- Python: Easy to learn but slow, dependency hell, incidental bugs
- Go: Fast, simple concurrency, but GC pauses, weak type system for complex domains
- Rust: Steep learning curve, but memory safe, performant, rich ecosystem

**Decision:**
Use Rust for editor core, terminal manager, and TUI. Use Go only for daemon (concurrency patterns simpler).

**Consequences:**
- **Pros:** Eliminates entire class of bugs, performance, ecosystem maturity
- **Cons:** Longer onboarding, borrow checker friction
- **Mitigations:** AI coding assistants (Claude Code, Copilot), Rust idioms guide

---

### ADR-002: Local-First Architecture

**Status:** Accepted
**Date:** 2025-10-26

**Context:**
- Cloud-based IDEs (GitHub Codespaces, GitPod) require internet, raise privacy concerns
- Local-first enables offline work, user control over data, faster iteration

**Decision:**
Core functionality (editor, terminal manager, LSP) works offline. LLM features degrade gracefully if API unavailable.

**Consequences:**
- **Pros:** Privacy, offline support, low latency, user trust
- **Cons:** No collaboration features (at least initially), larger binary size
- **Mitigations:** Future P2P sync (CRDTs), optional cloud backup

---

### ADR-003: SQLite for Context Store

**Status:** Accepted
**Date:** 2025-10-26

**Context:**
- Need persistent storage for LLM conversation history
- Options: JSON files (slow, no transactions), PostgreSQL (overkill), SQLite (embedded, ACID)

**Decision:**
Use SQLite with `sqlcipher` for encryption at rest.

**Consequences:**
- **Pros:** Zero-config, ACID transactions, encryption built-in, SQL queries
- **Cons:** Single-writer (but daemon is only writer), no horizontal scaling (not needed)
- **Mitigations:** Backup via `sqlite3 .dump`, periodic vacuuming

---

### ADR-004: Unix Sockets for IPC

**Status:** Accepted
**Date:** 2025-10-26

**Context:**
- Need IPC between editor and daemon (terminal output capture, context requests)
- Options: HTTP (overkill), pipes (unidirectional), shared memory (complex), Unix sockets (low-latency, secure)

**Decision:**
Use Unix domain sockets with JSON-based protocol.

**Consequences:**
- **Pros:** Low-latency (<1ms), secure (file permissions), bidirectional, widely supported
- **Cons:** Unix-only (Windows requires named pipes port)
- **Mitigations:** Abstract Windows IPC behind trait, swap implementation

---

### ADR-005: Secret Redaction Strategy

**Status:** Accepted
**Date:** 2025-10-26

**Context:**
- LLM APIs (Claude, GPT-4) must not receive secrets (API keys, tokens, passwords)
- Risk: Accidental leakage via terminal output, source code snippets

**Decision:**
Implement regex-based secret detection with 50+ patterns. Redact before sending to LLM API. Audit log of redacted secrets.

**Consequences:**
- **Pros:** Prevents most accidental leaks, user trust, compliance
- **Cons:** False positives (legitimate strings matching patterns), false negatives (novel secret formats)
- **Mitigations:** User can whitelist patterns, continuous improvement of regex library

---

## 14. Risk Analysis

| Risk | Likelihood | Impact | Mitigation | Owner |
|------|-----------|--------|------------|-------|
| **Secret leaked to LLM API** | Medium | High | Secret redaction, audit logs, user warnings | Security |
| **Daemon crashes (data loss)** | Low | Medium | Auto-restart, transaction safety, backups | SRE |
| **LLM API downtime** | Medium | Medium | Local fallback mode, caching, graceful degradation | Engineering |
| **Borrow checker learning curve** | High | Low | AI assistants, Rust idioms guide, pair programming | Engineering |
| **Slow adoption (team friction)** | Medium | High | Dogfooding, user research, iterative feedback | Product |
| **Ecosystem gaps (Rust AI libs)** | Low | Medium | Python fallback option, contribute to OSS | Engineering |
| **Performance degradation (large codebases)** | Low | Medium | Load testing, profiling, incremental indexing | Engineering |
| **Compliance issues (GDPR)** | Low | High | Privacy-by-design, audit trail, legal review | Compliance |

---

## 15. Appendix

### 15.1 Glossary

- **ADR**: Architecture Decision Record
- **CLI**: Command-Line Interface
- **IPC**: Inter-Process Communication
- **LSP**: Language Server Protocol
- **LLM**: Large Language Model
- **PTY**: Pseudo-Terminal
- **SLO**: Service Level Objective
- **TUI**: Text User Interface

### 15.2 References

- [Paradiddle README](./README.md)
- [SESSION_CONTEXT.md](./SESSION_CONTEXT.md)
- [Tree-sitter Documentation](https://tree-sitter.github.io/tree-sitter/)
- [LSP Specification](https://microsoft.github.io/language-server-protocol/)
- [Rust Book](https://doc.rust-lang.org/book/)
- [SQLCipher Documentation](https://www.zetetic.net/sqlcipher/documentation/)

### 15.3 Contact

- **Author:** Christopher Manahan
- **Email:** cmanahan@chanzuckerberg.com
- **Slack:** #cli-ide-dev
- **Repository:** [github.com/christophermanahan/cli-ide](https://github.com/christophermanahan/cli-ide)

---

**Document End**

This architecture document should be treated as a living document, updated as the project evolves and new ADRs are created. All major decisions should reference this document and create corresponding ADRs in `docs/adr/`.
