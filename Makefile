DATE := $(shell date +'%Y%m%d_%H%M%S')

pull: 
	git pull origin rath

push: 
	git add .
	git commit -m "Commited : $(DATE)"
	git push origin main

add: 
	git add .
	git commit -m "Commited : $(DATE)"

run: 
	flutter run

clean:
	flutter clean
	flutter pub get