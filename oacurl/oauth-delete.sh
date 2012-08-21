#!/bin/bash
# Check training status of a prediction model.
# Usage: oauth-delete.sh MODEL_ID

ID=$1
KEY='AIzaSyAgoA529IJ7Z6sGdyYfMq0PyLNJLl8uCr8'

# Check training status.
java -cp ./oacurl-1.3.0.jar com.google.oacurl.Fetch -X DELETE \
	"https://www.googleapis.com/prediction/v1.5/trainedmodels/$ID?key=$KEY"
echo
