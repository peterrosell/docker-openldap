TAG=`git config --get remote.origin.url | sed 's/.*\/\(.*\/.*\)/\1/'`
NAME=`echo $TAG | sed 's/.*\/.*-\(.?*\)/\1/'`
