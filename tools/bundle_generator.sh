#!/bin/bash
# Runs `mason bundle` to generate bundles for all bricks within the respective templates directories.

bricks=(
    dartexify_article
)

for brick in "${bricks[@]}"
do
    echo "bundling $brick..."
    mason bundle --source path ./bricks/$brick/ -t dart -o "lib/src/commands/create/templates/$brick/"
done

dart format .