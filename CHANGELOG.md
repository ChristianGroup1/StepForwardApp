# Changelog

All notable changes to the StepForward app are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [3.1.0] – 2026-03-17

### Fixed

- **Bottom navigation bar tap targets** — Inactive nav icons now meet the 48 dp minimum touch
  target recommended by Material Design. The SVG icon is wrapped in a `Padding` widget
  (`horizontal: 12 w`, `vertical: 8 h`) and the surrounding `GestureDetector` uses
  `HitTestBehavior.opaque`, so taps anywhere in the padded area register correctly instead of
  requiring a precise centre-point press. *(PR #10)*

- **Black screen on back-navigation after deep link** — Pressing Back after arriving at a game
  via a deep link no longer shows a blank screen. The fix ensures `mainView` is always pushed as
  the unconditional root before `gameDetailsById` is pushed on top of it. `signOut()` also now
  clears the cached user data so the auth check returns `false` after sign-out, preventing the
  broken-stack scenario from occurring in the first place. *(PR #9)*

- **YouTube video playback (error 153)** — All embedded YouTube videos were failing to load
  because `youtube_player_embed` uses a WebView approach that YouTube restricts. The package has
  been replaced with `youtube_player_flutter`, which uses YouTube's official iframe API.
  URL parsing was also improved to correctly handle Shorts (`/shorts/`), mobile
  (`m.youtube.com`), embed, and standard watch URLs. *(PR #8)*

- **Deep link warm-start z-order glitch** — When the app was already running in the background
  and a `stepforward://game/{id}` link was tapped, the game-details screen was rendered beneath
  the home screen (only a thin sliver visible). Navigation is now deferred with
  `addPostFrameCallback` so the route is pushed after Flutter's rendering pipeline has fully
  resumed. A double-push race condition where both `uriLinkStream` and `navigatePendingIfAny`
  fired for the same link was also resolved. *(PR #6)*

---

## [3.0.0] – 2026-03-06

### Added

- **Arabic / English language support** — Full bilingual UI via `flutter_intl` ARB files.
  A `LanguageCubit` persists the user's locale selection across restarts using
  `SharedPreferences`, and `MaterialApp.locale` updates without requiring an app restart. *(PR #7)*

- **Automatic AI-powered content translation** — Switching to English automatically translates
  Firebase-stored Arabic content (game names, explanations, tools, rules, spiritual goals,
  hashtags; servant denomination, church, city, ministries) using the MyMemory free translation
  API. Translated strings are cached in-memory so the same text is never re-fetched. *(PR #7)*

- **Approval & ID-upload flow** — Users whose accounts are pending approval see a contextual
  banner on the Games tab and are guided through uploading front/back ID images. The Brothers tab
  remains gated until approval is granted. *(PR #3)*

- **Profile picture menu** — A "more" badge on the profile picture in the More tab opens a
  dropdown for uploading or removing the profile photo. *(PR #3)*

- **`TranslatableText` widget** — Drop-in replacement for `Text` that translates its content
  automatically when the locale is English, with a version counter to discard stale async
  results. *(PR #7)*

### Fixed

- **Post-sign-out auth state** — Fixed a bug where `_isUserAuthenticated()` could return `true`
  after sign-out because only the location cache was cleared; user data is now also removed. *(PR #9)*

---

## [1.0.0] – 2025-06-25

### Added

- **Authentication system** — Full email/password login, sign-up, and forgot-password flows
  built with Firebase Authentication and the BLoC state-management pattern. *(PR #1)*

- **Login screen** — `LoginViewBody` widget with form validation and Firebase sign-in. *(PR #1)*

- **Sign-up screen** — `SignUpViewBody` with `SignUpTextFields` input widget and
  `SignUpBlocConsumer` for reactive state handling. *(PR #1)*

- **Forgot-password screen** — Password-reset email flow integrated with Firebase Auth. *(PR #1)*

- **`OrDivider` widget** — Visual "OR" separator reused across login and sign-up views. *(PR #1)*

- **Main view** — Initial `MainView` scaffold that displays the authenticated user's phone
  number. *(PR #1)*

- **Project scaffolding** — Flutter project set up with Firebase Core, Cloud Firestore, Firebase
  Storage, Firebase Analytics, BLoC, `flutter_screenutil`, Cairo font family, and multi-platform
  support (Android, iOS, Web, Linux, macOS, Windows). *(PR #1)*

---

## Deployment

The web build is deployed automatically to Firebase Hosting at
**[https://www.elshaddaiteam.com](https://www.elshaddaiteam.com)** on every push to `main` via
the GitHub Actions workflow in `.github/workflows/firebase-hosting-deploy.yml`.
