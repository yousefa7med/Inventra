---
name: Inventra
description: Offline-first Arabic RTL inventory + POS app for small retailers
colors:
  primary: "#1E3A8A"
  secondary: "#4F46E5"
  success: "#22C55E"
  warning: "#F59E0B"
  error: "#EF4444"
  dark-blue: "#04133C"
  grey: "#757682"
  red: "#BA1A1A"
  light-blue: "#5872C5"
  light-red: "#FFDAD6"
  surface: "#F9F9F9"
  white: "#FFFFFF"
  black-87: "#DD000000"
  black-54: "#8A000000"
  shadow-black: "#0A000000"
  white-70: "#B3FFFFFF"
  grey-light-100: "#F5F5F5"
  grey-medium-200: "#EEEEEE"
  grey-medium-300: "#E0E0E0"
  grey-medium-400: "#BDBDBD"
  grey-medium-500: "#9E9E9E"
  snackbar-default: "#323232"
  dark-red: "#960000"
typography:
  display:
    fontFamily: "Cairo"
    fontWeight: 700
    fontSize: "26sp"
    lineHeight: 1.2
  headline:
    fontFamily: "Cairo"
    fontWeight: 600
    fontSize: "24sp"
    lineHeight: 1.3
  title:
    fontFamily: "Cairo"
    fontWeight: 600
    fontSize: "20sp"
    lineHeight: 1.4
  body:
    fontFamily: "Cairo"
    fontWeight: 400
    fontSize: "16sp"
    lineHeight: 1.5
  label:
    fontFamily: "Cairo"
    fontWeight: 500
    fontSize: "14sp"
    letterSpacing: "0.02em"
rounded:
  sm: "8px"
  md: "12px"
  lg: "16px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "16px"
  lg: "24px"
  xl: "32px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.white}"
    rounded: "{rounded.md}"
    padding: "16px 24px"
  button-primary-hover:
    backgroundColor: "{colors.secondary}"
    textColor: "{colors.white}"
    rounded: "{rounded.md}"
    padding: "16px 24px"
  app-bar:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.primary}"
  dropdown:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.black-87}"
    borderColor: "{colors.grey-medium-300}"
    focusedBorderColor: "{colors.primary}"
    rounded: "{rounded.md}"
    padding: "14px 16px"
  input-field:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.black-87}"
    borderColor: "{colors.grey-medium-300}"
    focusedBorderColor: "{colors.primary}"
    rounded: "{rounded.md}"
    padding: "14px 16px"
  card:
    backgroundColor: "{colors.white}"
    borderColor: "{colors.grey-medium-200}"
    rounded: "{rounded.md}"
    padding: "16px"
---

# Design System: Inventra

## Overview

**Creative North Star: "The Trusted Ledger"**

Inventra's design system embodies the dependable, no-nonsense character of a well-worn merchant's ledger — precise, legible, and built for daily commercial rhythm. The visual language prioritizes Arabic-first clarity: generous touch targets for one-handed counter use, high-contrast typography in Cairo that renders Arabic diacritics cleanly, and a restrained blue-indigo palette that signals trust without ornament. Every screen serves the shop-floor workflow: scan → invoice → balance check in under 30 seconds. Density is purposeful, not decorative; whitespace breathes around numbers that matter (totals, balances, quantities). Dark theme exists but remains disabled pending full audit — the system is designed for daylight retail environments first.

**Key Characteristics:**
- Arabic RTL exclusive, Cairo font only
- Blue-indigo primary palette (trust, finance, clarity)
- 12px base radius — approachable, not sharp
- ScreenUtil scaling (360×690 baseline) — consistent across densities
- Flat surfaces with tonal layering — no decorative shadows
- Component themes centralized in AppTheme — zero hardcoded styling

## Colors

The palette centers on a deep blue primary (#1E3A8A) that reads as authoritative on both light and dark surfaces, paired with an indigo secondary (#4F46E5) for interactive accents. Semantic colors (success, warning, error) use Material-standard hues for instant recognition. Neutrals span a 6-step grey scale for text hierarchy and surface separation. Surface (#F9F9F9) serves as the default canvas — warmer than pure white, easier on eyes under shop lighting.

### Primary
- **Deep Trust Blue** (#1E3A8A): Primary brand color — app bars, primary buttons, active navigation, key totals. Used sparingly (≤15% of screen) to preserve weight.

### Secondary
- **Action Indigo** (#4F46E5): Secondary actions, focused states, links, hovered primary buttons. Signals interactivity without competing with primary.

### Tertiary
- **Info Light Blue** (#5872C5): Informational highlights, disabled primary variants, subtle backgrounds. Lower chroma for supporting roles.

### Neutral
- **Surface** (#F9F9F9): Default screen background, card backgrounds, input fills.
- **White** (#FFFFFF): Card elevations, modal backgrounds, printed invoice simulation.
- **Grey Light 100** (#F5F5F5): Dividers, disabled backgrounds, subtle separators.
- **Grey Medium 200** (#EEEEEE): Card borders, input borders (default).
- **Grey Medium 300** (#E0E0E0): Input borders (enabled), dropdown borders.
- **Grey Medium 400** (#BDBDBD): Placeholder text, secondary icons.
- **Grey Medium 500** (#9E9E9E): Hint text, disabled text.
- **Grey** (#757682): Secondary labels, inactive nav icons.
- **Black 87%** (#DD000000): Primary body text, headings.
- **Black 54%** (#8A000000): Secondary body text, metadata.
- **White 70%** (#B3FFFFFF): Disabled button text, inactive dark-theme elements.
- **Shadow Black** (#0A000000): Subtle elevation shadows (10% opacity).

### Semantic
- **Success Green** (#22C55E): Positive balances, completed transactions, inventory increases.
- **Warning Amber** (#F59E0B): Low stock alerts, pending payments, attention states.
- **Error Red** (#EF4444): Negative balances, failed operations, destructive actions.
- **Dark Red** (#960000): Critical alerts, delete confirmations, overdraft warnings.
- **Light Red** (#FFDAD6): Error field backgrounds, destructive action chips.
- **Snackbar Default** (#323232): Snackbar background for all toast messages.

### Named Rules
**The Ledger Ink Rule.** Primary blue appears on ≤15% of any screen — totals, primary CTAs, active nav only. Its scarcity creates trust.

**The Semantic Fidelity Rule.** Success/Warning/Error colors are reserved exclusively for their semantic meaning. Never repurpose success green for "primary action" or error red for "accent."

## Typography

**Display Font:** Cairo (with system fallback)
**Body Font:** Cairo (with system fallback)
**Label/Mono Font:** Cairo (with system fallback)

**Character:** Single-font system using Cairo at all weights and sizes. Cairo's open counters and clear diacritic rendering make it ideal for Arabic financial data — numerals stay distinguishable at small sizes, vocalization marks don't collide. The 4-weight scale (Regular 400, Medium 500, SemiBold 600, Bold 700) provides hierarchy without font switching. All sizes use `.sp` scaling via flutter_screenutil for density independence.

### Hierarchy
- **Display** (Bold 700, 26sp, 1.2 line-height): Screen titles only — Dashboard, Inventory, Safe. One per screen max.
- **Headline** (SemiBold 600, 24sp, 1.3 line-height): Section headers, card titles, invoice totals.
- **Title** (SemiBold 600, 20sp, 1.4 line-height): List item titles, form section labels, dialog titles.
- **Body** (Regular 400, 16sp, 1.5 line-height): Primary reading text, descriptions, invoice line items. Max line length ~60 Arabic chars.
- **Label** (Medium 500, 14sp, 0.02em letter-spacing): Button labels, chip text, nav labels, form field labels.

### Named Rules
**The Single Voice Rule.** One font family (Cairo) everywhere. No mixing, no fallback display faces. Consistency is the brand.

**The Scale Discipline Rule.** Only the 8 canonical sizes (12–26 in 2sp steps) are permitted. No arbitrary `fontSize: 17.5` — round to nearest step.

## Layout

ScreenUtil design baseline: 360×690dp (typical 5.5" phone). All spacing, sizing, and typography scale via `.w`, `.h`, `.sp` extensions. Base spacing unit: 8px. Rhythm follows 4px increments (4, 8, 12, 16, 24, 32). Content padding: 16px horizontal (standard), 24px for dense lists. Cards use 16px internal padding. Grid cards on Dashboard use 2-column layout with 16px gap, 1.6 aspect ratio. Bottom nav height: 58px fixed. App bar: standard Material height with RTL title alignment. No desktop/tablet breakpoints — Android phone primary, adaptive web secondary.

## Elevation & Depth

Flat-by-default with tonal layering. Shadows are structural, not decorative — used only for: modal bottom sheets (elevation 8), dropdown menus (elevation 4), and snackbar (elevation 6). Cards sit flat on surface with 1px border (Grey Medium 200) for separation. No shadow on cards, buttons, or app bar. Dark theme (when enabled) will use tonal elevation (surface variants) rather than shadow-heavy Material defaults.

### Shadow Vocabulary
- **Modal Elevation** (`0 8px 24px rgba(0,0,0,0.12)`): Bottom sheets, dialogs, full-screen modals.
- **Dropdown Elevation** (`0 4px 16px rgba(0,0,0,0.10)`): Dropdown menus, autocomplete popovers.
- **Snackbar Elevation** (`0 6px 20px rgba(0,0,0,0.15)`): All snackbars, toasts.

### Named Rules
**The Flat Surface Rule.** Cards, buttons, inputs, and app bars have zero elevation at rest. Borders and tonal contrast create separation — not shadows.

## Shapes

Unified 12px border radius (rounded.md) for all interactive containers: buttons, inputs, dropdowns, cards, dialogs, bottom sheets. Smaller 8px (rounded.sm) for chips, badges, and inline tags. No sharp corners (0px) and no pill shapes (fully rounded) — the 12px radius reads as "professional tool" not "consumer app." Borders: 1px Grey Medium 200 for cards/containers, 1px Grey Medium 300 for inputs/dropdowns (default), 2px Primary for focused inputs. No outset/inset border tricks — flat, honest edges.

## Components

### Buttons
- **Shape:** Gently rounded corners (12px / rounded.md)
- **Primary:** Deep Trust Blue background, White text, 16px vertical × 24px horizontal padding. Min width: full-width (AppButton) or 120px (inline).
- **Hover/Focus:** Action Indigo background (secondary), White text, instant transition (100ms).
- **Disabled:** Grey Medium 300 background, Grey Medium 500 text, no interaction.
- **Secondary (Outlined):** Transparent background, Primary border (2px), Primary text. Hover: Primary background 10% opacity.
- **Destructive:** Dark Red background, White text. Hover: Error Red.

### App Bar
- **Style:** Surface background, Primary foreground, centered RTL title. Back chevron (RTL-mirrored) on left. No elevation, 1px bottom border (Grey Medium 200) when content scrolls.

### Dropdown / Select
- **Style:** Surface fill, 12px radius, Grey Medium 300 border (default), Primary border 2px (focused). Padding: 14px vertical × 16px horizontal. Label: Grey Medium 500. Chevron: Grey Medium 400.

### Inputs / Fields (AppTextField)
- **Style:** Surface fill, 12px radius, Grey Medium 300 border (enabled), Primary 2px border (focused), Error Red border (error). Padding: 14px vertical × 16px horizontal. Placeholder: Grey Medium 500. Error text: Error Red, Label size (14sp).
- **Focus:** Border color shift to Primary (2px), no glow/shadow.
- **Error:** Error Red border, Error Red helper text, Light Red background tint optional.

### Cards / Containers
- **Corner Style:** 12px radius (rounded.md)
- **Background:** White (light), Surface variant (dark - TBD)
- **Border:** 1px Grey Medium 200
- **Internal Padding:** 16px (spacing.md)
- **Shadow:** None (flat by default)

### Navigation (Bottom Nav)
- **Style:** PersistentBottomNavBarV2 Style8, height 58px, White background. Active: Primary icon/label. Inactive: Grey icon/label (dark theme: White70). Label: Cairo navBar style (14sp equivalent). No elevation, top border: Grey Medium 200.

### Product Card (Signature Component)
- **Layout:** Horizontal — thumbnail (64×64, 8px radius) | name + barcode + prices | quantity badge | trailing actions
- **Typography:** Title (SemiBold 600, 16sp) for name; Label (Medium 500, 12sp) for barcode; Body (Regular 400, 14sp) for prices
- **Colors:** White card, Grey Medium 200 border, Success Green for positive stock, Error Red for zero/negative stock
- **Interactions:** Tap → edit, Long press → delete confirmation, Quantity counter inline (+/-)

### Dashboard Grid Card (Signature Component)
- **Layout:** Square-ish (1.6 aspect), large number centered, label below
- **Typography:** Display (Bold 700, 26sp) for number; Label (Medium 500, 14sp) for label
- **Colors:** Each card gets distinct semantic color (Primary, Grey, Error, Success) as accent bar (4px left border) + number color

## Do's and Don'ts

### Do:
- **Do** use `AppColors` exclusively `AppTextField` for every text input — never raw `TextFormField`.
- **Do** use `AppButton` for every full-width primary action — never `ElevatedButton` in `SizedBox`.
- **Do** use `AppNavigation.pushName()` for all navigation — never `Navigator.of(context)`.
- **Do** use `showSnackBar(context, message)` for all toasts — never `ScaffoldMessenger`.
- **Do** extract every reusable UI piece into a named widget class in `features/*/presentation/widgets/` or `core/widgets/`.
- **Do** use `buildWhen` on every `BlocBuilder` and `listenWhen` on every `BlocListener`.
- **Do** define component themes in `AppTheme` (elevatedButtonTheme, inputDecorationTheme, dropdownMenuTheme, cardTheme) — never hardcode `BoxDecoration` or `InputDecoration` in widgets.
- **Do** use `const` constructors for all immutable widgets and literals.
- **Do** scale all spacing/sizing/typography with `.w`, `.h`, `.sp` via flutter_screenutil.
- **Do** use 12px border radius for buttons, inputs, dropdowns, cards; 8px for chips/badges.
- **Do** reserve Primary blue for ≤15% of screen — totals, primary CTA, active nav only.

### Don't:
- **Don't** hardcode any color value — always reference `AppColors.*`.
- **Don't** hardcode any `TextStyle()` — always reference `AppTextStyle.*`.
- **Don't** hardcode `BoxDecoration`, `InputDecoration`, `ButtonStyle`, `DropdownMenuThemeData`, `CardTheme` in widgets.
- **Don't** use inline `Widget Function()` builders or private `_build*()` methods for reusable UI.
- **Don't** use raw `ElevatedButton`, `TextFormField`, `TextField`, `Navigator.push*`, `ScaffoldMessenger.showSnackBar`.
- **Don't** add new dependencies without PR justification.
- **Don't** use `getAll()` in build methods — use ObjectBox `query().watch()` for reactive UI.
- **Don't** invent arbitrary font sizes — stick to the 8 canonical steps (12–26sp).
- **Don't** use shadows on cards, buttons, or app bars — flat surfaces with borders only.
- **Don't** commit directly to main/master — all work on `feature/<spec-name>` branches via PR.