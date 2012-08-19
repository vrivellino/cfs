#!/bin/bash

model_id=cfg_pred_2004_2011_v3

while read line ; do
	data=$(echo $line | sed "s/\"/'/g")
	result=$(./scripts/oauth-predict.sh "$model_id" "$data" | sed -n 's/^ "outputValue": //p')
	echo "$result,$data" | sed "s/'/\"/g"
	if [ -z "$result" ]; then
		sleep 30
	fi
done
	
