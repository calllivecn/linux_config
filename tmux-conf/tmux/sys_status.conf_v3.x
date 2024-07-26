#monitor system status
new-window "top -d 1"
rename-window "monitor"

splitw -l 12% "iostat -md 1"
select-pane -t 0

splitw -h -l 50% "netio.py -m"
splitw -l 81% "watch -n 1 sensors"
#select-pane -t 2

splitw -h -l 40% "watch -n 1 grep \\'cpu MHz\\' /proc/cpuinfo"
select-pane -t 0
