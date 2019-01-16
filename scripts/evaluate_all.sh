#!/bin/sh

for model_dir in ./models/*; do
	Rscript ./scripts/evaluate.R ${model_dir}/3_layers | tee ${model_dir}/3_layers/evaluate.log
	Rscript ./scripts/evaluate.R ${model_dir}/5_layers | tee ${model_dir}/5_layers/evaluate.log
done
