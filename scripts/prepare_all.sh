#!/bin/sh

for data_dir in ./data/*; do
  Rscript ${data_dir}/prepare.R | tee ${data_dir}/prepare.log
done