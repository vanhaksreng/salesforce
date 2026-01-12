# salesforce

Trade B2B.

dart run realm generate
flutter build apk --release
flutter build appbundle --release

adb install build/app/outputs/flutter-apk/app-release.apk

flutter clean && flutter pub get

flutter clean && flutter pub get && flutter build apk --release
flutter clean && flutter pub get && flutter run

flutter build ios --build-name=13.0.0 --build-number=46