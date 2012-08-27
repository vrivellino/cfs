#!/bin/bash
# Train a prediction model from a CSV file
# Usage: oauth-train.sh ID DATA_LOCATION

ID=$1
DATA_LOCATION=$2
KEY='AIzaSyAgoA529IJ7Z6sGdyYfMq0PyLNJLl8uCr8'

post_data="{\"id\":\"$ID\",\"storageDataLocation\":\"$DATA_LOCATION\"}"

# Train the model.
java -cp ./oacurl-1.3.0.jar com.google.oacurl.Fetch -X POST \
	-t JSON \
	"https://www.googleapis.com/prediction/v1.5/trainedmodels?key=$KEY" <<< $post_data
echo