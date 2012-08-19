#!/bin/bash

# Update a pre-trained predictive model with new data.
# Usage: oauth-update.sh MODEL_ID LABEL DATA

ID=$1
LABEL="$2"
INPUT="$3"

KEY='AIzaSyCB41eABQj1X1IhHFwtUMMwTDQG2oZ5-o0'
data="{\"label\" : \" $LABEL \", \"csvInstance\" : [ $INPUT ]}"

# update the model
java -cp ./oacurl-1.3.0.jar com.google.oacurl.Fetch -X PUT \
-t JSON \
"https://www.googleapis.com/prediction/v1.5/trainedmodels/$ID?key=$KEY" <<< $data
echo

