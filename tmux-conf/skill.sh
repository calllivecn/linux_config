#!/bin/bash
# date 2023-01-08 13:45:00
# author calllivecn <calllivecn@outlook.com>


# 新建一个会话
tmux new -s <session-name> -d <shell command>

# 在指定的会话里新一个窗口运行 sleep 50 命令
tmux new-windows -t service -d sleep 50

# 查看指定会话有多少窗口
tmux list-windows -t <session-name>
