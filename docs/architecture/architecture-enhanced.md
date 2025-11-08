# Enhanced Technical and Security Architecture Document
## CLI-Driven IDE with Shared LLM Context

**Document Version:** 2.0 (Enhanced)
**Date:** 2025-10-26
**Author:** Christopher Manahan
**Status:** Draft - For LLM-Driven Iterative Development
**Base Document:** [ARCHITECTURE.md](./ARCHITECTURE.md)

**Related Documents:**
- [AI-Assisted Code Development Guidelines](./docs/AI-Assisted_Code_Development_Guidelines.pdf)
- [AI-Assisted Code Review Process](./docs/AI-Assisted_Code_Review_Process.pdf)
- [0 → 1 AI Driven Application Development](./docs/0_to_1_AI_Driven_Development.pdf)
- [Prototyping With Rust](./docs/Prototyping_With_Rust.pdf)
- [SESSION_CONTEXT.md](./SESSION_CONTEXT.md)

---

## Document Purpose & Enhancement Summary

This document **builds upon** the comprehensive [ARCHITECTURE.md](./ARCHITECTURE.md) by adding:

1. **VS Code-Inspired Implementation Patterns** - Concrete architectural patterns from Microsoft's VS Code codebase, adapted for Rust
2. **Cursor AI Integration Patterns** - Autonomy control, codebase indexing strategies, and multi-LLM support
3. **AI-Assisted Development Workflow** - Explicit integration of tooling, review gates, and contribution tracking from the provided PDFs
4. **Detailed Component Interaction Patterns** - Message flows, state machines, and protocol specifications
5. **Plugin/Extension Architecture** - Extensibility patterns for community contributions

**How to use this document:**
- Read [ARCHITECTURE.md](./ARCHITECTURE.md) first for the foundational architecture
- This document provides **implementation guidance** for the development phase
- Each section references specific files/modules in VS Code where patterns originate
- Code examples show Rust equivalents of TypeScript patterns

---

## Table of Contents

1. [VS Code-Inspired Implementation Patterns](#1-vs-code-inspired-implementation-patterns)
2. [Dependency Injection Architecture](#2-dependency-injection-architecture)
3. [Event-Driven Communication](#3-event-driven-communication)
4. [IPC & Multi-Process Architecture](#4-ipc--multi-process-architecture)
5. [Extension/Plugin System](#5-extensionplugin-system)
6. [Configuration Registry](#6-configuration-registry)
7. [Cursor-Inspired AI Integration](#7-cursor-inspired-ai-integration)
8. [AI-Assisted Development Workflow](#8-ai-assisted-development-workflow)
9. [Component Interaction Details](#9-component-interaction-details)
10. [Implementation Roadmap with Patterns](#10-implementation-roadmap-with-patterns)

---

## 1. VS Code-Inspired Implementation Patterns

### 1.1 Overview

VS Code's architecture provides battle-tested patterns for building extensible, performant desktop applications. This section extracts key patterns and adapts them for our Rust-based CLI IDE.

**Key Files Analyzed:**
- `vscode/src/vs/platform/instantiation/common/instantiation.ts` - Dependency injection
- `vscode/src/vs/base/common/event.ts` - Event system
- `vscode/src/vs/base/parts/ipc/common/ipc.ts` - IPC layer
- `vscode/src/vs/workbench/services/extensions/common/extensions.ts` - Extension host
- `vscode/src/vs/platform/configuration/common/configuration.ts` - Configuration

### 1.2 Architecture Layers (VS Code Pattern)

VS Code uses a **layered architecture** that we'll adapt:

```
┌─────────────────────────────────────────────┐
│          Workbench Layer                    │  (Our: Editor UI, Terminal Manager)
│  - UI Components                            │
│  - Command Palette                          │
│  - Workbench Services                       │
├─────────────────────────────────────────────┤
│          Platform Layer                     │  (Our: Core Services)
│  - Configuration Service                    │
│  - Instantiation Service (DI)               │
│  - Extension Management                     │
├─────────────────────────────────────────────┤
│          Base Layer                         │  (Our: Primitives)
│  - Event System                             │
│  - IPC Protocol                             │
│  - Lifecycle Management                     │
└─────────────────────────────────────────────┘
```

**Rust Equivalent Structure:**
```
cli-ide/
├── crates/
│   ├── cli-ide-base/          # Base layer: events, IPC, lifecycle
│   ├── cli-ide-platform/      # Platform layer: DI, config, services
│   ├── cli-ide-workbench/     # Workbench layer: UI, commands
│   ├── cli-ide-extensions/    # Extension host & API
│   └── cli-ide-daemon/        # LLM context daemon
```

### 1.3 Key Patterns Summary

| Pattern | VS Code Implementation | Our Rust Adaptation |
|---------|----------------------|---------------------|
| **Dependency Injection** | Branded service types with decorators | Trait objects with `Arc<dyn Trait>` |
| **Event System** | `Event<T>` as callable functions | `tokio::sync::broadcast` + custom `Event<T>` trait |
| **IPC** | Message passing with `VSBuffer` | Unix socket + `serde_json` or `bincode` |
| **Extension Host** | Separate process with RPC | Dynamic library loading (`libloading`) + trait API |
| **Configuration** | Multi-scope registry pattern | `serde`-based JSON with validation |

---

## 2. Dependency Injection Architecture

### 2.1 VS Code's Approach

VS Code uses a sophisticated DI system with **branded service types**:

```typescript
// vscode/src/vs/platform/instantiation/common/instantiation.ts
export interface IInstantiationService {
    readonly _serviceBrand: undefined;
    createInstance<T>(ctor: Ctor<T>, ...args: any[]): T;
    invokeFunction<R>(fn: (accessor: ServicesAccessor) => R): R;
}

export function createDecorator<T>(serviceId: string): ServiceIdentifier<T> {
    // Returns a decorator function for parameter injection
}
```

**Key Features:**
- Type-safe service identifiers
- Constructor parameter injection via decorators
- Hierarchical service containers (parent/child)
- Automatic disposal cascade

### 2.2 Rust Adaptation: ServiceContainer Pattern

**File:** `cli-ide-platform/src/di/service_container.rs`

```rust
use std::any::{Any, TypeId};
use std::collections::HashMap;
use std::sync::Arc;

/// Service identifier tied to a specific trait
pub struct ServiceId<T: ?Sized> {
    id: TypeId,
    name: &'static str,
    _marker: std::marker::PhantomData<T>,
}

impl<T: ?Sized + 'static> ServiceId<T> {
    pub const fn new(name: &'static str) -> Self {
        Self {
            id: TypeId::of::<T>(),
            name,
            _marker: std::marker::PhantomData,
        }
    }
}

/// Service container for dependency injection
pub struct ServiceContainer {
    services: HashMap<TypeId, Arc<dyn Any + Send + Sync>>,
    parent: Option<Arc<ServiceContainer>>,
}

impl ServiceContainer {
    pub fn new() -> Self {
        Self {
            services: HashMap::new(),
            parent: None,
        }
    }

    /// Register a service instance
    pub fn register<T: 'static + Send + Sync>(
        &mut self,
        _id: &ServiceId<T>,
        service: Arc<T>,
    ) {
        self.services.insert(TypeId::of::<T>(), service);
    }

    /// Retrieve a service instance
    pub fn get<T: 'static>(&self, _id: &ServiceId<T>) -> Option<Arc<T>> {
        // Check local services first
        if let Some(service) = self.services.get(&TypeId::of::<T>()) {
            return service.clone().downcast::<T>().ok();
        }

        // Check parent container
        if let Some(parent) = &self.parent {
            return parent.get(_id);
        }

        None
    }

    /// Create a child container (inherits parent services)
    pub fn create_child(self: Arc<Self>) -> Self {
        Self {
            services: HashMap::new(),
            parent: Some(self),
        }
    }
}
```

**Usage Example:**

```rust
// Define service traits
pub trait IConfigurationService: Send + Sync {
    fn get_value(&self, key: &str) -> Option<String>;
}

pub trait ITerminalService: Send + Sync {
    fn spawn_terminal(&self, tool_id: &str) -> Result<(), Error>;
}

// Define service IDs
pub const CONFIG_SERVICE: ServiceId<dyn IConfigurationService> =
    ServiceId::new("configurationService");
pub const TERMINAL_SERVICE: ServiceId<dyn ITerminalService> =
    ServiceId::new("terminalService");

// Register services
let mut container = ServiceContainer::new();
let config_service: Arc<dyn IConfigurationService> = Arc::new(ConfigService::new());
container.register(&CONFIG_SERVICE, config_service);

// Consume services
let config = container.get(&CONFIG_SERVICE).unwrap();
let value = config.get_value("editor.fontSize");
```

### 2.3 Service Lifecycle Management

**Pattern:** Implement `Drop` for cleanup, track dependencies:

```rust
pub trait IDisposable {
    fn dispose(&self);
}

pub struct DisposableStore {
    disposables: Mutex<Vec<Box<dyn IDisposable + Send + Sync>>>,
}

impl DisposableStore {
    pub fn add(&self, disposable: Box<dyn IDisposable + Send + Sync>) {
        self.disposables.lock().unwrap().push(disposable);
    }
}

impl Drop for DisposableStore {
    fn drop(&mut self) {
        for disposable in self.disposables.lock().unwrap().drain(..) {
            disposable.dispose();
        }
    }
}
```

---

## 3. Event-Driven Communication

### 3.1 VS Code's Event System

VS Code treats events as **first-class callable functions**:

```typescript
// vscode/src/vs/base/common/event.ts
export interface Event<T> {
    (listener: (e: T) => unknown, thisArgs?: any, disposables?: IDisposable[]): IDisposable;
}

export namespace Event {
    export function once<T>(event: Event<T>): Event<T> { /* ... */ }
    export function debounce<T>(event: Event<T>, delay: number): Event<T> { /* ... */ }
    export function map<I, O>(event: Event<I>, map: (i: I) => O): Event<O> { /* ... */ }
}
```

**Key Features:**
- Events return disposables (for unsubscription)
- Composable transformations (map, filter, debounce, once)
- Memory-safe (automatic cleanup when disposable dropped)

### 3.2 Rust Adaptation: Event<T> Trait

**File:** `cli-ide-base/src/event.rs`

```rust
use std::sync::Arc;
use tokio::sync::broadcast;

/// Event emitter and subscription
pub struct Event<T: Clone + Send + 'static> {
    sender: broadcast::Sender<T>,
}

impl<T: Clone + Send + 'static> Event<T> {
    pub fn new(capacity: usize) -> Self {
        let (sender, _) = broadcast::channel(capacity);
        Self { sender }
    }

    /// Emit an event to all subscribers
    pub fn fire(&self, event: T) {
        let _ = self.sender.send(event);
    }

    /// Subscribe to events (returns a receiver)
    pub fn subscribe(&self) -> broadcast::Receiver<T> {
        self.sender.subscribe()
    }

    /// Listen once (completes after first event)
    pub async fn once(&self) -> Option<T> {
        let mut receiver = self.subscribe();
        receiver.recv().await.ok()
    }
}

/// Event transformations
impl<T: Clone + Send + 'static> Event<T> {
    /// Map events to a new type
    pub fn map<U, F>(self, f: F) -> Event<U>
    where
        U: Clone + Send + 'static,
        F: Fn(T) -> U + Send + Sync + 'static,
    {
        let mapped = Event::new(100);
        let mapped_clone = mapped.sender.clone();

        tokio::spawn(async move {
            let mut receiver = self.subscribe();
            while let Ok(event) = receiver.recv().await {
                let _ = mapped_clone.send(f(event));
            }
        });

        mapped
    }

    /// Filter events based on predicate
    pub fn filter<F>(self, predicate: F) -> Event<T>
    where
        F: Fn(&T) -> bool + Send + Sync + 'static,
    {
        let filtered = Event::new(100);
        let filtered_clone = filtered.sender.clone();

        tokio::spawn(async move {
            let mut receiver = self.subscribe();
            while let Ok(event) = receiver.recv().await {
                if predicate(&event) {
                    let _ = filtered_clone.send(event);
                }
            }
        });

        filtered
    }

    /// Debounce events (only emit if no new event within duration)
    pub fn debounce(self, duration: std::time::Duration) -> Event<T> {
        let debounced = Event::new(100);
        let debounced_clone = debounced.sender.clone();

        tokio::spawn(async move {
            let mut receiver = self.subscribe();
            let mut last_event: Option<T> = None;

            loop {
                tokio::select! {
                    Ok(event) = receiver.recv() => {
                        last_event = Some(event);
                    }
                    _ = tokio::time::sleep(duration), if last_event.is_some() => {
                        if let Some(event) = last_event.take() {
                            let _ = debounced_clone.send(event);
                        }
                    }
                }
            }
        });

        debounced
    }
}
```

**Usage Example:**

```rust
#[derive(Clone, Debug)]
pub struct FileChangeEvent {
    pub path: String,
    pub change_type: ChangeType,
}

// Create event emitter
let file_change_event = Event::<FileChangeEvent>::new(100);

// Subscribe to events
let mut receiver = file_change_event.subscribe();
tokio::spawn(async move {
    while let Ok(event) = receiver.recv().await {
        println!("File changed: {:?}", event);
    }
});

// Emit events
file_change_event.fire(FileChangeEvent {
    path: "src/main.rs".to_string(),
    change_type: ChangeType::Modified,
});

// Use transformations
let rust_file_changes = file_change_event
    .filter(|e| e.path.ends_with(".rs"))
    .debounce(Duration::from_millis(500));
```

### 3.3 Event Relay Pattern (VS Code Pattern)

For relaying events between components:

```rust
pub struct EventRelay<T: Clone + Send + 'static> {
    input: Event<T>,
    output: Event<T>,
}

impl<T: Clone + Send + 'static> EventRelay<T> {
    pub fn new(input: Event<T>) -> Self {
        let output = Event::new(100);
        let output_clone = output.sender.clone();

        tokio::spawn(async move {
            let mut receiver = input.subscribe();
            while let Ok(event) = receiver.recv().await {
                let _ = output_clone.send(event);
            }
        });

        Self { input, output }
    }

    pub fn output(&self) -> &Event<T> {
        &self.output
    }
}
```

---

## 4. IPC & Multi-Process Architecture

### 4.1 VS Code's IPC Pattern

VS Code uses a **channel-based IPC** system:

```typescript
// vscode/src/vs/base/parts/ipc/common/ipc.ts
export interface IChannel {
    call<T>(command: string, arg?: any, cancellationToken?: CancellationToken): Promise<T>;
    listen<T>(event: string, arg?: any): Event<T>;
}

export interface IMessagePassingProtocol {
    send(buffer: VSBuffer): void;
    readonly onMessage: Event<VSBuffer>;
}
```

**Key Features:**
- Command/response pattern for RPC
- Event streaming over IPC
- Binary serialization (VSBuffer)
- Cancellation token support

### 4.2 Rust Adaptation: Unix Socket IPC

**File:** `cli-ide-base/src/ipc/protocol.rs`

```rust
use serde::{Deserialize, Serialize};
use tokio::net::{UnixListener, UnixStream};
use tokio::io::{AsyncReadExt, AsyncWriteExt};

#[derive(Debug, Serialize, Deserialize)]
pub enum IpcRequest {
    Call { id: u64, command: String, arg: serde_json::Value },
    Listen { id: u64, event: String, arg: Option<serde_json::Value> },
    CancelCall { id: u64 },
    UnsubscribeEvent { id: u64 },
}

#[derive(Debug, Serialize, Deserialize)]
pub enum IpcResponse {
    CallSuccess { id: u64, result: serde_json::Value },
    CallError { id: u64, error: String },
    EventFire { id: u64, data: serde_json::Value },
}

/// IPC channel for command/response pattern
pub struct IpcChannel {
    stream: UnixStream,
}

impl IpcChannel {
    pub async fn connect(path: &str) -> std::io::Result<Self> {
        let stream = UnixStream::connect(path).await?;
        Ok(Self { stream })
    }

    pub async fn call<T, R>(&mut self, command: &str, arg: &T) -> Result<R, String>
    where
        T: Serialize,
        R: for<'de> Deserialize<'de>,
    {
        let id = rand::random::<u64>();
        let request = IpcRequest::Call {
            id,
            command: command.to_string(),
            arg: serde_json::to_value(arg).unwrap(),
        };

        // Send request
        self.send_message(&request).await.map_err(|e| e.to_string())?;

        // Wait for response
        let response = self.recv_message().await.map_err(|e| e.to_string())?;

        match response {
            IpcResponse::CallSuccess { result, .. } => {
                serde_json::from_value(result).map_err(|e| e.to_string())
            }
            IpcResponse::CallError { error, .. } => Err(error),
            _ => Err("Unexpected response type".to_string()),
        }
    }

    async fn send_message(&mut self, msg: &IpcRequest) -> std::io::Result<()> {
        let json = serde_json::to_vec(msg)?;
        let len = json.len() as u32;

        // Write length prefix + message
        self.stream.write_all(&len.to_be_bytes()).await?;
        self.stream.write_all(&json).await?;
        self.stream.flush().await?;
        Ok(())
    }

    async fn recv_message(&mut self) -> std::io::Result<IpcResponse> {
        // Read length prefix
        let mut len_bytes = [0u8; 4];
        self.stream.read_exact(&mut len_bytes).await?;
        let len = u32::from_be_bytes(len_bytes) as usize;

        // Read message
        let mut buffer = vec![0u8; len];
        self.stream.read_exact(&mut buffer).await?;

        serde_json::from_slice(&buffer)
            .map_err(|e| std::io::Error::new(std::io::ErrorKind::InvalidData, e))
    }
}
```

**Usage Example:**

```rust
// Client side (Terminal Manager → Daemon)
let mut client = IpcChannel::connect("/tmp/cli-ide-daemon.sock").await?;

#[derive(Serialize)]
struct CaptureOutputRequest {
    tool_id: String,
    content: String,
}

let request = CaptureOutputRequest {
    tool_id: "claude_code".to_string(),
    content: "User asked: How do I implement async in Rust?".to_string(),
};

let result: serde_json::Value = client.call("captureOutput", &request).await?;
```

### 4.3 IPC Server Pattern

**File:** `cli-ide-daemon/src/ipc_server.rs`

```rust
pub struct IpcServer {
    listener: UnixListener,
    handlers: HashMap<String, Box<dyn IpcCommandHandler>>,
}

#[async_trait::async_trait]
pub trait IpcCommandHandler: Send + Sync {
    async fn handle(&self, arg: serde_json::Value) -> Result<serde_json::Value, String>;
}

impl IpcServer {
    pub async fn bind(path: &str) -> std::io::Result<Self> {
        // Remove existing socket file
        let _ = tokio::fs::remove_file(path).await;

        let listener = UnixListener::bind(path)?;
        Ok(Self {
            listener,
            handlers: HashMap::new(),
        })
    }

    pub fn register_handler(&mut self, command: String, handler: Box<dyn IpcCommandHandler>) {
        self.handlers.insert(command, handler);
    }

    pub async fn serve(self) -> std::io::Result<()> {
        loop {
            let (stream, _addr) = self.listener.accept().await?;
            let handlers = Arc::new(self.handlers.clone());

            tokio::spawn(async move {
                if let Err(e) = Self::handle_connection(stream, handlers).await {
                    eprintln!("Connection error: {}", e);
                }
            });
        }
    }

    async fn handle_connection(
        mut stream: UnixStream,
        handlers: Arc<HashMap<String, Box<dyn IpcCommandHandler>>>,
    ) -> std::io::Result<()> {
        loop {
            // Read request (length-prefixed JSON)
            let mut len_bytes = [0u8; 4];
            stream.read_exact(&mut len_bytes).await?;
            let len = u32::from_be_bytes(len_bytes) as usize;

            let mut buffer = vec![0u8; len];
            stream.read_exact(&mut buffer).await?;

            let request: IpcRequest = serde_json::from_slice(&buffer)?;

            // Handle request
            let response = match request {
                IpcRequest::Call { id, command, arg } => {
                    if let Some(handler) = handlers.get(&command) {
                        match handler.handle(arg).await {
                            Ok(result) => IpcResponse::CallSuccess { id, result },
                            Err(error) => IpcResponse::CallError { id, error },
                        }
                    } else {
                        IpcResponse::CallError {
                            id,
                            error: format!("Unknown command: {}", command),
                        }
                    }
                }
                _ => continue, // Handle other request types
            };

            // Send response
            let json = serde_json::to_vec(&response)?;
            let len = json.len() as u32;
            stream.write_all(&len.to_be_bytes()).await?;
            stream.write_all(&json).await?;
            stream.flush().await?;
        }
    }
}
```

---

## 5. Extension/Plugin System

### 5.1 VS Code's Extension Host Pattern

VS Code runs extensions in **separate processes** with RPC communication:

```
Main Process (Editor)          Extension Host Process
┌──────────────────┐          ┌───────────────────────┐
│  Workbench UI    │          │  Extension Runtime    │
│  Services        │◄────────►│  (isolate extensions) │
│                  │   RPC    │                       │
└──────────────────┘          └───────────────────────┘
```

**Key Files:**
- `extensionHostManager.ts` - Manages extension host lifecycle
- `extensionDescriptionRegistry.ts` - Registry of loaded extensions
- `extensionsRegistry.ts` - Extension point system

### 5.2 Rust Adaptation: Dynamic Library Loading

**File:** `cli-ide-extensions/src/plugin_host.rs`

```rust
use libloading::{Library, Symbol};
use std::path::PathBuf;

/// Plugin API that all plugins must implement
pub trait Plugin: Send + Sync {
    fn activate(&mut self, context: &PluginContext) -> Result<(), String>;
    fn deactivate(&mut self) -> Result<(), String>;
    fn name(&self) -> &str;
    fn version(&self) -> &str;
}

/// Context provided to plugins
pub struct PluginContext {
    pub config_service: Arc<dyn IConfigurationService>,
    pub terminal_service: Arc<dyn ITerminalService>,
    pub event_bus: Arc<EventBus>,
}

/// Plugin host manages plugin lifecycle
pub struct PluginHost {
    plugins: Vec<Box<dyn Plugin>>,
    libraries: Vec<Library>,
}

impl PluginHost {
    pub fn new() -> Self {
        Self {
            plugins: Vec::new(),
            libraries: Vec::new(),
        }
    }

    /// Load a plugin from a dynamic library
    pub unsafe fn load_plugin(&mut self, path: &PathBuf) -> Result<(), String> {
        let lib = Library::new(path).map_err(|e| e.to_string())?;

        // Look for plugin_create function
        let plugin_create: Symbol<unsafe extern "C" fn() -> *mut dyn Plugin> =
            lib.get(b"plugin_create").map_err(|e| e.to_string())?;

        let plugin_ptr = plugin_create();
        let plugin = Box::from_raw(plugin_ptr);

        self.plugins.push(plugin);
        self.libraries.push(lib);

        Ok(())
    }

    /// Activate all plugins
    pub fn activate_all(&mut self, context: &PluginContext) -> Result<(), String> {
        for plugin in &mut self.plugins {
            plugin.activate(context)?;
        }
        Ok(())
    }

    /// Deactivate all plugins
    pub fn deactivate_all(&mut self) -> Result<(), String> {
        for plugin in &mut self.plugins {
            plugin.deactivate()?;
        }
        Ok(())
    }
}
```

**Plugin Example:**

```rust
// In plugin crate (compiled as dylib)
pub struct MyPlugin {
    name: String,
}

impl Plugin for MyPlugin {
    fn activate(&mut self, context: &PluginContext) -> Result<(), String> {
        println!("MyPlugin activated!");

        // Register commands, subscribe to events, etc.
        context.event_bus.subscribe("fileChange", |event| {
            println!("File changed: {:?}", event);
        });

        Ok(())
    }

    fn deactivate(&mut self) -> Result<(), String> {
        println!("MyPlugin deactivated");
        Ok(())
    }

    fn name(&self) -> &str {
        &self.name
    }

    fn version(&self) -> &str {
        "1.0.0"
    }
}

#[no_mangle]
pub extern "C" fn plugin_create() -> *mut dyn Plugin {
    let plugin = Box::new(MyPlugin {
        name: "My Awesome Plugin".to_string(),
    });
    Box::into_raw(plugin)
}
```

### 5.3 Extension Point Registry (VS Code Pattern)

```rust
pub struct ExtensionPoint {
    pub name: String,
    pub schema: serde_json::Value, // JSON schema for validation
}

pub struct ExtensionRegistry {
    points: HashMap<String, ExtensionPoint>,
    contributions: HashMap<String, Vec<serde_json::Value>>,
}

impl ExtensionRegistry {
    pub fn register_point(&mut self, point: ExtensionPoint) {
        self.points.insert(point.name.clone(), point);
    }

    pub fn contribute(&mut self, point_name: &str, contribution: serde_json::Value) -> Result<(), String> {
        // Validate contribution against schema
        if let Some(point) = self.points.get(point_name) {
            // Validate using jsonschema crate
            // ...

            self.contributions
                .entry(point_name.to_string())
                .or_insert_with(Vec::new)
                .push(contribution);
            Ok(())
        } else {
            Err(format!("Unknown extension point: {}", point_name))
        }
    }

    pub fn get_contributions(&self, point_name: &str) -> Option<&[serde_json::Value]> {
        self.contributions.get(point_name).map(|v| v.as_slice())
    }
}
```

---

## 6. Configuration Registry

### 6.1 VS Code's Configuration Pattern

VS Code uses a **registry pattern** for configuration schemas:

```typescript
// vscode/src/vs/platform/configuration/common/configurationRegistry.ts
export interface IConfigurationRegistry {
    registerConfiguration(configuration: IConfigurationNode): void;
    getConfigurations(): IConfigurationNode[];
    onDidUpdateConfiguration: Event<{ properties: Set<string> }>;
}

export const enum ConfigurationTarget {
    APPLICATION = 1,
    USER,
    WORKSPACE,
    WORKSPACE_FOLDER,
}
```

### 6.2 Rust Adaptation: Config Service

**File:** `cli-ide-platform/src/config/configuration_service.rs`

```rust
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ConfigurationScope {
    Application,
    User,
    Workspace,
    WorkspaceFolder,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ConfigurationNode {
    pub properties: HashMap<String, PropertySchema>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PropertySchema {
    #[serde(rename = "type")]
    pub type_: String,
    pub default: Option<serde_json::Value>,
    pub description: Option<String>,
    pub enum_values: Option<Vec<serde_json::Value>>,
}

pub struct ConfigurationService {
    registry: HashMap<String, PropertySchema>,
    values: HashMap<ConfigurationScope, HashMap<String, serde_json::Value>>,
    change_event: Event<ConfigurationChangeEvent>,
}

#[derive(Clone, Debug)]
pub struct ConfigurationChangeEvent {
    pub affected_keys: Vec<String>,
    pub scope: ConfigurationScope,
}

impl ConfigurationService {
    pub fn new() -> Self {
        Self {
            registry: HashMap::new(),
            values: HashMap::new(),
            change_event: Event::new(100),
        }
    }

    /// Register configuration schema
    pub fn register_configuration(&mut self, node: ConfigurationNode) {
        for (key, schema) in node.properties {
            self.registry.insert(key, schema);
        }
    }

    /// Get configuration value (with scope precedence)
    pub fn get<T: for<'de> Deserialize<'de>>(&self, key: &str) -> Option<T> {
        // Precedence: WorkspaceFolder > Workspace > User > Application
        let scopes = [
            ConfigurationScope::WorkspaceFolder,
            ConfigurationScope::Workspace,
            ConfigurationScope::User,
            ConfigurationScope::Application,
        ];

        for scope in &scopes {
            if let Some(scope_values) = self.values.get(scope) {
                if let Some(value) = scope_values.get(key) {
                    return serde_json::from_value(value.clone()).ok();
                }
            }
        }

        // Fallback to default from schema
        if let Some(schema) = self.registry.get(key) {
            if let Some(default) = &schema.default {
                return serde_json::from_value(default.clone()).ok();
            }
        }

        None
    }

    /// Update configuration value
    pub fn update<T: Serialize>(
        &mut self,
        key: &str,
        value: T,
        scope: ConfigurationScope,
    ) -> Result<(), String> {
        // Validate against schema
        if let Some(schema) = self.registry.get(key) {
            let json_value = serde_json::to_value(value).map_err(|e| e.to_string())?;
            self.validate_value(&json_value, schema)?;

            // Store value
            self.values
                .entry(scope)
                .or_insert_with(HashMap::new)
                .insert(key.to_string(), json_value);

            // Emit change event
            self.change_event.fire(ConfigurationChangeEvent {
                affected_keys: vec![key.to_string()],
                scope,
            });

            Ok(())
        } else {
            Err(format!("Unknown configuration key: {}", key))
        }
    }

    fn validate_value(&self, value: &serde_json::Value, schema: &PropertySchema) -> Result<(), String> {
        // Basic type validation
        match schema.type_.as_str() {
            "string" => {
                if !value.is_string() {
                    return Err("Expected string".to_string());
                }
            }
            "number" => {
                if !value.is_number() {
                    return Err("Expected number".to_string());
                }
            }
            "boolean" => {
                if !value.is_boolean() {
                    return Err("Expected boolean".to_string());
                }
            }
            _ => {}
        }

        // Enum validation
        if let Some(enum_values) = &schema.enum_values {
            if !enum_values.contains(value) {
                return Err(format!("Value must be one of: {:?}", enum_values));
            }
        }

        Ok(())
    }

    /// Subscribe to configuration changes
    pub fn on_did_change(&self) -> broadcast::Receiver<ConfigurationChangeEvent> {
        self.change_event.subscribe()
    }
}
```

**Usage Example:**

```rust
let mut config = ConfigurationService::new();

// Register schema
config.register_configuration(ConfigurationNode {
    properties: HashMap::from([
        (
            "editor.fontSize".to_string(),
            PropertySchema {
                type_: "number".to_string(),
                default: Some(json!(14)),
                description: Some("Font size in pixels".to_string()),
                enum_values: None,
            },
        ),
    ]),
});

// Get value (returns default if not set)
let font_size: u32 = config.get("editor.fontSize").unwrap();
println!("Font size: {}", font_size);

// Update value
config.update("editor.fontSize", 16, ConfigurationScope::User)?;

// Subscribe to changes
let mut receiver = config.on_did_change();
tokio::spawn(async move {
    while let Ok(event) = receiver.recv().await {
        println!("Config changed: {:?}", event.affected_keys);
    }
});
```

---

## 7. Cursor-Inspired AI Integration

### 7.1 Cursor's Key Patterns

From research on Cursor (https://cursor.com/), key patterns identified:

1. **Autonomy Control Slider**
   - Tab completion (low autonomy)
   - Cmd+K edits (medium autonomy)
   - Agent mode (high autonomy)

2. **Codebase Indexing**
   - Semantic search over entire project
   - Context-aware suggestions based on project structure

3. **Multi-LLM Support**
   - OpenAI GPT-4, Anthropic Claude, Google Gemini, xAI
   - Model selection per-task

4. **Custom Tab Model**
   - Fine-tuned for code completion
   - 28% higher accept rate than Copilot

### 7.2 Autonomy Control Implementation

**File:** `cli-ide-workbench/src/ai/autonomy_controller.rs`

```rust
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum AutonomyLevel {
    /// Low: Inline suggestions only, user accepts/rejects
    Suggestion,
    /// Medium: Multi-line edits with preview, user confirms
    Edit,
    /// High: Autonomous changes across files, user reviews diff
    Agent,
}

pub struct AutonomyController {
    current_level: AutonomyLevel,
    config: Arc<ConfigurationService>,
}

impl AutonomyController {
    pub fn new(config: Arc<ConfigurationService>) -> Self {
        let current_level = config
            .get::<String>("ai.autonomyLevel")
            .and_then(|s| match s.as_str() {
                "suggestion" => Some(AutonomyLevel::Suggestion),
                "edit" => Some(AutonomyLevel::Edit),
                "agent" => Some(AutonomyLevel::Agent),
                _ => None,
            })
            .unwrap_or(AutonomyLevel::Suggestion);

        Self {
            current_level,
            config,
        }
    }

    pub fn can_execute_action(&self, action: &AiAction) -> bool {
        match (self.current_level, action) {
            (AutonomyLevel::Suggestion, AiAction::InlineCompletion(_)) => true,
            (AutonomyLevel::Edit, AiAction::InlineCompletion(_) | AiAction::MultiLineEdit(_)) => true,
            (AutonomyLevel::Agent, _) => true,
            _ => false,
        }
    }

    pub fn requires_confirmation(&self, action: &AiAction) -> bool {
        match (self.current_level, action) {
            (AutonomyLevel::Suggestion, AiAction::InlineCompletion(_)) => false,
            (AutonomyLevel::Edit, AiAction::MultiLineEdit(_)) => true,
            (AutonomyLevel::Agent, AiAction::MultiFileChange(_)) => true,
            _ => false,
        }
    }
}

#[derive(Debug)]
pub enum AiAction {
    InlineCompletion(String),
    MultiLineEdit { range: Range, new_text: String },
    MultiFileChange(Vec<FileEdit>),
}
```

### 7.3 Codebase Indexing Strategy

**File:** `cli-ide-workbench/src/ai/codebase_indexer.rs`

```rust
use tantivy::{Index, schema::*, collector::TopDocs};

pub struct CodebaseIndexer {
    index: Index,
    schema: Schema,
}

impl CodebaseIndexer {
    pub fn new(index_path: &str) -> Result<Self, Box<dyn std::error::Error>> {
        let mut schema_builder = Schema::builder();
        schema_builder.add_text_field("file_path", TEXT | STORED);
        schema_builder.add_text_field("content", TEXT);
        schema_builder.add_text_field("language", STRING | STORED);
        schema_builder.add_i64_field("last_modified", INDEXED | STORED);
        let schema = schema_builder.build();

        let index = Index::create_in_dir(index_path, schema.clone())?;

        Ok(Self { index, schema })
    }

    /// Index a file
    pub fn index_file(&self, file: &CodeFile) -> Result<(), Box<dyn std::error::Error>> {
        let mut index_writer = self.index.writer(50_000_000)?;

        let file_path = self.schema.get_field("file_path").unwrap();
        let content = self.schema.get_field("content").unwrap();
        let language = self.schema.get_field("language").unwrap();
        let last_modified = self.schema.get_field("last_modified").unwrap();

        index_writer.add_document(doc!(
            file_path => file.path.clone(),
            content => file.content.clone(),
            language => file.language.clone(),
            last_modified => file.last_modified as i64,
        ))?;

        index_writer.commit()?;
        Ok(())
    }

    /// Search codebase
    pub fn search(&self, query: &str, limit: usize) -> Result<Vec<SearchResult>, Box<dyn std::error::Error>> {
        let reader = self.index.reader()?;
        let searcher = reader.searcher();

        let content_field = self.schema.get_field("content").unwrap();
        let query_parser = tantivy::query::QueryParser::for_index(&self.index, vec![content_field]);
        let query = query_parser.parse_query(query)?;

        let top_docs = searcher.search(&query, &TopDocs::with_limit(limit))?;

        let mut results = Vec::new();
        for (_score, doc_address) in top_docs {
            let doc = searcher.doc(doc_address)?;
            let file_path = doc.get_first(self.schema.get_field("file_path").unwrap()).unwrap();

            results.push(SearchResult {
                file_path: file_path.as_text().unwrap().to_string(),
                score: _score,
            });
        }

        Ok(results)
    }
}

#[derive(Debug)]
pub struct CodeFile {
    pub path: String,
    pub content: String,
    pub language: String,
    pub last_modified: u64,
}

#[derive(Debug)]
pub struct SearchResult {
    pub file_path: String,
    pub score: f32,
}
```

### 7.4 Multi-LLM Provider Pattern

**File:** `cli-ide-workbench/src/ai/llm_provider.rs`

```rust
#[async_trait::async_trait]
pub trait LlmProvider: Send + Sync {
    async fn complete(&self, prompt: &str, options: &CompletionOptions) -> Result<String, String>;
    async fn stream_complete(&self, prompt: &str) -> Result<Pin<Box<dyn Stream<Item = String>>>, String>;
    fn name(&self) -> &str;
    fn supports_function_calling(&self) -> bool;
}

pub struct ClaudeProvider {
    api_key: String,
    client: reqwest::Client,
}

#[async_trait::async_trait]
impl LlmProvider for ClaudeProvider {
    async fn complete(&self, prompt: &str, options: &CompletionOptions) -> Result<String, String> {
        let response = self.client
            .post("https://api.anthropic.com/v1/messages")
            .header("x-api-key", &self.api_key)
            .header("anthropic-version", "2023-06-01")
            .json(&json!({
                "model": "claude-3-5-sonnet-20241022",
                "max_tokens": options.max_tokens,
                "messages": [{"role": "user", "content": prompt}],
            }))
            .send()
            .await
            .map_err(|e| e.to_string())?;

        let json: serde_json::Value = response.json().await.map_err(|e| e.to_string())?;
        let content = json["content"][0]["text"]
            .as_str()
            .ok_or("Missing text in response")?;

        Ok(content.to_string())
    }

    async fn stream_complete(&self, prompt: &str) -> Result<Pin<Box<dyn Stream<Item = String>>>, String> {
        // Implement streaming via SSE
        unimplemented!()
    }

    fn name(&self) -> &str {
        "Claude 3.5 Sonnet"
    }

    fn supports_function_calling(&self) -> bool {
        true
    }
}

pub struct LlmManager {
    providers: HashMap<String, Arc<dyn LlmProvider>>,
    default_provider: String,
}

impl LlmManager {
    pub fn new() -> Self {
        Self {
            providers: HashMap::new(),
            default_provider: "claude".to_string(),
        }
    }

    pub fn register_provider(&mut self, id: String, provider: Arc<dyn LlmProvider>) {
        self.providers.insert(id, provider);
    }

    pub fn get_provider(&self, id: Option<&str>) -> Option<Arc<dyn LlmProvider>> {
        let id = id.unwrap_or(&self.default_provider);
        self.providers.get(id).cloned()
    }
}
```

---

## 8. AI-Assisted Development Workflow

### 8.1 Integration with Development Process

From the **AI-Assisted Code Development Guidelines** PDF, integrate:

1. **AI Tool Approval** - Whitelist of approved tools (Claude Code, Copilot)
2. **Human Review Gate** - 100% review of AI-generated code
3. **Contribution Tracking** - Co-author attribution in commits
4. **Testing Responsibility** - Humans must write/verify tests

### 8.2 Code Review Integration

**File:** `cli-ide-workbench/src/ai/review_integration.rs`

```rust
pub struct AiCodeReviewIntegration {
    config: Arc<ConfigurationService>,
    git_service: Arc<dyn IgitService>,
}

impl AiCodeReviewIntegration {
    /// Mark AI-generated code for mandatory review
    pub fn mark_ai_generated(&self, file_path: &str, range: Range) {
        // Add comment in code
        let comment = "// AI-generated code - requires human review";
        // Track in metadata
        self.track_ai_contribution(file_path, range);
    }

    /// Track AI contribution for audit
    fn track_ai_contribution(&self, file_path: &str, range: Range) {
        // Store in local database
        // Later used for commit co-authorship
    }

    /// Generate git commit message with co-author
    pub fn generate_commit_message(&self, ai_tool: &str) -> String {
        format!(
            "feat: implement feature X\n\n\
            Co-Authored-By: {} <noreply@anthropic.com>",
            ai_tool
        )
    }

    /// Check if AI-generated code has been reviewed
    pub fn has_been_reviewed(&self, file_path: &str) -> bool {
        // Check if review marker removed
        // Or check git blame for human edits after AI generation
        false
    }
}
```

### 8.3 Security Scanning Integration

From **AI-Assisted Code Review Process** PDF:

**Tools to integrate:**
- CodeQL (semantic code analysis)
- Semgrep (pattern-based scanning)
- Gitleaks (secret detection)
- cargo audit (dependency vulnerabilities)

**File:** `cli-ide-workbench/src/security/scanner.rs`

```rust
pub struct SecurityScanner {
    config: Arc<ConfigurationService>,
}

impl SecurityScanner {
    /// Run all security scans
    pub async fn run_full_scan(&self, codebase_path: &str) -> ScanResult {
        let mut result = ScanResult::default();

        // Run Gitleaks (secret detection)
        result.secrets = self.run_gitleaks(codebase_path).await?;

        // Run Semgrep (pattern-based)
        result.semgrep_findings = self.run_semgrep(codebase_path).await?;

        // Run cargo audit (dependencies)
        result.dependency_vulns = self.run_cargo_audit(codebase_path).await?;

        result
    }

    async fn run_gitleaks(&self, path: &str) -> Result<Vec<SecretFinding>, String> {
        let output = tokio::process::Command::new("gitleaks")
            .args(&["detect", "--source", path, "--report-format", "json"])
            .output()
            .await
            .map_err(|e| e.to_string())?;

        if output.status.success() {
            let findings: Vec<SecretFinding> = serde_json::from_slice(&output.stdout)
                .map_err(|e| e.to_string())?;
            Ok(findings)
        } else {
            Err(String::from_utf8_lossy(&output.stderr).to_string())
        }
    }

    async fn run_semgrep(&self, path: &str) -> Result<Vec<SemgrepFinding>, String> {
        let output = tokio::process::Command::new("semgrep")
            .args(&["--config", "auto", "--json", path])
            .output()
            .await
            .map_err(|e| e.to_string())?;

        if output.status.success() {
            let findings: Vec<SemgrepFinding> = serde_json::from_slice(&output.stdout)
                .map_err(|e| e.to_string())?;
            Ok(findings)
        } else {
            Err(String::from_utf8_lossy(&output.stderr).to_string())
        }
    }

    async fn run_cargo_audit(&self, path: &str) -> Result<Vec<DependencyVuln>, String> {
        let output = tokio::process::Command::new("cargo")
            .args(&["audit", "--json"])
            .current_dir(path)
            .output()
            .await
            .map_err(|e| e.to_string())?;

        if output.status.success() {
            let vulns: Vec<DependencyVuln> = serde_json::from_slice(&output.stdout)
                .map_err(|e| e.to_string())?;
            Ok(vulns)
        } else {
            Err(String::from_utf8_lossy(&output.stderr).to_string())
        }
    }
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ScanResult {
    pub secrets: Vec<SecretFinding>,
    pub semgrep_findings: Vec<SemgrepFinding>,
    pub dependency_vulns: Vec<DependencyVuln>,
}

impl Default for ScanResult {
    fn default() -> Self {
        Self {
            secrets: Vec::new(),
            semgrep_findings: Vec::new(),
            dependency_vulns: Vec::new(),
        }
    }
}
```

### 8.4 Test Generation & Verification

```rust
pub struct TestGenerator {
    llm_manager: Arc<LlmManager>,
}

impl TestGenerator {
    /// Generate tests for a function using LLM
    pub async fn generate_tests(&self, function_code: &str, language: &str) -> Result<String, String> {
        let prompt = format!(
            "Generate comprehensive unit tests for the following {} function:\n\n\
            {}\n\n\
            Include:\n\
            - Happy path tests\n\
            - Edge cases\n\
            - Error conditions\n\
            - Use idiomatic test framework for {}",
            language, function_code, language
        );

        let provider = self.llm_manager.get_provider(Some("claude")).unwrap();
        let tests = provider.complete(&prompt, &CompletionOptions::default()).await?;

        // Mark as AI-generated, requires human review
        Ok(format!("// AI-generated tests - REQUIRES HUMAN REVIEW\n{}", tests))
    }

    /// Run tests and verify they pass
    pub async fn verify_tests(&self, test_file: &str) -> Result<TestResult, String> {
        // Run cargo test or appropriate test runner
        let output = tokio::process::Command::new("cargo")
            .args(&["test", "--", test_file])
            .output()
            .await
            .map_err(|e| e.to_string())?;

        Ok(TestResult {
            passed: output.status.success(),
            output: String::from_utf8_lossy(&output.stdout).to_string(),
        })
    }
}
```

---

## 9. Component Interaction Details

### 9.1 Terminal Manager ↔ LLM Context Daemon Flow

```
┌────────────────────────────────────────────────────────────────┐
│ Sequence: User Opens Claude Code Terminal (ALT+k)             │
└────────────────────────────────────────────────────────────────┘

Terminal Manager         Context Daemon          Claude API
      │                        │                      │
      │ 1. User presses ALT+k  │                      │
      ├───────────────────────>│                      │
      │ IPC: RequestContext    │                      │
      │    { tool_id: "claude" }│                     │
      │                        │                      │
      │                        │ 2. Query context DB  │
      │                        │ (last conversation)  │
      │                        │                      │
      │                        │ 3. Synthesize context│
      │                        ├─────────────────────>│
      │                        │ POST /v1/messages    │
      │                        │ (recent history)     │
      │                        │                      │
      │                        │<─────────────────────┤
      │                        │ Summary response     │
      │                        │                      │
      │<───────────────────────┤                      │
      │ IPC: ContextInjection  │                      │
      │ { summary, history }   │                      │
      │                        │                      │
      │ 4. Spawn claude process│                      │
      │    with injected       │                      │
      │    context in env vars │                      │
      │                        │                      │
      │ 5. Capture terminal    │                      │
      │    output              │                      │
      ├───────────────────────>│                      │
      │ IPC: CaptureOutput     │                      │
      │ { tool_id, content }   │                      │
      │                        │                      │
      │                        │ 6. Store in DB       │
      │                        │ (encrypted)          │
      │                        │                      │
```

### 9.2 File Change → LSP → AI Suggestion Flow

```
File Watcher         Editor Core         LSP Server      AI Assistant
     │                   │                    │               │
     │ 1. File modified  │                    │               │
     ├──────────────────>│                    │               │
     │ Event: FileChange │                    │               │
     │                   │                    │               │
     │                   │ 2. Update buffer   │               │
     │                   │    (incremental)   │               │
     │                   │                    │               │
     │                   │ 3. Send didChange  │               │
     │                   ├───────────────────>│               │
     │                   │ LSP: textDocument/ │               │
     │                   │      didChange     │               │
     │                   │                    │               │
     │                   │<───────────────────┤               │
     │                   │ LSP: Diagnostics   │               │
     │                   │                    │               │
     │                   │ 4. Request AI      │               │
     │                   │    suggestions     │               │
     │                   ├───────────────────────────────────>│
     │                   │ { buffer, diagnostics, context }   │
     │                   │                    │               │
     │                   │<───────────────────────────────────┤
     │                   │ Completion suggestions             │
     │                   │                    │               │
     │                   │ 5. Render inline   │               │
     │                   │    suggestions     │               │
```

### 9.3 Plugin Activation Flow

```
Plugin Host          Service Container      Plugin (dylib)
     │                      │                       │
     │ 1. Load plugin       │                       │
     │    from disk         │                       │
     ├─────────────────────────────────────────────>│
     │ dlopen("plugin.so") │                        │
     │                      │                       │
     │<──────────────────────────────────────────── │
     │ plugin_create()      │                       │
     │ returns Plugin trait │                       │
     │                      │                       │
     │ 2. Create context    │                       │
     ├─────────────────────>│                       │
     │ Get services         │                       │
     │                      │                       │
     │<─────────────────────┤                       │
     │ PluginContext with   │                       │
     │ service refs         │                       │
     │                      │                       │
     │ 3. Activate plugin   │                       │
     ├─────────────────────────────────────────────>│
     │ plugin.activate(ctx) │                       │
     │                      │                       │
     │                      │                       │  4. Plugin registers
     │                      │                       │     commands, events
     │                      │<──────────────────────┤
     │                      │  Register command     │
     │                      │  Subscribe to events  │
     │                      │                       │
```

---

## 10. Implementation Roadmap with Patterns

### 10.1 Phase 1: Foundation (Weeks 1-2)

**Goals:**
- Set up workspace with layered architecture
- Implement base event system and DI container
- Basic editor core with rope-based buffer

**Patterns to Implement:**
1. **Event System** (Section 3)
   - `Event<T>` trait with tokio::broadcast
   - Event transformations (map, filter, debounce)
   - File: `cli-ide-base/src/event.rs`

2. **Service Container** (Section 2)
   - ServiceId and ServiceContainer
   - Basic services: IConfigurationService, ILogService
   - File: `cli-ide-platform/src/di/service_container.rs`

3. **Text Buffer**
   - Rope data structure using `ropey` crate
   - Undo/redo stack
   - File: `cli-ide-workbench/src/editor/buffer.rs`

**Milestone:** Demo showing text editing with undo/redo, logging via DI

### 10.2 Phase 2: Terminal Manager (Weeks 3-4)

**Goals:**
- Spawn CLI tools as subprocesses
- Render floating terminals with cascading offsets
- Implement keybinding system

**Patterns to Implement:**
1. **Terminal Spawner** (adapted from VS Code's extension host pattern)
   - PTY allocation using `portable-pty`
   - Process lifecycle management
   - File: `cli-ide-workbench/src/terminal/spawner.rs`

2. **Window Manager**
   - TUI rendering with `ratatui`
   - Floating window layout algorithm
   - File: `cli-ide-workbench/src/terminal/window_manager.rs`

3. **Keybinding Router**
   - Event-based keybinding system
   - Conflict detection
   - File: `cli-ide-workbench/src/input/keybindings.rs`

**Milestone:** 3 terminals (Claude Code, k9s, lazygit) toggle via ALT+k/j/h

### 10.3 Phase 3: IPC & Context Daemon (Weeks 5-6)

**Goals:**
- Unix socket IPC between manager and daemon
- Context capture and storage (encrypted SQLite)
- Daemon survives editor restarts

**Patterns to Implement:**
1. **IPC Protocol** (Section 4)
   - Channel-based communication
   - Request/response with cancellation
   - File: `cli-ide-base/src/ipc/protocol.rs`

2. **Context Store**
   - SQLite with sqlcipher
   - Schema from ARCHITECTURE.md Section 6.1
   - File: `cli-ide-daemon/src/context_store.rs`

3. **Daemon Lifecycle**
   - Systemd/Launchd integration
   - Graceful shutdown
   - File: `cli-ide-daemon/src/main.rs`

**Milestone:** Daemon captures 1 hour of terminal output, survives restart

### 10.4 Phase 4: LLM Integration (Weeks 7-8)

**Goals:**
- Claude API client with streaming
- Context synthesis using LLM
- Context injection on tool launch

**Patterns to Implement:**
1. **LLM Provider** (Section 7.4)
   - Multi-provider pattern (Claude, GPT-4)
   - Async completion with streaming
   - File: `cli-ide-workbench/src/ai/llm_provider.rs`

2. **Context Synthesizer**
   - Prompt engineering for context summaries
   - Token counting and truncation
   - File: `cli-ide-daemon/src/context_synthesizer.rs`

3. **Secret Redaction** (from ARCHITECTURE.md Section 7.2)
   - Regex-based pattern matching
   - Audit trail
   - File: `cli-ide-daemon/src/secret_redactor.rs`

**Milestone:** Context handoff demo (Claude Code → Aider)

### 10.5 Phase 5: Configuration & Extensibility (Weeks 9-10)

**Goals:**
- Configuration registry with JSON schemas
- Dynamic CLI tool configuration via TUI
- Plugin system foundation

**Patterns to Implement:**
1. **Configuration Service** (Section 6)
   - Multi-scope configuration (user, workspace, etc.)
   - JSON schema validation
   - File: `cli-ide-platform/src/config/configuration_service.rs`

2. **Configuration TUI**
   - CRUD interface for CLI tools
   - Keybinding conflict detection
   - File: `cli-ide-workbench/src/config/config_ui.rs`

3. **Plugin Host** (Section 5)
   - Dynamic library loading
   - Plugin API trait
   - File: `cli-ide-extensions/src/plugin_host.rs`

**Milestone:** Add new CLI tool via TUI, no code changes needed

### 10.6 Phase 6: AI Features & Polish (Weeks 11-12)

**Goals:**
- Inline code completion (Copilot-style)
- Codebase indexing and semantic search
- Security scanning integration
- Performance testing

**Patterns to Implement:**
1. **Autonomy Controller** (Section 7.2)
   - Suggestion/Edit/Agent modes
   - Confirmation requirements
   - File: `cli-ide-workbench/src/ai/autonomy_controller.rs`

2. **Codebase Indexer** (Section 7.3)
   - Full-text search with `tantivy`
   - Incremental updates
   - File: `cli-ide-workbench/src/ai/codebase_indexer.rs`

3. **Security Scanner** (Section 8.3)
   - Integration with Gitleaks, Semgrep, cargo audit
   - File: `cli-ide-workbench/src/security/scanner.rs`

4. **Performance Testing**
   - k6 load testing scripts
   - Memory profiling with `heaptrack`
   - Directory: `tests/performance/`

**Milestone:** Internal dogfooding (5 developers using daily)

---

## Appendix A: VS Code Files Reference

**Key files analyzed for patterns:**

| File | Pattern | Our Adaptation |
|------|---------|----------------|
| `instantiation.ts:110-127` | Service decorators | ServiceId + trait objects |
| `event.ts:19-28` | Event as function | Event<T> with tokio::broadcast |
| `ipc.ts:25-38` | Channel interface | IpcChannel with Unix sockets |
| `extensions.ts:122-140` | Extension host interface | Plugin trait with dylib loading |
| `extensionHostManager.ts:58-150` | Extension lifecycle | PluginHost with activation |
| `configuration.ts:38-47` | Configuration scopes | ConfigurationScope enum |
| `configurationRegistry.ts:34-72` | Configuration registry | PropertySchema validation |

---

## Appendix B: Implementation Checklist

### Base Layer (`cli-ide-base`)
- [ ] Event system with transformations
- [ ] IPC protocol (Unix sockets)
- [ ] Disposable/lifecycle management
- [ ] Error types and result handling

### Platform Layer (`cli-ide-platform`)
- [ ] Service container (DI)
- [ ] Configuration service with registry
- [ ] Logging service (structured JSON)
- [ ] File system abstraction

### Workbench Layer (`cli-ide-workbench`)
- [ ] Editor core (text buffer, syntax highlighting)
- [ ] Terminal manager (spawner, window manager)
- [ ] AI assistant (LLM providers, completions)
- [ ] Configuration UI (TUI for CLI tools)

### Extensions Layer (`cli-ide-extensions`)
- [ ] Plugin host (dynamic loading)
- [ ] Plugin API traits
- [ ] Extension registry

### Daemon (`cli-ide-daemon`)
- [ ] IPC server
- [ ] Context store (SQLite + encryption)
- [ ] Context synthesizer (LLM integration)
- [ ] Secret redaction
- [ ] Daemon lifecycle (systemd/launchd)

### Security & Quality
- [ ] Secret redaction (50+ patterns)
- [ ] Gitleaks integration
- [ ] Semgrep integration
- [ ] cargo audit integration
- [ ] Performance tests (k6)
- [ ] Memory leak detection

---

## Appendix C: ADR Index

**From Base ARCHITECTURE.md:**
- ADR-001: Use Rust for Editor Core
- ADR-002: Local-First Architecture
- ADR-003: SQLite for Context Store
- ADR-004: Unix Sockets for IPC
- ADR-005: Secret Redaction Strategy

**New ADRs for Enhanced Architecture:**
- ADR-006: Adopt VS Code's Layered Architecture
- ADR-007: Use Trait Objects for Service DI (not macros)
- ADR-008: tokio::broadcast for Event System (not custom)
- ADR-009: Dynamic Library Loading for Plugins (not WASM)
- ADR-010: Tantivy for Codebase Indexing (not PostgreSQL FTS)

---

## Document End

This enhanced architecture document provides **concrete implementation patterns** derived from VS Code's battle-tested codebase, adapted for Rust. Use this document alongside [ARCHITECTURE.md](./ARCHITECTURE.md) to guide iterative development with AI assistance.

**Next Steps:**
1. Review both documents with technical lead
2. Create Phase 1 implementation tickets
3. Set up CI/CD with security scanning (per Section 8)
4. Begin iterative development with Claude Code

**Questions? Contact:**
- Christopher Manahan (cmanahan@chanzuckerberg.com)
- Slack: #cli-ide-dev
