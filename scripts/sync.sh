#!/bin/sh
#
# Sync repo
#
rsync -r -a -v -e ssh --delete repo/Linux64/ olear@10.0.0.10:/srv/www/htdocs/natron/Linux64/
rsync -r -a -v -e ssh --delete src/ olear@10.0.0.10:/srv/www/htdocs/natron/source/
