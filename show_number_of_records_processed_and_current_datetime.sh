#!/bin/sh
jfile=$1
#echo $jfile

./modules/renamecopy_delete_email.py $jfile

ls /tmp/james_claim/ -lrt

if [ $jfile == 'yy2.json' ]
then
	ind=$(TZ='America/New_York' date +'%m%d')
	#echo $ind
	wc -l /tmp/update_$ind* 
fi
