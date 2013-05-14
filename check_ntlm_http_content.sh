#!/bin/bash

###################################################################################
# Vahid Hedayati April 2013
###################################################################################
# Will not work for SSL
# Will support NTML (basic Authentication support)
# Takes user password converts to base64 string sends along with the:
# HTTP ( POST/GET/HEAD )  method 
# Using netcat makes a connection and looks for the pattern
###################################################################################
# ./check_ntlm_http_content.sh -h
# ./check_ntlm_http_content.sh -U http://url.com -u user -p pass -m Some_pattern
###################################################################################


function find_pattern() { 

  s=$(date +%s.%N)
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
	aline="";
	if [ ! "$username" == "" ] && [ ! "$password" == "" ]; then
 		bstring=$(echo -n $username:$password|base64)
		aline="Authorization: Basic $bstring\r\n";

	fi


	method="POST";
	if [[ $url =~ "\?" ]] || [[ $url =~ \& ]]; then
		method="GET";
	fi

	#echo "$h_url --- $c_url -- $e_url"

	head="$method $h_url HTTP/1.1\r\nHost: $(uname -n)\r\n"$aline"Content-type: text/html\r\nContent-length: 10\r\nConnection: Close\r\n\r\n";
	return=$(echo -e $head |nc $c_url $PORT|egrep "(Content-Length:|$pattern)")
	#echo -e $head 
	#echo -e $head |nc $c_url $PORT
	clfound=0;
   	cpfound=0;
	if [[ $return =~ "Content-Length:" ]]; then
		clfound=1;
		clength=$(echo $return|grep "Content-Length:"|awk -F"Content-Length: " '{print $2}'|awk -F" " '{print $1}'|tr -d "\r")
	fi
	if [[ $return =~ "$pattern" ]]; then
		cpfound=1;
		cpattern=$(echo $return|grep -v "Content-Length:"|tr -d "\r")
	fi
	if [[ $clfound == 0 ]]; then
		head="HEAD $h_url HTTP/1.1\r\nHost: $(uname -n)\r\n"$aline"Content-type: text/html\r\nContent-length: 10\r\nConnection: Close\r\n\r\n";
   		clength=$(echo -e "$head" |nc $c_url $PORT 2>&1|grep "Content-Length:"|awk -F"Content-Length: " '{print $2}'|tr -d "\r")
		if [ "$clength" == "" ]; then
			clength=0;
		fi
	fi

	f=$(date +%s.%N)
        sum=$(echo $f|awk -v s=$s '{$3 = $1 - 's'; printf "%f", $3}')

	if [[ $cpfound -ge 1 ]]; then
		echo "HTTP CONTENT OK: URL $h_url returned $pattern|time="$sum"ms;;;;0 size="$clength"B;;;0"
         	exit 0;
	else
		echo "HTTP CONTENT CRITICAL: URL $h_url did not return $pattern|time="$sum"ms;;;;0 size="$clength"B;;;0"
	exit 2;

	fi
}

function usage() { 
	echo "$0 -U http://url.com -u user -p pass -m Some_pattern"
	exit 1;
}

while test -n "$1"; do
case "$1" in
        --help|-h)
           usage
            exit 0
            ;;
        --url|-U)
url=$2;
shift
            ;;

	--user|-u)
username=$2;
shift
	;;
        --password|-p)
password=$2;
shift
            ;;
        --match|-m)
pattern=$2;
if [ "$pattern" == "" ]; then
usage;
fi
find_pattern;
            ;;
        *)
echo "Unknown argument: $1"
echo "-h for help";
exit 1
            ;;
    esac
shift
done

#############################################################################################

#############################################################################################
if [ $# -eq 0 ]; then
echo "-h for help";
    exit 1;
fi
#############################################################################################
