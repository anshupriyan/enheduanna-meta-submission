# Demo Walkthrough Scenario

> **Meta Global AI Developer Hackathon 2026** — *Indie Developer Track: Build for Your World*  
> **Repository:** [`anshupriyan/enheduanna-meta-submission`](https://github.com/anshupriyan/enheduanna-meta-submission)  
> **Target System:** Enheduanna (MemVision + IGI + cli-bridge)

---

## 1. Executive Summary

This document describes the end-to-end scenario featured in the Enheduanna demonstration. It follows a developer working across fragmented desktop applications, taking a break, and returning to resume their work seamlessly with Enheduanna.

---

## 2. Pre-Break Activity: The 40-Minute Scattered Session

Before taking a break, the developer spends ~40 minutes actively multitasking across five desktop surfaces (recorded locally across **231 captures** by MemVision):

| Surface / App | Activity Description | Local Capture Footprint |
|---|---|---|
| **LeetCode (Browser)** | Practicing algorithmic problem solving and debugging solution test cases. | Captured page titles, problem prompt, and editor code snippets. |
| **Wikipedia (Browser)** | Reading deep historical background on ancient Mesopotamia, Sumer, and the world's first named poet, Enheduanna of Ur. | Captured specific article headings, timeline charts, and paragraph text. |
| **Assignment PDF (Browser / Viewer)** | Working through a university / course assignment document with specific problem requirements. | Captured assignment title, problem prompt, and current page. |
| **YouTube (Browser)** | Watching an OBS Studio tutorial on setup and recording configurations. | Captured video player title, channel, and UI controls. |
| **VS Code (Full Screen)** | Editing a working draft notes file (`.md`) without explicitly saving a memorable path or naming it to any external tool. | Captured editor window content, active buffers, and terminal panels. |

During this session, MemVision captures screen states locally, runs local WinRT OCR, and indexes text into SQLite FTS5. Sensitive applications remain masked before OCR processing.

---

## 3. The Break: Context Decays, Memory Persists

The developer steps away from the desk:
- Active tabs sit idle or get buried behind full-screen applications.
- Working memory decays.
- In traditional setups, returning requires re-reading open tabs, re-searching browser history, hunting for the right editor tab, and manually reconstructing what was left unfinished.

---

## 4. Post-Break Recovery: How Enheduanna Helps

When the developer returns to the workstation, Enheduanna seamlessly restores their entire workflow without the user having to supply any URLs, filenames, or background context:

- **Rebuilding Context from Memory**: Enheduanna analyzes the last 40 minutes of desktop activity across the 231 background captures, reconstructing exactly what the user was working on before stepping away.
- **Restoring Active Workspaces & Deep Pages**: She automatically reopens the exact destinations where the user left off—relaunching the LeetCode question, reopening the Wikipedia article on Sumer at the exact section previously read, and bringing back the assignment PDF.
- **Locating and Modifying the Unnamed File**: Even though VS Code was running full-screen and the user never provided a file path or formal document name, Enheduanna identifies the draft markdown file from screen memory and applies the requested edits.
- **Clarifying Visuals with Igi**: When the developer needs an explanation of a complex Sumerian timeline chart on screen, they press `Ctrl+Shift+Q` and circle the diagram; Igi snaps to the chart boundaries and provides a direct visual explanation of that specific region.
- **Governed Action with Explicit Permission**: Before modifying files or running commands on disk, Enheduanna pauses and prompts for user authorization with a 120-second auto-denying approval card, ensuring no changes occur without consent.
