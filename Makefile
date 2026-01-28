DATE := $(shell date +'%Y%m%d_%H%M%S')

pull: 
	git pull origin rath

push: 
	git push origin main

add: 
	git add .
	git commit -m "Commited : $(DATE)"

run: 
	flutter run

clean:
	flutter clean
	flutter pub get

build-android:
	flutter clean
	flutter pub get
	flutter build apk --release

release-android:
	flutter clean
	flutter pub get
	flutter build appbundle --release

build-ios:
	flutter clean
	flutter pub get
	flutter build ios --release --build-name=13 --build-number=46