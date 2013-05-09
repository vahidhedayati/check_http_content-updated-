check_http_content-updated-
===========================

Nagios script by CapSiDE SL - has been updated to generate graphs for pnp4nagios



./check_http_content.v -U http://www.google.com -m google

CONTENT OK: EXPR google FOUND on http://www.google.com FOUND|rtime=0;;;0.000000 size=10738B 


Modified output to include the url and pattern so it is easier to work out what the actual issue is 


Performance data added where it caculates time  taken to get the page as well as the content size 


There is also now an additional script called web.sh

web.sh works with URL's that *redirect or require a session id

Basically there are certain types of addresses that either create a session ID or do a quick *redirect and I found the check_http_content fails, initial web.sh was using elinks/links to get the content which worked in both cases of session ID's or redirects.

I decided to re-write it using netcat to connect to the given port 

./web.sh -u http://address -p 80 -m text_to_match


Now if you are testing some url that is as follows:

http://server:8080/base/app
Try:
./web.sh -u http://server/base/app -p 8080 -m text_to_match

If it fails try something like:
./web.sh -u http://server/base/app/ -p 8080 -m text_to_match


The script will work out where to put the port if no port given it will default to 80  if no url give it will default to localhost


                   ./web.sh 
                        -h for help
                        
                  ./web.sh -h
                  ./web.sh -u http://url.com -p 80 -m Some_pattern
                  ./web.sh  -m Some_pattern
                  
                  ./web.sh -m aa
                   HTTP CONTENT CRITICAL: URL http://localhost:80/ did not return aa|time=0.014712ms;;;;0 size=301B;;;0
                   
                  ./web.sh -m a
                   HTTP CONTENT OK: URL http://localhost:80/ returned a|time=0.047703ms;;;;0 size=301B;;;0

Mmm  just been testing this now sessions was working for sure but redirects needs a lot more work - will update it soon



