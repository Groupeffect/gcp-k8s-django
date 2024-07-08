#!/bin/sh
helm template -f ./$1/templates/$2.yaml # > ../$1/$2.yaml
