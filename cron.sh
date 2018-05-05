#!/bin/bash

if [ "$CAL2324_COMMIT_USER" = "" ]
then
  CAL2324_COMMIT_USER="cal2434"
fi
if [ "$CAL2324_COMMIT_USER_EMAIL" = "" ]
then
  CAL2324_COMMIT_USER="kmccal@localhost"
fi

cd `dirname $0`

bundle exec ruby parse_wiki.rb
bundle exec ruby parse_wiki_history.rb
bundle exec ruby make_ics.rb > cal2434.ics
