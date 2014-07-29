#!/bin/sh
rsync -r -a -v -e ssh repo/ olear@10.0.0.10:/srv/www/htdocs/natron/repo/
#rsync -r -a -v -e ssh src/ olear@10.0.0.10:/srv/www/htdocs/natron/source/
