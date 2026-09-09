# Todo Flutter

Small Android/iOS foundation for the MAULE Todo rebuild.

## Structure
- models/todo.dart: immutable task and explicit three-state enum.
- data/todo_database.dart: Drift SQLite table, schema version 1, and CRUD.
- controllers/todo_controller.dart: ChangeNotifier list state and operations.
- screens/home_screen.dart: launch placeholder, loading and load-error display.
- theme/: original six-colour palette and VT323 font constants.

IDs are SQLite auto-incrementing primary keys. Status is stored as enum text.
Tasks load oldest first by createdAt, then ID for deterministic ties.
Task numbers are not stored. Future rows should derive numbers from list position.
The app owns and closes the database; the controller owns an immutable list snapshot.
Mutation failures propagate to callers; future dialogs must handle them.
Clear all is a data operation only: a future UI must confirm before invoking it.

## Development
Run flutter pub get, then dart run build_runner build to generate Drift code.
Run flutter analyze and flutter test for targeted checks.
Android and iOS scaffolds are included. iOS build/signing requires a Mac.

## Intentionally deferred
Task rows, header, legend, add/details/clear-confirmation dialogs, and audio service
will be added when implemented; no empty speculative widget/service files exist.
No final UI, sounds, task text editing, notifications, cloud, or additional features.

VT323 was copied from the local original Android project and registered in pubspec.
TODO: copy the original MAULE logo and chosen audio assets when implementing their UI.
No replacement branding has been invented. Launcher assets remain Flutter defaults.