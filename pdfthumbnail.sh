#!/bin/bash
# Outputs a thumbnail based on the section of the first page of the PDF that
# contains the greatest number of black pixels.
file=$@
png="$file.png"
convert -density 300 $file[0] -quality 100 $png
# add later: -threshold 70% 
convert -crop 500x500 +repage $png $png-box%02d.png

# Which box has more black pixels than any other?
find . | grep $png-box.*png | while read boxfile; do
    echo -n "$boxfile"$'\t' >> temp_box_data
    convert $boxfile -format %c histogram:info: | grep black | cut -d ":" -f 1 | tr -d ' ' >> $png-temp_box_data
done
best_thumbnail=`cat $png-temp_box_data | sort -bgrk2 --field-separator=$'\t' | head -n 1 | cut -d $'\t' -f 1`
convert -resize 250x250 $best_thumbnail $best_thumbnail

# clean up
rm $png-temp_box_data
cat $best_thumbnail # outputs the file itself
find . -name "$png-box*png" -print0 | xargs -0 rm
