#!/bin/bash

tmux last-pane
tmux swap-pane -s ! -t $(tmux display-message -p "#{pane_id}")
