#!/bin/bash

SOURCE_DATA_DIR="$(dirname $0)/../source_data"

year=$1
if [ -z "$year" ]; then
	echo "Usage: $(basename $0) <YEAR>"
	exit 1
fi

while read line ; do
	name=$(echo $line | cut -f 2 -d , | sed 's/&amp;/\&/g')
	url=$(echo $line | cut -f 3 -d ,)
	first=$(echo $line | cut -f 4 -d ,)
	last=$(echo $line | cut -f 5 -d ,)

	if [ $year -ge $first -a $year -le $last ]; then
		mkdir -p "$SOURCE_DATA_DIR/$year/stats"
		#mkdir -p "./$year/schedules"
		if [ ! -f "$SOURCE_DATA_DIR/$year/stats/$name.html" ]; then
			wget -O "$SOURCE_DATA_DIR/$year/stats/$name.html" "http://www.sports-reference.com${url}${year}.html"
			usleep 500000
		fi
		## instead: COPY & PASTE SCHEDULE CSV FROM HERE -> http://www.sports-reference.com/cfb/years/2011-schedule.html
		#if [ ! -f "./$year/schedules/$name.html" ]; then
		#	wget -O "./$year/schedules/$name.html" "http://www.sports-reference.com${url}${year}-schedule.html"
		#	usleep 500000
		#fi
	fi
done < "$SOURCE_DATA_DIR/schools-2012.csv"
