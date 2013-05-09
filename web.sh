#!/bin/bash
#
# Simple URL checker  - interpretation of URL redirects.
# This should work with any appplication - run in a command line as:
#
# web.sh -u http://host.something/uri1/etc -p 80 -m content
# web.sh -u http://host.something/uri1/etc -p 8080 -m content
#
# This will then load the full URL requested, and will search the page for the word "content". 
# Issues with redirects - session content should work 

function find_pattern() { 
	s=$(date +%s.%N)

	if [ "$URL" == "" ]; then
       		URL="http://localhost";
        fi

	if [ "$PORT" == "" ]; then
		PORT=80;
	fi
	if [[ $URL  =~ http:// ]]; then
       		c_url=$(echo $URL|sed -e "s:http\://::g")
	else
		c_url=$URL;
	fi

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
 		h_url="http://"$b_url":"$PORT$e_url

  	head="POST $h_url HTTP/1.1\r\nHost: $(uname -n)\r\nContent-type: text/html\r\nContent-length: 10\r\nConnection: Close\r\n\r\n";
	# Enable below to see actual output for debugging purposes
	#echo -e "$head" |nc $c_url $PORT  2>&1
  	return=$(echo -e "$head" |nc $c_url $PORT  2>&1|egrep "(Content-Length:|$PATTERN)")
  	clfound=0;
  	cpfound=0;
	if [[ $return =~  "Content-Length:" ]]; then
		clfound=1;
		clength=$(echo $return|grep  "Content-Length:"|awk -F"Content-Length: " '{print $2}'|awk -F" " '{print $1}'|tr -d "\r")
		
	fi
	if [[ $return =~ "$PATTERN" ]]; then
		cpfound=1;
		cpattern=$(echo $return|grep -v "Content-Length:"|tr -d "\r")
	fi

	if [[ $clfound == 0 ]]; then 
		head="HEAD $h_url HTTP/1.1\r\nHost: $(uname -n)\r\nContent-type: text/html\r\nContent-length: 10\r\nConnection: Close\r\n\r\n";
  		clength=$(echo -e "$head" |nc $c_url $PORT  2>&1|grep  "Content-Length:"|awk -F"Content-Length: " '{print $2}'|tr -d "\r")
		if [ "$clength" == "" ]; then 
			clength=0;
		fi
	fi

	f=$(date +%s.%N)
        sum=$(echo $f|awk -v s=$s '{$3 = $1 - 's';  printf "%f", $3}')

	if [[ $cpfound -ge 1 ]]; then 
		echo "HTTP CONTENT OK: URL $h_url returned $PATTERN|time="$sum"ms;;;;0 size="$clength"B;;;0"
        	exit 0;
	else
		echo "HTTP CONTENT CRITICAL: URL $h_url did not return $PATTERN|time="$sum"ms;;;;0 size="$clength"B;;;0"
		exit 2;

	fi
}

function usage() { 
	echo "$0 -u http://url.com -p 80 -m Some_pattern"
	echo "$0  -m Some_pattern"
	echo "2nd will check localhost on default port 80 for some_pattern"
	exit 1;
}


while test -n "$1"; do
    case "$1" in
        --help|-h)
           usage
            exit 0
            ;;
        --url|-u)
		URL=$2;

		shift
            ;;

        --port|-p)
		PORT=$2;
		shift
            ;;
        --match|-m)
		PATTERN=$2;
		if [ "$PATTERN" == "" ]; then	
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
