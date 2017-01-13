#!/bin/bash

DPI=300

mkdir -p result
for i in *.pdf; do
    echo -n "$i? " 
    if [ -f result/$i ]; then
        echo "skip"
        continue
    fi
    count=`pdftk $i dump_data output | grep NumberOfPages | awk '{ print $2 }'`
    echo "processing $count pages"

    mkdir _$i
    echo -n "running ghostscript... "
    gs -dNOPAUSE -sDEVICE=png16m \
        -sOutputFile=_$i/image%04d.png \
        -r$DPIx$DPI -q $i -c quit &

    gspid=$!
    while kill -0 $gspid 2> /dev/null; do
        sleep 1
        countdone=`ls _$i | grep -e .png$ | wc -l`
        echo -e -n "\rrunning ghostscript... $countdone/$count pages"
    done
    echo -e "\rrunning ghostscript... $countdone/$count pages done!"
    echo -n "building single pdfs..."
    for j in _$i/*.png; do
        convert -compress lzw -quality 10 $j $j.pdf 
        #rm $j
        countdone=`ls _$i | grep -e .pdf$ | wc -l`
        echo -e -n "\rbuilding single pdfs... $countdone/$count pages"
    done
    echo -e "\rbuilding single pdfs... $countdone/$count pages done!"
    echo -n "joining pdfs... "
    pdftk _$i/*.pdf cat output result/$i
    echo done!
    #rm -r _$i
done
