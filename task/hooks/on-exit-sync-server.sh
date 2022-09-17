#!/bin/bash

n=0

# Read modified or added tasks
while read -r _
do
    n=$((n + 1))
done

# Sync only if there are modified or added tasks
if ((n > 0)); then
  task sync >> ~/.task/sync.log 2>&1
fi

exit 0
