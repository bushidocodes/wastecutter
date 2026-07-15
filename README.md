# WasteCutter: The COBOL Bureaucracy slayer

You are a heroic (or villainous) waste slayer in the swamp of government spending. Cut waste, manage approval, dodge scandals, outmaneuver factions, and try not to trigger an angry mob.

## How to Play

Build with Make:
```bash
make
./wastecutter
```

Or compile directly with GNUCobol:
```bash
cobc -x -o wastecutter hello.cbl
./wastecutter
```

On Windows (WSL or native GNUCobol):
```powershell
make
.\wastecutter.exe
```

Full-screen TUI. Choices matter. Approval is everything. Zero approval? Game over with style.

### Goal

- **Win:** cut **$1B+** with **approval ≥ 50%** (extra endings for technocrats, chainsaw legends, and fragile mandates).
- **Die:** approval hits **0** — mob ending.
- **12 turns**, with a mid-run **Term 2 crisis** when the clock hits 6.

### Actions

| # | Action | Notes |
|---|--------|--------|
| 1 | **Investigate** | Small verified cut, +approval, **arms** bold cuts on this target |
| 2 | **Bold cuts** | Big money; safer and larger if investigated; RNG risk/reward |
| 3 | **Rally** | Approval + modest cuts |
| 4 | **Media leak** | Narrative swing or blowback |
| 5 | **Relocate** | **Free** (no turn cost) — new department, dossier, and waste target |
| 6 | **Resign** | Leave the swamp |

### Systems

- **Locations matter:** Oval Office, Pentagon, Congress, EPA — each changes cut power, scandal pain, rally/media effectiveness, and faction heat.
- **Waste targets:** named pork projects (bridges to nowhere, synergy workshops, …) with dollar bases.
- **Dual feed:** `RESULT` (what you did) stays separate from `NEWS` (scandals, NPCs, crises).
- **Factions:** media favor, union heat, green heat, donors — scandals get likelier as heat rises.
- **Advisors:** hallway interventions with 2-option choices.
- **NPCs:** department bosses reappear in the news if you keep cutting their turf.
- **Reputation titles:** evolve from Fresh Appointee → Chainsaw Czar / Audit Nerd / …
- **Progress bar** toward $1B and approval bands `HIGH` / `WATCH` / `DANGER`.
- **High scores** appended to `scores.dat` when the run ends.

### Endings

- Hero of the People, Quiet Technocrat, Chainsaw Legacy, Narrow Win, Solid Effort, Mission Incomplete, Resigned, Mob Game Over.

## Install GNUCobol + Make (Cheeky Edition)

### macOS (The "It Just Works" Lie)
1. Install Homebrew if you haven't (the only sane package manager):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
2. Then:
   ```bash
   brew install gnucobol make
   ```
   Now you're fancy. Go cut some pork.

### Linux (Ubuntu/Debian - The Adult Choice)
```bash
sudo apt update
sudo apt install gnucobol make
```
   Done. You're now a real developer. Unlike those Windows peasants.

### Windows (The Suffering Path)
**Option 1 (Recommended):** Install WSL2 + Ubuntu (Microsoft finally did one thing right).
1. Enable WSL in PowerShell (admin):
   ```powershell
   wsl --install
   ```
2. Reboot, then in Ubuntu terminal:
   ```bash
   sudo apt update && sudo apt install gnucobol make
   ```

**Option 2 (Vanilla Windows - Slightly Less Painful):**
- GNUCobol: Download the SuperBOL bundle from https://superbol.eu/developers/windows/
- Make: `winget install GnuWin32.Make`

**Option 3:** Just install Linux. Seriously.

## Why?
Because nothing says "cutting government waste" like writing a full TUI game in 2026 COBOL. Enjoy the irony. Now go make some cuts (and try not to get canceled).

Made with love, spite, and too much free time. Contributions welcome (but keep the jokes tasteful... or don't).
