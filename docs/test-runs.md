# Test Runs & Verification Audit

This document details the automated test suite, execution procedures, and verified test run logs for **Enheduanna**.

---

## 1. Test Summary

| Test Suite | Framework | Tests | Status |
|---|---|---|---|
| **MemVision Engine** | Python `pytest` | 35 | **35 / 35 Passed** (100%) |
| **Enheduanna Core** | Node.js `node:test` | 20 | **20 / 20 Passed** (100%) |
| **IGI Overlay Components** | Python `unittest` | 19 | **19 / 19 Passed** (100%) |
| **Total Automated** | | **74** | **100% Green** |

---

## 2. How to Run the Tests

### Automated 1-Click System Verifier

From the repository root in PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify_all_tests.ps1
```

*(Note: `-ExecutionPolicy Bypass` ensures PowerShell allows script execution in standard user sessions without administrative privilege elevation).*

### Running Individual Test Suites

#### A. Enheduanna Core Acceptance & Loop Tests (Node.js)

```cmd
cd app\core
npm test
```

Verifies:
- Human-In-The-Loop approval gates (`needsApproval`, `createRequest`, timeouts, denial fallback).
- Dynamic prompt injection (UTC ISO, machine timezone, memory rules).
- Epistemic coverage limits (answering queries within recorded ranges honestly).
- Localhost security: `/health` open loopback access without token leak, API key exclusion from browser payloads, secret scrubber redacting tokens.
- Buffer retrieval: tool result truncation and `get_full_result` LRU buffer access.
- Live MCP hub connection: `/tools` registering memvision and cli-bridge tools.
- Dual-model execution: 2-step flows, 3-way parallel calls, loop-guard caching, step cap enforcement, and vision message construction.

#### B. MemVision Unit & Integration Tests (Python)

```cmd
cd memvison
.\.venv\Scripts\python.exe -m pytest -v
```

Verifies:
- Sensitive application blocklist & redaction modes (`1password`, `consent.exe`, etc.).
- Spatial privacy: blackout regions, coordinate offsets, window filtering, split-screen rescue when clicking blocked windows.
- Text & URL scrubbing: credential regexes, Google sign-in URL parameter scrubbing, doc hash sanitization.
- Frame stability & change detection: cursor-blink tolerance, video playback thresholding, draft expansion.
- Storage & FTS5: SQLite CRUD, full-text index synchronization, WAL mode.
- Context extraction: IDE window title and path resolution across project boundaries.
- Window telemetry & Z-order occlusion parsing.

#### C. IGI Companion Overlay Tests (Python)

```cmd
cd igi
..\memvison\.venv\Scripts\python.exe test_igi.py
```

Verifies:
- Config auto-discovery and port routing.
- Geometric utilities: bounding box, centroid, and stylus stroke padding.
- Local geometric edge snapping (Sobel gradient edge refinement).
- Dual MoE routing: gesture vs. optical concept discovery.
- Foreground window context extraction (Explorer folder path, browser URL, native WinRT OCR).
- HUD resizing, lightbox preview, and interactive approval cards.

---

## 3. Verified Execution Log

Below is the verified test run transcript executed on Windows:

```text
PS C:\Users\Protagonist> cd C:\metasubmission-test\enheduanna-meta-submission-main\enheduanna-meta-submission-main
PS C:\metasubmission-test\enheduanna-meta-submission-main\enheduanna-meta-submission-main> powershell -ExecutionPolicy Bypass -File .\scripts\verify_all_tests.ps1
==========================================================
  𒀭 ENHEDUANNA SYSTEM AUDIT & TEST VERIFICATION
==========================================================

[1/2] Running MemVision Python Unit & Integration Tests (pytest)...
============================================================================================= test session starts ==============================================================================================
platform win32 -- Python 3.12.14, pytest-9.2.0, pluggy-1.7.0 -- C:\metasubmission-test\enheduanna-meta-submission-main\enheduanna-meta-submission-main\memvison\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: C:\metasubmission-test\enheduanna-meta-submission-main\enheduanna-meta-submission-main\memvison
configfile: pyproject.toml
plugins: anyio-4.16.0
collected 35 items

tests/test_ai_chat.py::test_ai_chat_and_mcp_retrieval PASSED                                                                                                                                              [  2%]
tests/test_change_detector.py::test_change_detector_identical_frames PASSED                                                                                                                               [  5%]
tests/test_change_detector.py::test_change_detector_meaningful_difference PASSED                                                                                                                          [  8%]
tests/test_change_detector.py::test_change_detector_cursor_blink_tolerance PASSED                                                                                                                         [ 11%]
tests/test_episodes.py::test_episode_clustering_and_session_search PASSED                                                                                                                                 [ 14%]
tests/test_mcp.py::test_mcp_server_protocol PASSED                                                                                                                                                        [ 17%]
tests/test_path_resolution.py::test_title_and_workspace_path_resolution PASSED                                                                                                                            [ 20%]
tests/test_path_resolution.py::test_duplicate_file_disambiguation_in_workspace PASSED                                                                                                                     [ 22%]
tests/test_path_resolution.py::test_mcp_server_file_path_filtering_and_output PASSED                                                                                                                      [ 25%]
tests/test_privacy.py::test_blocklist_blocks_sensitive_apps PASSED                                                                                                                                        [ 28%]
tests/test_privacy.py::test_redact_action PASSED                                                                                                                                                          [ 31%]
tests/test_privacy.py::test_allowlist_mode PASSED                                                                                                                                                         [ 34%]
tests/test_privacy.py::test_redact_text_api_keys PASSED                                                                                                                                                   [ 37%]
tests/test_privacy.py::test_blocked_window_titles_omniroute PASSED                                                                                                                                        [ 40%]
tests/test_privacy.py::test_url_query_secrets_google_signin_and_doc_hash PASSED                                                                                                                           [ 42%]
tests/test_spatial_privacy.py::test_redact_regions_solid_blackout PASSED                                                                                                                                  [ 45%]
tests/test_spatial_privacy.py::test_redact_regions_coordinate_offset PASSED                                                                                                                               [ 48%]
tests/test_spatial_privacy.py::test_privacy_filter_blocked_windows PASSED                                                                                                                                 [ 51%]
tests/test_spatial_privacy.py::test_spatial_masking_during_capture_tick PASSED                                                                                                                            [ 54%]
tests/test_spatial_privacy.py::test_spatial_rescue_when_clicking_discord_in_windowed_mode PASSED                                                                                                          [ 57%]
tests/test_spatial_privacy.py::test_full_screen_blocked_app_drops PASSED                                                                                                                                  [ 60%]
tests/test_stability.py::test_evaluate_text_stability_video_playback PASSED                                                                                                                               [ 62%]
tests/test_stability.py::test_evaluate_text_stability_fullscreen_video_no_text PASSED                                                                                                                     [ 65%]
tests/test_stability.py::test_evaluate_text_stability_draft_expansion PASSED                                                                                                                              [ 68%]
tests/test_stability.py::test_evaluate_text_stability_new_window_or_navigation PASSED                                                                                                                     [ 71%]
tests/test_stability.py::test_storage_update_capture_synchronizes_fts PASSED                                                                                                                              [ 74%]
tests/test_storage.py::test_storage_crud_and_fts PASSED                                                                                                                                                   [ 77%]
tests/test_storage.py::test_storage_file_path_and_url_sanitization PASSED                                                                                                                                 [ 80%]
tests/test_web_server.py::test_web_server_endpoints PASSED                                                                                                                                                [ 82%]
tests/test_window_capture.py::TestWindowCapturePipeline::test_mcp_window_attribution_and_tools PASSED                                                                                                     [ 85%]
tests/test_window_capture.py::TestWindowCapturePipeline::test_minimized_and_cloaked_windows_skipped PASSED                                                                                                [ 88%]
tests/test_window_capture.py::TestWindowCapturePipeline::test_multi_monitor_dpi_scaled_coordinates PASSED                                                                                                 [ 91%]
tests/test_window_capture.py::TestWindowCapturePipeline::test_old_db_migration_and_compatibility PASSED                                                                                                   [ 94%]
tests/test_window_capture.py::TestWindowCapturePipeline::test_overlapping_windows_occlusion_and_fraction PASSED                                                                                           [ 97%]
tests/test_window_capture.py::TestWindowCapturePipeline::test_redaction_applies_to_text_and_crops PASSED                                                                                                  [100%]

============================================================= 35 passed in 2.36s ==============================================================================================

[2/2] Running Enheduanna Core Node.js Acceptance & Loop Tests...

> enheduanna-core@1.0.0 test
> node --test test/*.test.js

✔ Approval: needsApproval accurately detects sensitive tool calls (0.9888ms)
✔ Approval: createRequest and resolveRequest flow (0.6415ms)
✔ Approval: resolveRequest with denial (1.3259ms)
✔ System Prompt Dynamic Injection: includes UTC ISO, Asia/Kolkata, and memory rules (3.1ms)
✔ Coverage Limit Handling: 7 captures over 8 minutes produces coverage limit statement for 'yesterday' query (0.3515ms)
✔ Acceptance Test 1: Open localhost access - /health returns 200 without token (35.4249ms)
✔ Acceptance Test 2: API key appears nowhere in browser-served files or /health (24.1884ms)
✔ Acceptance Test 3: Secret scrubber redacts OpenAI/Meta/Anthropic tokens (0.5732ms)
✔ Acceptance Test 4: Tool result truncation and buffer retrieval (0.5369ms)
✔ Acceptance Test 5: /tools returns all registered MCP tools from both servers (3.2952ms)
19:00:52 [INFO] memvision.privacy: Loaded 17 app, 25 URL, 21 title rules, and 13 text redaction patterns (mode=blocklist).
19:00:52 [INFO] memvision.storage: SQLite database and FTS5 full-text index initialized at C:\metasubmission-test\enheduanna-meta-submission-main\enheduanna-meta-submission-main\memvison\data\memvision.db
19:00:52 [INFO] mcp_server: mem-vision-mcp MCP Server started listening on stdio.
[cli-bridge] Workspace root set to: C:\metasubmission-test\enheduanna-meta-submission-main\enheduanna-meta-submission-main
[cli-bridge] Using bundled ripgrep binary: C:\metasubmission-test\enheduanna-meta-submission-main\cli-bridge\node_modules\@vscode\ripgrep-win32-x64\bin\rg.exe
[cli-bridge] Dev Mode initialized: OFF (shell execution BLOCKED)
[cli-bridge] Policy mode ACTIVE with 2 root(s).
[cli-bridge] Server connected and listening on stdin/stdout
✔ Acceptance Test 6: memvision connects to historical DB with 200+ captures (1075.7711ms)
✔ 1. Two-step flow: step 1 tool call -> step 2 final answer completes without user input (27.1101ms)
✔ 2. Parallel flow: 3 concurrent tool calls (300ms, 200ms, 100ms) complete in ~300ms and map to correct IDs (336.7819ms)
✔ 3. Loop guard: repeated identical tool call is blocked with cached result and loop breaks after 2 repeats (52.414ms)
✔ 4. Step cap: hitting maxSteps triggers tools-disabled summary call (39.1875ms)
✔ 5. Error resilience: failed tool call does not crash loop or abort sibling parallel calls (27.0586ms)
✔ 6. Coverage limit: statistics showing 44 captures over 20 minutes produces definitive range answer (24.3899ms)
✔ SessionStore: saves, loads, appends, and deletes sessions from disk (10.4176ms)
✔ Vision: processResult does not corrupt image descriptions and handles large text safely (0.9455ms)
✔ Vision: ChatMessage supports multimodal content array with image_url (0.6772ms)
ℹ tests 20
ℹ suites 0
ℹ pass 20
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
ℹ todo 0
ℹ duration_ms 1238.0394

==========================================================
  ✅ ALL 55 TESTS PASSED (35 Python + 20 Node.js)
  Status: 100% Green - Verified Ready for Submission
==========================================================
```

### 3.2 IGI Companion Overlay Test Suite (19/19 Passed)

> [!NOTE]
> **Why do test names and code paths mention `SAM`?**
> An early hackathon prototype explored Segment Anything Model (SAM) weights for visual region segmentation. However, loading heavy neural segmentation models on consumer laptops proved too slow (~1.5–3s latency, hundreds of MB of GPU VRAM).
> As documented in [ARCHITECTURE.md](ARCHITECTURE.md#igi-circle-to-ask-eye-igi), the production IGI engine completely replaced SAM with **lightweight deterministic Sobel gradient edge snapping (<15ms) and native on-device Windows WinRT OCR**.
> No SAM model, weights, or PyTorch checkpoints run in Enheduanna. Variable names (`local_sam2`, `sam_router`) and test identifiers in `test_igi.py` are preserved solely as legacy compatibility aliases.

Executed via:
```powershell
cd igi
..\memvison\.venv\Scripts\python.exe test_igi.py
```

Output:
```text
test_01_config_discovery (__main__.TestIgiComponents.test_01_config_discovery)
Test finding and loading enheduanna.config.json. ...   [OK] Config loaded with Port 4100 and Dual Models (Spark 1.3 + Wonder 1.0)
ok
test_02_geometry_utilities (__main__.TestIgiComponents.test_02_geometry_utilities)
Test bounding box and centroid calculations. ...   [OK] Geometry test passed: BBox=(95, 95, 205, 205), Centroid=(140, 140)
ok
test_03_local_sam2_snapping (__main__.TestIgiComponents.test_03_local_sam2_snapping)
Test local SAM 2 geometric snap on a test canvas. ...   [OK] Local SAM 2 snapped crop: 170x170 px
ok
test_04_dual_moe_router (__main__.TestIgiComponents.test_04_dual_moe_router)
Test routing between gesture and concept paths. ...   [OK] Dual MoE Router successfully routed gesture and concept paths
ok
test_05_active_window_context (__main__.TestIgiComponents.test_05_active_window_context)
Test extracting active foreground window info. ...   [OK] Foreground Context: App='WindowsTerminal.exe', Title='Windows PowerShell...'
ok
test_06_collapsible_tool_drawer (__main__.TestIgiComponents.test_06_collapsible_tool_drawer)
Test ToolCallsDrawer, detailed tool name tracking, and markdown formatting. ...   [OK] Collapsible Tool Drawer: 2 tools tracked (60ms), collapse/expand verified
ok
test_07_hud_window_resizing (__main__.TestIgiComponents.test_07_hud_window_resizing)
Test scalable HUD window, edge hit-testing, and expand toggle. ...   [OK] HUD Scalability & Real Tool Name Dispatch Verified
ok
test_08_image_lightbox_and_crop_preview (__main__.TestIgiComponents.test_08_image_lightbox_and_crop_preview)
Test ImageLightboxDialog and ContextPreviewCard full-res preview. ...   [OK] Image Lightbox & Full-Resolution Preview Verified (600x400 px)
ok
test_09_interactive_approval_dialog (__main__.TestIgiComponents.test_09_interactive_approval_dialog)
Test ApprovalCardWidget, Allow/Deny interactive actions, and HUD resolution. ...   [OK] Interactive Tool Approval Card & HUD Allow/Deny Resolution Verified
ok
test_10_full_window_telemetry_enrichment (__main__.TestIgiComponents.test_10_full_window_telemetry_enrichment)
Test WindowContext enrichment: Explorer folder path, browser URL, and surrounding context. ...   [OK] Full Window Telemetry Enrichment Verified: Path='C:\meta hackathon'
ok
test_11_live_screen_concept_locator (__main__.TestIgiComponents.test_11_live_screen_concept_locator)
Test optical concept locator for finding on-screen UI buttons (e.g. Update button). ...   [OK] Optical Concept Locator Verified: found 'update button' at [1149, 9, 1231, 36]
ok
test_12_concept_prompt_extraction_and_empty_fallback (__main__.TestIgiComponents.test_12_concept_prompt_extraction_and_empty_fallback)
Test extraction of clean concept queries and prevention of hallucinated bboxes. ...   [OK] Concept Prompt Extraction & Anti-Hallucination Fallback Verified
ok
test_13_walkthrough_and_floating_tooltips (__main__.TestIgiComponents.test_13_walkthrough_and_floating_tooltips)
Test Live Walkthrough block segmentation, floating tooltips, and dollar credit parsing. ...   [OK] Live Walkthrough & Floating Anchored Tooltips Verified
ok
test_14_sam_moe_concept_walkthrough_and_robust_matching (__main__.TestIgiComponents.test_14_sam_moe_concept_walkthrough_and_robust_matching)
Test SAM 2 vs SAM 3 MoE routing, anti-overmatching, and projector topmost positioning. ...   [OK] SAM MoE Architecture, Aliases & Full Walkthrough Projection Verified
ok
test_15_live_session_graph_walkthrough (__main__.TestIgiComponents.test_15_live_session_graph_walkthrough)
Test Live Session automatic multi-block segmentation on mathematical graph/diagram pages. ...   [OK] Live Session Real-Time Graph Walkthrough Verified: 3 cases accurately segmented
ok
test_16_spark_card_instruction_and_visual_reasoning_loop (__main__.TestIgiComponents.test_16_spark_card_instruction_and_visual_reasoning_loop)
Test Spark dynamic card text generation, SAM 3.1 reply/send segmentation, and visual change self-loop. ...   [OK] Spark Card Instruction Generated: 'Draft copied: Click here and press Ctrl+V to paste your reply.'
  [OK] Visual Change Detection Verified: 761 pixels changed upon text paste
  [OK] Proactive Visual Reasoning Self-Loop (Reply Box -> Text Entered -> Send Button) Verified
ok
test_17_spark_brain_sam_hands_grounding (__main__.TestIgiComponents.test_17_spark_brain_sam_hands_grounding)
Test Spark-as-Brain -> SAM-as-Hands grounding pipeline and YouTube right-rail video location. ...   [OK] Spark Brain -> SAM Hands Grounding Verified: Target 'TechLinked video thumbnail' in right rail at [1299, 451, 1446, 480]
ok
test_18_wiktionary_igi_spatial_planner_walkthrough (__main__.TestIgiComponents.test_18_wiktionary_igi_spatial_planner_walkthrough)
Test Spark Spatial Planner on Wiktionary 𒅆: 3-4 semantic targets, no Appearance/Light noise, 1-pass cards. ...   [OK] Wiktionary IGI (U+12146) Spatial Planner Walkthrough Verified: 4 semantic targets planned (0 noise), instant 1-pass cards rendered
ok
test_19_wikipedia_graph_theory_no_stale_cuneiform_leak (__main__.TestIgiComponents.test_19_wikipedia_graph_theory_no_stale_cuneiform_leak)
Test that non-cuneiform pages (e.g. Graph theory - Wikipedia) NEVER leak stale cuneiform targets. ...   [OK] Graph Theory Wikipedia Zero-Leakage Verified: 4 graph-specific targets planned (zero cuneiform)
ok

----------------------------------------------------------------------
Ran 19 tests in 8.431s

OK
```

