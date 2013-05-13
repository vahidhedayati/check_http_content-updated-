#!/bin/bash
# Examples
# ./web.sh http://url pattern
# ./web.sh http://localhost apache
# ./working-web.sh https://www.gooogle.com google
# ./working-web.sh https://www.gooogle.com:443/google google
# ./working-web.sh http://www.gooogle.com:8080/google google


url=$1;
pattern=$2;



PORT=80;

if [[ $url  =~ http:// ]]; then
       	c_url=$(echo $url|sed -e "s:http\://::g")
elif [[ $url =~ https:// ]]; then
        c_url=$(echo $url|sed -e "s:https\://::g")
	PORT=443;
else
	c_url=$url;
fi

 if [[ $c_url =~ : ]]; then
	C_PORT=${c_url##*:}
	b_url=${c_url%:*}  
	if [[ $C_PORT =~ / ]]; then
	 C_PORT=${C_PORT%%/*} 
	 e_url=${c_url#*/}
	fi
 	PORT=$C_PORT
	e_url="/"$e_url
 else
	if [[ $c_url =~ / ]]; then
		b_url=${c_url%%/*}
  		e_url=${c_url#*/}
		if [ "$e_url" == "" ]; then
			e_url="/";
		else
			e_url="/"$e_url;
		fi
		c_url=$b_url
	else
		b_url=$c_url;
		e_url="/";
	fi
  fi

 if [[ $PORT =~ 443 ]]; then 
  h_url="https://"$b_url":"$PORT$e_url
 else
	if [[ $c_url =~ : ]]; then
  		h_url="http://"$b_url":"$PORT$e_url
	else
  		h_url="http://"$b_url$e_url
	fi
		
 fi
	#echo $h_url
s=$(date +%s.%N)
elinks --dump "$h_url" | grep "$pattern" >/dev/null 2>&1
if [ $? -ne 0 ] ; then
	f=$(date +%s.%N)
	sum=$(echo $f|awk -v s=$s '{$3 = $1 - 's';  printf "%f", $3}')
	echo "CONTENT_CHECK CRITICAL: URL $h_url is down or content $pattern was not found on the webpage|time="$sum"s;;;;0 size=0B;;;0"
	exit 2
else
	f=$(date +%s.%N)
	sum=$(echo $f|awk -v s=$s '{$3 = $1 - 's';  printf "%f", $3}')
	size=0;
	if [[ ! "$PORT" == "443" ]]; then
		head="HEAD $h_url HTTP/1.1\r\nHost: $(uname -n)\r\nContent-type: text/html\r\nContent-length: 10\r\nConnection: Close\r\n\r\n"; 
		#echo "-- $h_url -- $c_url"
		size=$(echo -e $head |nc $c_url $PORT 2>&1|grep "Content-Length:"|awk -F"Content-Length: " '{print $2}'|tr -d "\r")
		if [ "$size" == "" ]; then
			size=0;
		fi
	fi
	echo "CONTENT_CHECK OK: URL $h_url returned $pattern|time="$sum"ms;;;;0 size="$size"B;;;0"
	exit 0;
fi
