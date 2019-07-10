#!/bin/bash

gcloud auth list

gcloud config list project

pip install --user --upgrade tensorflow

python -c "import tensorflow as tf; print('TensorFlow version {} is installed.'.format(tf.VERSION))"

git clone https://github.com/GoogleCloudPlatform/cloudml-samples.git

cd cloudml-samples/census/estimator

mkdir data

gsutil -m cp gs://cloud-samples-data/ml-engine/census/data/* data/

export TRAIN_DATA=$(pwd)/data/adult.data.csv
export EVAL_DATA=$(pwd)/data/adult.test.csv

head data/adult.data.csv

#Install Dependencies
pip install --user -r ../requirements.txt

export MODEL_DIR=output

gcloud ai-platform local train \
       --module-name trainer.task \
       --package-path trainer/ \
       --job-dir $MODEL_DIR \
       -- \
       --train-files $TRAIN_DATA \
       --eval-files $EVAL_DATA \
       --train-steps 1000 \
       --eval-steps 100

#Open TensorBoard
# tensorboard --logdir=$MODEL_DIR --port=8080

export TIME_STAMP=$(ls output/export/census)
echo $TIME_STAMP
