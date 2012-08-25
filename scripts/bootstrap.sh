#!/bin/bash

echo "WARNING: This will delete all data in the database!"
echo -n "<Enter> to continue ..."
read junk

cd "$(dirname $0)/../perllib" || exit $?

# blow away database and re-create
mysql -u root < ../sql/00_create_tables.mysql || exit $?

# import schools
./parse_schools.pl < ../source_data/schools-2012.html > ../source_data/schools-2012.csv  || exit $?

# import stats
./parse_stats.pl ../source_data/20??/stats || exit $?

# import schedules
./parse_past_schedules.pl ../source_data/20??/schedule.csv || exit $?

# export training data to csv
for d in ../source_data/20?? ; do
	yr=$(basename $d)
	./export_training_data.pl $yr > ../training_data/$yr.csv
done
