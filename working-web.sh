#!/bin/bash

# ./web.sh http://url pattern
# ./web.sh http://localhost apache

url=$1;
pattern=$2;

if [[ $url  =~ http:// ]]; then
        h_url=$url
       	c_url=$(echo $url|sed -e "s:http\://::g")
elif [[ $url  =~ https:// ]]; then
  	h_url=$url
        c_url=$(echo $url|sed -e "s:https\://::g")

else
	h_url="http://"$url;
	c_url=$url;
fi
s=$(date +%s.%N)
elinks --dump "$h_url" | grep "$pattern" >/dev/null 2>&1
if [ $? -ne 0 ] ; then
	f=$(date +%s.%N)
	sum=$(echo $f|awk -v s=$s '{$3 = $1 - 's';  printf "%f", $3}')
	echo "SESSION CONTENT CRITICAL: URL $h_url is down or content $pattern was not found on the webpage|time="$sum"s;;;;0 size=0B;;;0"
	exit 2
else
	f=$(date +%s.%N)
	sum=$(echo $f|awk -v s=$s '{$3 = $1 - 's';  printf "%f", $3}')
	head="POST $h_url HTTP/1.1\r\nHost: $(uname -n)\r\nContent-type: text/html\r\nContent-length: 10\r\nConnection: Close\r\n\r\n"; 
	size=$(echo -e $head |nc $c_url 80 2>&1|grep "Content-Length:"|awk -F"Content-Length: " '{print $2}'|tr -d "\r")
	if [ "$size" == "" ]; then
		size=0;
	fi
	echo "SESSION CONTENT OK: URL $h_url returned $pattern|time="$sum"ms;;;;0 size="$size"B;;;0"
	exit 0;
fi
