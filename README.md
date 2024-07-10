# bads_sdk

SDK for bads advertising project.


## Run it

Pre flight checklist:
1. Flutter SDK
2. Android Studio
3. Backend running
4. Replace all `http://*` with your backends ip+port
5. Install `bads-app` and run it (enable the notification permissions in the settings before the app launched for more infos)

**Lets go**
- `flutter run`


## Time complexity

- Fetching ads: `bads_sdk.dart`: ll. 70 - 94, `IDService.dart` ll. 43-58
- Selecting ads: `bads_sdk.dart`: ll. 103-106
- Uploading interaction: `bads_sdk.dart` ll. 117-134 & ll. 110-115, `AppIDManager.dart` ll. 5-9


## TODO
- More ad formats
- Replace direct reporting with proxy based reporting 
- Either build it nativly or drop method channels
- TOTP?

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

