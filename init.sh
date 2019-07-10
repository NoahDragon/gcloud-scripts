#!/bin/bash

gcloud auth list
gcloud config list project

pip install --user --upgrade tensorflow
python -c "import tensorflow as tf; print('TensorFlow version {} is installed.'.format(tf.VERSION))"
