#!/bin/sh
#
# Used to test repo before going live
#
rsync -r -a -v -e ssh --delete repo/Linux64/ olear@10.0.0.10:/srv/www/htdocs/natron/testing/Linux64/
