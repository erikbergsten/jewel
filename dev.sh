#!/bin/bash
podman run -it --rm --name ruby-jewel -v $PWD:/work -w /work \
  -e OPENAI_API_KEY=$MY_SECRET_API_KEY \
  --entrypoint bash \
  ruby:3.4.7
