#!/usr/bin/env bash

JEKYLL_ENV=production jekyll build

rm -rf _site/versions
aws s3 sync _site/ s3://aegis.ist/

aws cloudfront create-invalidation --distribution-id EZFGMY32S3BBS --paths "/*"