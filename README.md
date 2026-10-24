# Pyrewick

A first-person vault raid for phones. Five torchlit holds, a brass key, and an ember ring at the end of each one. Collect cinders along the way; they are not required to leave.

This started from Brackeys' [3D game in Godot](https://github.com/Brackeys/3d-game-in-godot) (CC0) and the KayKit dungeon kit. The playable game, name, and icon are new. It is a first-person dungeon, so it does not share a name or icon with a side-view platformer.

- **Name:** Pyrewick
- **iOS bundle id:** `es.verkvest.pyrewick`
- **Android application id:** `es.verkvest.pyrewick`
- **Godot:** 4.7.2 stable, Mobile renderer, built-in Jolt Physics
- **Team:** ALEKSANDR VERKHOVOD, Team ID `38PT254HDZ`

## Play

Open `3d_game/` in Godot 4.7. The main scene is the title menu.

Landscape. On a phone: the left stick moves, a drag on the right side looks, and JUMP hops. On a desktop: WASD, mouse look (click to capture, Escape to release), and space to jump. Pause is the button at the top right, or the Android back gesture.

Falling into a pit sends you back to the entrance of that hold. Coins you already picked up stay collected. The last ring opens the end screen.

## Why Godot 4.7 and built-in Jolt

The tutorial targeted Godot 4.3 and the godot-jolt 0.14 GDExtension. That extension only loads in Godot 4.3 (`compatibility_maximum = 4.3`), so it cannot ship inside a 4.7 export. Official Godot 4.4+ builds include Jolt Physics in the engine itself, including the iOS and Android templates. The project setting is `Jolt Physics`. The old extension is not in this tree.

The renderer is Mobile, with 2× MSAA and a 2048 directional shadow. There is no SSAO or glow. The 4K autumn HDR stays in the repo for the original tutorial scene and is excluded from the phone export.

## Export

Presets live in `3d_game/export_presets.cfg`.

- **iOS** writes an Xcode project (`application/export_project_only`) for `build/ios/Pyrewick.xcodeproj`. The workflow archives it unsigned, then signs with automatic cloud signing when the App Store Connect API key secrets are present.
- **Android APK** and **Android AAB** use the Gradle build, `minSdk` 24, `targetSdk` 36, and `arm64-v8a`.

`tools/stamp_build.py` sets the iOS build number and the Android version code from `github.run_number` in CI. The marketing version stays `0.1.0`.

## GitHub Actions

| Workflow | What it does |
| --- | --- |
| `ios-testflight` | macOS, Godot export, unsigned archive, then TestFlight upload when `APPSTORE_API_KEY_ID`, `APPSTORE_API_ISSUER_ID`, and `APPSTORE_API_KEY_P8` are set |
| `android` | Ubuntu, release APK and AAB. Signs with `ANDROID_KEYSTORE_B64`, `ANDROID_KEYSTORE_PASSWORD`, and `ANDROID_KEY_ALIAS` when set, otherwise a debug keystore |
| `screenshots` | Phone-aspect menu and gameplay PNGs |

`ITSAppUsesNonExemptEncryption` is false. The iOS job registers bundle id `es.verkvest.pyrewick` through the App Store Connect API if it is missing.

The App Store Connect **app record** cannot be created by the API. If the upload fails because that record does not exist, the workflow says so. Create the app in App Store Connect → Apps → + with bundle id `es.verkvest.pyrewick`, then re-run `ios-testflight`.

For a Play-signed Android bundle, add the three keystore secrets. Without them the artifacts are debug-signed.

## Licenses

Credits & licenses is on the title menu and the end screen. The same notices are in `THIRD_PARTY_LICENSES.md` and `3d_game/THIRD_PARTY_LICENSES.txt`.

KayKit, the Brackeys tutorial, the proto controller, and the Poly Haven autumn HDR are CC0. Godot and Jolt are MIT. The Pyrewick icon and the new game scripts are original and CC0. No extra font and no music are bundled.
