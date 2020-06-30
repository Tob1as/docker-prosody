#!/bin/sh

set -eu

## Variables
## https://stackoverflow.com/a/32343069/3441436
: "${TZ:=""}"                                 # set timezone, example: "Europe/Berlin"
: "${SELECT_COMMUNITY_MODULES:=""}"           # select modules, separate with spaces (symlink will create from available to enable)
: "${ENABLE_CONFD:="0"}"                      # set 1 to enable
: "${ENABLE_MODULE_PATHS:="0"}"               # set 1 to enable

lsb_dist="$(. /etc/os-release && echo "$ID")" # get os (example: debian or alpine) - do not change!

## set TimeZone
if [ -n "$TZ" ]; then
	echo ">> set timezone to ${TZ} ..."
	#if [ "$lsb_dist" = "alpine" ]; then apk add --no-cache --virtual .fetch-tmp tzdata; fi
	#ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime
	cp /usr/share/zoneinfo/${TZ} /etc/localtime
	echo ${TZ} >  /etc/timezone
	#if [ "$lsb_dist" = "alpine" ]; then apk del --no-network .fetch-tmp; fi
	date
fi

## select modules, separate with spaces (symlink will create from available to enable)
if [ -n "$SELECT_COMMUNITY_MODULES" ]; then
	#echo ">> set community modules: ${SELECT_COMMUNITY_MODULES}"
	echo ">> set community modules:"
	#reset_IFS=$IFS
	#IFS=' '
	for c_module in $SELECT_COMMUNITY_MODULES; do
		echo "-> $c_module"
		ln -sf /usr/lib/prosody/modules-community-available/${c_module} /usr/lib/prosody/modules-community-enable/${c_module}
	done
	#IFS=$reset_IFS
fi

# more entrypoint-files
for f in /entrypoint.d/*; do
	#echo ">> entrypoint-file: $f"
	case "$f" in
		*.sh)
			if [ ! -x "$f" ] ; then 
				chmod +x $f
			fi
			echo ">> execute $f"
			/bin/sh $f
			;;
		*.cfg.lua)
			if [ "/entrypoint.d/prosody.cfg.lua" == "$f" ] ; then 
				cp $f /etc/prosody/
				echo ">> copy $f in /etc/prosody/"
			else
				cp $f /etc/prosody/conf.d/
				echo ">> copy $f in /etc/prosody/conf.d/"
			fi
			;;
		*)  echo ">> $f must be a \".sh\" or \".cfg.lua\" file!" ;;
	esac
done

## enable conf.d (only need if use default config and conf.d folder)
if [ "$ENABLE_CONFD" -eq "1" ] ; then
	grep -qxF 'Include "conf.d/*.cfg.lua"' /etc/prosody/prosody.cfg.lua || echo 'Include "conf.d/*.cfg.lua"' >> /etc/prosody/prosody.cfg.lua
	echo ">> enable conf.d"
fi

## enable module path (see dockerfile)
if [ "$ENABLE_MODULE_PATHS" -eq "1" ] ; then
	sed -i "s/--plugin_paths = {}/plugin_paths = { \"/usr/lib/prosody/modules\" , \"/usr/lib/prosody/modules-community-enable\", \"/usr/lib/prosody/modules-custom\" }/" /etc/prosody/prosody.cfg.lua
	echo ">> enable and set module path (see dockerfile)"
fi

## use shell (docker run --name prosody -it $imagename sh)
if [[ "$1" == "sh" ]]; then
	exec sh
fi

## ...
if [[ "$1" != "prosody" ]]; then
	exec prosodyctl "$@"
	exit 0;
fi

## ...
if [ "$LOCAL" -a  "$PASSWORD" -a "$DOMAIN" ] ; then
	prosodyctl register "$LOCAL" "$DOMAIN" "$PASSWORD"
fi

# exec CMD
echo ">> exec docker CMD"
echo "$@"
exec "$@"
