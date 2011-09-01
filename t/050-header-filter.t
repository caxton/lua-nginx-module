# vim:set ft= ts=4 sw=4 et fdm=marker:

use lib 'lib';
use Test::Nginx::Socket;

#worker_connections(1014);
#master_process_enabled(1);
#log_level('warn');

repeat_each(2);
#repeat_each(10000);

plan tests => blocks() * repeat_each() * 3 - repeat_each();

#no_diff();
#no_long_string();

run_tests();

__DATA__

=== TEST 1: set response content-type header
--- config
    location /read {
        echo "Hi";
        header_filter_by_lua '
            ngx.header.content_type = "text/my-plain";
        ';

    }
--- request
GET /read
--- response_headers
Content-Type: text/my-plain
--- response_body
Hi



=== TEST 2: lua code run failed
--- config
    location /read {
        echo "Hi";
        header_filter_by_lua '
            ngx.header.content_length = "text/my-plain";
        ';

    }
--- request
GET /read
--- error_code
--- response_body



=== TEST 3: use variable generated by content phrase
--- config
   location /read {
        set $strvar '1';
        content_by_lua '
            ngx.var.strvar = "127.0.0.1:8080";
            ngx.say("Hi");
        ';
        header_filter_by_lua '
            ngx.header.uid = ngx.var.strvar;
        ';

    }
--- request
GET /read
--- response_headers
uid: 127.0.0.1:8080
--- response_body
Hi



=== TEST 4: use variable generated by content phrase for HEAD
--- config
   location /read {
        set $strvar '1';
        content_by_lua '
            ngx.var.strvar = "127.0.0.1:8080";
            ngx.say("Hi");
        ';
        header_filter_by_lua '
            ngx.header.uid = ngx.var.strvar;
        ';

    }
--- request
HEAD /read
--- response_headers
uid: 127.0.0.1:8080
--- response_body



=== TEST 5: use variable generated by content phrase for HTTP 1.0
--- config
   location /read {
        set $strvar '1';
        content_by_lua '
            ngx.var.strvar = "127.0.0.1:8080";
            ngx.say("Hi");
        ';
        header_filter_by_lua '
            ngx.header.uid = ngx.var.strvar;
        ';

    }
--- request
GET /read HTTP/1.0
--- response_headers
uid: 127.0.0.1:8080
--- response_body
Hi


