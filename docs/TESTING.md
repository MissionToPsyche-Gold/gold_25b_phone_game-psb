# Testing Cosmic Quest: Psyche

We use **GUT (Godot Unit Test) 9.7.1**, a free test automation framework for Godot 4 (MIT License). It lives in `addons/gut/`.

## Install GUT (already done in this repo)

If you ever need to reinstall it:

1. In Godot, open the **AssetLib** tab, search for **GUT**, and install "Gut - Godot Unit Testing (Godot 4)". Or download release 9.7.1 from github.com/bitwes/Gut and copy its `addons/gut` folder into this project's `addons/` folder.
2. Go to **Project → Project Settings → Plugins** and enable **Gut**.
3. Restart the editor. A **GUT** panel appears at the bottom of the editor.

## Run the tests

**In the editor (easiest)**
1. Open the **GUT** panel at the bottom of the editor.
2. The settings come from `.gutconfig.json`, which points at `res://tests/unit/` and `res://tests/integration/`.
3. Click **Run All**. Each test shows green (pass) or red (fail). A failure shows the line and the reason.

**From a terminal (for repeatable records)**
```
godot --headless --path . -s addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json
```
The run ends with a summary like `Tests 33 / Passing Tests 33`. A JUnit XML report is saved to `user://gut_results_<time>.xml`, which is the project's data folder; in Godot, use **Project → Open User Data Folder** to find it.

**Legacy smoke test** (the team's original script, still kept):
```
godot --headless --path . -s tests/smoke.gd      # ends with: CHECKS: 126 | FAILURES: 0
```

> If a headless run hangs right after "Loading docks", the Godot Git plugin is waiting on a folder that isn't a Git repository. Run it inside the cloned repo (or `git init` the folder).

## Test-driven workflow (what the professor asks for)

1. Write the test case for the feature first, in the right suite file.
2. Run it and **record the failure**: the feature doesn't exist yet, so it must fail.
3. Write the code until the test passes. Record the pass.
4. Clean up the code, then run **all** suites again (regression) and record that run too.

## Suites

| Suite | File | Stage | Covers |
|---|---|---|---|
| TS-001 Player Setup | `tests/unit/test_ts001_player_setup.gd` | Unit | TC-001 to TC-005 |
| TS-002 Turns, Scoring and Lives | `tests/unit/test_ts002_turns_scoring_lives.gd` | Unit | TC-006 to TC-009 |
| TS-003 Trivia Question Bank | `tests/unit/test_ts003_question_bank.gd` | Unit | TC-010 to TC-014 |
| TS-004 Trivia Screen | `tests/unit/test_ts004_trivia_screen.gd` | Unit | TC-015 to TC-017 |
| TS-005 Maze Minigame | `tests/unit/test_ts005_maze.gd` | Unit | TC-018 to TC-022 |
| TS-006 Bonus Challenge | `tests/integration/test_ts006_bonus_challenge.gd` | Unit + Integration | TC-023 to TC-025 |
| TS-007 Main Menu and About | `tests/integration/test_ts007_about_navigation.gd` | Integration | TC-026 to TC-028 |
| TS-008 Look and Accessibility | `tests/unit/test_ts008_look_accessibility.gd`, `tests/integration/test_ts008_screen_fit.gd` | Unit + Integration | TC-029 to TC-031 |
| TS-009 Game Flow | `tests/integration/test_ts009_game_flow.gd` | Integration | TC-032 to TC-033 |

Each test function starts with its ID (`test_tc012_...`) and has a one-line comment saying what it checks, so a failing test in the GUT panel points straight to the test case in Appendix T.

Run history from November 12, 2026 is in `docs/test_records/`.
