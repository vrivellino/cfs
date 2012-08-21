#!/bin/bash
# List all trained models.
# Usage: oauth-list.sh

KEY='AIzaSyAgoA529IJ7Z6sGdyYfMq0PyLNJLl8uCr8'

# List resources
java -cp ./oacurl-1.3.0.jar com.google.oacurl.Fetch -X GET \
-t JSON \
"https://www.googleapis.com/prediction/v1.5/trainedmodels/list?key=$KEY"
echo
