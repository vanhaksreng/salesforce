# salesforce

Trade B2B.

dart run realm generate
flutter build apk --release
flutter build appbundle --release

adb install build/app/outputs/flutter-apk/app-release.apk

flutter clean && flutter pub get

flutter clean && flutter pub get && flutter build apk --release
flutter clean && flutter pub get && flutter run

flutter build ios --release --build-name=13.0.6 --build-number=1


==============
=> In sale order not show pending upload when create new sale offline
=> Duble check on auto synce & upload sale
=> Double check on upload data , why saleperson schedule auto insert blank record