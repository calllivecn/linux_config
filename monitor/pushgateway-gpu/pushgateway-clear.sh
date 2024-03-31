#!/bin/bash
# date 2022-06-05 14:44:23
# author calllivecn <calllivecn@outlook.com>

example(){
	baseurl=localhost:9091
	for uri in $(curl -sS $baseurl/api/v1/metrics | jq -r '
	  .data[].push_time_seconds.metrics[0] |
	  select((now - (.value | tonumber)) > 60) |
	  (.labels as $labels | ["job", "instance"] | map(.+"/"+$labels[.]) | join("/"))
	'); do
	  curl -XDELETE $baseurl/metrics/$uri | exit
	  echo curl -XDELETE $baseurl/metrics/$uri
	done
}


URL="http://localhost:9091"

check_expire_metric(){
	metrics=$(curl $URL/api/v1/metrics)
	
	last_push_timestamp=$(echo "$metrics" |jsonfmt.py -d data[0].push_time_seconds.metrics[0].value)
	
	T=$(python3 -c "print(int(float($last_push_timestamp)))")
	
	CUR_T=$(date +%s)
	interval=$[CUR_T - T]
	
	if [ $interval -ge 60 ];then
		echo "delete job: gpu_nvidia nodename: zxdiy"
		curl -X DELETE http://localhost:9091/metrics/job/gpu_nvidia/nodename/zxdiy
	fi

}

while :
do
	check_expire_metric
	sleep 60
done
