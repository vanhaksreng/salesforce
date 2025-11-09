
git-pull: 
	git pull origin rath

git-push: 
	git add .
	git commit -m "Commited : $(DATE)"
	git push origin main