#!/bin/bash -x

# If trying to export ALL of the tours, scroll down the web page until you view them all and then save the web page in komoot_blob.htm
# then get all the tour IDs (remember, only the public ones will download) , so the code would be:

grep -Eo 'data-tour-id\=\"[0-9]{1,10}\"' komoot_blob.htm | sed 's/[^0-9]*//g' > komoot_tours.txt ;


# If you need to download just the last page (the last 20 ones I guess):
# log in to Komoot using the browser
# export the cookies in a Netscape formatted file and then:


curl 'https://www.komoot.it/user/2192937331115/tours?type=recorded' -s -b komoot_cookies.txt \
 | grep -Eo 'data-tour-id\=\"[0-9]{1,10}\"' \
 | sed 's/[^0-9]*//g' > komoot_tours.txt ;


while read -r TourID ;
do 
curl "https://www.komoot.it/api/v007/tours/$TourID.gpx" -s -b komoot_cookies.txt -o "$TourID".gpx
done<komoot_tours.txt
