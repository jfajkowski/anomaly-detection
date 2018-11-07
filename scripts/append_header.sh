#!/bin/bash

header_file=./data/kddcup.names.txt
raw_train_file=$1
train_file=./data/train_data.csv
raw_test_file=$2
test_file=./data/test_data.csv

echo "Extracting header line and writing it at the beggining of train and test files"
tail --lines=+2 $header_file | cut -f 1 -d ':' | tr '\n' ',' | tee $train_file $test_file 1>/dev/null
echo "category" | tee --append $train_file $test_file 1>/dev/null

echo "Appending the rest of raw files (without dot at the end of the file)"
sed 's/.$//' $raw_train_file >>$train_file
sed 's/.$//' $raw_test_file >>$test_file
