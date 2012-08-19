#!/bin/bash
# Train a prediction model from a CSV file
# Usage: oauth-train.sh ID DATA_LOCATION

ID=$1
DATA_LOCATION=$2
KEY='AIzaSyCB41eABQj1X1IhHFwtUMMwTDQG2oZ5-o0'

post_data="{\"id\":\"$ID\",\"storageDataLocation\":\"$DATA_LOCATION\"}"

# Train the model.
java -cp ./oacurl-1.3.0.jar com.google.oacurl.Fetch -X POST \
	-t JSON \
	"https://www.googleapis.com/prediction/v1.5/trainedmodels?key=$KEY" <<< $post_data
echo
