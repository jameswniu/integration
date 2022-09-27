#! /bin/bash

psql  -h revpgdb01 -U james_niu_u tpliq_tracker_db -f ../../sqls/dump_fax_json.sql > group.json
ls -lrt | grep group.json
mail -s "Fax file dumped" yi.yan@medlytix.com < modules/dumped_fax.txt
