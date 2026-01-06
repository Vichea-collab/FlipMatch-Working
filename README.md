# FlipMatch – Memory Pair Game

FlipMatch is an offline animal-themed memory pair game built with Flutter. Players get a quick splash experience, land on a welcoming hub, enter their name, and progress through increasingly challenging levels while their scores are persisted locally.

## Features
- Animated splash screen that transitions to a rich welcome screen.
- Guided onboarding with "How to Play" and player name entry before starting.
- Offline player persistence and leaderboard seeded from `assets/data/leaderboard.json` using `path_provider`.
- Level configuration loaded from `assets/data/level.json`.
- Modern Material 3 styling with custom backgrounds and card visuals.

## Project Structure
- `lib/main.dart` – app entrypoint and theming.
- `lib/ui/screens/` – splash, welcome, how-to-play, name entry, menu, and gameplay screens.
- `lib/ui/widgets/` – shared UI (background, card tiles, buttons).
- `lib/domain/` – entities, repositories, and services for game logic.
- `lib/data/` – local data sources and repository implementations.
- `assets/data/` – level definitions and leaderboard seed data.
- `test/widget_test.dart` – widget tests covering splash and welcome flows.

## Getting Started
1) Install the Flutter SDK (3.x) and a device/simulator.
2) Fetch dependencies:
   ```bash
   flutter pub get
   ```
3) Run the app:
   ```bash
   flutter run
   ```

## Testing
Run the widget tests:
```bash
flutter test
```

## Notes
- Player and leaderboard data are stored in the app documents directory; deleting the app data resets progress.
- Assets listed in `pubspec.yaml` (`assets/data/level.json`, `assets/data/leaderboard.json`) must remain available for the game to load properly.
