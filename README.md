# salesforce

./gradlew clean
./gradlew build 

Trade B2B.

dart run realm generate
flutter build apk --release
flutter build appbundle --release

adb install build/app/outputs/flutter-apk/app-release.apk

flutter clean && flutter pub get

flutter clean && flutter pub get && flutter build apk --release
flutter clean && flutter pub get && flutter run

flutter build ios --release --build-name=13.0.9 --build-number=1

ALTER TABLE distribution_setup 
    ADD COLUMN IF NOT EXISTS promotion_type_expanded VARCHAR(3) DEFAULT 'No' COMMENT 'checkbox',
    ADD COLUMN IF NOT EXISTS choose_sale_price VARCHAR(3) DEFAULT 'No' COMMENT 'checkbox',
    ADD COLUMN IF NOT EXISTS check_in_area_mode VARCHAR(15) DEFAULT '' COMMENT 'option|"",By Customer';

ALTER TABLE customer 
    ADD COLUMN IF NOT EXISTS check_in_area INT(11) DEFAULT 0;
