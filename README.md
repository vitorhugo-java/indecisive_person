# indecisive_person

The Universe Decides is a polished Flutter shell for an indecisive-person utility app. This phase focuses on release preparation by replacing the default starter screen with a branded overview and by tightening the native app setup for store submission.

## Included in this phase

- Branded home screen describing the three core experiences:
  - Animated Coin Flip
  - RPG Dice Roller
  - Custom List Picker
- Consistent app naming for Android and iOS
- Unique application identifier: `com.hugo.theuniversedecides`
- Release signing support through `android/key.properties`
- Custom launcher icons for Android and iOS

## Android release signing

1. Generate a keystore and keep it somewhere safe.
2. Copy `android/key.properties.example` to `android/key.properties`.
3. Fill in the real values and keep both the keystore file and passwords out of source control.

Example:

```properties
storePassword=replace-me
keyPassword=replace-me
keyAlias=upload
storeFile=upload-keystore.jks
```

When `android/key.properties` is present, release builds use that keystore automatically. Otherwise, the project falls back to the debug signing config for local-only release runs.

## Icon workflow

The repository now includes branded launcher icons. If you want to regenerate them later, use the same source artwork with either:

- [App Icon Forge](https://www.appicon.co/)
- [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons)
