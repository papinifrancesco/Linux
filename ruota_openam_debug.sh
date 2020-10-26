#
# Ruota il log Authentication
#----------------------


date=$(date '+%Y-%m-%d')

declare -a myArray=("Authentication" "CoreSystem" "Session")

for i in "${myArray[@]}"


do


echo "$i"

cp /opt/openam_config/openam/debug/$i /apps/tmp/ && > /opt/openam_config/openam/debug/$i

mv /apps/tmp/$i /apps/tmp/$i.$date

xz -9 /apps/tmp/$i.$date

mv /apps/tmp/$i.$date.xz /opt/openam_config/openam/debug/history/


done
