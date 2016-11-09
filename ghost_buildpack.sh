#!/bin/bash
# https://myfox.ghost.morea.fr/doc/rst/scripts.html
set -e

usage()
{
    cat << EOF
Choose supervisor config files to enable

Usage : $(basename $0) -e <environment> -c "foo bar"
      -h | --help      : Show this message
      -e | --env       : Environment
      -A | --app       : Application name
               
               ex : Enable configs for the app foo
               $(basename $0) -e preprod -A foo
EOF
}

# Options parsing
while (($#)); do
    case "$1" in
        -h | --help) usage; exit 0;;
        -e | --env) CLIENT_ENV=${2}; shift 2;;
        -A | --app) APP=${2}; shift 2;;
        *)
            echo "ERROR : Unknown option"
            exit 3
        ;;
    esac
done

ALLOWED_APPS=("shcp api videocloud consumers update partners2 rabbitmq rabbitmqtt sso b2b")
KNOWN_ENVS=("prod preprod")

if [ -z ${CLIENT_ENV} ]; then
  echo "ERROR Client environment must be defined"
  exit 1
fi
if [ -z ${APP} ]; then
  echo "ERROR Application name must be defined"
  exit 1
fi
if ! [[ "${ALLOWED_APPS}" =~ "${APP}" ]]; then
  echo "ERROR: App ${APP} not allowed, allowed apps : ${ALLOWED_APPS}"
  exit 1
fi

if ! [[ "${KNOWN_ENVS}" =~ ${CLIENT_ENV} ]]; then
  echo "ERROR: Unknown environment ${CLIENT_ENV}, envs : ${KNOWN_ENVS}"
  exit 1
fi

if [ "${CLIENT_ENV}" == "preprod" ]; then
  LOGS_SERVER="log-preprod.myfox.io"
elif [ "${CLIENT_ENV}" == "prod" ]; then
  LOGS_SERVER="internal-log.myfox.io"
fi

# Enable application configuration
mv ${APP} config.d

# Replace LOGS_SERVER
sed -i "s/LOGS_SERVER/${LOGS_SERVER}/g" config.d/*

# Change environment in tags for production environment
if [ "${CLIENT_ENV}" = "prod" ]; then
  sed -i "s/preprod/prod/g" config.d/*
fi

# Remove unused directories
find . -maxdepth 1 -type d -not \( -name "config.d" -o -name "." -o -name ".." \) -exec rm -rf {} \;
