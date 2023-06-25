#!/bin/bash

# Check if the correct number of arguments is provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <table_name> <csv_file>"
    exit 1
fi

# Assign the arguments to variables
table_name=$1
csv_file=$2

# Add a new line at the end of the CSV file if it doesn't exist
echo "" >> "$csv_file"

# Read the first line of the CSV file to get column names
read -r header < "$csv_file"
IFS='|' read -r -a columns <<< "$header"

# Read the remaining lines of the CSV file and generate the INSERT statements
tail -n +2 "$csv_file" | while IFS='|' read -r -a values; do
    insert="INSERT INTO $table_name ("
    for ((i=0; i<${#columns[@]}; i++)); do
        if [ $i -ne 0 ]; then
            insert+=', '
        fi
        insert+="${columns[$i]}"
    done
    insert+=") VALUES ("

    for ((i=0; i<${#values[@]}; i++)); do
        if [ $i -ne 0 ]; then
            insert+=', '
        fi
        insert+="'${values[$i]//\'/''}'"
    done
    insert+=");"

    echo "$insert"
done | tr -d '\r'
