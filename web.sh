#!/bin/bash
#
# Simple URL checker  - interpretation of URL redirects.
# This should work with any appplication - run in a command line as:
#
# web.sh http://host.something/uri1/etc content
#
# This will then load the full URL requested, and will search the page for the word "content". 
#
# To enable the monitor in Appmanager, use the following settings:

url=$1;
pattern=$2;

if [[ $url  =~ http:// ]]; then
  h_url=$url
       	c_url=$(echo $url|sed -e "s:http\://::g")
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
	#sum=$(echo $f|awk -v s=$s '{$3 = $1 - 's';  printf "%f", $3}')
	#head="POST $h_url HTTP/1.1\r\nHost: $(uname -n)\r\nContent-type: text/html\r\nContent-length: 10\r\nConnection: Close\r\n\r\n"; 
	#size=$(echo -e $head |nc $c_url 80 2>&1|grep "Content-Length:"|awk -F"Content-Length: " '{print $2}'|tr -d "\r")
	#echo "SESSION CONTENT OK: URL $h_url returned $pattern|time="$sum"ms;;;;0 size="$size"B;;;0"
	echo "SESSION CONTENT OK: URL $h_url returned $pattern|time="$sum"ms;;;;0 "
	exit 0;
fi
