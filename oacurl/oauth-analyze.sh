#!/bin/bash

ID=$1

KEY='AIzaSyAgoA529IJ7Z6sGdyYfMq0PyLNJLl8uCr8'

# Get analysis of model.

java -cp ./oacurl-1.3.0.jar com.google.oacurl.Fetch -X GET \
-t JSON \
"https://www.googleapis.com/prediction/v1.5/trainedmodels/$ID/analyze?key=$KEY"
echo
