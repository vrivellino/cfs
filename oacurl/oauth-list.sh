#!/bin/bash
# List all trained models.
# Usage: oauth-list.sh

KEY='AIzaSyCB41eABQj1X1IhHFwtUMMwTDQG2oZ5-o0'

# List resources
java -cp ./oacurl-1.3.0.jar com.google.oacurl.Fetch -X GET \
-t JSON \
"https://www.googleapis.com/prediction/v1.5/trainedmodels/list?key=$KEY"
echo
