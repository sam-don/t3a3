# Idle Delve

A native iOS idle dungeon crawler. Your hero auto-battles down an endless
dungeon — even while the app is closed — collecting gear, leveling up, and
eventually prestiging ("ascending") for permanent power that makes every run
faster than the last.

Built with Swift, SwiftUI, and SpriteKit. No third-party dependencies.

## Core loop

- **Auto-battle**: hero and enemy trade attacks on a timer. Kill an enemy,
  advance a floor, repeat forever. Every 10th floor is a boss with a big
  stat bump and guaranteed loot.
- **Offline progress**: closing the app doesn't stop the dungeon. On
  relaunch, elapsed time (capped at 8h, at a reduced rate) is simulated and
  reported back as a "Welcome Back" summary.
- **Gear**: three slots (Weapon / Armor / Trinket), six rarity tiers
  (Common → Mythic), randomly rolled affixes. Drops from kills, guaranteed
  from bosses.
- **Talents**: a per-run skill tree spent with skill points (earned on
  level-up). Reset every prestige.
- **Prestige (Ascension)**: once you've reached floor 25, reset your run in
  exchange for Essence — a permanent currency spent on an Ascension tree
  that never resets. This is the long-term progression loop.
- **Active tap**: tapping the battle stage triggers a bonus attack on a
  cooldown — the one deliberately active mechanic layered on an otherwise
  idle game.

## Project structure

```
IdleDelve/
  App/            App entry point, scene-phase-driven start/stop of the game loop
  Models/         Value types: Hero, Enemy, Gear, Rarity, Zone, Talent trees, GameState
  Engine/         GameEngine (the tick loop), Balance (tunable formulas),
                  CombatResolver, LootTable, SaveManager
  SpriteKit/      BattleScene — the animated battle stage (currently emoji
                  placeholder "sprites"; swap for real art via SKSpriteNode later)
  Views/          SwiftUI screens: Dungeon, Hero, Skills, Prestige
  Resources/      Asset catalog (placeholder app icon / accent color)
IdleDelveTests/   XCTest coverage for combat math, progression, offline simulation
```

All game balance constants live in `Engine/Balance.swift` — tune difficulty,
economy, and pacing there without touching engine logic.

## Building

This repo has no `.xcodeproj` checked in — it's generated from
[`project.yml`](project.yml) via [XcodeGen](https://github.com/yonaskolb/XcodeGen)
so the project file never rots or produces merge conflicts as files are
added.

```sh
brew install xcodegen
xcodegen generate
open IdleDelve.xcodeproj
```

Then build/run the `IdleDelve` scheme on an iOS 16+ simulator or device. Run
`IdleDelveTests` (Cmd+U) to run the unit test suite.

Requires Xcode 15+ (Swift 5.9). No Mac was used to write this code — it was
authored without a local toolchain, so give the first build a careful look;
if XcodeGen isn't installed, `project.yml` is still a complete, readable spec
of every target/setting.

## Roadmap ideas

Things that would extend this vertical slice without changing the core
architecture:

- Real art (replace the emoji placeholders in `BattleScene`)
- More zones / boss variety, elite (rare) enemy modifiers
- A second hero class or companion system
- Daily quests / login streak rewards
- Push notifications for "your hero is under-leveled for this floor" or
  "offline cap reached, come collect"
- Equipment set bonuses, socketed gems
- Cloud save (iCloud key-value or CloudKit) so progress isn't device-bound
