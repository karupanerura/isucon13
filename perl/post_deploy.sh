#!/bin/bash
set -ue

source $HOME/.local.env

set -x

cd $(dirname $0)
carton install