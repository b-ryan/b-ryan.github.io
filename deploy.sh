#!/bin/bash
pelican -t theme/ -o output/ -s publishconf.py content/
aws --region us-west-2 s3 sync output s3://buckryan.com/
