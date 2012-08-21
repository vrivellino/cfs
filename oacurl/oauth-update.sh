#!/bin/bash

# Update a pre-trained predictive model with new data.
# Usage: oauth-update.sh MODEL_ID LABEL DATA

ID=$1
LABEL="$2"
INPUT="$3"

KEY='AIzaSyAgoA529IJ7Z6sGdyYfMq0PyLNJLl8uCr8'
data="{\"label\" : \" $LABEL \", \"csvInstance\" : [ $INPUT ]}"

# update the model
java -cp ./oacurl-1.3.0.jar com.google.oacurl.Fetch -X PUT \
-t JSON \
"https://www.googleapis.com/prediction/v1.5/trainedmodels/$ID?key=$KEY" <<< $data
echo

