#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

indir=$1;

if [[ "$indir" == "" ]];
then
   echo "nothing to prime, master?"

   exit
fi

for i in 1 2 3 4 5 ;
do
   find "$indir" -ls >/dev/null 2>&1
done

echo primed fscache for "$indir"
