#!/usr/bin/env bash

cat ./public/sitemap.xml | grep -P "https?://ytlm[^<>]*" -o  > urls.txt

curl -H 'Content-Type:text/plain' --data-binary @urls.txt "http://data.zz.baidu.com/urls?site=https://ytlm.github.io&token=6IHH93TjHvvymgnY"

rm -rf urls.txt
