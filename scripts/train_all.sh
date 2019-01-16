#!/bin/sh

for model_dir in ./models/ccfd/*; do
	Rscript ./scripts/ccfd/train_3_layers.R ${model_dir}/3_layers | tee ${model_dir}/3_layers/train.log
	Rscript ./scripts/ccfd/train_5_layers.R ${model_dir}/5_layers | tee ${model_dir}/5_layers/train.log
done
