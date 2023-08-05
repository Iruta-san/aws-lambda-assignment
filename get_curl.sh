#!/bin/sh
API_URL=$(terraform output -raw invoke_url_default)
API_KEY=$(terraform output -raw api_key)
PARAMS=""

if [ ! -z $1 ] 
    then PARAMS="?i=$1"
fi


echo 'Use this command to test the API'
echo "curl --header \"x-api-key:$API_KEY\" $API_URL$PARAMS"

