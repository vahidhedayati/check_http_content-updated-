check_http_content-updated-
===========================

Nagios script by CapSiDE SL - has been updated to generate graphs for pnp4nagios



./check_http_content.v -U http://www.google.com -m google

CONTENT OK: EXPR google FOUND on http://www.google.com FOUND|rtime=0;;;0.000000 size=10738B 


Modified output to include the url and pattern so it is easier to work out what the actual issue is 


Performance data added where it caculates time  taken to get the page as well as the content size 
