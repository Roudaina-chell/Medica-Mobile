# Copilot instructions for Medica-Mobile (Flutter)

Quick reference for AI coding agents working on this repository.

- Project type: Flutter app (Dart, Flutter 3+, Hive local DB)
- Entry point: `lib/main.dart` — calls `InitAccounts.initialize()` (see `lib/pages/init_accounts.dart`) before `runApp()`.
- Local DB: Hive box named `users` (opened in `DatabaseHelper.usersBox`). Prefer using `DatabaseHelper` methods instead of directly opening boxes.

Key files and responsibilities
- `lib/pages/database_helper.dart` — central data access layer. Implements singleton `DatabaseHelper` and methods:
  - `addUser(String email, Map<String,dynamic> userData)` (uses `carte_id` uniqueness check)
  - `authenticateUser(String identifier, String password)` — supports email OR numeric `carte_id` (string identifier is parsed to int when needed)
  - `getUserByCarteId`, `getAllUsers`, `getUsersByRole`, `initializeSystemAccounts`, `clearAllUsers`
- `lib/pages/init_accounts.dart` — initializes Hive (`Hive.initFlutter()`) and populates two system accounts (`system@hospital.dz`, `admin@hospital.dz`) with fixed 10-digit `carte_id` values.
- `lib/main.dart` — ensures initialization runs before app launches.
- UI pages: `lib/pages/SignUp.dart`, `lib/pages/SignIn.dart`, `lib/pages/Profile.dart`, `lib/pages/SplashPage.dart`, `lib/pages/SignUp.dart` (and other pages under `lib/pages`).

Important data shape & conventions
- User object (stored as a Map) example:
  {
    'carte_id': 1111111111, // int, 10 digits
    'email': 'system@hospital.dz',
    'password': 'System@2025', // stored in plain text (security caveat)
    'fullName': 'Système Principal',
    'role': 'system' | 'nurse_admin' | 'medecin' | 'patient',
    'phone': '',
    'dateOfBirth': '',
    'address': '',
    'createdAt': 'ISO timestamp'
  }
- Keys to check when changing schema: `carte_id`, `email` (box key), `password`, `fullName`, `role`.
- Roles: `system`, `nurse_admin`, `medecin`, `patient`. Some UI code expects `doctor/admin/administration` (see `Profile.dart`) — watch for role label/value mismatches.

Notable code issues and checks for agents (actionable)
- Mismatch: `SignIn._getHomePageForRole()` returns `Profile(userData: user)` (pass whole Map), but `Profile` constructor expects `username`, `email`, `role`. Fix either the call site or `Profile` to accept `userData` or a `User` model.
- Missing files: `SignIn.dart` imports `home_system.dart`, `home_administ.dart`, `home_doctor.dart` — these files are not present in `lib/pages` or `lib/`. Verify their locations or update imports to the actual home pages.
- Security: passwords are stored plain-text in Hive. If making auth changes, consider hashing password and updating `authenticateUser` accordingly.
- Tests: there are no unit/integration tests. When adding tests, stub `Hive` or use `Hive.initMemory()` and `DatabaseHelper.clearAllUsers()` for setup/teardown.

Developer workflow & useful commands
- Fetch packages: `flutter pub get` (pubspec uses `hive`, `hive_flutter`, `hive_generator`, `build_runner`)
- Run app: `flutter run` (or use platform-specific run targets)
- Generate Hive TypeAdapters (if you switch to typed models): `flutter pub run build_runner build --delete-conflicting-outputs`
- Inspect early initialization logs: `InitAccounts.initialize()` prints created accounts to console.

Conventions & patterns
- Database access is centralized via `DatabaseHelper` singleton — prefer adding new DB methods there.
- UI strings and comments are written in French; preserve or translate consistently when modifying UI.
- UI uses consistent color `0xFF2DB4F6` for primary buttons/headers — follow for visual consistency.
- Use `carte_id` (int, 10 digits) for identity lookup; `authenticateUser` supports email OR numeric identifier.

When making a change, run these checks
1. If you change user shape: update `DatabaseHelper`, `SignUp`, `SignIn`, `Profile` and any place reading/writing users.
2. If you introduce new pages referenced by role, ensure imports and tests cover navigation flows.
3. Add or update console-visible messages (French) to match language in UI.

Ask me for clarifications if a change crosses multiple files (e.g., schema migration, auth) — I can list exact files to update and suggest minimal migration steps.

---
If you'd like, I can:
- convert the Map-based users to a typed `User` model + Hive TypeAdapter and outline the migration steps
- add unit tests for `DatabaseHelper` (Hive in-memory) and for auth flows

Please tell me which items to prioritize or if you want the `Profile`/`SignIn` mismatch fixed automatically.