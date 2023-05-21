#!/bin/bash

tmux new-window
tmux split-window -t 1 -v -p 50
tmux split-window -t 1 -h -p 50
tmux split-window -t 3 -h -p 50

tmux send-keys -t 1 'zk lucky' Enter
tmux send-keys -t 2 'zk allganize' Enter
tmux send-keys -t 3 'zk monthly' Enter
