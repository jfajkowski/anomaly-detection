#!/bin/sh

model_dir="./models/best_roc"

for data_dir in ./data/variable_ratio/*; do
	Rscript ./scripts/train_3_layers_cross.R ${data_dir} ${model_dir}/3_layers | tee ${model_dir}/3_layers/$(basename $data_dir).log
	Rscript ./scripts/train_5_layers_cross.R ${data_dir} ${model_dir}/5_layers | tee ${model_dir}/5_layers/$(basename $data_dir).log
done
