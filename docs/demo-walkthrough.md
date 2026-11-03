# Demo Walkthrough Scenario

> **Meta Global AI Developer Hackathon 2026** — *Indie Developer Track: Build for Your World*  
> **Repository:** [`anshupriyan/enheduanna-meta-submission`](https://github.com/anshupriyan/enheduanna-meta-submission)  
> **Target System:** Enheduanna (MemVision + IGI + cli-bridge)

---

## 1. Executive Summary

This document describes the end-to-end scenario featured in the Enheduanna demonstration. It follows a developer working across fragmented desktop applications, taking a break, and returning to resume their work seamlessly with Enheduanna.

---

## 2. Pre-Break Activity: The 40-Minute Scattered Session

Before taking a break, the developer spends ~40 minutes actively multitasking across several applications (recorded locally across **231 captures** by MemVision):

| Surface / App | What the User Was Doing |
|---|---|
| **LeetCode (Browser)** | Practicing algorithmic problem solving and debugging solution test cases. |
| **Wikipedia (Browser)** | Reading deep historical background on ancient Mesopotamia, Sumer, and Enheduanna of Ur. |
| **Assignment PDF (Browser / Viewer)** | Working through a course assignment document with specific problem requirements. |
| **YouTube (Browser)** | Watching an OBS Studio tutorial on setup and recording configurations. |

During this session, MemVision captures screen states locally, runs local WinRT OCR, and indexes text into SQLite FTS5. Sensitive applications remain masked before OCR processing.

---

## 3. The Break: Context Decays, Memory Persists

The developer steps away from the desk:
- Active tabs sit idle or get buried behind full-screen applications.
- Working memory decays.
- In traditional setups, returning requires re-reading open tabs, re-searching browser history, hunting for the right editor tab, and manually reconstructing what was left unfinished.


