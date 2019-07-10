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
#echo $TIME_STAMP

gcloud ai-platform local predict \
       --model-dir output/export/census/$TIME_STAMP \
       --json-instances ../test.json

PROJECT_ID=$(gcloud config list project --format "value(core.project)")
BUCKET_NAME=${PROJECT_ID}-mlengine
echo $BUCKET_NAME
REGION=us-central1

gsutil mb -l $REGION gs://$BUCKET_NAME

gsutil cp -r data gs://$BUCKET_NAME/data

TRAIN_DATA=gs://$BUCKET_NAME/data/adult.data.csv
EVAL_DATA=gs://$BUCKET_NAME/data/adult.test.csv

gsutil cp ../test.json gs://$BUCKET_NAME/data/test.json

TEST_JSON=gs://$BUCKET_NAME/data/test.json

JOB_NAME=census_single_1

OUTPUT_PATH=gs://$BUCKET_NAME/$JOB_NAME

gcloud ai-platform jobs submit training $JOB_NAME \
       --job-dir $OUTPUT_PATH \
       --runtime-version 1.10 \
       --module-name trainer.task \
       --package-path trainer/ \
       --region $REGION \
       -- \
       --train-files $TRAIN_DATA \
       --eval-files $EVAL_DATA \
       --train-steps 1000 \
       --eval-steps 100 \
       --verbosity DEBUG

gcloud ai-platform jobs stream-logs $JOB_NAME

gsutil ls -r $OUTPUT_PATH

# tensorboard --logidr=$OUTPUT_PATH --port=8080

MODEL_NAME=census

gcloud ai-platform models create $MODEL_NAME --regions=$REGION

gsutil ls -r $OUTPUT_PATH/export

MODEL_BINARIES=$OUTPUT_PATH/export/census/$TIME_STAMP/

gcloud ai-platform versions create v1 \
       --model $MODEL_NAME \
       --origin $MODEL_BINARIES \
       --runtime-version 1.10

gcloud ai-platform models list

gcloud ai-platform predict \
       --model $MODEL_NAME \
       --version v1 \
       --json-instances ../test.json



