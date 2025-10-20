# Terminal Workflow Enhancement Plan

This document outlines a phased approach to enhancing your terminal-based development workflow. Enhancements are prioritized based on immediate impact to your daily workflow, with language-specific tooling organized separately for future reference.

---

## Recently Implemented ✅

### Wezterm Launch Menu
- **Shortcut:** `Ctrl+A` then `m`
- **What it does:** Opens a fuzzy-searchable menu to quickly launch k9s, lazygit, lazydocker, btm (bottom), or htop
- **Workflow tip:** Use this instead of typing commands manually. Perfect for when you're already in Wezterm and need to spin up a monitoring tool quickly.

### Markdown Preview
- **Shortcut:** `<leader>mp` (Space + mp in Neovim)
- **What it does:** Opens a live preview of your markdown file in your default browser. Auto-updates as you type.
- **Workflow tip:** Essential for documentation work. Keep it open on a second monitor while editing READMEs, project docs, or technical write-ups.

---

## Phase 1: Essential Terminal Productivity (Week 1-2)

These tools will immediately improve your daily terminal experience with minimal learning curve.

### 1.1 Enhanced File Operations
**Tools to install:**
```bash
brew install fzf bat fd ripgrep
```

**What you get:**
- **fzf:** Fuzzy finder for everything (files, command history, git branches)
- **bat:** cat with syntax highlighting and git integration
- **fd:** faster, more intuitive find
- **ripgrep:** already installed, but good to verify

**ZSH aliases to add to `.zshrc`:**
```bash
# Enhanced file viewing
alias cat="bat"
alias find="fd"

# FZF integration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview "bat --color=always --style=numbers --line-range=:500 {}"'

# Enable FZF keybindings
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
```

**Workflow tips:**
- Press `Ctrl+R` to fuzzy search command history (game-changer!)
- Press `Ctrl+T` to fuzzy search files in current directory
- Use `cat filename` to get syntax-highlighted file viewing
- Use `fd pattern` instead of `find . -name pattern`

### 1.2 Git Workflow Enhancement
**Tools to install:**
```bash
brew install delta lazygit
```

**Add to `~/.gitconfig`:**
```gitconfig
[core]
    pager = delta

[interactive]
    diffFilter = delta --color-only

[delta]
    navigate = true
    side-by-side = true
    line-numbers = true

[merge]
    conflictstyle = diff3

[diff]
    colorMoved = default
```

**ZSH aliases:**
```bash
alias lg="lazygit"
alias gst="git status"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gp="git push"
alias gpl="git pull"
alias gcm="git commit -m"
alias glog="git log --oneline --graph --decorate --all"
```

**Workflow tips:**
- Use `lazygit` for interactive git operations instead of memorizing commands
- Use `delta` automatically for all git diffs (much more readable)
- Launch lazygit from Wezterm launch menu (`Ctrl+A` then `m`)

### 1.3 System Monitoring
**Tools to install:**
```bash
brew install bottom dust duf procs
```

**ZSH aliases:**
```bash
alias top="btm"
alias du="dust"
alias df="duf"
alias ps="procs"
```

**Workflow tips:**
- `btm` provides better system monitoring than htop (already in Wezterm launch menu)
- `dust` shows directory sizes visually
- `duf` shows disk usage with colors and better formatting
- `procs` shows processes with better filtering

---

## Phase 2: DevOps & Infrastructure (Week 3-4)

Essential tools for working with Kubernetes, AWS, and Terraform in your daily workflow.

### 2.1 Kubernetes Workflow
**Tools to install:**
```bash
brew install kubectx kubens stern helm
```

**ZSH aliases:**
```bash
alias k="kubectl"
alias kgp="kubectl get pods"
alias kgs="kubectl get svc"
alias kgd="kubectl get deployments"
alias kl="kubectl logs -f"
alias kx="kubectx"
alias kns="kubens"
alias kdesc="kubectl describe"
alias kexec="kubectl exec -it"
alias stern="stern --tail=50"

# Helm shortcuts
alias h="helm"
alias hls="helm list"
alias hsh="helm show values"
```

**Workflow tips:**
- Use `kubectx` to quickly switch between clusters (no more typing full context names)
- Use `kubens` to switch default namespace
- Use `stern pod-prefix` for multi-pod log tailing (much better than kubectl logs)
- k9s (already available) provides the TUI, these tools complement it for CLI workflows

### 2.2 Docker Workflow
**Tools to install:**
```bash
brew install lazydocker dive ctop
```

**ZSH aliases:**
```bash
alias d="docker"
alias dc="docker compose"
alias dcu="docker compose up -d"
alias dcd="docker compose down"
alias dcl="docker compose logs -f"
alias dps="docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias dpsa="docker ps -a"
alias di="docker images"
alias dprune="docker system prune -af"

# Use dive to explore image layers
alias dive="dive"
```

**Workflow tips:**
- Use `lazydocker` TUI for quick container management (already in Wezterm launch menu)
- Use `dive <image>` to analyze Docker image layers and find bloat
- Use `ctop` for real-time container metrics
- Use `dps` for cleaner docker ps output

### 2.3 AWS & Terraform
**Tools to install:**
```bash
brew install awscli terraform-ls tflint
```

**ZSH aliases:**
```bash
# Terraform
alias tf="terraform"
alias tfi="terraform init"
alias tfp="terraform plan"
alias tfa="terraform apply"
alias tfd="terraform destroy"
alias tfv="terraform validate"
alias tff="terraform fmt -recursive"
alias tfw="terraform workspace"

# AWS
alias awswhoami="aws sts get-caller-identity"
alias s3ls="aws s3 ls"

# Quick profile switcher
awsprofile() {
  export AWS_PROFILE=$1
  echo "AWS Profile set to: $AWS_PROFILE"
  awswhoami
}
```

**Update Neovim LSP (already in mason-lspconfig):**
- terraformls ✅ (already installed)
- tflint integration via null-ls (optional enhancement)

**Workflow tips:**
- Use `awsprofile <profile-name>` function to quickly switch AWS profiles
- Use `tff` before commits to ensure consistent terraform formatting
- Use `tfv` to validate terraform before plan/apply

### 2.4 ArgoCD Integration
**Tools to install:**
```bash
brew install argocd
```

**ZSH aliases:**
```bash
alias argolist="argocd app list"
alias argosync="argocd app sync"
alias argoget="argocd app get"
alias argodiff="argocd app diff"
alias argowait="argocd app wait"

# Quick sync with wait
argosyncwait() {
  argocd app sync $1 && argocd app wait $1
}
```

**Workflow tips:**
- Use `argolist` to see all applications and their sync status
- Use `argosyncwait <app-name>` to sync and wait for completion in one command
- Use `argodiff <app-name>` before syncing to preview changes

---

## Phase 3: API Development & Testing (Week 5)

Tools for working with APIs, HTTP requests, and data formats.

### 3.1 HTTP & API Tools
**Tools to install:**
```bash
brew install httpie jq yq
```

**ZSH aliases:**
```bash
alias http="httpie"
alias json="jq -C"
alias yaml="yq -C"
```

**Neovim plugin to add:**
```lua
{
  "rest-nvim/rest.nvim",
  ft = "http",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("rest-nvim").setup()
  end,
},
```

**Neovim keybinding to add:**
```lua
-- Add to mappings.lua
{
  "<leader>rr",
  "<Plug>RestNvim",
  desc = "run REST request",
  icon = {
    icon = "󰖟",
    color = "green",
  },
},
{
  "<leader>rp",
  "<Plug>RestNvimPreview",
  desc = "preview REST request",
  icon = {
    icon = "󰖟",
    color = "blue",
  },
},
```

**Workflow tips:**
- Create `.http` files in your projects to document and test APIs
- Use `<leader>rr` to execute HTTP requests directly from Neovim
- Use `http GET https://api.example.com/endpoint` for quick CLI tests
- Pipe JSON responses through `json` for pretty formatting: `http GET url | json`

### 3.2 Data Format Processing
**Already installed:** jq, yq

**Common jq patterns to remember:**
```bash
# Pretty print JSON
cat file.json | jq '.'

# Extract specific field
cat file.json | jq '.field.nested'

# Filter arrays
cat file.json | jq '.items[] | select(.status == "active")'

# Get keys
cat file.json | jq 'keys'
```

**Common yq patterns:**
```bash
# Convert YAML to JSON
yq -o=json file.yaml

# Extract field from YAML
yq '.field.nested' file.yaml

# Edit YAML in place
yq -i '.field = "new value"' file.yaml
```

---

## Phase 4: Testing & Debugging (Week 6)

Enhanced testing and debugging capabilities within your terminal workflow.

### 4.1 Universal Test Runner
**Neovim plugin:**
```lua
{
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-neotest/neotest-python",
    "nvim-neotest/neotest-jest",
    "nvim-neotest/neotest-plenary",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-python"),
        require("neotest-jest"),
        require("neotest-plenary"),
      },
    })
  end,
},
```

**Neovim keybindings:**
```lua
-- Add to mappings.lua
{
  "<leader>tr",
  "<cmd>lua require('neotest').run.run()<cr>",
  desc = "run nearest test",
  icon = { icon = "󰙨", color = "green" },
},
{
  "<leader>tf",
  "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>",
  desc = "run test file",
  icon = { icon = "󰙨", color = "blue" },
},
{
  "<leader>ts",
  "<cmd>lua require('neotest').summary.toggle()<cr>",
  desc = "toggle test summary",
  icon = { icon = "󰙨", color = "yellow" },
},
{
  "<leader>to",
  "<cmd>lua require('neotest').output.open({ enter = true })<cr>",
  desc = "show test output",
  icon = { icon = "󰙨", color = "orange" },
},
```

**Workflow tips:**
- Put cursor on a test function and press `<leader>tr` to run just that test
- Use `<leader>tf` to run all tests in current file
- Use `<leader>ts` to see test summary sidebar with pass/fail status
- Works with Python (pytest), JavaScript/TypeScript (Jest), and Lua tests

### 4.2 Enhanced Navigation
**Already installed:** flash.nvim ✅

**Additional plugin for project management:**
```lua
{
  "ahmedkhalf/project.nvim",
  config = function()
    require("project_nvim").setup({
      detection_methods = { "pattern", ".git" },
      patterns = { ".git", "package.json", "Cargo.toml", "go.mod", "pyproject.toml" },
    })
    require("telescope").load_extension("projects")
  end,
},
```

**Neovim keybinding:**
```lua
{
  "<leader>fp",
  "<cmd>Telescope projects<cr>",
  desc = "find projects",
  icon = { icon = "󰷾", color = "purple" },
},
```

**Workflow tips:**
- Use `<leader>fp` to quickly switch between recent projects
- Automatically detects project roots based on git, package.json, etc.
- Maintains per-project working directory

---

## Phase 5: Session & Project Management (Week 7)

Tools for managing multiple projects and persistent sessions.

### 5.1 Auto Session Management
**Neovim plugin:**
```lua
{
  "rmagatti/auto-session",
  opts = {
    log_level = "error",
    auto_session_suppress_dirs = { "~/", "~/Downloads", "~/Desktop", "/"},
    auto_save_enabled = true,
    auto_restore_enabled = true,
  },
},
```

**Workflow tips:**
- Sessions automatically save when you quit Neovim
- Sessions automatically restore when you open Neovim in same directory
- Each project directory gets its own session (open files, splits, etc.)
- No more manually reopening files after closing Neovim

### 5.2 Git Worktree Management
**Neovim plugin:**
```lua
{
  "ThePrimeagen/git-worktree.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("git-worktree").setup()
    require("telescope").load_extension("git_worktree")
  end,
},
```

**Neovim keybindings:**
```lua
{
  "<leader>gw",
  "<cmd>Telescope git_worktree<cr>",
  desc = "git worktrees",
  icon = { icon = "", color = "orange" },
},
{
  "<leader>gW",
  "<cmd>Telescope git_worktree create_git_worktree<cr>",
  desc = "create git worktree",
  icon = { icon = "", color = "green" },
},
```

**Workflow tips:**
- Use git worktrees to work on multiple branches simultaneously
- Each worktree is a separate directory pointing to the same repo
- No more stashing/switching when you need to quickly check another branch
- Example: main branch in `~/project`, feature branch in `~/project-feature`

---

## Phase 6: GitHub Integration (Week 8)

Enhanced GitHub workflow without leaving the terminal.

### 6.1 GitHub CLI Integration
**Tool to install:**
```bash
brew install gh
```

**ZSH aliases:**
```bash
alias ghpr="gh pr list"
alias ghprc="gh pr create"
alias ghprv="gh pr view"
alias ghprd="gh pr diff"
alias ghis="gh issue list"
alias ghisc="gh issue create"
alias ghisv="gh issue view"
alias ghrepo="gh repo view --web"
```

**Workflow tips:**
- Use `gh auth login` first time to authenticate
- Use `ghpr` to quickly see all open PRs
- Use `ghprc` to create PR from current branch
- Use `ghrepo` to open current repo in browser

### 6.2 GitHub in Neovim
**Neovim plugin:**
```lua
{
  "pwntester/octo.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {},
},
```

**Neovim keybindings:**
```lua
{
  "<leader>gpr",
  "<cmd>Octo pr list<cr>",
  desc = "list pull requests",
  icon = { icon = "", color = "purple" },
},
{
  "<leader>gis",
  "<cmd>Octo issue list<cr>",
  desc = "list issues",
  icon = { icon = "", color = "red" },
},
{
  "<leader>gpc",
  "<cmd>Octo pr create<cr>",
  desc = "create pull request",
  icon = { icon = "", color = "green" },
},
```

**Workflow tips:**
- View and edit PRs directly in Neovim
- Comment on PRs without leaving editor
- Create PRs with `<leader>gpc`
- Review PR diffs with full Neovim editing capabilities

---

## Phase 7: Advanced Quality of Life (Week 9-10)

Additional enhancements that further streamline your workflow.

### 7.1 Better Man Pages & Documentation
**Tools to install:**
```bash
brew install tldr cheat
```

**ZSH aliases:**
```bash
alias help="tldr"
```

**Workflow tips:**
- Use `tldr command` for practical examples (better than man pages)
- Use `cheat command` for community cheat sheets
- Much faster than searching StackOverflow for basic syntax

### 7.2 Directory Jumping Enhancement
**Already installed:** zoxide ✅

**Additional ZSH configuration:**
```bash
# Add to .zshrc for enhanced zoxide
alias cd="z"
alias cdi="zi"  # Interactive directory selection with fzf

# Quick jump to common directories
alias work="z ~/work"
alias dots="z ~/dotfiles"
alias repos="z ~/repos"
```

**Workflow tips:**
- zoxide learns your most-used directories
- Just type `z proj` to jump to `/path/to/my-project`
- Use `cdi` for interactive fuzzy search of directories

### 7.3 Network Utilities
**Tools to install:**
```bash
brew install gping
```

**ZSH aliases:**
```bash
alias ping="gping"
```

**Workflow tips:**
- `gping` shows ping statistics as a live graph
- Better for monitoring network connectivity issues

---

## Language-Specific Enhancements Reference

This section contains language-specific tooling to reference when you start learning these technologies.

### Rust Development

**Prerequisites:**
```bash
brew install rust rust-analyzer
cargo install cargo-watch cargo-expand cargo-edit
```

**Neovim plugins:**
```lua
{
  "Saecki/crates.nvim",
  event = { "BufRead Cargo.toml" },
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    completion = { cmp = { enabled = true } },
  },
},
{
  "mrcjkb/rustaceanvim",
  version = "^5",
  lazy = false,
  ft = "rust",
},
{
  "rouge8/neotest-rust",  -- Add to neotest adapters
},
```

**ZSH aliases:**
```bash
alias cr="cargo run"
alias cb="cargo build"
alias cbr="cargo build --release"
alias ct="cargo test"
alias cc="cargo check"
alias ccw="cargo check --workspace"
alias cw="cargo watch -x check -x test -x run"
alias clippy="cargo clippy -- -W clippy::all"
alias cex="cargo expand"  # Shows macro expansions
```

**Workflow tips:**
- Use `crates.nvim` to see latest versions inline in Cargo.toml
- Use `cargo watch` for continuous compilation checking
- Use `rustaceanvim` for enhanced rust-analyzer features
- Rust LSP already configured via mason-lspconfig ✅

### Go Development

**Prerequisites:**
```bash
brew install go gopls golangci-lint
```

**Neovim LSP:**
```lua
-- Add to mason-lspconfig ensure_installed
"gopls",
```

**Neovim plugin:**
```lua
{
  "nvim-neotest/neotest-go",  -- Add to neotest adapters
},
```

**ZSH aliases:**
```bash
alias gor="go run ."
alias gob="go build"
alias got="go test ./..."
alias gotv="go test -v ./..."
alias gom="go mod tidy"
alias gofmt="gofumpt -l -w ."  # Requires: go install mvdan.cc/gofumpt@latest
alias govet="go vet ./..."
alias golint="golangci-lint run"
```

**Workflow tips:**
- Go LSP (gopls) provides excellent inline documentation
- Use `got` for running all tests in project
- Use `golint` for comprehensive linting

### Elixir Development

**Prerequisites:**
```bash
brew install elixir
```

**Neovim LSP:**
```lua
-- Add to mason-lspconfig ensure_installed
"elixirls",
```

**ZSH aliases:**
```bash
alias mt="mix test"
alias mtw="mix test.watch"
alias mc="mix compile"
alias mf="mix format"
alias mps="mix phx.server"
alias iex="iex -S mix"
alias mdo="mix ecto.migrate"
alias mdr="mix ecto.rollback"
alias mds="mix ecto.reset"
```

**Workflow tips:**
- Use `iex` for interactive Elixir shell with your project loaded
- Use `mps` to start Phoenix server (if using Phoenix framework)
- Mix test runs very fast, use `mt` frequently

### Scala Development

**Prerequisites:**
```bash
brew install scala sbt coursier
cs setup  # Sets up Scala tooling
cs install metals  # Scala LSP
```

**Neovim LSP:**
```lua
-- Add to mason-lspconfig ensure_installed
"metals",
```

**Note:** Metals requires additional setup in Neovim. Consider using nvim-metals plugin.

**ZSH aliases:**
```bash
alias sbtc="sbt compile"
alias sbtt="sbt test"
alias sbtr="sbt run"
alias sbtcc="sbt clean compile"
```

**Workflow tips:**
- Metals LSP provides excellent IDE-like features
- sbt can be slow to start; consider using sbt shell
- Use `sbt ~compile` for continuous compilation

### Python/PySpark Development

**Prerequisites:**
```bash
brew install python ipython jupyterlab
pip install pyspark pytest black mypy
```

**Neovim LSP:**
```lua
-- Add to mason-lspconfig ensure_installed
"pyright",  -- Already installed ✅
```

**Neovim plugins:**
```lua
{
  "GCBallesteros/jupytext.nvim",
  config = true,
  ft = { "ipynb" },
},
```

**ZSH aliases:**
```bash
alias py="python3"
alias ipy="ipython"
alias jlab="jupyter lab"
alias nb="jupyter notebook"
alias pyt="pytest"
alias pytv="pytest -v"
alias pyts="pytest -s"
alias black="black ."
alias mypy="mypy ."
alias pyspark="pyspark --conf spark.driver.memory=4g"
```

**Workflow tips:**
- Use `jupytext` to edit notebooks as plain Python files
- Use `pyright` for type checking (already configured)
- Use `black` for consistent formatting
- For Databricks work, consider databricks-cli

---

## Installation Priority Summary

**Immediate (This Week):**
1. fzf, bat, fd (file operations)
2. delta, lazygit (git workflow)
3. bottom, dust, duf, procs (system monitoring)

**Week 2-3:**
1. kubectx, kubens, stern, helm (Kubernetes)
2. lazydocker, dive, ctop (Docker)
3. tflint, awscli (Infrastructure)
4. argocd (GitOps)

**Week 4-5:**
1. httpie, jq, yq (API/data)
2. rest.nvim plugin
3. neotest plugin setup

**Week 6-7:**
1. project.nvim, auto-session plugins
2. git-worktree plugin
3. gh cli

**Week 8+:**
1. octo.nvim plugin
2. tldr, cheat
3. gping

---

## Quick Reference: Most Impactful Changes

**Top 5 Workflow Improvements:**
1. **fzf** - Fuzzy find everything (Ctrl+R for history, Ctrl+T for files)
2. **lazygit** - Visual git interface (available in Wezterm launch menu)
3. **kubectx/kubens** - Quick K8s context/namespace switching
4. **bat** - Better file viewing with syntax highlighting
5. **stern** - Multi-pod log tailing for Kubernetes debugging

**Top 5 Neovim Enhancements:**
1. **neotest** - Universal test runner
2. **rest.nvim** - HTTP client in editor
3. **auto-session** - Automatic session persistence
4. **project.nvim** - Quick project switching
5. **octo.nvim** - GitHub integration

---

## Notes

- All brew installations can be batched: `brew install <tool1> <tool2> <tool3>`
- Neovim plugins will auto-install on next nvim launch via Lazy.nvim
- ZSH aliases can be added incrementally to `.zshrc` as you learn each tool
- Focus on learning one phase at a time; don't rush to install everything at once
