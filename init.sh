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
