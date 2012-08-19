#!/bin/bash

if [ -n "$1" ]; then
	cd "$1" || exit $?
fi

i=1
j=1
for t1 in *.html ; do
	t1=$(basename "$t1" .html)
	for t2 in *.html ; do
		t2=$(basename "$t2" .html)
		if [ "$t1" != "$t2" ]; then
			#Rk,Wk,Date,Day,Winner/Tie,Pts,,Loser/Tie,Pts,Notes
			echo "$i,$j,Sep 1 2011,Sat,$t2,0,@,$t1,0,"
			i=$(($i+1))
		fi
	done
	j=$(($j+1))
done

