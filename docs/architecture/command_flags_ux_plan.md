# Interactive Command Builder UX Plan
## Flags & Arguments Selection System

**Status:** Planning Phase
**Created:** 2025-01-26
**Related PR:** #24 (Hierarchical Command Search)

---

## Overview

Extend the hierarchical command search to include **interactive flag and argument selection**, transforming Paradiddle into a smart command builder that guides users through constructing complex CLI commands.

### Design Principles

1. **Progressive Disclosure**: Show flags only when relevant
2. **Non-Intrusive**: Quick path for experts, helpful for learners
3. **Contextual Help**: Show flag descriptions and examples inline
4. **Flexible**: Support both quick selection and detailed building
5. **Smart Defaults**: Suggest commonly-used flags first

---

## UX Design Options

### **Option A: Two-Stage Selection** ⭐ (Recommended)

**Flow:**
```
Stage 1: Select Command
Alt+X → Type "docker build" → Enter

Stage 2: Select Flags (Auto-triggered)
┌─────────────────────────────────────────────────────────┐
│ 🔧 docker build [flags] <path>                          │
│                                                          │
│ Common Flags:                                           │
│ ✓ --tag, -t           Name and tag (e.g., name:tag)   │
│   --file, -f          Path to Dockerfile               │
│   --build-arg         Set build-time variables         │
│   --target            Set target build stage           │
│   --no-cache          Don't use cache                  │
│   --platform          Set platform (linux/amd64)       │
│                                                          │
│ All Flags: (24 more) Press Tab to see all              │
└─────────────────────────────────────────────────────────┘

Actions:
- Space:    Select/deselect flag
- Enter:    Finish and insert command
- Tab:      Expand to show all flags
- Ctrl+V:   Enter value for selected flag
- Esc:      Cancel and insert base command only
```

**Pros:**
- ✅ Guided experience for learners
- ✅ Still fast for experts (just press Enter to skip)
- ✅ Encourages flag discovery
- ✅ Clear two-step mental model

**Cons:**
- ⚠️ Extra step for users who don't need flags
- ⚠️ Requires pressing Esc to bypass

**User Flow:**
1. Select "docker build" from command search
2. Flag picker opens automatically
3. Select desired flags with Space
4. Press Enter → `docker build --tag --file ` inserted
5. User fills in values manually

---

### **Option B: Inline Preview** (Simplest)

**Flow:**
```
Stage 1: Select Command (Preview shows flags)
┌──────────────────────────────┬─────────────────────────────────┐
│ 🔍 Commands:                 │ Preview: docker build           │
│                              │                                 │
│ > docker build               │ Build image from Dockerfile     │
│   docker buildx              │                                 │
│   docker commit              │ Common flags:                   │
│   docker container           │   -t, --tag <name:tag>         │
│   docker container ls        │   -f, --file <path>            │
│                              │   --build-arg <key=val>        │
│                              │   --target <stage>             │
│                              │   --no-cache                   │
│                              │                                 │
│                              │ Press Ctrl+F for flag picker   │
└──────────────────────────────┴─────────────────────────────────┘

Actions:
- Enter:    Insert base command
- Ctrl+F:   Open flag picker for selected command
```

**Pros:**
- ✅ Zero friction for experts (just press Enter)
- ✅ Flags visible for discovery
- ✅ Opt-in flag selection
- ✅ Minimal changes to existing flow

**Cons:**
- ⚠️ Requires extra key (Ctrl+F) for flag selection
- ⚠️ Flags only visible in preview (might be missed)

**User Flow:**
1. See flags in preview while browsing
2. Press Enter for basic command, or Ctrl+F to build with flags
3. Quick and non-intrusive

---

### **Option C: Template-Based** (Most Advanced)

**Flow:**
```
Stage 1: Select Command
Alt+X → "docker build" → Enter

Stage 2: Choose Template or Custom
┌─────────────────────────────────────────────────────────┐
│ 🎯 docker build - Select a template or build custom    │
│                                                          │
│ 📋 Templates:                                           │
│   1. Basic build                                        │
│      docker build -t <name> .                          │
│                                                          │
│   2. Build with Dockerfile path                        │
│      docker build -t <name> -f <dockerfile> .          │
│                                                          │
│   3. Multi-stage build with target                     │
│      docker build -t <name> --target <stage> .         │
│                                                          │
│   4. Build with build args                             │
│      docker build -t <name> --build-arg <key=val> .    │
│                                                          │
│   5. Custom (pick your own flags)                      │
│                                                          │
└─────────────────────────────────────────────────────────┘

Stage 3: Fill Template Placeholders
┌────────────────────────────────────────────────┐
│ Template: Multi-stage build with target       │
│                                                │
│ Enter image-name:                              │
│ > myapp:v1.2.3█                               │
│                                                │
│ Enter stage:                                   │
│ > production█                                  │
│                                                │
│ Result:                                        │
│ docker build -t myapp:v1.2.3 \               │
│              --target production .             │
└────────────────────────────────────────────────┘
```

**Pros:**
- ✅ Perfect for common workflows
- ✅ Educational (shows proper syntax)
- ✅ Fastest for frequent patterns
- ✅ Ensures correct flag ordering

**Cons:**
- ⚠️ Requires maintaining template library
- ⚠️ Limited to pre-defined patterns
- ⚠️ Three-stage flow (more complex)

**User Flow:**
1. Select command
2. Choose from common templates or build custom
3. Fill in template placeholders
4. Command generated with proper syntax

---

## Data Structure Design

### **Extended commands.yaml Format**

```yaml
commands:
  docker:
    subcommands:
      - name: build
        description: "Build an image from a Dockerfile"
        usage: "docker build [OPTIONS] PATH"
        flags:
          - name: "--tag"
            short: "-t"
            type: "string"
            description: "Name and optionally a tag in the 'name:tag' format"
            example: "myapp:latest"
            required: false
            category: "common"

          - name: "--file"
            short: "-f"
            type: "string"
            description: "Name of the Dockerfile (Default is 'PATH/Dockerfile')"
            example: "Dockerfile.prod"
            required: false
            category: "common"

          - name: "--build-arg"
            type: "key=value"
            description: "Set build-time variables"
            example: "VERSION=1.2.3"
            required: false
            category: "common"
            repeatable: true

          - name: "--target"
            type: "string"
            description: "Set the target build stage to build"
            example: "production"
            required: false
            category: "common"

          - name: "--no-cache"
            type: "boolean"
            description: "Do not use cache when building the image"
            required: false
            category: "common"

          - name: "--platform"
            type: "string"
            description: "Set platform if server is multi-platform capable"
            example: "linux/amd64"
            required: false
            category: "advanced"

        templates:
          - name: "Basic build"
            command: "docker build -t <image-name> ."
            placeholders:
              - name: "image-name"
                description: "Name and tag (e.g., myapp:latest)"
                default: "myapp:latest"

          - name: "Build with custom Dockerfile"
            command: "docker build -t <image-name> -f <dockerfile-path> ."

          - name: "Multi-stage build"
            command: "docker build -t <image-name> --target <stage-name> ."
```

### **Flag Database Format**

File: `~/.config/paradiddle/flags/docker_build.flags`

```
flag|short|type|description|example|category|required|repeatable
--tag|-t|string|Name and optionally a tag (name:tag format)|myapp:latest|common|false|false
--file|-f|string|Name of the Dockerfile|Dockerfile.prod|common|false|false
--build-arg||key=value|Set build-time variables|VERSION=1.2.3|common|false|true
--target||string|Set the target build stage to build|production|common|false|false
--no-cache||boolean|Do not use cache when building|<none>|common|false|false
--platform||string|Set platform if multi-platform capable|linux/amd64|advanced|false|false
--progress||string|Set type of progress output|plain|advanced|false|false
--quiet|-q|boolean|Suppress the build output|<none>|advanced|false|false
```

---

## Flag Discovery Strategies

### **1. Parse --help Output** (Automatic)

```bash
discover_flags() {
  local cmd="$1"

  # Parse flags from --help
  $cmd --help 2>&1 | grep -E '^\s+(-[a-z]|--[a-z])' | \
  awk '{
    flag = $1
    gsub(/,/, "", flag)
    description = substr($0, index($0, $2))
    print flag "|" description
  }'
}
```

### **2. Man Page Parsing** (Fallback)

```bash
parse_man_flags() {
  local cmd="$1"

  man $cmd | \
  col -b | \
  grep -A 2 -E '^\s+(-[a-z]|--[a-z])' | \
  awk 'BEGIN {RS=""} {print}'
}
```

### **3. Static Curated Database** ⭐ (Recommended)

Maintain high-quality flag data for top 50 commands:
- Better descriptions
- Examples included
- Categorized (common vs advanced)
- Type information (string, boolean, key=value)

---

## Keybinding Strategy

| Key | Action | Description |
|-----|--------|-------------|
| `Alt+X` | Command search | Select command (existing) |
| `Enter` | Insert base | Insert command without flags |
| `Ctrl+F` | Flag picker | Open flag selection for command |
| `Ctrl+T` | Template | Choose from command templates |
| `Space` | Toggle flag | Select/deselect flag in picker |
| `Ctrl+V` | Enter value | Set value for selected flag |
| `Tab` | Show all | Expand to show all flags (not just common) |
| `Ctrl+C` | Categories | Show flag categories |
| `Esc` | Cancel | Exit flag picker, insert base command |

---

## Implementation Phases

### **Phase 1: Enhanced Preview** (Quick Win - 1 day)

**Goal:** Show flags in preview window without changing flow

**Implementation:**
1. Extend `commands.yaml` to include top 5 flags per command
2. Modify preview window to show:
   ```
   Command: docker build
   Description: Build an image from Dockerfile

   Common Flags:
     -t, --tag <name>        Name and tag (e.g., myapp:latest)
     -f, --file <path>       Path to Dockerfile
     --build-arg <key=val>   Set build-time variables
     --target <stage>        Set target build stage
     --no-cache              Don't use cache

   Press Ctrl+F to open flag picker
   ```

3. No interaction change - just better info

**Deliverable:** Users can see available flags while browsing

**Files to modify:**
- `~/.config/paradiddle/commands.yaml` - Add flag data
- `zsh/.zshrc` - Update preview window in `fzf-command-widget`

---

### **Phase 2: Flag Picker** (1 week)

**Goal:** Interactive flag selection

**Implementation:**
1. Create flag database:
   ```
   ~/.config/paradiddle/flags/
   ├── git_commit.flags
   ├── docker_build.flags
   ├── kubectl_apply.flags
   └── ...
   ```

2. Create `fzf-flag-picker` function in `.zshrc`:
   ```bash
   fzf-flag-picker() {
     local cmd="$1"
     local flags_file="$HOME/.config/paradiddle/flags/${cmd//[\/: ]/_}.flags"

     # Multi-select flags with fzf
     local selected=$(cat "$flags_file" | \
       fzf --multi \
           --header="Space: Toggle | Ctrl+V: Set value | Enter: Confirm")

     # Build command with selected flags
     # ...
   }
   ```

3. Bind `Ctrl+F` in command search to trigger flag picker

4. Handle value entry for flags (string vs boolean)

5. Build final command string

**Deliverable:** Full interactive flag selection

**Files to modify:**
- `~/.config/paradiddle/flags/*` - Flag database files
- `zsh/.zshrc` - Add `fzf-flag-picker` function
- `~/.local/bin/paradiddle-discover-flags` - Flag discovery script

---

### **Phase 3: Templates** (1 week)

**Goal:** Pre-built command templates

**Implementation:**
1. Add templates to `commands.yaml`:
   ```yaml
   templates:
     docker_build:
       - name: "Basic build"
         command: "docker build -t <image-name> ."
   ```

2. Create template picker interface:
   ```bash
   fzf-template-picker() {
     # Select template
     # Fill placeholders interactively
     # Return completed command
   }
   ```

3. Interactive placeholder filling with fzf

4. Build template library for common commands

**Deliverable:** Quick command building from templates

**Files to modify:**
- `~/.config/paradiddle/commands.yaml` - Add templates
- `zsh/.zshrc` - Add `fzf-template-picker` function
- Bind `Ctrl+T` to template picker

---

### **Phase 4: Smart Suggestions** (Future)

**Goal:** Context-aware suggestions

**Ideas:**
- Suggest flags based on context (directory contents, git state, etc.)
- Learn from usage patterns (track frequently used flags)
- Show "users who ran X also used Y" suggestions
- Integration with tldr/cheat.sh for better examples

---

## Example User Workflows

### **Workflow 1: Expert User (Quick Path)**

```
1. Alt+X
2. Type "docker build"
3. Press Enter
4. Manual: docker build -t myapp:latest .
```
**Time:** 3 seconds
**Keystrokes:** ~15

---

### **Workflow 2: Learning User (Flag Picker)**

```
1. Alt+X
2. Type "docker build"
3. Press Ctrl+F (flag picker opens)
4. Select:
   - [x] --tag
   - [x] --file
   - [x] --no-cache
5. Press Ctrl+V on --tag, enter "myapp:latest"
6. Press Ctrl+V on --file, enter "Dockerfile.prod"
7. Press Enter
8. Result: docker build --tag myapp:latest --file Dockerfile.prod --no-cache
```
**Time:** 20 seconds
**Educational value:** High

---

### **Workflow 3: Template User**

```
1. Alt+X
2. Type "docker build"
3. Press Ctrl+T (template picker)
4. Select "Multi-stage build with target"
5. Fill placeholder: image-name = "myapp:v1.0"
6. Fill placeholder: stage = "production"
7. Result: docker build -t myapp:v1.0 --target production .
```
**Time:** 15 seconds
**Reliability:** High (correct syntax guaranteed)

---

## Priority Commands for Flag Data

### **Tier 1 (Must Have)**
- **docker**: build, run, exec, ps, logs
- **git**: commit, push, pull, clone, rebase
- **kubectl**: apply, get, describe, logs, exec
- **aws s3**: cp, sync, ls, rm
- **npm**: install, run, build, test

### **Tier 2 (Important)**
- **cargo**: build, test, run, clippy
- **terraform**: apply, plan, init, state
- **helm**: install, upgrade, repo add
- **curl**: GET, POST, headers
- **ssh**: connection, tunneling, port forwarding

### **Tier 3 (Nice to Have)**
- tar, zip, unzip
- grep, sed, awk
- systemctl
- ffmpeg
- rsync, scp

---

## Success Metrics

1. **Coverage**: Flag data for 30+ most common commands
2. **Accuracy**: 95%+ accurate flag descriptions and examples
3. **Usability**: Users can build complex commands without leaving terminal
4. **Performance**: Flag picker opens in <100ms
5. **Adoption**: 50%+ of Alt+X usage includes flag selection (tracked via cache)
6. **Learning**: Users discover 3+ new flags per week on average

---

## Technical Architecture

### **Directory Structure**

```
~/.config/paradiddle/
├── commands.yaml              # Extended with flags and templates
├── flags/                     # Per-command flag databases
│   ├── git_commit.flags
│   ├── docker_build.flags
│   ├── kubectl_apply.flags
│   └── ...
└── templates/                 # Command templates (optional)
    ├── docker.templates
    ├── git.templates
    └── ...

~/.cache/paradiddle/
├── commands.db                # Existing command cache
└── flags.cache               # Merged flag cache for fast lookup

~/.local/bin/
├── paradiddle-update-commands    # Existing
├── paradiddle-discover-commands  # Existing
├── paradiddle-add-command        # Existing
├── paradiddle-discover-flags     # New: Auto-discover flags
└── paradiddle-add-flag          # New: Add custom flag
```

### **Performance Considerations**

- Flag database: Plain text, line-delimited (fast grep/awk)
- Cache merged flags on first run
- Lazy load: Only parse flags when Ctrl+F pressed
- Preview window: Async loading, don't block UI

---

## Open Questions

1. **Which UX option to implement first?**
   - Option A: Two-stage selection (recommended)
   - Option B: Inline preview (simplest)
   - Option C: Template-based (most advanced)

2. **Flag categorization granularity?**
   - Just "common" vs "advanced"?
   - Or: "common", "advanced", "networking", "security", "debugging"?

3. **Value entry method?**
   - Inline in fzf with Ctrl+V?
   - Separate prompt after flag selection?
   - Placeholder insertion for manual filling?

4. **Template format?**
   - YAML in commands.yaml?
   - Separate .template files?
   - Both?

5. **Discovery priority?**
   - Start with static curated flags?
   - Or implement --help parsing first?
   - Or both in parallel?

---

## Next Steps

**Decision Required:** Which option (A, B, or C) to proceed with?

**Quick Win Available:** Phase 1 (Enhanced Preview) can be implemented immediately:
- 1 day of work
- No new keybindings
- Just better information display
- Foundation for later phases

**Full Implementation Timeline:**
- Phase 1: 1 day (preview enhancement)
- Phase 2: 1 week (flag picker)
- Phase 3: 1 week (templates)
- **Total: ~2.5 weeks for complete system**

---

## Related Documents

- [Hierarchical Command Search PR #24](https://github.com/christophermanahan/paradiddle/pull/24)
- [CLAUDE.md](./CLAUDE.md) - Current command search documentation
- [commands.yaml](~/.config/paradiddle/commands.yaml) - Static command database

---

**Document Version:** 1.0
**Last Updated:** 2025-01-26
**Author:** Planning session with Claude Code
