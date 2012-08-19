#!/bin/bash

ID=$1

KEY='AIzaSyCB41eABQj1X1IhHFwtUMMwTDQG2oZ5-o0'

# Get analysis of model.

java -cp ./oacurl-1.3.0.jar com.google.oacurl.Fetch -X GET \
-t JSON \
"https://www.googleapis.com/prediction/v1.5/trainedmodels/$ID/analyze?key=$KEY"
echo
