#!/bin/bash

if [ "$CAL2324_COMMIT_USER" = "" ]
then
  CAL2324_COMMIT_USER="cal2434"
fi
if [ "$CAL2324_COMMIT_USER_EMAIL" = "" ]
then
  CAL2324_COMMIT_USER="cal2434@localhost"
fi

cd `dirname $0`

bundle exec ruby parse_wiki.rb
bundle exec ruby make_ics.rb > cal2434.ics

git add resource/ cal2434.ics
git -c "user.name=$CAL2324_COMMIT_USER" -c "user.email=$CAL2324_COMMIT_USER_EMAIL" commit -m "`date`"
git push
