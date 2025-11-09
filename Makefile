DATE := $(shell date +'%Y%m%d_%H%M%S')

git-pull: 
	git pull origin rath

git-push: 
	git add .
	git commit -m "Commited : $(DATE)"
	git push origin main

run: 
	flutter run

clean:
	flutter clean
	flutter pub get