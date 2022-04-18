#!/bin/sh

SERVER_PORT=8081

for i in "$@"; do
  case $i in
    --bq-project-id=*)
      BQ_PROJECT_ID="${i#*=}"
      shift
      ;;
    --allowed-email-regex=*)
      ALLOWED_EMAIL_REGEX="${i#*=}"
      shift
      ;;
    --cookie-secret=*)
      OAUTH_COOKIE_SECRET="${i#*=}"
      shift
      ;;
    --client-id=*)
      OAUTH_CLIENT_ID="${i#*=}"
      shift
      ;;
    --client-secret=*)
      OAUTH_CLIENT_SECRET="${i#*=}"
      shift
      ;;
    -*|--*)
      echo "Unknown option $i"
      exit 1
      ;;
    *)
      ;;
  esac
done

PORT=$SERVER_PORT /bin/server --bq-project-id $BQ_PROJECT_ID --allowed-email-regex $ALLOWED_EMAIL_REGEX &

while ! nc -z localhost $SERVER_PORT; do
  sleep 0.1 # wait for 1/10 of the second before check again
done

/bin/oauth2-proxy --http-address=0.0.0.0:8080 \
                --email-domain=* \
                --upstream=http://localhost:$SERVER_PORT \
                --cookie-secret=$OAUTH_COOKIE_SECRET \
                --cookie-secure=true \
                --provider=google \
                --client-id=$OAUTH_CLIENT_ID \
                --client-secret=$OAUTH_CLIENT_SECRET
