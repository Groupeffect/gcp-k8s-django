#!/bin/sh
helm template $1 > $1/manifest.yaml
