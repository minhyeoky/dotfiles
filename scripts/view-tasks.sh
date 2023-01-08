#!/bin/bash

tmux new-window
tmux split-window -t 1 -v -p 80
tmux split-window -t 1 -h -p 50
tmux split-window -t 3 -v -p 70
tmux split-window -t 3 -h -p 50

tmux send-keys -t 1 'task summary' Enter
tmux send-keys -t 2 'task calendar' Enter
tmux send-keys -t 3 'task burndown.weekly' Enter
tmux send-keys -t 4 'timew day' Enter
tmux send-keys -t 5 'task' Enter

tmux select-pane -t 5
