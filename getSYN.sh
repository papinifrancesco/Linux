# That script is meant to create a TSV file
# SRC    DST    PORT
# to be imported into a graphing tool.
# I had to find something that was very lightweight and with an auto adapting filter:
# I don't want to capture the same thing over and over again.
# Note that even if such an optimization is not needed for a textual output,
# adapting the code for dumping real packets made that necessary.


#!/bin/bash

# Temporary file name
temp_file="results_temp.tsv"

# Temporary results file name
temp_results_file="temp_results.txt"

# Results file name
results_file="results.tsv"

rm -f $temp_file $temp_results_file $results_file

# Initial filter
filter="tcp[13] = 2"

# Infinite loop
while true; do
    # Capture initiation packets with tcpdump and write to the temporary file
    tcpdump -c100 -U -iany -nn -l -q -t "$filter" | awk '{split($4, src, "."); split($6, dst, "."); print src[1]"."src[2]"."src[3]"."src[4] "\t" dst[1]"."dst[2]"."dst[3]"."dst[4] "\t" substr(dst[5], 1, length(dst[5])-1)}' > $temp_file

    # Remove duplicates, corrupted lines and write to the results file
    sort $temp_file | uniq | awk 'NF==3' >> $temp_results_file
    sort $temp_results_file | uniq | awk 'NF==3' > $results_file  

    # Read the results file and build the filter  
    $filterAdd=""
    while IFS=$'\t' read -r src dst port; do
        filterAdd="$filterAdd and not (src host $src and dst host $dst and port $port) "
    done < $results_file
    filter="tcp[13] = 2"
    filter+=$filterAdd
    echo $filter >> filter.txt
    
done
