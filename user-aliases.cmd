;= @echo off
;= rem Call DOSKEY and use this file as the macrofile
;= %SystemRoot%\system32\doskey /listsize=1000 /macrofile=%0%
;= rem In batch mode, jump to the end of the file
;= goto:eof
;= Add aliases below here
e.=explorer .
ls=ls --show-control-chars -F --color $*
pwd=cd
clear=cls
history=cat "%CMDER_ROOT%\config\.history"
unalias=alias /d $1
vi=vim $*
cmderr=cd /d "%CMDER_ROOT%"

;= rem Ahmed Eid <ahmedaeid@outlook.com>


;= rem Custom Aliases

..=cd ..
...=cd ../..
....=cd ../../..
/=cd /
md=mkdir $1
rd=rmdir $1

;= rem Git Aliases
g=git
gls=git log --pretty=format:"%C(yellow)%h%Cred%d %Creset%s%Cblue [%cn]" --decorate
gll=git log --pretty=format:"%C(yellow)%h%Cred%d %Creset%s%Cblue [%cn]" --decorate --numstat
gld=git log --pretty=format:"%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=relative
glg=git log --graph --abbrev-commit --decorate --format=format:"%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)" --all
glg2=git log --graph --abbrev-commit --decorate --format=format:"%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)" --all
gfl=git log -u
ggr=git grep -Ii
gcp=git cherry-pick
gs=git status
gst=git status -sb
gc=git commit
gci=git commit --interactive
gcm=git commit -m $1
gamend=git commit --amend
ga=git add .
gai=git add --interactive
ggo=git checkout $1
gbr=git branch $1
gdiff=git diff --word-diff
gr=git reset
grh=git reset --hard
gundo=git reset
grh1=git reset HEAD~1 --hard
gcl=git clone $1
gpl=git pull $1 $2:$2
gpsh=git push $1 $2:$2
gt=git tag $1


;= rem NPM Aliases
n=npm
ni=npm install
nig=npm install -g $1
nis=npm install --save $1
nid=npm install --save-dev $1
nus=npm unistall --save $1
nud=npm unistall --save-dev $1
nr=npm run
nt=npm test
nit=npm install && npm test