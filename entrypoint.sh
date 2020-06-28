#!/bin/sh

set -eu

## Variables
## https://stackoverflow.com/a/32343069/3441436
: "${TZ:=""}"                                 # set timezone, example: "Europe/Berlin"

lsb_dist="$(. /etc/os-release && echo "$ID")" # get os (example: debian or alpine) - do not change!

if [[ "$1" == "sh" ]]; then
    exec sh
fi

## set TimeZone
if [ -n "$TZ" ]; then
	echo ">> set timezone to ${TZ} ..."
	if [ "$lsb_dist" = "alpine" ]; then apk add --no-cache --virtual .fetch-tmp tzdata; fi
	#ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime
	cp /usr/share/zoneinfo/${TZ} /etc/localtime
	echo ${TZ} >  /etc/timezone
	echo "date.timezone=${TZ}" >> /usr/local/etc/php/conf.d/${PHP_INI_FILE_NAME}
	if [ "$lsb_dist" = "alpine" ]; then apk del --no-network .fetch-tmp; fi
	date
fi

# more entrypoint-files
for f in /entrypoint.d/*; do
	case "$f" in
		*.sh)
			if [ ! -x "$f" ] ; then 
				chmod +x $f
			fi
			echo ">> execute $f"
			/bin/sh $f
			;;
		*)  echo ">> $f is no *.sh-file!" ;;
	esac
done

if [[ "$1" != "prosody" ]]; then
    exec prosodyctl "$@"
    exit 0;
fi

if [ "$LOCAL" -a  "$PASSWORD" -a "$DOMAIN" ] ; then
    prosodyctl register "$LOCAL" "$DOMAIN" "$PASSWORD"
fi

# exec CMD
echo ">> exec docker CMD"
echo "$@"
exec "$@"
