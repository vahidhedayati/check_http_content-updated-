#!/usr/bin/perl

use LWP::UserAgent;
use HTTP::Request::Common;
use LWP::Debug qw(+);

my $url=$ARGV[0];
my $pattern=$ARGV[1];

my $ua = new LWP::UserAgent(keep_alive => 1);
$ua->proxy([qw( https http )], "http://your_proxy_server:8080");
my $req = GET  $url;
$req->proxy_authorization_basic('USERNAME', 'PASSWORD');
my $res = $ua->request($req);
$result_found="0";
$return_val="";
if ($res->is_success) {
   $content = $res->content();
        @page = split(/\n/,$content);
        foreach $line (@page) {
           # print "$line\n";
           #$line = uri_unescape($line);
           if ($line =~ /$pattern/) {  $result_found=1; $return_val=$line; }
           # print "$line\n";

         }
        #print "Result found=$result_found\n";
	#print "Line was $return_val\n";
	if ($result_found==1) { 
		print "HTTP_CONTENT_CHECK: OK $url pattern: $pattern found\n";
		exit 0;
	}else{
		print "HTTP_CONTENT_CHECK: CRITICAL $url pattern: $pattern NOT FOUND\n";
		exit 2;
	}
	
} else {
   # print "Error: " . $res->status_line . "\n";
	  print "HTTP_CONTENT_CHECK: CRITICAL".$res->status_line."\n";
	 exit 2;
    #print $res->headers()->as_string(), "\n";
}
exit 0;
