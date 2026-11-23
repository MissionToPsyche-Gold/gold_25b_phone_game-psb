# Cosmic Quest: Psyche — themed UI + team game state

A portrait phone web game for 2–4 players sharing one phone (pass and play), built in **Godot 4.7 (GDScript)**.
The UI follows the project report: it fits a 360 × 640 screen with no sideways scrolling, text is 16 px or larger, buttons are at least 44 px tall, and every instruction and result appears on screen so the game works with the sound off.

## How it's put together

| Folder | What's inside | Owner |
|---|---|---|
| `models/` | `game_state.gd` (players, lives, score, turns, rounds) and `player.gd` | Game state teammate |
| `controllers/game_controller.gd` | `GameFlow`: opens the right scene for each phase | Game state teammate |
| `scenes/` | One scene per screen (see below) | UI |
| `scripts/scenes/` | The thin script behind each scene; reads `GameState` and shows a screen | UI |
| `scripts/ui/screens/` | The screens themselves: setup, rules, pass the phone, trivia, minigame frame, results, pause | UI |
| `scripts/ui/components/` | Reusable parts: `FxButton`, hearts (`LivesDisplay`), `PlayerHud`, `TimerBar`, `RulesPager` | UI |
| `scripts/ui/ui_style.gd` | **All colors, sizes, fonts and the theme in one place** | UI |
| `scripts/background/` | Animated space: stars, nebula, meteors, Psyche, spacecraft | UI |
| `scripts/autoload/` | `Backdrop` (background that stays loaded across scenes), `UITheme`, `GameSettings`, `SceneTransition`, `QuestionBank` (placeholder) | UI |
| `data/sample_questions.json` | **Sample** questions for testing only | Trivia teammate replaces |
| `scripts/demo/placeholder_minigame.gd` | "Tap 5 times" stand-in until the real maze exists | Maze teammate replaces |

### Screens and the GameFlow phase that opens each one

| Phase | Scene | What players see |
|---|---|---|
| (menu) | `main_menu.tscn`, `how_to_play.tscn`, `settings.tscn` | Title screen, rule cards, volume and Reduce motion |
| `setup` | `player_setup.tscn` | Pick 2/3/4 players, enter names (each bad field gets its own error), then the "Crew ready" rules and **Ready!** |
| `handoff` | `player_handoff.tscn` | "Pass the phone to ___" in that player's color, with lives, score, what's next, **Scores** and **Quit** |
| `trivia` | `trivia.tscn` | Player HUD, the question, 4 answers (first tap only), then right/wrong, the answer, the explanation, **Continue** |
| `maze` | `maze.tscn` | Bonus challenge intro, then the minigame with a countdown bar, then the result (+1 life) |
| `results` | `results.tscn` | Ranked results with ties sharing a rank, eliminated players marked OUT, confetti, **Play again** |
| (from handoff) | `leaderboard.tscn` | Mid-game scoreboard |

The UI only displays things. It changes the game only by calling `GameState`'s own functions (`start_session`, `record_trivia_result`, `record_maze_result`, and so on), so the MVC split from report section 6.1 stays intact.

## Changing the look

- **Colors, font sizes, button height:** edit the constants at the top of `scripts/ui/ui_style.gd`. Every screen updates.
- **Your own art from the mockup:** replace the PNGs in `assets/art/` using the same file names (`psyche.png`, `spacecraft.png`, `planet.png`, `earth.png`, `rock_1.png` to `rock_4.png`). Use transparent backgrounds. The current ones are placeholders I drew.
- **Where Psyche and the spacecraft sit:** see `scripts/autoload/backdrop.gd` (`use_menu_layout` and `use_game_layout`).
- **Rule text:** see `PAGES` in `scripts/ui/components/rules_pager.gd`.
- **Button colors:** set `accent` on any `FxButton` to Orange, Cyan, Purple, Pink, Green, Red or Gold. For a plain `Button`, set Theme Type Variation to `CyanButton` (and so on). Panels work the same way (`CyanPanel`).

Fonts: **Jersey 10** for the logo and headings (its C and O look different), and **DotGothic16** for body text and numbers (its 5 and S look different). Both are under the SIL Open Font License; the license files are in `assets/fonts/` (report EL-1).

## Things the team should decide (the report disagrees with itself)

1. **Minigame reward.** UF-12 says +100 points, SF24 says +10 points, and UC-5 and the abstract say a bonus life. The current `GameState` gives **+1 life (max 3)**, and the UI and rule text match that. If it changes, update `GameStateUI.MINIGAMES` and `rules_pager.gd` too.
2. **Round limit.** `GameState` supports a demo round limit (it was 3). The setup scene passes **0**, meaning no limit: the game ends when one player is left or the questions run out, as UC-2 describes. Change `round_limit` on the PlayerSetup scene if you want a limit.

For how teammates plug in trivia and minigames, see **docs/UI_GUIDE.md**.
