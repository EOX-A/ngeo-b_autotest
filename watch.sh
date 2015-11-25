#!/bin/bash
# This script displays files that are written to the /tmp directory 
# e.g during ingestion.


inotifywait -m -e close_write -e delete /tmp/ |
    while read path action file; do

        if [ $action = "CLOSE_WRITE,CLOSE" ] ; then
            info=`gdalinfo $path$file 2> /dev/null`

            file $path$file
            if [ "$info" ] ; then
                echo $path$file
                echo "$info"
            fi
        fi
    done 

