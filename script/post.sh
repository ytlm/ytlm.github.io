#!/usr/bin/env bash

grep -P "https?://ytlm[^<>]*" ./public/sitemap.xml -o > /tmp/urls.txt

wc -l /tmp/urls.txt

curl -v -H 'Content-Type:text/plain' --data-binary @/tmp/urls.txt "http://data.zz.baidu.com/urls?site=ytlm.github.io&token=6IHH93TjHvvymgnY"

rm -rf /tmp/urls.txt
