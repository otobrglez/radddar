#!/usr/bin/env bash

echo "Precompiling assets"
rake assets:precompile

echo "Pushing assets to S3"
bundle exec jammit-s3

echo "Adding manifest to commit."
git add -f public/assets/manifest.yml
