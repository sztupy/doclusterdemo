#!/usr/bin/env sh

echo "Using $API_ROOT_URL as the API url"
sed "s|API_ROOT_URL|$API_ROOT_URL|" /usr/share/nginx/html/js/app-config.js.sample > /usr/share/nginx/html/js/app-config.js

exec nginx -g 'daemon off;'
