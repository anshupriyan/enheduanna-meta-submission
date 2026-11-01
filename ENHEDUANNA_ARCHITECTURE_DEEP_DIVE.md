# ENHEDUANNA — Deep Architecture & Implementation Dossier

> Generated: 2026-11-01 by Enheduanna self-inspection
> Source: C:\meta hackathon\enheduanna-submission + sibling cli-bridge
> Purpose: Exhaustive technical reference for README polishing / judging.
> Note: Downloads folder write was denied by user, so saved here instead. Copy to Downloads manually.

## 0. TL;DR

Enheduanna (Sumerian priestess of Ur, c.2300 BCE, first signed author) is a local-first autonomous desktop intelligence for Meta Global AI Hackathon 2026 (Oct 26-29).

Thesis: "Ask about anything you saw, then act on it."

Three faculties over MCP 2.0 JSON-RPC stdio, orchestrated by TypeScript ReAct core talking to Meta Model API Muse Spark 1.3 (tool agent) + Muse Wonder 1.0 (synthesis):

- Scribe memvison/ (Python): continuous screen memory capture, WinRT OCR, privacy gate, SQLite FTS5, MCP tools + web dashboard
- Operator ../cli-bridge (Node/TS, external prior work, meta-hackathon branch): sandboxed filesystem + policy-gated shell + journals + audit
- Eye igi/ (Python+PySide6): Circle-to-Search, HUD, Sobel+WinRT OCR grounding, projector halos
- Core app/core/ (TS ES2022): MCP multiplexer, dual-model ReAct, SSE trace, sessions, HTTP server
- Dashboard app/dashboard/ (vanilla JS/CSS): chat + trace + galleries + lightbox + settings

Ports: 127.0.0.1:4100 Core+Dashboard, 127.0.0.1:8765 MemVision monitor.

Disclosure: cli-bridge is pre-existing OSS github.com/anshupriyan/cli-bridge. Everything else built Oct 26-29 from scratch.

## 1. Repo Layout

```
enheduanna-submission/
 README.md 13982B, HACKATHON_STATUS_AUDIT.md 5414B, enheduanna.config.json 1196B,
 enheduanna.config.example.json 1052B, setup.bat 656B
 app/core/src/index.ts, config.ts, server.ts 13632B, auth.ts,
   agent/orchestrator.ts 27945B, session.ts, evidence.ts 10032B, approval.ts,
   mcp/manager.ts 13275B, mcp/buffer.ts, providers/meta.ts 8614B,
   prompts/loader.ts, trace/bus.ts, capture/supervisor.ts
 app/core/prompts/system_prompt.txt 11505B (13 rules + 2 few-shots)
 app/core/test/ 6 files, eval/quality_eval.js 16257B, dist/ compiled
 app/dashboard/index.html 12608B, app.js 66885B, styles.css 41249B
 memvison/main.py 16040B, pyproject.toml, requirements.txt,
   src/memvision/capture.py 11762B, change_detector.py 4051B, context.py 30997B,
   ocr.py 8392B, privacy.py 21416B, engine.py 26323B, storage.py 40296B,
   mcp_server.py 31188B, web_server.py 11663B, ai_chat.py 18564B
 memvison/tests/ 11 files, data/ (db + screenshots)
 igi/main.py 4310B, config.py 4455B, requirements.txt, test_igi.py 36809B,
   bridge/core_client.py 40720B, screen_context.py 14286B, sam_prompts.py 3399B,
   overlay/canvas.py 8344B, hotkey.py 1729B, projector.py 16361B,
   hud/chat_window.py 54884B, stream_view.py 31214B, cards.py 12659B, theme.py 7917B,
   sam/router.py 21238B, local_sam2.py 6034B, mask_utils.py 2274B
 scripts/setup.ps1 16784B, launch_igi.bat/ps1, verify_all_tests.ps1 1691B
 docs/NEXT_SESSION_PLAN.md 6983B, TODAYS_ACHIEVEMENTS.md 7390B,
   meta-api-notes.md 4554B, IGI_SAM_FLAWS_AND_VISION.md 9712B
 assets/enheduanna.gif 2191297B, data/sessions.json 1430890B
```

Sibling cli-bridge/: src/index.ts 66296B, src/policy/engine.ts 20926B + 7 files, build/, tests/ vitest.

## 2. Topology

User (Brave :4100, Brave :8765, IGI HUD + Ctrl+Shift+Q) -> Core :4100 (CoreServer node:http, Orchestrator 16-step max 5 parallel, ModelProvider -> https://api.meta.ai/v1/chat/completions, McpManager 2x stdio, EvidencePacker, ApprovalManager, ToolResultBuffer 64KB/128KB buf_* LRU50, TraceBus 100-ring scrubbed, SessionStore sessions.json, CaptureSupervisor spawn python main.py run --interval 2.0) -> memvision MCP 9 tools (SQLite WAL+FTS5, webp) + cli-bridge MCP 13+ tools (WORKSPACE_ROOT C:\meta hackathon, PolicyEngine+DevMode+audit).

Boot: loadConfig (DEFAULT + json + env PORT/HOST/MODEL_NAME/TOOL_MODEL/SYNTHESIS/ENABLE_TWO_MODEL/OMNIROUTE_BASE_URL, hydrate META_API_KEY) -> buffer limit -> getApiKey (META||MODEL, OMNIROUTE, config fallback, log abcd...wxyz) -> McpManager.init (spawn python ../memvison/.venv/Scripts/python.exe main.py mcp + node ../cli-bridge/build/index.js --policy policy.json, listTools union + get_full_result) -> listen 4100, SIGINT/SIGTERM graceful.

Live config: server 127.0.0.1:4100, model provider meta modelName/toolModel muse-spark-1.3 synthesisModel muse-wonder-1.0 baseUrl https://api.meta.ai/v1, spatial localGeometry true opticalOcr true projections false min16px, limits maxSteps 16 maxParallel 5 maxToolResult 64000, mcpServers memvision ../memvison + C:\meta hackathon\memvison\data\... (sibling dev DB 4915 caps 118MB), cli-bridge ../cli-bridge WORKSPACE_ROOT C:\meta hackathon.

## 3. Core TS Deep Dive

Stack: Node18+, TS5.7 strict type:module, deps @modelcontextprotocol/sdk ^1.0.1, dompurify, dotenv, marked, zod. No Express, node:http direct.

server.ts: parseJsonBody 2MB, CORS *, OPTIONS, validateAuth for /api/* /chat /tools /trace /health. Routes: GET /health {status,modelConfig,mcp,capture}, GET /tools, GET /trace SSE (replay 30), POST /chat {sessionId?,message,images?,options?} -> create session if missing -> text/event-stream -> orchestrator.runTurn, GET /api/capture/status, POST /api/capture/toggle, GET /api/capture/image/:id (internal get_screenshot max1280 -> data URL, zero tokens), GET/POST /api/sessions, GET/DELETE /api/sessions/:id, GET/POST /api/config (live mutate + persistApiKeyToEnv .env + saveConfigFile json + trace), GET /api/approvals, POST /api/approvals/:id. serveStatic app/dashboard traversal-guarded, SPA fallback.

orchestrator.ts: temp 0.2, reasoning_effort passthrough. executeStep: tools = synthesis?[]:getChatCompletionsTools (OpenAI shape), activeModel = synthesis?wonder:spark, step_start SSE + trace, provider.callStreaming (reasoning->reasoning event, delta->delta only if synthesis), synthesis fallback Wonder->Spark + event, strip hallucinated tool_calls in synthesis, terminal (no calls): delta unless suppressTerminalDelta (two-model with prior results), append assistant+reasoning, return terminal. Tool path: step_narration, append assistant tool_calls, slice active 0:5 skipped 5: (pseudo [Skipped...]), tool_group_start, per-call Promise.allSettled: loop guard cacheKey name+JSON args in per-turn Map -> repeatCounter++, reuse + [Notice...], isRepeated, >=2 -> isRepeatCapHit; HITL needsApproval -> createRequest 120s -> approval_required -> await -> resolved, denied -> [Permission Denied...], execute_command approved -> auto toggle_dev_mode true; exec tool_call_start -> mcpManager.executeTool -> tool_call_done {preview300,resultContent,isTruncated,bufferId,hasImage,imageUrl}. History: all role:tool contiguously first, then max ONE multimodal role:user image_url if any image (HTTP400 fix). tool_group_done + trace wall-clock.

runTurn: refresh system prompt live UTC+Asia/Kolkata, append user (+images data URLs), loop step<maxSteps executeStep (suppressTerminalDelta = twoModel && priorResults), operator guard consecutive execute_command >=3 -> operator_limit_reached break, loop guard repeat>=2 break, step>=maxSteps -> step_cap_reached break. Synthesis if (twoModel && results>0)||!finalAnswer: partition actionResults (non-memory 400ch) + EvidencePacker.packEvidence (memory -> PackedTimelineEvidence JSON), append role:user [ACTION RESULTS]+[VERIFIED TIMELINE]+[STEP BUDGET NOTICE]+6 Wonder instructions (confirm files/paths, full code, inspect crops, chrono bullets, no #IDs), executeStep isFinalSynthesis tools disabled -> stream Wonder. Fallbacks, done {sessionId,finalAnswer,messageCount,stepsTaken} + turn_end, catch error.

providers/meta.ts: sanitizeMessages (only [0] system, max 3 recent image_url else [Historical Screenshot Analyzed]), callStreaming POST {baseUrl}/chat/completions {model,messages,tools?,stream:true,temp0.2,reasoning_effort} Bearer, parse SSE data: (skip :/[DONE]), delta.reasoning_content|reasoning|thought, delta.content, delta.tool_calls indexed reassembly JSON.parse fallback {raw}, usage, traces Model Call/Response ms.

mcp/manager.ts: getCleanEnv, unwrapMcpResult (single text JSON parse), init 2x StdioClientTransport + Client enheduanna-core 1.0.0 connect listTools union, traces Connected/Failed, internal get_full_result. getChatCompletionsTools/getResponsesApiTools adapters. executeTool: get_full_result -> buffer, memvision callTool scan content[] {type:image} -> extractedImage + unwrap remainder or [Visual screenshot ... KB...], cli-bridge unwrap, buffer.processResult, traces Tool Call/Done ms preview/hasImage. getStatus for /health.

buffer.ts: maxEntries 50 LRU, 64KB (128KB read_file), truncated -> preview + [... Truncated N. call get_full_result buf_xxxx].

trace/bus.ts: EventEmitter 100-ring, redactSecrets (sk-, sk-ant-, sk-or-v1-, ghp_, Bearer, AIza, api_key|password|secret|token assignments -> [REDACTED_*]), redactObject JSON round-trip, handleSseStream replay30+live+keepalive15s. Types turn_start|turn_end|model_request|model_chunk|tool_call|tool_result|tool_group|capture_toggle|error|warning|system, sources orchestrator|meta-api|mcp-memvision|mcp-cli-bridge|capture|system.

session.ts: sessions.json pretty array, sess_<12hex> {id,title,createdAt,updatedAt,messages[]}, auto-title 40ch, list sorted updatedAt desc messageCount len-1.

evidence.ts: parseItems results|captures|[] + nested windows sort chrono, inferPurpose coding|project_tools|video|research|communication|browsing|system, packEvidence merge same app+title 30s (duration, max fraction, OR fg, dedup OCR200), filter <3s only if >8 segs unless query hit, return {summary{start,end,total_duration_s,segment_count,primary_purposes},segments[]}.

approval.ts: needsApproval copy_file, request_path_access, execute_command, toggle_dev_mode true, request_command_access. createRequest 120s auto-deny, resolve, getPending.

supervisor.ts: spawn python main.py run --interval 2.0 cwd memvisionRoot env DB/screenshots windowsHide, stdout Captured|Dropped|Sanitized -> trace, stderr lastError, SIGTERM+1.5s SIGKILL, toggle.

loader.ts: read system_prompt.txt replace CURRENT_TIME_UTC (ISO), CURRENT_TIME_LOCAL (full+long Asia/Kolkata), USER_TIMEZONE. Fallback 4-liner.

System prompt 13 rules: 1 captures-only not history, 2 broad->get_session_summaries first, 3 specific->get_memory_statistics+search parallel, 4 time-bounded search_desktop_memory since/until UTC never get_recent, 5 parallel together, 6 epistemic modesty coverage gaps, 7 no pre-tool chatter, 8 chrono blocks exact filenames/repos/quoted videos duration-judged 2-4s=glance cross-ref Confirmed/Not confirmed no #IDs natural tone, 9 window attribution + proactive 1-3 crops gallery, 10 request_path_access Allow/Deny, 11 multimodal inspect, 12 IGI crops describe colors/UI live [Active Window] not history, 13 file actions [Active Directory]+[Circled Selection] copy_file/read+write same turn never powershell -Command. Few-shots day-log Oct27 + Jumanji multitasking.

## 4. Scribe memvison/ Python

Req Win10/11, Py3.10 .venv, mss pillow imagehash numpy psutil pywin32 uiautomation winrt-* pytesseract httpx.

capture.py: _init_capture_thread OpenWindowStation winsta0 SetProcess SetThread Desktop, ScreenCapturer ocr_max 0=native storage_max 1280 format webp quality80 monitor all|primary single-worker ThreadPool, _grab_worker mss monitors[0] or primary -> (PIL,origin), redact_blocked_windows opaque mattes pre-OCR, save_image LANCZOS WebP75/JPEG70.

change_detector.py: ChangeDetector threshold3 dhash hash8 64-bit, dhash ~13ms phash ~300ms (downscale>256) ahash, evaluate_change (first True dist64, distance>threshold update), stats suppressed ratio.

context.py 30.9KB: enable_dpi_awareness_v2 (-4->2->Aware), BROWSER_PROCESSES 8, IDE_PROCESSES 16, WindowContext/VisibleWindow dataclasses, get_active_context GetForegroundWindow ThreadProcessId psutil name GetWindowText UIA ValuePattern URL IDE title file_path workspace, get_visible_windows EnumWindows Z-order IsVisible !IsIconic !CLOAKED GetWindowRect MonitorFromWindow.

ocr.py: LocalOCREngine winrt primary pytesseract fallback, OcrEngine.try_create_from_user_profile_languages, extract_text / extract_text_and_lines (full, [{text,rect,words}]) asyncio PIL->PNG->InMemoryRandomAccessStream->BitmapDecoder->SoftwareBitmap->recognize_async, offsets by caller, 100% offline HW accel.

privacy.py 21.4KB: 12 regex families sk-*/sk-or-v1/sk-ant, gh[pousr]_, AIza, AKIA|ABIA|ACCA|ASIA, hf_, xox[baprs]-, Bearer, api_key|secret|password|access_token|auth_token|private_key assignments, JWT eyJ, BEGIN PRIVATE KEY blocks, URL query state|code|token..., doc hashes. PrivacyRules mode blocklist|allowlist action drop|redact blocked_apps/urls/titles allowed + redacted_text_patterns from privacy_rules.json mtime hot-reload. evaluate fnmatch case-insensitive + regex fallback -> PrivacyDecision. redact_text iterate count replace group1 or whole -> (sanitized,count,[rules]). redact_url urlsplit public allowlist (client_id,redirect_uri,scope,q,v...) sensitive denylist (state,code,token,secret,password,sig,nonce,hash...) + long hex/b64 >=32 + fragment pairs + bare >=16 + path /viewer/<20+> + regex defense. filter_blocked_windows.

engine.py 26.3KB capture_once 9 stages: 1 capturer.capture native + origin, 2 get_active+visible filter_blocked evaluate active (blocked + win_ratio>=0.85 or no allowed -> drop None log PRIVACY DROP or redact [REDACTED] no shot, else spatial rescue topmost allowed log SPATIAL RESCUE), redact_blocked mattes masked_names, 3 dhash gate static->None, 4 occlusion Z-order clip mask subtract covered_rects visible_fraction skip<0.05 append covered crop native blank [128,128,128] tight-crop visible + offset, 5 per-window evaluate (drop skip redact [REDACTED]+blur20 else extract_text_and_lines + offset + redact_text full+lines) text_hash sha256[:16] text_changed vs _window_text_hashes save crop <=1600 WebP75 if fg|changed|force else reuse WindowRecord aggregate [app|title (fg/bg N%)] text, 6 sanitize title+URL sum redactions, 7 video suppression same app+title + enabled _evaluate_text_stability SequenceMatcher.quick_ratio + containment is_video_static = sim>=0.90 or (cont>=0.95 and lenD<20) both-empty True one-empty False -> None log VIDEO SUPPRESSION, draft expansion !static longer cont>=0.85, 8 primary_screenshot fg crop else first else downscaled full, 9 CaptureRecord ISO UTC + metadata {change_distance,ocr_ms,process_id,native/storage dims,spatial_masked,is_masked,virtual_origin,window_count,windows[],redacted_count/rules,file_path,workspace,is_ide} -> save_capture auto-episode -> save_windows -> prune 500MB/7d -> log CAPTURE #id callbacks. run interval max0.2 config (supervisor 2.0) SIG only main thread sleep interval-elapsed.

storage.py 40.2KB: connection timeout10 Row WAL NORMAL FK ON. Schema captures(id,timestamp,app,title,url,ocr,screenshot,phash,w,h,is_redacted,metadata JSON,episode_id FK,file_path) indexes timestamp/app/phash/(app,time)/time/episode/file_path, windows(id,capture_id CASCADE,hwnd,app,pid,title,url,rect_x/y/w/h,z,fg,monitor,fraction,ocr,ocr_lines JSON,text_hash,crop_path,created_at) indexes capture/app/hash/fg/time, episodes(id,app,title,url,start,end,duration,count,key_capture,screenshot,keywords) indexes time/app, captures_fts/windows_fts FTS5 + ai/ad/au triggers, LIKE fallback if no FTS, migrations ADD episode/file_path, auto-backfill episodes. API save_capture (ISO meta cluster UPDATE episode), update_capture (draft collapse FTS auto), search (empty indexed direct, FTS MATCH "phrase" + filters ORDER rank, fallback LIKE 5 cols), get_recent ORDER id DESC, get_by_id, save_windows batch, get_windows_by_capture, get_window_by_id, get_episodes, get_session_summaries auto-backfill48h, get_stats, sanitize_database retro sweep. Live 4915 caps 3684 wins 598 redacted Oct26 16:55-Nov1 15:43 UTC 124.5MB.

mcp_server.py 31.1KB: MCPServer load_config PrivacyGate MEMVISION_DB_PATH override MemoryStorage screenshots_dir, stderr logging only, make_snippet 60+query+140. Tools: search_desktop_memory{query* limit5 since until app_name file_path} matching window query->fg->first window/matching/all ocr_snippet paths, get_recent_memory, get_capture_details full OCR+URL+shot+meta+windows, get_memory_statistics, get_activity_sessions episodes+minutes, get_capture_windows Z-order rects/fractions/has_crop fallback pseudo, get_window_crop{capture* window0 max1024} open crop_path|screenshots/basename else crop full via virtual_origin privacy blur25 thumbnail LANCZOS WebP75 b64 [{type:image}], get_screenshot -> window0 max1280, get_session_summaries auto-backfill. run_stdio UTF8 line JSON initialize 2024-11-05 mem-vision-mcp 0.1.0 tools:{}, initialized noop, tools/list, tools/call image passthrough else text JSON, ping, -32601.

main.py CLI: run --interval --threshold, once -f, search query -l, chat [query] REPL, mcp, ui|web --host --port8765 --no-browser --no-capture (thread capture + run_web_server), mcp-config Claude/Cursor JSON, sessions|episodes -l, stats, privacy-test --app --title --url, sanitize|redact, open Explorer, latest --view.

web_server.py: ThreadingHTTPServer GET / index.html styles app.js /api/stats /api/sessions?20 /api/recent?48 /api/search?q&48 /api/capture/:id /api/screenshot/:id POST /api/chat {query} -> AIChatEngine.ask + citations.

ai_chat.py: get_api_credentials auto Omniroute ANTHROPIC_* free-stack -> OpenAI gpt-4o-mini -> Groq llama-3.3-70b-versatile -> OpenRouter meta-llama/llama-3.3-70b-instruct -> DeepSeek -> Gemini gemini-2.0-flash -> Meta llama-3.3-70b-instruct -> Ollama, ask RAG search 6 + httpx -> ChatResponse{answer,citations,model,tokens}.

config.py dataclasses Capture{interval1.0 threshold3 dhash webp80 ocr0 native storage1280 monitor all video_suppression text0.90 draft_collapse window60} OCR{winrt pytesseract} Storage{data/memvision.db data/screenshots fts retention30} Privacy{config enabled} AI{meta https://api.meta.ai/v1 META_API_KEY llama-3.3-70b temp0.2 max1024 context6} env MEMVISION_DB_PATH/SCREENSHOTS_DIR overrides.

## 5. Operator cli-bridge/ (prior work)

priyanshu-cli-bridge 0.0.2 Node18 TS5.3 sdk ripgrep zod tsc vitest.

index.ts 66KB: parse --policy, workspaceRoot arg||WORKSPACE_ROOT||cwd (policy first root if none), loadPolicyFromArgs PolicyEngine+Audit, verify dir, log root rgPath DevMode OFF Policy/Workspace. resolveSafePath realpath root+target dangling check inside else throw CWE-59. DevMode false reset, toggle_dev_mode only on, execute_command blocked if off. Tools read: read_file, list_directory, search_files glob, grep_content rg fixed max50, get_dev_mode_status, get_recent_journal_entries; write/exec: write_file mkdir-p, edit_file exactly-once, copy_file, execute_command spawn no shell except wrappers npm|npx|yarn|pnpm|tsc|jest|eslint|prettier with &|;`$><^ scan block, toggle_dev_mode, request_path_access ro|rw JIT, request_command_access JIT, log_journal_entry PROJECT_LOG.md. Audit .cli-bridge-audit.log JSON timestamp args200 status. No network.

policy/: types PolicyConfig mode policy roots[{path,access}] restrictedPaths/Commands allowDevMode Zod fail-closed, engine.ts 20.9KB canonicalRoots+sessionRoots+sessionCommands restrictedPaths/Write globs globToRegex **/ case-insensitive normalizeCommandName looksLikePath (URL exclude ../ C: ./ slash heuristics) checks inside roots ro/rw restricted path/glob/command inline interpreters wrapper metachars -> Approver default deny, canonicalize resolve+realpath inside/equal, defaults built-in restricted paths (System32 Windows ProgramFiles...) commands (format diskpart reg shutdown...) INLINE_INTERPRETERS (powershell -Command cmd /c - why prompt forbids), approver audit loader index.

## 6. Eye igi/

Req PySide6-Essentials mss pillow httpx numpy pynput pywin32. launch_igi.bat -> main.py.

main.py: QApplication quitOnLastWindowClosed False PassThrough HiDPI, DualMoESAMRouter -> IgiCanvasOverlay -> IgiHudWindow projector None (disabled clean), overlay.selection_completed->hud.set_selection_context, GlobalHotkeyManager <ctrl>+<shift>+q pynput daemon -> HotkeyBridge signal -> freeze_screen_and_show, tray 32px amber eye #f59e0b ring #0d0f12 pupil tooltip menu Circle/HUD/Exit, banner shortcut core URL Spark/Wonder Grounder Sobel+OCR, hud.show.

config.py: CoreServer{host port base_url} Model{provider tool_model synthesis_model base_url api_key} Spatial{local_geometry optical_ocr projections false min16 + compat local_sam2/cloud_sam3 alias SAMConfig} HUD{440x600 margin36 hotkey accent #f59e0b bg #0d0f12 border #262b36 acrylic0.94} find_enheduanna_config 4 parents merge server/model/spatial|sam + META_API_KEY/ENHEDUANNA_PORT.

bridge/core_client.py 40.7KB: CoreClient httpx90 base_url session_id check_health GET /health 2s ensure_session POST /api/sessions IGI Session fallback igi_default resolve_approval POST /api/approvals. stream_chat_turn(prompt,crop?,ocr?,title?,proc?,ctx?,on_token/status/event): context [Active Window] [Active Directory] detected_path [Active Web Page URL] [Full Window OCR 1200] [Circled OCR] [Visual Crop WxH], image_crop PIL JPEG85 b64 images[], POST /chat {sessionId,message,images,options reasoning} SSE delta|reasoning|tool_start|done|approval|narration|done|error callbacks return text. Fallback direct POST {base_url}/chat/completions {model tool_model messages [system SAM_PLANNER][user text+image_url] stream} META_API_KEY. spatial_plan strict JSON intent|targets + write_card.

bridge/screen_context.py 14.2KB: sys.path parents3/memvison/src LocalOCREngine winrt, WindowContext{title proc pid hwnd rect path url full_ocr display_chip} detect_explorer_folder_path title-is-path known shells (Downloads... meta hackathon enheduanna-submission memvison cli-bridge) OCR C:\ regex UIA bar, detect_browser_url UIA ValuePattern Brave/Chrome/Edge/Firefox, get_active/at_point WindowFromPoint extract_text_from_crop enrich 1200 capture_window_image mss bbox.

overlay/canvas.py 8.3KB: IgiCanvasOverlay Frameless StaysOnTop Tool Translucent CrossCursor signal selection_completed(crop,ocr,title,proc,ctx), freeze_screen_and_show capture active before focus mss monitors0 PIL JPEG85 QImage QPixmap fullscreen show, mouse press/move/release stroke_points update, paintEvent blit + dim40% + amber stylus 3px+8px halo + bbox, Esc hide, release route_gesture -> {crop,bbox,centroid} extract OCR enrich emit hide.

hotkey.py pynput GlobalHotKeys start/stop daemon. projector.py 16.3KB SpatialProjectorOverlay enabled False Frameless StaysOnTop Tool TransparentForInput click-through Translucent VisualHighlight{bbox,label,desc,color cyan|amber|red,alpha,index,spawn} project_highlights duration fullscreen 80ms pulse 120-220 auto-clear paintEvent layered glow 10px25%+4px60%+2px solid fade180ms badge 1,2,3 anchored card QFontMetrics 120px leader below/above/side stagger anti-collision shadow. Currently disabled HUD-only.

hud/chat_window.py 54.8KB: IgiHudWindow frameless 440x600 bottom-right drag header 8px EDGE resize QSizeGrip StreamSignals token/status/finished/event/highlight/blocks/workflow/context, set_selection_context show ContextPreviewCard + focus, send_message threading.Thread _stream_worker CoreClient.stream_chat_turn callbacks Signals slots tokens tool drawer approval Allow/Deny resolve_approval, extract_concept_from_prompt 60+ prefix (where is highlight mark find vs code update...) + suffix (and explain on screen...) for ground_target. stream_view transcript User/Agent bubbles ToolDrawer rows ToolName cyan mono Duration green Detail, cards ContextPreview + QuickActions pills, theme.py solid dark-grey QSS #1c1d22 #22242b #f3f4f6 Segoe+Consolas 12px radius no transparency.

sam/router.py 21.2KB DualMoESAMRouter Tier1 LocalSAM2Engine use_onnx False alias Tier2 self cloud_client/cloud_sam3 zero cloud. route_gesture -> segment_gesture, route_concept/segment_concept/ground_target(screenshot,concept,region_hint any|top|sidebar|left|right|bottom|center,exclude_rect?,referring?,verify?,client?): crop region (top28% sidebar36%L right36% bottom32% center76% any full) _optical_ocr_ground WinRT word boxes fuzzy exact->substr->overlap scores fallback full is_fallback refine_box Sobel exclude HUD optional Spark verify sort -> [{bbox,score,method optical+sobel,region,fallback}]. segment_code_or_ui_blocks OCR clustering. local_sam2 segment_gesture bbox+centroid 100px fallback <10px refine search14 -> {crop,bbox,centroid,polygon,w,h} refine_box expand patch gray scipy sobel X/Y (noop if no scipy/<6px) vert=gx.mean0 horiz=gy.mean1 find_peak window14 snap if max>mean*1.35 and >12 clamp min10. mask_utils bbox/centroid/crop.

sam_prompts.py SPATIAL_PLANNER_SYSTEM (=SAM_PLANNER alias): thumbnail+question+title+URL+OCR -> strict JSON only {intent explain_page|explain_code|locate|compare|act targets[{concept,region_hint,referring_expression quoted text+colors+shape+neighbors+layout,label 2-4w,relevance,why,say <=28w}]} Rules exploratory 3-5 top-bottom targeted 1-2 never chrome/tabs/cookie/ads/HUD unless asked prefer headings/tables/code/bodies say what+why no click here unless act drop<0.6. CARD_WRITER 1-2sent <=28w specific no directives.

## 7. Dashboard vanilla zero-build

index.html top bar brand 𒀭 model spark|wonder|two-model reasoning minimal|max pills memvision|cli-bridge capture Recording(2s) Trace Settings, workspace sidebar+New stream+welcome+form trace panel, settings modal provider/base/model/reasoning/key, lightbox modal img+title+meta+open+Esc.

app.js 66.8KB IIFE apiFetch bootstrap loadHealth10s loadSessions loadCapture6s connectTrace SSE, lightbox, extractOcrRecords parse JSON gallery, renderMessage marked+DOMPurify bubbles thinking details tool cards collapsible preview/content/buffer/duration/error/image approval Allow/Deny POST visual accordion thumbnails lightbox zero tokens OCR accordion counts View Screenshot /api/capture/image/:id, sendMessage POST /chat SSE step_start reasoning delta narration group_start call_start done group_done approval_required/resolved synthesis_fallback operator_limit step_cap done error, sessions CRUD settings POST /api/config capture toggle.

styles.css 41.2KB dark glass Inter+JetBrains pills dots pulse bubbles trace timeline color source galleries lightbox blur responsive.

## 8. Flows

Write 2s: mss -> Win32 Z+UIA -> Privacy filter -> mattes -> dhash -> occlusion -> WinRT OCR+redact -> hash dedupe -> WebP -> video gate -> SQLite+FTS+episode -> prune.

Chat: User (+IGI crop/ctx) -> POST /chat SSE -> runTurn refresh prompt append -> [Spark stream -> parallel MCP memvision+crops+cli files -> approvals -> buffer/image -> history] xN <=16 guards -> EvidencePacker+Wonder tools-disabled -> delta -> done.

Visual: Spark get_screenshot/crop -> MCP PIL crop/blur/thumb WebP b64 -> Manager image -> Orchestrator multimodal user (<=3) + SSE imageUrl -> gallery lightbox zero tokens + Wonder vision.

Approval: needsApproval -> create 120s -> SSE required -> card -> POST /api/approvals -> resolve -> exec/denied -> resolved + trace.

## 9. Protocols

MCP JSON-RPC2 line stdio initialize 2024-11-05 tools/list tools/call ping SDK Client Server Stdio transports. Meta POST https://api.meta.ai/v1/chat/completions Bearer {model,messages,tools?,stream,temperature0.2,reasoning_effort} SSE data choices delta content/reasoning/tool_calls usage. Core SSE step_start reasoning delta narration group_start call_start done group_done approval_required/resolved synthesis_fallback operator_limit step_cap done error + trace data TraceEvent. IGI->Core GET /health POST /api/sessions POST /chat POST /approvals JSON localhost trust. DB SQLite WAL FTS5 +6 triggers B-tree.

## 10. Privacy/Stability

1 spatial curtain Win32 opaque pre-OCR 0 chars, is_masked metadata, 598/4915 redacted. 2 zero-leak 12 families pre-persist + retro sanitize + trace scrub + crop blur20-25. 3 video sim>=0.90/cont>=0.95 drop 1000+/hr, both-empty drop. 4 draft cont>=0.85 longer 60s update in-place unlink crops 20->1. 5 dhash>3 cursor immune. 6 WebP 25-35% smaller 1280 store 1600 crops native OCR 500MB/7d prune. 7 100% local screenshots/DB/actions, WinRT offline, only prompts+images to Meta.

## 11. Tests

verify_all_tests.ps1 pytest + npm test 55 (35 Py +20 Node) ALL PASSED. Py 11 files ai_chat change episodes mcp path_resolution privacy spatial_privacy stability storage web_server window_capture17KB (audit 10/10 0.26s, achievements 19/19). Node 6 approval coverage integration orchestrator_loop13.7KB session vision node --test. IGI test_igi 36.8KB. Eval quality_eval.js 10 Q multitasking work distraction debugging code research media productivity app_detection session_summary mock+gists. Live 4915/118MB sessions1.4MB dashboards GitHub anshupriyan/enheduanna + meta-submission.

## 12. Setup

1-click setup.bat -> setup.ps1 [-WithIgi|-NoIgi|-Force] zero-deadlock spinner temp-file no pipe block Test-NodeIsBuilt idempotent ~2s parallel auto-uv: clone cli-bridge@meta-hackathon ../cli-bridge npm i build, memvison/.venv pip -r requirements + ../igi/requirements, app/core npm i build, gen config portable. Run META_API_KEY, cd app/core npm start :4100, cd memvison .venv python main.py ui :8765, launch_igi.bat HUD. Manual git clone -b meta-hackathon ... venv pip core npm.

## 13. Flaws/Roadmap (honest)

IGI flaws Nov1 02:45: 1 UI-thread 25s httpx freeze (HUD threaded fixed, Live risky), 2 SAM2 stub bbox (now Sobel, no ONNX), 3 SAM3 fragile 1280 JPEG regex offline-dead 0.5 over-fire, 4 no region brain live split prefix-strip brittle ground_target unused, 5 no fusion, 6 tray missing 3 hotkeys ad-hoc segment_credit prod.

Plan 7: 1 HTTP400 strict sequence single1024 crop DONE, 2 operator 3-cap DONE, 3 WebP DONE, 4 buffer 4K->64K/128K DONE, 5 CLI streaming drawer pending, 6 MobileSAM ONNX pending (Sobel now), 7 Clear Time GetLastInputInfo adaptive1-15s HUD pill pending.

Audit shaky Oct29: invalid-key handshake deterministic .env->config->client, chattiness preview+prompt, test-on-camera verify_all_tests live.

## 14. File Index

index.ts boot, config.ts AppConfig load/getApiKey/resolve, server.ts 14 routes static, auth.ts Bearer, orchestrator.ts ReAct guards synthesis, session.ts JSON, evidence.ts Timeline packer, approval.ts 5 gates 120s, manager.ts stdio2 image, buffer.ts 64/128 LRU buf_*, meta.ts streaming sanitize, loader.ts live timestamps, bus.ts ring scrub, supervisor.ts spawn toggle, system_prompt 13 rules, app.js SSE chat trace gallery lightbox, main.py 12 cmds, capture.py WinSta0 mattes, change_detector dhash, context.py Win32 UIA DPI, ocr.py WinRT, privacy.py 12 regex URL, engine.py 9-stage, storage.py WAL FTS5, mcp_server.py 9 tools stdio, web_server.py 7 REST, ai_chat.py 7-provider RAG, igi main wiring, core_client SSE fallback, screen_context Win32 OCR, router grounding, local_sam2 Sobel, projector halo disabled, chat_window HUD threads, cli index 13+ DevMode audit, policy engine allow/ask/deny.

## 15. README Polish Recs

1 hero ASCII+quote+5 badges + live stats 4915/118MB/55 tests. 2 tri-faculty diagram Scribe/Operator/Eye+Core+Dashboard+Meta ports protocols. 3 Quick Start setup.bat 1-click then 4 runs. 4 faculties add Eye Circle Sobel HUD projector. 5 privacy quantify 598 0 chars 12 families WebP30% 500MB/7d. 6 inference dual Spark/Wonder fallback reasoning 16/5 buffer buf_* approvals. 7 verification verify_all_tests 55 + eval + demo memory->resume video. 8 disclosure prior-work prominent.

End. All grounded in source reads, no hallucinations.
