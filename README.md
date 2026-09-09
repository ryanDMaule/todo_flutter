# Todo Flutter

Small Android/iOS foundation for the MAULE Todo rebuild.

## Structure
- models/todo.dart: immutable task and explicit three-state enum.
- data/todo_database.dart: Drift SQLite table, schema version 1, and CRUD.
- controllers/todo_controller.dart: ChangeNotifier list state and operations.
- screens/home_screen.dart: retro main screen bound to the persisted list.
- theme/: original six-colour palette and VT323 font constants.

IDs are SQLite auto-incrementing primary keys. Status is stored as enum text.
Tasks load oldest first by createdAt, then ID for deterministic ties.
Task numbers are not stored. Rows derive numbers from visible list position (index + 1).
The app owns and closes the database; the controller owns an immutable list snapshot.
Mutation failures propagate to callers; future dialogs must handle them.
Clear all is a data operation only: a future UI must confirm before invoking it.

## Development
Run flutter pub get, then dart run build_runner build to generate Drift code.
Run flutter analyze and flutter test for targeted checks.
Android and iOS scaffolds are included. iOS build/signing requires a Mac.

## Intentionally deferred
Add/details/clear-confirmation dialogs and audio playback remain deferred.
Add Task and Clear all are disabled visual placeholders; task rows have no action.

VT323 was copied from the local original Android project and registered in pubspec.
The original MAULE logo is copied and registered. Audio assets remain deferred.
No replacement branding has been invented. Launcher assets remain Flutter defaults.
Main screen uses the original colours, VT323 sizes, 2dp corners, borders, and heading shadow.
The clock uses local time (hh:mm:ss, no AM/PM); date is MMM dd with English month names.
Header and title scale down only when needed. Physical-device fidelity is still to be checked.
