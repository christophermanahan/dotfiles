# Tiling Window Manager Architecture
## CLI-Driven IDE with Integrated Window Management

**Document Version:** 3.0 (Tiling WM Edition)
**Date:** 2025-10-27
**Author:** Christopher Manahan
**Status:** Draft - For LLM-Driven Iterative Development
**Base Documents:**
- [ARCHITECTURE.md](./ARCHITECTURE.md)
- [ARCHITECTURE_ENHANCED.md](./ARCHITECTURE_ENHANCED.md)

**Inspiration:** [Omarchy](https://omarchy.org/) - "A beautiful system is a motivating system"

---

## Document Purpose

This document **extends** the enhanced architecture by introducing a **tiled window manager** into the TUI application. Drawing inspiration from Omarchy's philosophy and Hyprland's tiling mechanics, we aim to create a terminal-based window manager that offers:

1. **Unified Window Management** - Treating editor buffers, terminals, AI assistants, and documentation viewers as windows.
2. **Flexible Layouts** - Supporting i3/sway-inspired algorithms like hsplit, vsplit, tabbed, stacked, and floating.
3. **Multi-Context Workspaces** - Enabling virtual desktops for diverse project setups.
4. **Keyboard-Centric Navigation** - Leveraging Vim-style bindings for seamless window control.
5. **Aesthetic Excellence** - Embracing "beautiful system = motivating system" with Catppuccin themes.
6. **Integrated Tooling** - Promoting all 11 CLI tools as first-class tiling windows.

**Key Insight:** This tiling system evolves beyond tmux by offering:
- Shared AI context across all windows.
- Integrated code editing with LSP.
- Semantic window awareness (e.g., differentiating an editor from a terminal).
- Persistent layouts to maintain session state.

---

## Table of Contents

1. [Tiling Window Manager Overview](#1-tiling-window-manager-overview)
2. [Window Abstraction Layer](#2-window-abstraction-layer)
3. [Layout Algorithms](#3-layout-algorithms)
4. [Workspace Management](#4-workspace-management)
5. [Focus & Navigation System](#5-focus--navigation-system)
6. [Window Lifecycle & State](#6-window-lifecycle--state)
7. [Integration with Existing Architecture](#7-integration-with-existing-architecture)
8. [Aesthetic System Design](#8-aesthetic-system-design)
9. [Keybinding System](#9-keybinding-system)
10. [Implementation Roadmap](#10-implementation-roadmap)

---

## 1. Tiling Window Manager Overview

### 1.1 What is a TUI Tiling Window Manager?

Unlike Omarchy (OS-level Hyprland tiling) or tmux (simple panes), our tiling WM is **semantically aware**:

```
┌─────────────────────────────────────────────────────────────────┐
│ Workspace 1: Main Project                        [Super+1]      │
├───────────────────────┬─────────────────────────────────────────┤
│                       │                                         │
│  Editor Window        │  Terminal Window                        │
│  (Rust code)          │  (cargo build)                         │
│  - LSP active         │  - Stdout captured                      │
│  - Syntax highlighting│  - Context shared                       │
│  - Git integration    │  - Exit code tracked                    │
│                       │                                         │
│  src/main.rs:45       │  $ cargo build                          │
│                       │  Compiling...                           │
│                       │                                         │
├───────────────────────┴─────────────────────────────────────────┤
│  AI Assistant Window (tabbed with Documentation)                │
│  > Explain this borrow checker error                            │
│  Claude: The lifetime 'a needs...                               │
└─────────────────────────────────────────────────────────────────┘
```

**Key Differences from Traditional Tiling WMs:**

| Feature | Traditional (i3/sway) | Our TUI WM |
|---------|----------------------|------------|
| **Window Type** | X11/Wayland apps | TUI panes with semantic types |
| **Navigation** | Focus by window ID | Focus by content type (editor, terminal, AI) |
| **Context** | None | Shared LLM context across all windows |
| **State** | Process-based | Session-based with serialization |
| **Aesthetics** | Desktop compositor | TUI rendering with themes |

### 1.2 Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    Tiling WM Layer                          │
│  ┌───────────────┬──────────────┬────────────────────┐     │
│  │  Workspace    │   Layout     │    Focus Manager   │     │
│  │  Manager      │   Engine     │                    │     │
│  └───────────────┴──────────────┴────────────────────┘     │
├─────────────────────────────────────────────────────────────┤
│                   Window Abstraction                        │
│  ┌────────────┬────────────┬──────────┬──────────────┐     │
│  │ Editor     │ Terminal   │ AI Chat  │ Documentation│     │
│  │ Window     │ Window     │ Window   │ Window       │     │
│  └────────────┴────────────┴──────────┴──────────────┘     │
├─────────────────────────────────────────────────────────────┤
│              Component Layer (from ENHANCED)                │
│  ┌───────────┬───────────┬────────────┬──────────────┐     │
│  │ Editor    │ Terminal  │ AI         │ LLM Context  │     │
│  │ Core      │ Manager   │ Assistant  │ Daemon       │     │
│  └───────────┴───────────┴────────────┴──────────────┘     │
├─────────────────────────────────────────────────────────────┤
│              Platform Layer (DI, Config, Events)            │
└─────────────────────────────────────────────────────────────┘
```

### 1.3 Window Types

Every window in the system implements the `Window` trait:

```rust
#[async_trait]
pub trait Window: Send + Sync {
    /// Unique identifier for this window
    fn id(&self) -> WindowId;

    /// Window type (editor, terminal, ai_chat, etc.)
    fn window_type(&self) -> WindowType;

    /// Render window content to TUI buffer
    fn render(&mut self, area: Rect, buf: &mut Buffer);

    /// Handle keyboard input
    async fn handle_input(&mut self, event: KeyEvent) -> Result<InputResult, Error>;

    /// Window title (shown in tab bar)
    fn title(&self) -> String;

    /// Can this window be closed?
    fn is_closable(&self) -> bool;

    /// Serialize window state for persistence
    fn serialize_state(&self) -> serde_json::Value;

    /// Restore window from serialized state
    async fn restore_state(&mut self, state: serde_json::Value) -> Result<(), Error>;

    /// Get window's contribution to LLM context
    fn get_context(&self) -> Option<WindowContext>;
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum WindowType {
    Editor,           // Code editor with LSP
    Terminal,         // Shell or CLI tool
    AiChat,          // Chat interface with LLM
    Documentation,   // Man pages, docs viewer
    FileExplorer,    // File browser
    GitDiff,         // Git diff viewer
    Diagnostics,     // LSP diagnostics panel
    FloatingOverlay, // Floating window (e.g., command palette)
}
```

---

## 2. Window Abstraction Layer

### 2.1 Window Container

**File:** `cli-ide-workbench/src/window/container.rs`

```rust
pub struct WindowContainer {
    id: WindowId,
    window: Box<dyn Window>,
    constraints: WindowConstraints,
    metadata: WindowMetadata,
}

pub struct WindowConstraints {
    pub min_width: u16,
    pub min_height: u16,
    pub max_width: Option<u16>,
    pub max_height: Option<u16>,
    pub aspect_ratio: Option<f32>,
}

pub struct WindowMetadata {
    pub created_at: SystemTime,
    pub last_focused: SystemTime,
    pub focus_count: u64,
    pub parent_workspace: WorkspaceId,
    pub tags: Vec<String>,
}

impl WindowContainer {
    pub fn new(window: Box<dyn Window>) -> Self {
        Self {
            id: WindowId::new(),
            window,
            constraints: WindowConstraints::default(),
            metadata: WindowMetadata::new(),
        }
    }

    pub fn render(&mut self, area: Rect, buf: &mut Buffer) {
        // Apply constraints
        let constrained_area = self.apply_constraints(area);

        // Render border (if focused)
        if self.metadata.is_focused {
            self.render_border(constrained_area, buf);
        }

        // Render window content
        self.window.render(constrained_area, buf);
    }

    fn apply_constraints(&self, area: Rect) -> Rect {
        let mut result = area;

        if result.width < self.constraints.min_width {
            result.width = self.constraints.min_width;
        }
        if result.height < self.constraints.min_height {
            result.height = self.constraints.min_height;
        }

        if let Some(max_width) = self.constraints.max_width {
            if result.width > max_width {
                result.width = max_width;
            }
        }

        result
    }
}
```

### 2.2 Editor Window Implementation

**File:** `cli-ide-workbench/src/window/editor_window.rs`

```rust
pub struct EditorWindow {
    id: WindowId,
    buffer: TextBuffer,
    cursor: Cursor,
    lsp_client: Option<Arc<LspClient>>,
    syntax_highlighter: SyntaxHighlighter,
}

#[async_trait]
impl Window for EditorWindow {
    fn id(&self) -> WindowId {
        self.id
    }

    fn window_type(&self) -> WindowType {
        WindowType::Editor
    }

    fn render(&mut self, area: Rect, buf: &mut Buffer) {
        // Render line numbers
        let line_number_width = 4;
        let text_area = Rect {
            x: area.x + line_number_width,
            width: area.width - line_number_width,
            ..area
        };

        // Render visible lines
        let visible_range = self.calculate_visible_range(area.height);
        for (i, line_idx) in visible_range.enumerate() {
            let line = self.buffer.line(line_idx);
            let highlighted = self.syntax_highlighter.highlight_line(line);

            // Render line number
            let line_num = format!("{:>3} ", line_idx + 1);
            buf.set_string(area.x, area.y + i as u16, &line_num, Style::default().fg(Color::DarkGray));

            // Render line content
            buf.set_spans(text_area.x, area.y + i as u16, &highlighted, text_area.width);
        }

        // Render cursor
        self.render_cursor(text_area, buf);

        // Render LSP diagnostics (underlines, warnings)
        if let Some(lsp) = &self.lsp_client {
            self.render_diagnostics(text_area, buf, lsp);
        }
    }

    async fn handle_input(&mut self, event: KeyEvent) -> Result<InputResult, Error> {
        match event.code {
            KeyCode::Char(c) => {
                self.buffer.insert_char(self.cursor.position, c);
                self.cursor.move_right();
                Ok(InputResult::Handled)
            }
            KeyCode::Backspace => {
                self.buffer.delete_char(self.cursor.position);
                self.cursor.move_left();
                Ok(InputResult::Handled)
            }
            _ => Ok(InputResult::NotHandled),
        }
    }

    fn title(&self) -> String {
        self.buffer.file_path()
            .map(|p| p.file_name().unwrap().to_string_lossy().to_string())
            .unwrap_or_else(|| "[No Name]".to_string())
    }

    fn get_context(&self) -> Option<WindowContext> {
        Some(WindowContext {
            window_type: WindowType::Editor,
            content_summary: format!(
                "Editing {} at line {}",
                self.title(),
                self.cursor.position.line
            ),
            relevant_data: json!({
                "file_path": self.buffer.file_path(),
                "cursor_line": self.cursor.position.line,
                "language": self.syntax_highlighter.language(),
                "diagnostics_count": self.lsp_client.as_ref().map(|l| l.diagnostics_count()).unwrap_or(0),
            }),
        })
    }
}
```

### 2.3 Terminal Window Implementation

**File:** `cli-ide-workbench/src/window/terminal_window.rs`

```rust
pub struct TerminalWindow {
    id: WindowId,
    pty: PortablePty,
    parser: vt100::Parser,
    tool_config: CliToolConfig,
    stdout_capture: Vec<String>,
}

#[async_trait]
impl Window for TerminalWindow {
    fn id(&self) -> WindowId {
        self.id
    }

    fn window_type(&self) -> WindowType {
        WindowType::Terminal
    }

    fn render(&mut self, area: Rect, buf: &mut Buffer) {
        let screen = self.parser.screen();

        for (row, row_idx) in screen.rows().enumerate().take(area.height as usize) {
            for (col, cell) in row.cells().enumerate().take(area.width as usize) {
                let style = Style {
                    fg: self.convert_color(cell.fg()),
                    bg: self.convert_color(cell.bg()),
                    ..Default::default()
                };

                buf.get_mut(area.x + col as u16, area.y + row_idx as u16)
                    .set_char(cell.contents())
                    .set_style(style);
            }
        }

        // Render cursor if terminal is focused
        if self.is_focused() {
            let cursor_pos = screen.cursor_position();
            buf.get_mut(area.x + cursor_pos.col as u16, area.y + cursor_pos.row as u16)
                .set_bg(Color::White);
        }
    }

    async fn handle_input(&mut self, event: KeyEvent) -> Result<InputResult, Error> {
        // Convert KeyEvent to terminal escape sequences
        let bytes = self.key_event_to_bytes(event);
        self.pty.write_all(&bytes).await?;
        Ok(InputResult::Handled)
    }

    fn title(&self) -> String {
        format!("{} - {}", self.tool_config.name, self.get_process_name())
    }

    fn get_context(&self) -> Option<WindowContext> {
        Some(WindowContext {
            window_type: WindowType::Terminal,
            content_summary: format!(
                "Running {} with {} lines of output",
                self.tool_config.name,
                self.stdout_capture.len()
            ),
            relevant_data: json!({
                "tool_id": self.tool_config.id,
                "recent_output": self.stdout_capture.iter().rev().take(50).collect::<Vec<_>>(),
                "exit_code": self.pty.exit_status(),
            }),
        })
    }
}
```

---

## 3. Layout Algorithms

### 3.1 Layout Types

Inspired by i3/sway tiling algorithms:

```rust
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum LayoutType {
    HSplit,     // Horizontal split (side-by-side)
    VSplit,     // Vertical split (top-bottom)
    Tabbed,     // Tabs (only one visible)
    Stacked,    // Stack with headers (all visible, minimized)
    Floating,   // Floating overlay
}
```

### 3.2 Layout Engine

**File:** `cli-ide-workbench/src/layout/engine.rs`

```rust
pub struct LayoutEngine {
    root: LayoutNode,
    focused_node: NodeId,
}

pub enum LayoutNode {
    Container {
        id: NodeId,
        layout_type: LayoutType,
        children: Vec<LayoutNode>,
        split_ratio: f32,  // For HSplit/VSplit
    },
    Leaf {
        id: NodeId,
        window: WindowContainer,
    },
}

impl LayoutEngine {
    pub fn new() -> Self {
        Self {
            root: LayoutNode::Container {
                id: NodeId::new(),
                layout_type: LayoutType::HSplit,
                children: Vec::new(),
                split_ratio: 0.5,
            },
            focused_node: NodeId::new(),
        }
    }

    /// Calculate layout rectangles for all windows
    pub fn calculate_layout(&self, area: Rect) -> HashMap<WindowId, Rect> {
        let mut result = HashMap::new();
        self.calculate_node_layout(&self.root, area, &mut result);
        result
    }

    fn calculate_node_layout(
        &self,
        node: &LayoutNode,
        area: Rect,
        result: &mut HashMap<WindowId, Rect>,
    ) {
        match node {
            LayoutNode::Leaf { window, .. } => {
                result.insert(window.id(), area);
            }
            LayoutNode::Container { layout_type, children, split_ratio, .. } => {
                match layout_type {
                    LayoutType::HSplit => {
                        self.layout_hsplit(children, area, *split_ratio, result);
                    }
                    LayoutType::VSplit => {
                        self.layout_vsplit(children, area, *split_ratio, result);
                    }
                    LayoutType::Tabbed => {
                        self.layout_tabbed(children, area, result);
                    }
                    LayoutType::Stacked => {
                        self.layout_stacked(children, area, result);
                    }
                    LayoutType::Floating => {
                        self.layout_floating(children, area, result);
                    }
                }
            }
        }
    }

    fn layout_hsplit(
        &self,
        children: &[LayoutNode],
        area: Rect,
        split_ratio: f32,
        result: &mut HashMap<WindowId, Rect>,
    ) {
        if children.is_empty() {
            return;
        }

        let split_width = (area.width as f32 * split_ratio) as u16;

        // Left side
        let left_area = Rect {
            x: area.x,
            y: area.y,
            width: split_width,
            height: area.height,
        };
        if let Some(left_child) = children.get(0) {
            self.calculate_node_layout(left_child, left_area, result);
        }

        // Right side
        let right_area = Rect {
            x: area.x + split_width,
            y: area.y,
            width: area.width - split_width,
            height: area.height,
        };
        if let Some(right_child) = children.get(1) {
            self.calculate_node_layout(right_child, right_area, result);
        }
    }

    fn layout_vsplit(
        &self,
        children: &[LayoutNode],
        area: Rect,
        split_ratio: f32,
        result: &mut HashMap<WindowId, Rect>,
    ) {
        if children.is_empty() {
            return;
        }

        let split_height = (area.height as f32 * split_ratio) as u16;

        // Top
        let top_area = Rect {
            x: area.x,
            y: area.y,
            width: area.width,
            height: split_height,
        };
        if let Some(top_child) = children.get(0) {
            self.calculate_node_layout(top_child, top_area, result);
        }

        // Bottom
        let bottom_area = Rect {
            x: area.x,
            y: area.y + split_height,
            width: area.width,
            height: area.height - split_height,
        };
        if let Some(bottom_child) = children.get(1) {
            self.calculate_node_layout(bottom_child, bottom_area, result);
        }
    }

    fn layout_tabbed(
        &self,
        children: &[LayoutNode],
        area: Rect,
        result: &mut HashMap<WindowId, Rect>,
    ) {
        // Reserve top row for tabs
        let tab_height = 1;
        let content_area = Rect {
            x: area.x,
            y: area.y + tab_height,
            width: area.width,
            height: area.height.saturating_sub(tab_height),
        };

        // Only layout the focused child (others are hidden)
        if let Some(focused_child) = self.get_focused_child(children) {
            self.calculate_node_layout(focused_child, content_area, result);
        }
    }

    fn layout_stacked(
        &self,
        children: &[LayoutNode],
        area: Rect,
        result: &mut HashMap<WindowId, Rect>,
    ) {
        // Each window gets a header bar
        let header_height = 1;
        let total_headers = (children.len() as u16) * header_height;
        let content_area = Rect {
            x: area.x,
            y: area.y + total_headers,
            width: area.width,
            height: area.height.saturating_sub(total_headers),
        };

        // Only layout the focused child
        if let Some(focused_child) = self.get_focused_child(children) {
            self.calculate_node_layout(focused_child, content_area, result);
        }
    }

    fn layout_floating(
        &self,
        children: &[LayoutNode],
        area: Rect,
        result: &mut HashMap<WindowId, Rect>,
    ) {
        // Floating windows have their own positions
        for child in children {
            if let LayoutNode::Leaf { window, .. } = child {
                // Get stored floating position or center it
                let floating_rect = self.get_floating_rect(window, area);
                result.insert(window.id(), floating_rect);
            }
        }
    }
}
```

### 3.3 Layout Operations

```rust
impl LayoutEngine {
    /// Split focused window horizontally
    pub fn split_horizontal(&mut self, new_window: WindowContainer) -> Result<(), Error> {
        let focused_node = self.find_focused_node_mut()?;

        // Replace leaf with container
        if let LayoutNode::Leaf { id, window } = focused_node {
            let old_window = std::mem::replace(
                focused_node,
                LayoutNode::Container {
                    id: *id,
                    layout_type: LayoutType::HSplit,
                    children: vec![
                        LayoutNode::Leaf { id: NodeId::new(), window: window.clone() },
                        LayoutNode::Leaf { id: NodeId::new(), window: new_window },
                    ],
                    split_ratio: 0.5,
                },
            );
        }

        Ok(())
    }

    /// Split focused window vertically
    pub fn split_vertical(&mut self, new_window: WindowContainer) -> Result<(), Error> {
        // Similar to split_horizontal but with VSplit
        unimplemented!()
    }

    /// Convert focused window to tabbed layout
    pub fn toggle_tabbed(&mut self) -> Result<(), Error> {
        let focused_node = self.find_focused_node_mut()?;

        if let LayoutNode::Container { layout_type, .. } = focused_node {
            *layout_type = if *layout_type == LayoutType::Tabbed {
                LayoutType::HSplit
            } else {
                LayoutType::Tabbed
            };
        }

        Ok(())
    }

    /// Resize split ratio
    pub fn resize_split(&mut self, delta: f32) -> Result<(), Error> {
        let parent = self.find_parent_of_focused()?;

        if let LayoutNode::Container { split_ratio, .. } = parent {
            *split_ratio = (*split_ratio + delta).clamp(0.1, 0.9);
        }

        Ok(())
    }
}
```

---

## 4. Workspace Management

### 4.1 Workspace Structure

**File:** `cli-ide-workbench/src/workspace/workspace.rs`

```rust
pub struct Workspace {
    id: WorkspaceId,
    name: String,
    layout_engine: LayoutEngine,
    windows: HashMap<WindowId, WindowContainer>,
    metadata: WorkspaceMetadata,
}

pub struct WorkspaceMetadata {
    pub created_at: SystemTime,
    pub last_active: SystemTime,
    pub project_path: Option<PathBuf>,
    pub git_branch: Option<String>,
    pub tags: Vec<String>,
}

impl Workspace {
    pub fn new(name: String) -> Self {
        Self {
            id: WorkspaceId::new(),
            name,
            layout_engine: LayoutEngine::new(),
            windows: HashMap::new(),
            metadata: WorkspaceMetadata::new(),
        }
    }

    /// Add a window to this workspace
    pub fn add_window(&mut self, window: Box<dyn Window>) -> WindowId {
        let container = WindowContainer::new(window);
        let id = container.id();

        self.windows.insert(id, container);
        self.layout_engine.insert_window(id);

        id
    }

    /// Remove a window from this workspace
    pub fn remove_window(&mut self, id: WindowId) -> Option<WindowContainer> {
        self.layout_engine.remove_window(id);
        self.windows.remove(&id)
    }

    /// Render entire workspace
    pub fn render(&mut self, area: Rect, buf: &mut Buffer) {
        // Calculate layout for all windows
        let layout = self.layout_engine.calculate_layout(area);

        // Render each window
        for (window_id, rect) in layout {
            if let Some(container) = self.windows.get_mut(&window_id) {
                container.render(rect, buf);
            }
        }

        // Render workspace indicator
        self.render_workspace_indicator(area, buf);
    }

    fn render_workspace_indicator(&self, area: Rect, buf: &mut Buffer) {
        let indicator = format!(" {} ", self.name);
        buf.set_string(
            area.x,
            area.y,
            &indicator,
            Style::default().bg(Color::Blue).fg(Color::White),
        );
    }
}
```

### 4.2 Workspace Manager

**File:** `cli-ide-workbench/src/workspace/manager.rs`

```rust
pub struct WorkspaceManager {
    workspaces: Vec<Workspace>,
    active_workspace: usize,
    config: Arc<ConfigurationService>,
}

impl WorkspaceManager {
    pub fn new(config: Arc<ConfigurationService>) -> Self {
        let mut workspaces = Vec::new();

        // Create default workspaces
        for i in 1..=9 {
            workspaces.push(Workspace::new(format!("Workspace {}", i)));
        }

        Self {
            workspaces,
            active_workspace: 0,
            config,
        }
    }

    /// Switch to workspace by index
    pub fn switch_to(&mut self, index: usize) -> Result<(), Error> {
        if index < self.workspaces.len() {
            self.active_workspace = index;
            Ok(())
        } else {
            Err(Error::InvalidWorkspace(index))
        }
    }

    /// Get currently active workspace
    pub fn active(&mut self) -> &mut Workspace {
        &mut self.workspaces[self.active_workspace]
    }

    /// Move window to another workspace
    pub fn move_window_to_workspace(
        &mut self,
        window_id: WindowId,
        target_workspace: usize,
    ) -> Result<(), Error> {
        if target_workspace >= self.workspaces.len() {
            return Err(Error::InvalidWorkspace(target_workspace));
        }

        // Remove from current workspace
        let window = self.active()
            .remove_window(window_id)
            .ok_or(Error::WindowNotFound(window_id))?;

        // Add to target workspace
        let target = &mut self.workspaces[target_workspace];
        target.windows.insert(window_id, window);
        target.layout_engine.insert_window(window_id);

        Ok(())
    }

    /// Save workspace layouts to disk
    pub fn save_session(&self) -> Result<(), Error> {
        let session = Session {
            active_workspace: self.active_workspace,
            workspaces: self.workspaces
                .iter()
                .map(|ws| ws.serialize())
                .collect(),
        };

        let session_path = self.config.get_session_path();
        let json = serde_json::to_string_pretty(&session)?;
        std::fs::write(session_path, json)?;

        Ok(())
    }

    /// Restore workspace layouts from disk
    pub fn restore_session(&mut self) -> Result<(), Error> {
        let session_path = self.config.get_session_path();
        let json = std::fs::read_to_string(session_path)?;
        let session: Session = serde_json::from_str(&json)?;

        self.active_workspace = session.active_workspace;

        for (i, ws_data) in session.workspaces.into_iter().enumerate() {
            if let Some(workspace) = self.workspaces.get_mut(i) {
                workspace.restore_from(ws_data)?;
            }
        }

        Ok(())
    }
}

#[derive(Serialize, Deserialize)]
struct Session {
    active_workspace: usize,
    workspaces: Vec<WorkspaceData>,
}
```

---

## 5. Focus & Navigation System

### 5.1 Focus Manager

**File:** `cli-ide-workbench/src/focus/manager.rs`

```rust
pub struct FocusManager {
    focus_stack: Vec<WindowId>,
    current_focus: Option<WindowId>,
    focus_mode: FocusMode,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FocusMode {
    Normal,      // Standard focus
    Zen,         // Hide all but focused window
    Presentation,// Large font, hide distractions
}

impl FocusManager {
    pub fn new() -> Self {
        Self {
            focus_stack: Vec::new(),
            current_focus: None,
            focus_mode: FocusMode::Normal,
        }
    }

    /// Focus a window
    pub fn focus(&mut self, window_id: WindowId) {
        if self.current_focus == Some(window_id) {
            return;
        }

        // Add previous focus to stack
        if let Some(prev) = self.current_focus {
            self.focus_stack.push(prev);
        }

        self.current_focus = Some(window_id);
    }

    /// Focus previous window (Alt+Tab style)
    pub fn focus_previous(&mut self) {
        if let Some(prev) = self.focus_stack.pop() {
            if let Some(curr) = self.current_focus {
                self.focus_stack.insert(0, curr);
            }
            self.current_focus = Some(prev);
        }
    }

    /// Navigate focus directionally (vim-like hjkl)
    pub fn focus_direction(&mut self, direction: Direction, layout: &LayoutEngine) -> Result<(), Error> {
        let current = self.current_focus.ok_or(Error::NoFocusedWindow)?;

        // Get current window position
        let current_rect = layout.get_window_rect(current)?;

        // Find nearest window in direction
        let target = layout.find_nearest_window_in_direction(current_rect, direction)?;

        self.focus(target);
        Ok(())
    }

    /// Toggle zen mode
    pub fn toggle_zen_mode(&mut self) {
        self.focus_mode = match self.focus_mode {
            FocusMode::Normal => FocusMode::Zen,
            FocusMode::Zen => FocusMode::Normal,
            FocusMode::Presentation => FocusMode::Normal,
        };
    }
}

#[derive(Debug, Clone, Copy)]
pub enum Direction {
    Left,
    Right,
    Up,
    Down,
}
```

### 5.2 Directional Navigation Algorithm

```rust
impl LayoutEngine {
    /// Find nearest window in a given direction
    pub fn find_nearest_window_in_direction(
        &self,
        from_rect: Rect,
        direction: Direction,
    ) -> Result<WindowId, Error> {
        let all_windows = self.get_all_window_rects();

        let candidates: Vec<_> = all_windows
            .iter()
            .filter(|(_, rect)| self.is_in_direction(from_rect, **rect, direction))
            .collect();

        if candidates.is_empty() {
            return Err(Error::NoWindowInDirection(direction));
        }

        // Find closest candidate
        let closest = candidates
            .into_iter()
            .min_by_key(|(_, rect)| self.calculate_distance(from_rect, **rect, direction))
            .unwrap();

        Ok(*closest.0)
    }

    fn is_in_direction(&self, from: Rect, to: Rect, direction: Direction) -> bool {
        match direction {
            Direction::Left => to.x < from.x,
            Direction::Right => to.x > from.x,
            Direction::Up => to.y < from.y,
            Direction::Down => to.y > from.y,
        }
    }

    fn calculate_distance(&self, from: Rect, to: Rect, direction: Direction) -> u32 {
        let dx = (from.x as i32 - to.x as i32).abs() as u32;
        let dy = (from.y as i32 - to.y as i32).abs() as u32;

        match direction {
            Direction::Left | Direction::Right => dx + dy / 2,  // Favor horizontal
            Direction::Up | Direction::Down => dy + dx / 2,     // Favor vertical
        }
    }
}
```

---

## 6. Window Lifecycle & State

### 6.1 Window State Machine

```rust
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum WindowState {
    Initializing,  // Loading resources
    Active,        // Normal operation
    Suspended,     // Not visible (in background workspace)
    Closing,       // Cleanup in progress
    Crashed,       // Error state
}

pub struct WindowStateMachine {
    current_state: WindowState,
    transitions: Vec<StateTransition>,
}

struct StateTransition {
    timestamp: SystemTime,
    from: WindowState,
    to: WindowState,
    reason: String,
}

impl WindowStateMachine {
    pub fn transition_to(&mut self, new_state: WindowState, reason: String) {
        self.transitions.push(StateTransition {
            timestamp: SystemTime::now(),
            from: self.current_state,
            to: new_state,
            reason,
        });

        self.current_state = new_state;
    }

    pub fn can_render(&self) -> bool {
        matches!(self.current_state, WindowState::Active)
    }
}
```

### 6.2 Window Persistence

**File:** `cli-ide-workbench/src/window/persistence.rs`

```rust
pub struct WindowPersistence {
    storage: SqliteStorage,
}

impl WindowPersistence {
    /// Save window state to disk
    pub async fn save_window(&self, window: &dyn Window) -> Result<(), Error> {
        let state = window.serialize_state();

        let record = WindowStateRecord {
            window_id: window.id(),
            window_type: window.window_type(),
            state_json: serde_json::to_string(&state)?,
            workspace_id: self.get_workspace_for_window(window.id())?,
            created_at: SystemTime::now(),
        };

        self.storage.insert_window_state(record).await?;
        Ok(())
    }

    /// Restore window from disk
    pub async fn restore_window(&self, window_id: WindowId) -> Result<Box<dyn Window>, Error> {
        let record = self.storage.get_window_state(window_id).await?;

        let state: serde_json::Value = serde_json::from_str(&record.state_json)?;

        // Create window based on type
        let mut window: Box<dyn Window> = match record.window_type {
            WindowType::Editor => Box::new(EditorWindow::new()),
            WindowType::Terminal => Box::new(TerminalWindow::new()),
            WindowType::AiChat => Box::new(AiChatWindow::new()),
            _ => return Err(Error::UnsupportedWindowType(record.window_type)),
        };

        // Restore state
        window.restore_state(state).await?;

        Ok(window)
    }
}
```

---

## 7. Integration with Existing Architecture

### 7.1 Component Integration Map

```
┌─────────────────────────────────────────────────────────────┐
│                    NEW: Tiling WM Layer                     │
│  ┌──────────────┬───────────────┬──────────────────────┐   │
│  │ Workspace    │ Layout Engine │ Focus Manager        │   │
│  │ Manager      │               │                      │   │
│  └───────┬──────┴───────┬───────┴──────┬───────────────┘   │
│          │              │               │                   │
├──────────┼──────────────┼───────────────┼───────────────────┤
│          │              │               │                   │
│  ┌───────▼──────────────▼───────────────▼───────────────┐   │
│  │         Window Abstraction Layer                     │   │
│  │  (Editor, Terminal, AI windows implement Window trait) │
│  └───────┬──────────────┬───────────────┬───────────────┘   │
│          │              │               │                   │
├──────────┼──────────────┼───────────────┼───────────────────┤
│          │              │               │                   │
│  ┌───────▼──────┐  ┌───▼────────┐  ┌───▼─────────────┐    │
│  │ Editor Core  │  │ Terminal   │  │ AI Assistant    │    │
│  │ (ENHANCED)   │  │ Manager    │  │ (ENHANCED)      │    │
│  │              │  │ (ENHANCED) │  │                 │    │
│  └──────┬───────┘  └────┬───────┘  └─────┬───────────┘    │
│         │               │                 │                │
│         └───────────────┴─────────────────┘                │
│                         │                                  │
│                         ▼                                  │
│              ┌────────────────────┐                        │
│              │  LLM Context       │                        │
│              │  Daemon            │                        │
│              │  (ENHANCED)        │                        │
│              └────────────────────┘                        │
└─────────────────────────────────────────────────────────────┘
```

### 7.2 Shared Context Across Windows

All windows contribute to shared LLM context:

```rust
pub struct SharedContextAggregator {
    daemon_client: Arc<DaemonClient>,
    workspace_manager: Arc<Mutex<WorkspaceManager>>,
}

impl SharedContextAggregator {
    /// Aggregate context from all windows in active workspace
    pub async fn aggregate_context(&self) -> Result<AggregatedContext, Error> {
        let workspace = self.workspace_manager.lock().await.active();

        let mut contexts = Vec::new();

        for window in workspace.windows.values() {
            if let Some(ctx) = window.window.get_context() {
                contexts.push(ctx);
            }
        }

        // Send to daemon for synthesis
        let summary = self.daemon_client
            .synthesize_contexts(contexts)
            .await?;

        Ok(AggregatedContext {
            workspace_name: workspace.name.clone(),
            window_count: workspace.windows.len(),
            contexts,
            summary,
        })
    }
}
```

### 7.3 Event Flow with Tiling WM

```
User Input → Focus Manager → Active Window → Window Handles Input
                │                                     │
                │                                     ▼
                │                          Window Updates State
                │                                     │
                │                                     ▼
                │                          Event Emitted (e.g., FileChanged)
                │                                     │
                ▼                                     ▼
        Layout Engine                      Context Daemon Captures
        (may trigger                       (for LLM context)
         re-layout)
                │
                ▼
          Render Loop
```

---

## 8. Aesthetic System Design

### 8.1 Theme System (Omarchy-Inspired)

**File:** `cli-ide-workbench/src/theme/catppuccin.rs`

```rust
pub struct CatppuccinTheme {
    flavor: Flavor,
    palette: Palette,
}

#[derive(Debug, Clone, Copy)]
pub enum Flavor {
    Latte,   // Light
    Frappe,  // Mid-dark
    Macchiato, // Dark
    Mocha,   // Darkest (default)
}

pub struct Palette {
    pub rosewater: Color,
    pub flamingo: Color,
    pub pink: Color,
    pub mauve: Color,
    pub red: Color,
    pub maroon: Color,
    pub peach: Color,
    pub yellow: Color,
    pub green: Color,
    pub teal: Color,
    pub sky: Color,
    pub sapphire: Color,
    pub blue: Color,
    pub lavender: Color,

    pub text: Color,
    pub subtext1: Color,
    pub subtext0: Color,
    pub overlay2: Color,
    pub overlay1: Color,
    pub overlay0: Color,
    pub surface2: Color,
    pub surface1: Color,
    pub surface0: Color,
    pub base: Color,
    pub mantle: Color,
    pub crust: Color,
}

impl CatppuccinTheme {
    pub fn new(flavor: Flavor) -> Self {
        let palette = match flavor {
            Flavor::Mocha => Palette::mocha(),
            // ... other flavors
            _ => Palette::mocha(),
        };

        Self { flavor, palette }
    }

    /// Get style for window border (focused vs unfocused)
    pub fn window_border_style(&self, focused: bool) -> Style {
        if focused {
            Style::default()
                .fg(self.palette.lavender)
                .add_modifier(Modifier::BOLD)
        } else {
            Style::default().fg(self.palette.overlay0)
        }
    }

    /// Get style for workspace indicator
    pub fn workspace_indicator_style(&self, active: bool) -> Style {
        if active {
            Style::default()
                .bg(self.palette.blue)
                .fg(self.palette.base)
        } else {
            Style::default()
                .bg(self.palette.surface0)
                .fg(self.palette.subtext0)
        }
    }
}
```

### 8.2 Border Rendering

```rust
pub struct BorderRenderer {
    theme: Arc<CatppuccinTheme>,
}

impl BorderRenderer {
    pub fn render_window_border(&self, area: Rect, buf: &mut Buffer, focused: bool, title: &str) {
        let style = self.theme.window_border_style(focused);

        // Top border with title
        let top_border = format!("─┤ {} ├{}", title, "─".repeat(area.width as usize - title.len() - 6));
        buf.set_string(area.x, area.y, "┌", style);
        buf.set_string(area.x + 1, area.y, &top_border, style);
        buf.set_string(area.x + area.width - 1, area.y, "┐", style);

        // Side borders
        for y in 1..area.height - 1 {
            buf.set_string(area.x, area.y + y, "│", style);
            buf.set_string(area.x + area.width - 1, area.y + y, "│", style);
        }

        // Bottom border
        buf.set_string(area.x, area.y + area.height - 1, "└", style);
        for x in 1..area.width - 1 {
            buf.set_string(area.x + x, area.y + area.height - 1, "─", style);
        }
        buf.set_string(area.x + area.width - 1, area.y + area.height - 1, "┘", style);
    }
}
```

### 8.3 Smooth Transitions (TUI Animations)

```rust
pub struct TransitionAnimator {
    current_frame: u32,
    total_frames: u32,
    easing: EasingFunction,
}

#[derive(Debug, Clone, Copy)]
pub enum EasingFunction {
    Linear,
    EaseInOut,
    EaseOut,
}

impl TransitionAnimator {
    /// Animate window resize
    pub fn animate_resize(
        &mut self,
        from: Rect,
        to: Rect,
    ) -> Rect {
        let progress = self.get_progress();

        Rect {
            x: self.interpolate(from.x as f32, to.x as f32, progress) as u16,
            y: self.interpolate(from.y as f32, to.y as f32, progress) as u16,
            width: self.interpolate(from.width as f32, to.width as f32, progress) as u16,
            height: self.interpolate(from.height as f32, to.height as f32, progress) as u16,
        }
    }

    fn get_progress(&self) -> f32 {
        let t = self.current_frame as f32 / self.total_frames as f32;

        match self.easing {
            EasingFunction::Linear => t,
            EasingFunction::EaseInOut => {
                if t < 0.5 {
                    2.0 * t * t
                } else {
                    -1.0 + (4.0 - 2.0 * t) * t
                }
            }
            EasingFunction::EaseOut => {
                t * (2.0 - t)
            }
        }
    }

    fn interpolate(&self, from: f32, to: f32, progress: f32) -> f32 {
        from + (to - from) * progress
    }
}
```

---

## 9. Keybinding System

### 9.1 Keybinding Configuration

Inspired by i3 and vim:

```rust
pub struct KeybindingConfig {
    pub modifier: Modifier,
    pub bindings: HashMap<KeyEvent, Command>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Modifier {
    Super,  // Windows/Command key
    Alt,
    Ctrl,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Command {
    // Focus navigation
    FocusLeft,
    FocusRight,
    FocusUp,
    FocusDown,

    // Window management
    SplitHorizontal,
    SplitVertical,
    CloseWindow,
    ToggleFullscreen,

    // Layout
    LayoutHSplit,
    LayoutVSplit,
    LayoutTabbed,
    LayoutStacked,

    // Workspace
    SwitchWorkspace(u8),
    MoveToWorkspace(u8),

    // Resize
    ResizeIncrease,
    ResizeDecrease,

    // Mode
    ToggleZenMode,

    // Application
    OpenCommandPalette,
    Quit,
}
```

### 9.2 Default Keybindings

```rust
impl KeybindingConfig {
    pub fn default_super() -> Self {
        let mut bindings = HashMap::new();

        // Focus navigation (Super+hjkl)
        bindings.insert(key!(Super, 'h'), Command::FocusLeft);
        bindings.insert(key!(Super, 'j'), Command::FocusDown);
        bindings.insert(key!(Super, 'k'), Command::FocusUp);
        bindings.insert(key!(Super, 'l'), Command::FocusRight);

        // Splitting (Super+v/s)
        bindings.insert(key!(Super, 'v'), Command::SplitVertical);
        bindings.insert(key!(Super, 's'), Command::SplitHorizontal);

        // Layouts (Super+w/e/t)
        bindings.insert(key!(Super, 'w'), Command::LayoutTabbed);
        bindings.insert(key!(Super, 'e'), Command::LayoutHSplit);
        bindings.insert(key!(Super, 't'), Command::LayoutStacked);

        // Workspaces (Super+1-9)
        for i in 1..=9 {
            bindings.insert(
                key!(Super, char::from_digit(i, 10).unwrap()),
                Command::SwitchWorkspace(i as u8),
            );
        }

        // Move to workspace (Super+Shift+1-9)
        for i in 1..=9 {
            bindings.insert(
                key!(Super | Shift, char::from_digit(i, 10).unwrap()),
                Command::MoveToWorkspace(i as u8),
            );
        }

        // Misc
        bindings.insert(key!(Super, 'f'), Command::ToggleFullscreen);
        bindings.insert(key!(Super, 'z'), Command::ToggleZenMode);
        bindings.insert(key!(Super, 'p'), Command::OpenCommandPalette);
        bindings.insert(key!(Super, 'q'), Command::CloseWindow);

        Self {
            modifier: Modifier::Super,
            bindings,
        }
    }
}
```

### 9.3 Keybinding Handler

```rust
pub struct KeybindingHandler {
    config: KeybindingConfig,
    workspace_manager: Arc<Mutex<WorkspaceManager>>,
    focus_manager: Arc<Mutex<FocusManager>>,
}

impl KeybindingHandler {
    pub async fn handle_key_event(&self, event: KeyEvent) -> Result<bool, Error> {
        if let Some(command) = self.config.bindings.get(&event) {
            self.execute_command(command.clone()).await?;
            Ok(true)
        } else {
            Ok(false)
        }
    }

    async fn execute_command(&self, command: Command) -> Result<(), Error> {
        match command {
            Command::FocusLeft => {
                let mut focus = self.focus_manager.lock().await;
                let workspace = self.workspace_manager.lock().await.active();
                focus.focus_direction(Direction::Left, &workspace.layout_engine)?;
            }
            Command::SplitHorizontal => {
                let workspace = self.workspace_manager.lock().await.active();
                let new_window = self.create_window_from_command_palette().await?;
                workspace.layout_engine.split_horizontal(new_window)?;
            }
            Command::SwitchWorkspace(index) => {
                self.workspace_manager.lock().await.switch_to(index as usize)?;
            }
            // ... handle all other commands
            _ => {}
        }

        Ok(())
    }
}
```

---

## 10. Implementation Roadmap

### 10.1 Phase 1: Window Abstraction (Weeks 1-2)

**Goals:**
- Implement `Window` trait and base containers
- Create EditorWindow, TerminalWindow wrappers
- Basic rendering pipeline

**Tasks:**
- [ ] Define Window trait (window/mod.rs)
- [ ] Implement WindowContainer (window/container.rs)
- [ ] Create EditorWindow (window/editor_window.rs)
- [ ] Create TerminalWindow (window/terminal_window.rs)
- [ ] Basic render loop

**Milestone:** Single EditorWindow and TerminalWindow side-by-side

### 10.2 Phase 2: Layout Engine (Weeks 3-4)

**Goals:**
- Implement layout algorithms (HSplit, VSplit)
- Calculate window rectangles
- Handle splits and resizing

**Tasks:**
- [ ] LayoutNode tree structure (layout/engine.rs)
- [ ] HSplit algorithm (layout/engine.rs)
- [ ] VSplit algorithm (layout/engine.rs)
- [ ] Resize operations (layout/engine.rs)
- [ ] Layout persistence (layout/persistence.rs)

**Milestone:** 2x2 grid of windows with manual resizing

### 10.3 Phase 3: Workspace System (Weeks 5-6)

**Goals:**
- Multiple workspaces (1-9)
- Switch between workspaces
- Move windows between workspaces

**Tasks:**
- [ ] Workspace struct (workspace/workspace.rs)
- [ ] WorkspaceManager (workspace/manager.rs)
- [ ] Workspace switching logic
- [ ] Window migration between workspaces
- [ ] Session persistence

**Milestone:** 3 workspaces with different layouts, switch with Super+1/2/3

### 10.4 Phase 4: Focus & Navigation (Weeks 7-8)

**Goals:**
- Focus management system
- Directional navigation (vim-like hjkl)
- Focus history (Alt+Tab)

**Tasks:**
- [ ] FocusManager (focus/manager.rs)
- [ ] Directional navigation algorithm (focus/navigation.rs)
- [ ] Focus indicators (borders, highlights)
- [ ] Zen mode implementation
- [ ] Focus persistence

**Milestone:** Navigate between windows with Super+hjkl, zen mode with Super+z

### 10.5 Phase 5: Advanced Layouts (Weeks 9-10)

**Goals:**
- Tabbed layout
- Stacked layout
- Floating windows

**Tasks:**
- [ ] Tabbed layout algorithm (layout/tabbed.rs)
- [ ] Stacked layout algorithm (layout/stacked.rs)
- [ ] Floating window manager (layout/floating.rs)
- [ ] Layout switching (Super+w/e/t)
- [ ] Tab rendering with indicators

**Milestone:** All 5 layout types working, switch between them seamlessly

### 10.6 Phase 6: Aesthetics & Polish (Weeks 11-12)

**Goals:**
- Catppuccin theme integration
- Smooth transitions
- Command palette
- Performance optimization

**Tasks:**
- [ ] Catppuccin theme (theme/catppuccin.rs)
- [ ] Border rendering (theme/borders.rs)
- [ ] Transition animations (theme/animations.rs)
- [ ] Command palette UI (ui/command_palette.rs)
- [ ] Performance profiling and optimization
- [ ] Documentation and demos

**Milestone:** Polished, beautiful TUI tiling WM ready for daily use

---

## Appendix A: Comparison with Other Systems

| Feature | Omarchy (Hyprland) | tmux | i3wm | Our TUI WM |
|---------|-------------------|------|------|------------|
| **Level** | OS (Wayland) | Terminal multiplexer | X11 WM | TUI application |
| **Windows** | GUI apps | Terminal panes | X11 windows | Semantic windows |
| **Tiling** | ✅ Full | ✅ Simple | ✅ Advanced | ✅ Advanced |
| **Workspaces** | ✅ | ✅ | ✅ | ✅ |
| **AI Context** | ❌ | ❌ | ❌ | ✅ |
| **LSP Integration** | ❌ | ❌ | ❌ | ✅ |
| **Persistence** | ✅ | ✅ (limited) | ❌ | ✅ |
| **Themes** | ✅ | ✅ (limited) | ✅ | ✅ |
| **Floating** | ✅ | ❌ | ✅ | ✅ |

---

## Appendix B: Keybinding Quick Reference

### Navigation
- `Super+h/j/k/l` - Focus left/down/up/right
- `Super+Tab` - Cycle through windows
- `Super+Shift+Tab` - Reverse cycle

### Window Management
- `Super+v` - Split vertical
- `Super+s` - Split horizontal
- `Super+q` - Close window
- `Super+f` - Fullscreen toggle
- `Super+z` - Zen mode

### Layouts
- `Super+e` - HSplit layout
- `Super+w` - Tabbed layout
- `Super+t` - Stacked layout
- `Super+Shift+space` - Floating toggle

### Workspaces
- `Super+1-9` - Switch to workspace
- `Super+Shift+1-9` - Move window to workspace

### Resizing
- `Super+r` - Enter resize mode
  - `h/j/k/l` - Resize in direction
  - `Esc` - Exit resize mode

### Application
- `Super+p` - Command palette
- `Super+Enter` - New terminal
- `Super+Shift+q` - Quit application

---

## Appendix C: Architecture Decision Records

### ADR-011: TUI Tiling Window Manager (Not OS-Level)

**Status:** Accepted
**Date:** 2025-10-27

**Context:**
Omarchy implements tiling at the OS level (Hyprland/Wayland compositor). We could:
1. Integrate with existing OS WM (i3, sway)
2. Build OS-level compositor
3. Build TUI-level tiling inside our application

**Decision:**
Build TUI-level tiling inside the application (option 3).

**Consequences:**
- **Pros:**
  - Portable (works on any OS)
  - Semantic awareness (knows editor vs terminal vs AI)
  - Shared LLM context trivial
  - Session persistence built-in
  - No compositor complexity
- **Cons:**
  - Limited to single terminal window
  - Can't tile external GUI apps
  - Nested inside OS WM (could be confusing)
- **Mitigations:**
  - Run in fullscreen terminal for best experience
  - Document interaction with OS WM
  - Consider OS WM integration in Phase 7+

---

### ADR-012: i3-Style Keybindings (Not tmux-Style)

**Status:** Accepted
**Date:** 2025-10-27

**Context:**
Keybinding schemes:
1. tmux-style (Ctrl+b prefix)
2. i3-style (Super key modifier)
3. Vim-style (mode-based)

**Decision:**
Use i3-style Super key modifier bindings.

**Consequences:**
- **Pros:**
  - No prefix key (faster)
  - Consistent with Omarchy philosophy
  - Super key rarely conflicts
  - Spatial reasoning (hjkl for direction)
- **Cons:**
  - Super key may be captured by OS
  - Not modal (unlike vim)
  - Learning curve for tmux users
- **Mitigations:**
  - Configurable modifier key
  - Provide tmux-style preset
  - Document OS WM conflicts

---

### ADR-013: Semantic Window Types (Not Generic Panes)

**Status:** Accepted
**Date:** 2025-10-27

**Context:**
Window abstraction could be:
1. Generic panes (tmux-style)
2. Process-based (OS WM style)
3. Semantic types (EditorWindow, TerminalWindow, etc.)

**Decision:**
Use semantic window types with shared `Window` trait.

**Consequences:**
- **Pros:**
  - Rich context for LLM (knows what's in each window)
  - Type-specific features (LSP in editor, exit code in terminal)
  - Better serialization (restore editor cursor position)
  - Command palette can filter by type
- **Cons:**
  - More complex than generic panes
  - Need to implement each type
  - Plugin system needs type registry
- **Mitigations:**
  - Window trait keeps abstraction simple
  - Generic fallback for unknown types
  - Plugin API for custom types

---

## Document End

This tiling window manager architecture transforms the CLI IDE into a **terminal operating environment** where development happens entirely within a beautifully tiled interface. Inspired by Omarchy's philosophy that "a beautiful system is a motivating system," we create an aesthetic, keyboard-driven workspace with AI context flowing seamlessly between all windows.

**Next Steps:**
1. Review with team and align on roadmap
2. Prototype Phase 1 (Window abstraction)
3. Demo early tiling to validate UX
4. Iterate on keybindings with user feedback

**Questions? Contact:**
- Christopher Manahan (cmanahan@chanzuckerberg.com)
- Slack: #cli-ide-dev
- Repository: [github.com/christophermanahan/paradiddle](https://github.com/christophermanahan/paradiddle)
