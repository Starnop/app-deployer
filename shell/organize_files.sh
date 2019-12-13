#!/bin/bash

set -e

# This script helps to copy the files defined by each identifier into a uniform directory.
# 
# And it receives four arguments:
# $1: The key prefix of the uniform folder which will be `$1_files`.
# $2: The root absolute path of the files located.
# $3: The relative path of the source files.
# $4: The file path list that should be copied.
#
# Eg. $1=node $2=/root $3=relative_path $4=["static_files/static.file","temp_files/temp.file"]
# The tree-like directories will become from 
# 
# /root
# └── relative_path
#     ├── static_files
#     │   └── static.file
#     └── temp_files
#         └── temp.file
# 
# To
# 
# /root
# ├── .node_files
# │   ├── static.file
# │   └── temp.file
# └── relative_path
#     ├── static_files
#     │   └── static.file
#     └── temp_files
#         └── temp.file

if [ -n $4 ]; then 
  for filePath in $4; do 
    test -d $(dirname $2/.$1_files/$filePath) || mkdir -p $(dirname $2/.$1_files/$filePath)
    cp $2/$3/$filePath $2/.$1_files/$filePath;   
  done
fi