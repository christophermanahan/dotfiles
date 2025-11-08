# Paradiddle Video Showcase Plan

**Goal:** Create a compelling 3-5 minute video demonstrating Paradiddle's unique CLI-first IDE capabilities

**Target Audience:** Developers familiar with vim/Neovim who want better terminal integration

---

## Video Structure

### 1. Hook (0:00 - 0:15) - 15 seconds

**Opening Shot:** Terminal screen with title overlay
```
"What if CLI tools weren't separate apps,
but first-class citizens in your editor?"
```

**Voiceover:**
> "Most IDEs treat terminals as an afterthought. Paradiddle makes them the foundation."

**Visual:** Quick montage of terminals appearing/disappearing with single keystrokes (ALT+k, ALT+j, ALT+h) - rapid, rhythmic cuts

---

### 2. The Problem (0:15 - 0:45) - 30 seconds

**Split Screen Comparison:**

**Left: "Traditional Workflow"**
- Show VSCode/traditional IDE
- Opening terminal panel
- Clicking through menus
- Switching to external app
- Copy/paste between windows
- Visual clutter, slow transitions

**Right: "Paradiddle"**
- Single keystroke (ALT+j)
- k9s appears instantly
- Cluster selection
- ALT+p to dismiss
- Clean, fast, focused

**Voiceover:**
> "Traditional IDEs force you to context switch. Click. Navigate. Wait. Paradiddle? One keystroke. Ten CLI tools. Zero friction."

---

### 3. Core Concept (0:45 - 1:15) - 30 seconds

**Title Card:** "10 Integrated Floating Terminals"

**Visual:** Show terminal grid overlay with all keybindings
```
ALT+k: Claude Code    ALT+o: Codex         ALT+1: AWS ECS
ALT+i: Tmux           ALT+d: Lazydocker    ALT+2: AWS EC2
ALT+j: k9s            ALT+e: w3m
ALT+h: Lazygit        ALT+c: Carbonyl
```

**Animation:** Cascade all terminals appearing with offset positions (0.02 to 0.12)

**Voiceover:**
> "Paradiddle integrates ten CLI tools as floating terminals. Each one keystroke away. Each with intelligent defaults. Each positioned to prevent disorientation."

**On-screen Text:** "Cascading windows. Visual clarity."

---

### 4. Key Feature Demos (1:15 - 3:30) - 2 minutes 15 seconds

#### Demo 1: Kubernetes Workflow (30 seconds)

**Scenario:** Check pod status, view logs, commit changes

**Actions:**
1. Working in code editor
2. `ALT+j` - k9s launches
3. fzf menu: select cluster "production"
4. fzf menu: select namespace "api"
5. k9s shows pods, navigate to failing pod
6. View logs in k9s
7. `ALT+j` - k9s disappears
8. Fix code
9. `ALT+h` - Lazygit appears
10. Stage changes, commit
11. `ALT+h` - Lazygit disappears

**Voiceover:**
> "Real workflow: Check Kubernetes pods. ALT+j. Select cluster. Select namespace. See the issue. Fix it. ALT+h. Commit. Done. No window management. No context loss."

#### Demo 2: AWS Infrastructure (30 seconds)

**Scenario:** Debug EC2 instance, check ECS service

**Actions:**
1. `ALT+2` - e2s launches
2. Select AWS profile from fzf
3. Select region
4. Browse EC2 instances
5. Select instance, view details
6. Copy instance ID (shown in clipboard)
7. `ALT+p` - e2s disappears
8. `ALT+1` - e1s launches
9. Select profile/region
10. View ECS services
11. Paste instance ID into code

**Voiceover:**
> "AWS work: Browse EC2 instances. Copy details. Check ECS services. All without leaving your editor. All with intelligent profile selection."

#### Demo 3: AI-Assisted Development (30 seconds)

**Scenario:** Use Claude Code and Codex together

**Actions:**
1. Writing authentication code
2. `ALT+k` - Claude Code appears
3. Ask: "Help refactor this auth handler"
4. Claude provides suggestions
5. `ALT+k` - hide Claude
6. Make changes
7. `ALT+o` - Codex appears
8. Ask: "Generate tests for this handler"
9. Codex generates test code
10. Copy test code
11. `ALT+p` - dismiss

**Voiceover:**
> "AI assistance: Claude for architecture. Codex for tests. Switch instantly. No copy-paste between browser tabs. Everything in your flow."

#### Demo 4: Documentation & Research (30 seconds)

**Scenario:** Look up API docs, search Stack Overflow

**Actions:**
1. Writing API integration code
2. `ALT+e` - w3m appears with DuckDuckGo
3. `ALT+s` - search prompt appears
4. Type: "stripe api webhooks"
5. Navigate docs with vim keys (j/k)
6. Find webhook signature verification code
7. Yank code snippet
8. `ALT+e` - w3m disappears
9. Paste into editor (clipboard integration)
10. Code works

**Voiceover:**
> "Research without breaking flow. w3m with vim keys. Yank from browser. Paste in editor. System clipboard integration. Seamless."

#### Demo 5: The Rhythm (15 seconds)

**Visual:** Fast-paced montage showing rapid switching
- `ALT+k` (Claude) → ask question → `ALT+k`
- `ALT+j` (k9s) → check pods → `ALT+j`
- `ALT+h` (Lazygit) → commit → `ALT+h`
- Edit code
- Repeat

**Voiceover:**
> "This is the paradiddle. The rhythm. The flow. Muscle memory. One keystroke. Ten tools. Zero friction."

**Music:** Subtle drum beat pattern (actual paradiddle: RLRR LRLL)

---

### 5. Unique Differentiators (3:30 - 4:00) - 30 seconds

**Title Cards with Quick Visuals:**

1. **"Intelligent Auto-Start"**
   - Show k9s launching with cluster selection
   - Show e1s prompting for AWS profile
   - Text: "Tools configure themselves"

2. **"Cascading Windows"**
   - Show all 10 terminals open at once
   - Highlight different offsets (0.02 to 0.12)
   - Text: "Never lose orientation"

3. **"Zero Cleanup"**
   - Show tmux session auto-cleanup on exit
   - Show `ALT+p` killing terminal and resetting state
   - Text: "No orphaned processes"

4. **"Built on NvChad"**
   - Show LSP features, completion, formatting
   - Text: "All the power, plus CLI integration"

**Voiceover:**
> "Paradiddle isn't just keybindings. It's intelligent defaults. Visual clarity. Automatic cleanup. Built on NvChad, extended with CLI-first philosophy."

---

### 6. Call to Action (4:00 - 4:30) - 30 seconds

**Title Card:** "Paradiddle - CLI-First IDE"

**On Screen:**
```
github.com/christophermanahan/paradiddle

✓ 10 Integrated Terminals
✓ Intelligent Auto-Start
✓ macOS Clipboard Integration
✓ Built on NvChad v2.5

Installation: 3 commands
brew install ...
stow nvim
nvim
```

**Voiceover:**
> "Paradiddle. A CLI-first IDE where terminal tools are first-class citizens. Open source. MIT licensed. Install in minutes. Master in days. Flow forever."

**Final Visual:** Terminal screen showing all 10 tools in rapid succession, ending on clean editor view

**Text Overlay:** "Build your rhythm. github.com/christophermanahan/paradiddle"

---

## Production Specifications

### Recording Setup

**Tools:**
- **Screen Recording:** OBS Studio or ScreenFlow (60fps, 1080p minimum)
- **Terminal:** Wezterm (configured in repo)
- **Theme:** Catppuccin Mocha (as configured)
- **Font:** Hack Nerd Font (clear at any resolution)

**Settings:**
- Resolution: 1920x1080 or 2560x1440
- Frame Rate: 60fps (for smooth terminal animations)
- Bitrate: 8000+ kbps
- Window Size: 85% of screen (consistent with terminal offsets)

### Recording Environment

**Terminal Configuration:**
```lua
-- Increase font size for recording
font_size = 16  -- Up from default 12

-- Ensure clear colors
color_scheme = "Catppuccin Mocha"

-- Disable cursor blink for recording
cursor_blink = false
```

**Neovim Configuration:**
- Disable status updates that might distract
- Pre-load all plugins to avoid loading delays
- Use fast network for any API calls (Claude, Codex)

### Editing

**Software:** DaVinci Resolve (free) or Adobe Premiere Pro

**Timeline Structure:**
```
Track 1: Primary Screen Recording
Track 2: Voiceover/Narration
Track 3: Music (subtle drum patterns)
Track 4: Text Overlays
Track 5: Transition Effects
```

**Transitions:**
- Fast cuts between demos (no crossfades - keeps energy high)
- 0.5 second hold on text overlays
- Zoom in on relevant terminal areas when needed

**Effects:**
- Highlight cursor with subtle glow during key moments
- Slow motion (50% speed) during rapid switching montage
- Speed up (200%) during long waits (if any)

**Color Grading:**
- Match Catppuccin Mocha colors
- Ensure terminal text is readable
- Consistent brightness across clips

### Audio

**Voiceover:**
- Record in quiet room with USB microphone (Blue Yeti or similar)
- Sample Rate: 48kHz
- Bit Depth: 24-bit
- Format: WAV (uncompressed)

**Background Music:**
- Subtle electronic/lo-fi beats
- Incorporate actual drum paradiddle pattern (RLRR LRLL)
- Volume: -20dB to -15dB (background, not foreground)
- No copyright music (use royalty-free: Epidemic Sound, Artlist)

**Sound Effects:**
- Subtle "whoosh" on terminal appear/disappear
- Quiet "click" on keystrokes (not every keystroke, just featured ones)
- Keep minimal - let the visuals speak

---

## Script

### Full Narration Script

**[0:00 - Hook]**
> "Most IDEs treat terminals as an afterthought. Paradiddle makes them the foundation. What if CLI tools weren't separate apps, but first-class citizens in your editor?"

**[0:15 - Problem]**
> "Traditional IDEs force you to context switch. Click through menus. Navigate panels. Wait for apps to load. Paradiddle? One keystroke. Ten CLI tools. Zero friction."

**[0:45 - Concept]**
> "Paradiddle integrates ten CLI tools as floating terminals. Each one keystroke away. Each with intelligent defaults. Each positioned with cascading windows for visual clarity."

**[1:15 - Demo 1: Kubernetes]**
> "Real workflow: You're debugging production. ALT+j launches k9s. Select your cluster. Select your namespace. See the failing pod. Check the logs. Find the issue. ALT+j to dismiss. Fix the code. ALT+h for lazygit. Stage, commit, done. No window management. No context loss. Pure flow."

**[1:45 - Demo 2: AWS]**
> "AWS infrastructure work. ALT+2 launches e2s. Select your profile. Select your region. Browse EC2 instances interactively. Copy instance details. ALT+1 for e1s. Check ECS services. Paste that instance ID right into your code. All without leaving your editor. All with intelligent profile selection."

**[2:15 - Demo 3: AI Development]**
> "AI-assisted development. ALT+k for Claude Code. Ask for refactoring help. Get architectural guidance. ALT+o for Codex. Generate tests. Generate boilerplate. Switch between AI assistants instantly. No browser tabs. No copy-paste. Everything in your flow."

**[2:45 - Demo 4: Documentation]**
> "Research without breaking flow. ALT+e launches w3m with vim keys. ALT+s to search. Find API documentation. Navigate with hjkl. Yank code snippets. Paste directly in your editor. System clipboard integration makes it seamless."

**[3:15 - The Rhythm]**
> "This is the paradiddle. The rhythm. The flow. Claude for guidance. k9s for infrastructure. Lazygit for version control. Back to code. The pattern repeats. Muscle memory takes over. One keystroke. Ten tools. This is development at the speed of thought."

**[3:30 - Differentiators]**
> "Paradiddle isn't just keybindings. k9s auto-configures with cluster selection. e1s prompts for your AWS profile. Cascading windows prevent disorientation. Tmux sessions auto-cleanup. No orphaned processes. And it's built on NvChad - you get LSP, completion, formatting, everything. All the power of a modern IDE, plus CLI-first integration."

**[4:00 - Call to Action]**
> "Paradiddle. A CLI-first IDE where terminal tools are first-class citizens. Ten integrated terminals. Intelligent auto-start. macOS clipboard integration. Built on NvChad two-point-five. Open source. MIT licensed. Install in minutes with three commands. Master in days through muscle memory. Flow forever. Build your rhythm. The link is in the description."

---

## Demo Preparation Checklist

### Before Recording

**Environment Setup:**
- [ ] Clean terminal history (`history -c`)
- [ ] Clear all terminal sessions (`ALT+p` on each)
- [ ] Reset global flags in Neovim
- [ ] Close all open buffers
- [ ] Set working directory to demo project

**Demo Project Setup:**
- [ ] Create clean demo project with realistic code
- [ ] Pre-configure AWS profiles for quick demo
- [ ] Pre-configure kubectl contexts for k9s demo
- [ ] Ensure git repo is clean with changes ready to commit
- [ ] Have test failures ready to show debugging workflow

**Tool Configuration:**
- [ ] Verify Claude Code API key is active
- [ ] Verify Codex API key is active
- [ ] Verify AWS credentials are valid
- [ ] Verify kubectl can reach demo cluster
- [ ] Test all 10 terminal integrations
- [ ] Verify clipboard integration works

**Recording Environment:**
- [ ] Close notification apps (Slack, email, etc.)
- [ ] Enable Do Not Disturb mode
- [ ] Disable screen saver
- [ ] Set fixed screen resolution
- [ ] Test microphone levels
- [ ] Clear desktop clutter (if showing desktop)

### Practice Runs

**Run Through Each Demo 3 Times:**
1. **First run:** Script check, identify issues
2. **Second run:** Smooth out timing
3. **Third run:** Final rehearsal, ready to record

**Common Issues to Watch:**
- API call latency (Claude, Codex)
- Network delays (AWS, k9s)
- Typing speed (too fast = hard to follow)
- Terminal responsiveness (ensure 60fps)

---

## Recording Day Workflow

### Session Structure

**Session 1: Setup & Hook (30 minutes)**
- Record title card
- Record hook with multiple takes
- Record problem comparison
- Select best take

**Session 2: Concept & Demos (60 minutes)**
- Record core concept explanation
- Record Demo 1 (Kubernetes)
- Record Demo 2 (AWS)
- Break (5 minutes)
- Record Demo 3 (AI)
- Record Demo 4 (Documentation)
- Record Demo 5 (Rhythm montage)

**Session 3: Differentiators & CTA (30 minutes)**
- Record unique features section
- Record call to action
- Record B-roll (extra shots for editing)

**Session 4: Voiceover (45 minutes)**
- Record narration script start to finish
- Record alternate takes for variety
- Record pickup lines for any issues

### File Organization

```
paradiddle-video/
├── raw/
│   ├── 01-hook/
│   ├── 02-problem/
│   ├── 03-concept/
│   ├── 04-demo-k8s/
│   ├── 05-demo-aws/
│   ├── 06-demo-ai/
│   ├── 07-demo-docs/
│   ├── 08-rhythm/
│   ├── 09-differentiators/
│   └── 10-cta/
├── audio/
│   ├── voiceover.wav
│   ├── music.wav
│   └── sfx/
├── assets/
│   ├── title-cards/
│   └── overlays/
└── edit/
    └── paradiddle-showcase-v1.prproj
```

---

## Post-Production Checklist

### Editing Phase

- [ ] Import all clips into editing software
- [ ] Sync voiceover with video
- [ ] Add background music
- [ ] Add text overlays
- [ ] Add transitions
- [ ] Color grade for consistency
- [ ] Add sound effects (subtle)
- [ ] Review pacing (aim for 3-5 minutes)

### Review Phase

- [ ] Watch full video 3 times
- [ ] Check audio levels (voiceover clear, music background)
- [ ] Verify text is readable at 1080p
- [ ] Test on different devices (laptop, phone)
- [ ] Get feedback from 2-3 developers
- [ ] Make revision notes

### Export Settings

**Primary Export (YouTube):**
- Format: MP4 (H.264)
- Resolution: 1920x1080
- Frame Rate: 60fps
- Bitrate: 8000 kbps (VBR, 2-pass)
- Audio: AAC, 192 kbps, 48kHz

**Secondary Export (Twitter/X):**
- Format: MP4 (H.264)
- Resolution: 1280x720
- Frame Rate: 30fps
- Bitrate: 5000 kbps
- Max Duration: 2:20 (Twitter limit)

**Thumbnail:**
- Resolution: 1280x720
- Format: PNG or JPG
- Text: "Paradiddle - CLI-First IDE"
- Visual: Clean terminal with floating windows

---

## Distribution Strategy

### YouTube

**Title:** "Paradiddle: A CLI-First IDE Where Terminals Are First-Class Citizens"

**Description:**
```
Paradiddle is a CLI-first development environment that integrates 10 terminal tools as floating windows in Neovim. One keystroke, zero friction.

🥁 What is Paradiddle?
A drumming rudiment (RLRR LRLL) that represents rhythm and flow - exactly how development should feel.

⚡ Key Features:
• 10 integrated floating terminals (ALT+k/i/j/h/o/d/e/c/1/2)
• Intelligent auto-start with smart defaults
• Cascading window positions for visual clarity
• Built on NvChad v2.5
• macOS clipboard integration

🔧 Integrated Tools:
• Claude Code (ALT+k) - AI pair programming
• k9s (ALT+j) - Kubernetes management
• Lazygit (ALT+h) - Git TUI
• AWS tools (ALT+1/2) - ECS & EC2 browsers
• And 5 more...

📦 Installation:
brew install [dependencies]
git clone github.com/christophermanahan/paradiddle
stow nvim

🔗 Links:
• GitHub: https://github.com/christophermanahan/paradiddle
• Documentation: [README link]
• Issues: [Issues link]

⏱️ Timestamps:
0:00 - Hook
0:15 - The Problem
0:45 - Core Concept
1:15 - Kubernetes Workflow
1:45 - AWS Infrastructure
2:15 - AI-Assisted Development
2:45 - Documentation & Research
3:15 - The Rhythm
3:30 - Unique Differentiators
4:00 - Installation & CTA

#neovim #nvchad #cli #terminal #ide #productivity #development
```

**Tags:**
neovim, nvchad, vim, cli, terminal, ide, productivity, development, kubernetes, aws, git, linux, macos, developer tools

### Social Media

**Twitter/X Thread:**
```
1/ Ever feel like your IDE fights you instead of helping you?

I built Paradiddle - a CLI-first IDE where terminal tools are first-class citizens.

10 tools. 1 keystroke each. Zero friction.

Watch the demo 👇
[video]

2/ What makes Paradiddle different?

Most IDEs treat terminals as an afterthought.
Paradiddle makes them the foundation.

ALT+k: Claude Code
ALT+j: k9s
ALT+h: Lazygit
And 7 more...

3/ The name comes from drumming.

A paradiddle (RLRR LRLL) is a fundamental rhythm pattern.

Just like drummers build muscle memory with rudiments, developers achieve flow through integrated CLI tools.

4/ Built on NvChad v2.5.
Open source (MIT).
Install in 3 commands.

Want to try it?
github.com/christophermanahan/paradiddle

[end thread]
```

**Reddit Posts:**

**r/neovim:**
> **Paradiddle: A CLI-first IDE with 10 integrated floating terminals**
>
> I've been frustrated with how traditional IDEs handle terminal integration - they're always an afterthought. So I built Paradiddle, a development environment where CLI tools are first-class citizens.
>
> **Key features:**
> - 10 tools accessible via ALT+key (k9s, Lazygit, Claude Code, AWS tools, etc.)
> - Intelligent auto-start (k9s prompts for cluster, e1s for AWS profile)
> - Cascading window positions (0.02 to 0.12 offset for visual clarity)
> - Built on NvChad v2.5
> - macOS clipboard integration
>
> **Demo video:** [link]
> **GitHub:** github.com/christophermanahan/paradiddle
>
> Would love feedback from the Neovim community!

**r/devops:**
> **Demo: Managing Kubernetes + AWS from inside Neovim**
>
> Made a video showing how I integrated k9s, e1s (ECS), and e2s (EC2) directly into Neovim as floating terminals. One keystroke to launch, intelligent defaults for cluster/profile selection.
>
> The project is called Paradiddle (a drumming term representing rhythm and flow). It's changed how I work with infrastructure.
>
> [video link]

**Hacker News:**
> **Paradiddle: A CLI-First IDE Where Terminals Are First-Class Citizens**
>
> I built a development environment on top of NvChad that integrates 10 CLI tools as floating terminals. Each tool is one keystroke away (ALT+k/i/j/etc.) with intelligent auto-start behavior.
>
> The name "Paradiddle" comes from drumming - it's a fundamental rhythm pattern. The metaphor fits: like drummers build muscle memory with rudiments, developers achieve flow through well-integrated tools.
>
> Demo video and code: github.com/christophermanahan/paradiddle

---

## Success Metrics

### Quantitative

**YouTube:**
- Target: 1,000 views in first month
- Target: 50+ likes
- Target: 20+ comments
- Watch time: 60%+ average

**GitHub:**
- Target: 100+ stars in first month
- Target: 10+ forks
- Target: 5+ issues/discussions

### Qualitative

**Positive Indicators:**
- Comments saying "this changed my workflow"
- Questions about specific features (shows engagement)
- Requests for similar integrations
- Other developers forking and customizing

**Feedback to Address:**
- Confusion about any feature → update docs
- Questions about installation → create installation video
- Requests for Windows/Linux support → roadmap item

---

## Future Video Ideas

### Follow-up Videos

1. **"Setting Up Paradiddle from Scratch"** (10 minutes)
   - Complete installation walkthrough
   - Dependency explanation
   - Configuration customization

2. **"Adding Your Own CLI Tool"** (5 minutes)
   - Show how to add a new tool (e.g., htop, lazydocker)
   - Explain keybinding selection
   - Configure auto-start behavior

3. **"Advanced Workflows"** (7 minutes)
   - Multi-tool sequences
   - Custom scripts
   - Integration with external tools

4. **"Behind the Scenes"** (8 minutes)
   - How terminal integration works
   - Lua configuration deep dive
   - NvChad architecture

---

## Budget Estimate

**Equipment (if needed):**
- USB Microphone (Blue Yeti): $130
- Pop filter: $15
- Acoustic panels (2): $40
- **Total equipment:** ~$185

**Software (free alternatives available):**
- OBS Studio: Free
- DaVinci Resolve: Free
- Audacity: Free
- **Total software:** $0 (using free options)

**Time Investment:**
- Planning: 4 hours
- Script writing: 3 hours
- Demo preparation: 4 hours
- Recording: 3 hours
- Editing: 6 hours
- Review & revisions: 2 hours
- **Total time:** ~22 hours

**Optional:**
- Royalty-free music license: $15-30/month (Epidemic Sound)
- Professional voice actor: $100-300 (if not self-recording)

---

## Timeline

**Week 1: Pre-Production**
- Day 1-2: Finalize script
- Day 3-4: Set up demo environment
- Day 5: Practice demos
- Day 6-7: Test recording setup

**Week 2: Production**
- Day 1: Record all video segments
- Day 2: Record voiceover
- Day 3: Review footage
- Day 4-5: Video editing
- Day 6: Audio editing & mixing
- Day 7: Final review

**Week 3: Post-Production & Launch**
- Day 1-2: Color grading & final touches
- Day 3: Create thumbnail & description
- Day 4: Export & upload to YouTube
- Day 5: Post to social media
- Day 6-7: Monitor & engage with comments

---

## Notes & Tips

**Recording Tips:**
- Record in 5-minute segments max (easier to edit)
- Always slate your takes ("Demo 1, Take 3")
- Record room tone for 30 seconds (for audio editing)
- Keep water nearby (for voiceover sessions)

**Editing Tips:**
- Cut ruthlessly - remove any dead space
- Use J/L cuts for smooth transitions
- Add subtle motion to static shots (slow zoom)
- Export a draft early - watch on different devices

**Common Mistakes to Avoid:**
- Talking too fast (speak slower than natural)
- Showing too much too quickly (give viewer time to absorb)
- Over-explaining (show don't tell)
- Forgetting CTAs (tell viewers what to do next)

**What Makes a Great Demo:**
- Real workflows, not toy examples
- Clear problem → solution structure
- Visible enthusiasm for the tool
- Relatable pain points
- Satisfying "wow" moments
