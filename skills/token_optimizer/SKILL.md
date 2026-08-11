---
name: token-optimizer
description: Navigates the appex_lead project directory efficiently without redundant directory listings or file reads, adhering to the 200-lines-per-file modular architecture rule.
---

# Project Token Optimizer Skill

This skill provides instant context on the **appex_lead** codebase structure and enforces modular architecture guidelines. Future agents must use this skill to directly target files and minimize token usage.

## 1. Codebase Structure & Directory Map
Instead of running recursive directory listings, directly navigate to the appropriate path based on the feature layer:

- **Views/Screens (`lib/view/`)**: Containing UI views, organized by feature subfolders.
  - `auth/`: Authentication flow screens.
  - `camera/`: Camera/image capture screens.
  - `complaints/`: Customer complaints screens.
  - `form/`: Generic and specific form UI screens.
  - `interaction/`: Customer interaction/check-in screens.
  - `internet/`: Internet status check screens.
  - `leads/`: Lead management screens.
  - `notifications/`: Push & system notifications.
  - `tracking/`: Location & route tracking.
  - Key standalone files: `dashboard.dart`, `app_settings.dart`, `method_channel_screen.dart`, `shared_prefs_screen.dart`, `splash_screen.dart`.
- **Controllers (`lib/controller/`)**: State management and business logic (mostly using GetX).
  - Organized similarly to `lib/view/` with subfolders like `camera/`, `chart/`, `dash/`, `form/`, `interaction/`, `lead/`, `theme/`, `tracking/`.
  - Standalone controllers: `app_update_controller.dart`, `auth_controller.dart`, `connection_manager.dart`, `notification_controller.dart`.
- **Reusable UI Components (`lib/component/`)**: Tiny widgets, custom drawers, appbars, buttons, inputs.
- **Data Models (`lib/model/`)**: Structure declarations for API payloads and local storage.
  - `form_model.dart`, `lead_model.dart`, `notification_model.dart`.
- **Services (`lib/service/`)**: DB helpers, HTTP/API services, firebase integration.
  - `api_service.dart`, `app_infor_service.dart`, `att_service.dart`, `db_helper.dart`, `firebase_service.dart`, `notificaion_services.dart`, `splash_service.dart`.
- **Utilities (`lib/utils/`)**: Style themes, colors, string constants, and helpers.

---

## 2. Token-Saving Guidelines for Agents
- **No Large Directory Lists**: Do not list top-level directories recursively. Use the map above to determine the exact path.
- **Pinpoint Grepping**: When searching for variables or class references, restrict the `SearchPath` to specific directories (e.g. `lib/controller` or `lib/view`) and use `Includes` to filter by file types (`*.dart`, `*.kt`).
- **Targeted File Reading**: Only read the files relevant to the active task. Read only the specific line range needed using `StartLine` and `EndLine` parameters when files are large.

---

## 3. The 200-Line Limit Constraint
To keep the project clean, structured, and easy to maintain, all new features/files must strictly adhere to the following rule:
- **No file should exceed 200 lines.**
- If a file starts approaching 200 lines, refactor immediately:
  - **For Views**: Extract sub-widgets (e.g. cards, custom headers, forms) into separate files in `lib/component/` or a feature subfolder in `lib/view/`.
  - **For Controllers**: Split massive controllers into smaller sub-controllers or utility helper classes (e.g., delegate APIs to `lib/service/` rather than keeping business logic inside the controller).
