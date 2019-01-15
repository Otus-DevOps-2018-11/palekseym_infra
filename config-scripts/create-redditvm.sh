#!/bin/bash
gcloud compute instances create reddit-app --zone=europe-west4-c --image-family reddit-full --image-project=sapient-cycling-225707 --machine-type=g1-small --tags puma-server --restart-on-failure
