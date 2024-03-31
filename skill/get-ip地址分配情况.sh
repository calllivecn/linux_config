#!/bin/bash
# date 2021-01-05 13:15:39
# author calllivecn <calllivecn@outlook.com>

set -e 

tmp=$(mktemp)

tmp_clear(){
	rm "$tmp"
}

trap "tmp_clear" SIGINT SIGTERM ERR EXIT

curl -v https://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest > "$tmp"

# 把国内的ipv4拿出来
awk -F'|' '{if($2 == "CN" && $3 == "ipv4") print $4"/"32-log($5)/log(2)}' "$tmp"


# 把车内的ipv6拿出来
awk -F'|' '{if($2 == "CN" && $3 == "ipv6") print $4"/"$5}' "$tmp"


