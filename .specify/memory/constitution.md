<!--
Sync Impact Report
-Version change: 1.4.0 → 1.5.0
-Modified principles:
  - IX. Custom Widget Architecture → expanded with BlocBuilder state body rule
-Added sections: none
-Removed sections: none
-Templates requiring updates:
  - .specify/templates/plan-template.md — ⚠ pending
  - .specify/templates/spec-template.md — ⚠ pending
  - .specify/templates/tasks-template.md — ⚠ pending
-Follow-up TODOs: none
-->

# Inventra Constitution

## Core Principles

### I. Code Quality & Maintainability
All production code MUST adhere to established Dart/Flutter style conventions (effective Dart, lint rules from `analysis_options.yaml`). Every feature MUST be implemented as a self-contained module within `features/` following the existing feature-based architecture. Code MUST be reviewed for: single-responsibility, dependency inversion via GetIt, proper error handling with Result/Either patterns, and zero compiler warnings (`flutter analyze` clean). Refactoring is MANDATORY when cyclomatic complexity exceeds 10 or a file exceeds 300 lines. Copy-paste reuse is FORBIDDEN—extract shared logic to `core/` utilities or feature-shared packages.

### II. Test-First Discipline (NON-NEGOTIABLE)
Test-Driven Development is mandatory for all new business logic. Unit tests MUST be written FIRST (Red), then implementation (Green), then refactor—no exceptions. Minimum coverage targets: 90% for `core/` and feature `controller/cubit/` layers, 80% for `presentation/views/`. Integration tests REQUIRED for: ObjectBox entity CRUD, repository contracts, navigation routes, and BLoC state transitions. Test files MUST live alongside source (`*_test.dart`) and use `flutter_test` + `bloc_test` + `mocktail`. CI gate: `flutter test --coverage` must pass with thresholds enforced.

### III. User Experience Consistency (Arabic RTL First)
The app is ARABIC-ONLY (RTL, `Locale('ar')`). ALL user-facing text MUST use Arabic localization keys—no hardcoded strings in widgets. UI MUST conform to `AppTheme` (light/dark `ColorScheme` from `AppColors`), `flutter_screenutil` sizing (`.w`, `.h`, `.sp`), and `PersistentBottomNavBarV2` navigation patterns. Custom page transitions via `AppRouter` are REQUIRED for all feature screens. Accessibility: semantic labels in Arabic, minimum 4.5:1 contrast (WCAG AA), touch targets ≥48×48dp. RTL mirroring is automatic—never hardcode `textDirection: ltr`.

### IV. Visual Consistency (Colors & TextStyles — NON-NEGOTIABLE)
NEVER hardcode colors or TextStyles in widgets. All colors MUST use the `AppColors` class exclusively. All text styles MUST use the `AppTextStyle` class exclusively. If a needed color or style is missing, add it to the respective class FIRST, then reference it everywhere. This ensures theme consistency, easy maintenance, and single source of truth for the visual language.

### V. Performance & Resource Efficiency
App startup (cold) MUST stay ≤2s on mid-range Android (Snapdragon 680 / 4GB RAM). Frame drops (jank) MUST stay <5% during scroll-heavy screens (inventory lists, dashboards). ObjectBox queries MUST use indexes and `query()` with `watch()` for reactive UI—no `getAll()` in build methods. Images MUST use `flutter_svg` for icons, `image_picker` with `maxWidth: 800` compression. Memory leaks from BLoC streams, `StreamController`, or `ImageCache` are BLOCKING issues—profile with `flutter run --profile --trace-startup` before merge.

### VI. Architectural Simplicity & YAGNI
Prefer SIMPLE solutions: BLoC Cubits over full Blocs, feature folders over micro-packages, `GetIt` singletons over code-gen DI. NO external backend—ObjectBox is the ONLY persistence. NO code generation beyond ObjectBox (`build_runner`). NO feature flags, A/B testing, or analytics unless explicitly spec'd. Every new dependency MUST be justified in PR description with `flutter pub add` rationale. Remove dead code ruthlessly—`dart analyze --fatal-infos` enforces.

### VII. Navigation & UI Utilities Consistency (NON-NEGOTIABLE)
ALL navigation MUST use `AppNavigation` methods (`pushName`, `pushWithReplacement`, `pushAndRemoveUntil`, `pop`) exclusively. Direct `Navigator.of(context)` or `Navigator.push*` calls are FORBIDDEN. ALL snackbar/messages MUST use the `showSnackBar` function from `core/helper/functions.dart` exclusively. Direct `ScaffoldMessenger.of(context).showSnackBar()` calls are FORBIDDEN. This ensures consistent navigation behavior, uniform snackbar styling, and a single point of maintenance for UI feedback patterns.

### VIII. Shared Widget Consistency (NON-NEGOTIABLE)
ALL text input fields MUST use `AppTextField` from `core/widgets/app_text_field.dart` exclusively. Raw `TextFormField` or `TextField` with manual `InputDecoration` is FORBIDDEN. ALL full-width action buttons MUST use `AppButton` from `core/widgets/app_button.dart` exclusively. Raw `ElevatedButton` wrapped in `SizedBox` is FORBIDDEN. If a needed variant is missing, extend the shared widget FIRST, then use it everywhere. This ensures uniform input styling, consistent button sizing, and a single point of maintenance for form elements.

### IX. Custom Widget Architecture (NON-NEGOTIABLE)
NEVER use inline `Widget Function()` builders or private `_build*()` methods for reusable UI sections. ALL distinct UI components MUST be extracted into proper `StatelessWidget` or `StatefulWidget` classes. Feature-specific widgets go in `features/<name>/presentation/widgets/`. Common/reusable widgets go in `core/widgets/`. Each widget file MUST contain a single public widget class. In `BlocBuilder`, each state body (e.g., `SafeLoading`, `SafeError`, `SafeLoaded`) MUST be a separate widget class (e.g., `SafeLoadingBody`, `SafeErrorBody`, `SafeLoadedBody`). This ensures testability, reusability, clear separation of concerns, and prevents view files from exceeding 300 lines.

## Quality Gates & Compliance

### Definition of Done (Mandatory for every PR)
- [ ] `flutter analyze` — zero errors/warnings
- [ ] `flutter test --coverage` — thresholds met (core 90%, features 80%)
- [ ] `flutter build apk --debug` — compiles without warnings
- [ ] Manual RTL smoke test on device/emulator (Arabic text, nav, forms)
- [ ] Performance profile: no new jank frames in changed screens
- [ ] CHANGELOG.md entry under `## [Unreleased]` with type (feat/fix/perf/refactor)

### Technology Stack Constraints
- Flutter SDK: pinned in `.fvm/fvm_config.json` (currently 3.22.x)
- State: `flutter_bloc` ^9.1.1 (Cubit pattern only)
- DI: `get_it` ^9.2.1 (LazySingleton registrations in `main.dart`)
- DB: `objectbox` ^5.3.2 + `objectbox_generator` (codegen mandatory)
- Navigation: Custom `AppRouter` + `AppNavigation` (NO go_router)
- Theming: `AppTheme.lightTheme` / `darkTheme` only
- Localization: `flutter_localizations` + `Locale('ar')` hardcoded
- Responsive: `flutter_screenutil` ^5.9.3 (design size 360×690)

## Governance

This Constitution supersedes all ad-hoc practices, team conventions, and prior art. Amendments require:
1. Written proposal in PR description referencing principle(s) affected
2. Approval from 2+ core maintainers (or sole maintainer + 24h review period)
3. Migration plan for existing code if breaking
4. Version bump per SemVer: MAJOR for principle removal/redefinition, MINOR for new principle/section, PATCH for clarifications
5. Update of `CHANGELOG.md`, `AGENTS.md`, and affected templates (`.specify/templates/*`)

All PR reviews MUST verify compliance with Core Principles I–IX and Quality Gates. Complexity (new deps, patterns, files >300 LOC) MUST be justified in PR description. Runtime guidance lives in `AGENTS.md`—keep both docs in sync.

**Version**: 1.5.0 | **Ratified**: 2026-07-06 | **Last Amended**: 2026-07-07
