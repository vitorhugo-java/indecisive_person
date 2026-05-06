# The Universe Decides 🌌

The Universe Decides is a Flutter decision app with a dark mystical Material 3 interface. It uses Random.org whenever possible and silently falls back to local randomness when the network is unavailable.

## Included in this app

- Coin flip screen with animated tosses
- RPG dice roller with configurable quantities and polyhedral sides
- Custom list picker with highlighted winners
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

## GitHub Actions signed APK workflow

The repository includes `.github/workflows/build-signed-apk.yml` to generate a signed Android APK, upload it as a workflow artifact, and publish it to this repository's GitHub Releases.

Configure these repository secrets before running the workflow:

- `ANDROID_KEYSTORE_BASE64`: base64-encoded contents of your `.jks` or `.keystore` file
- `ANDROID_KEYSTORE_PASSWORD`: keystore password
- `ANDROID_KEY_ALIAS`: key alias inside the keystore
- `ANDROID_KEY_PASSWORD`: key password

Example command to prepare the keystore secret value:

```bash
base64 -w 0 android/upload-keystore.jks
```

After the secrets are configured, you can:

- push a tag such as `v1.0.0` to build the APK and publish it to the matching GitHub Release
- run the workflow manually and provide a `release_tag` value so the workflow creates or updates that GitHub Release before attaching the APK

## Icon workflow

The repository now includes branded launcher icons. If you want to regenerate them later, use the same source artwork with either:

- [App Icon Forge](https://www.appicon.co/)
- [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons)
