#!/bin/bash

cd public/

cat sitemap.xml | grep -P "https?://ytlm[^<>]*" -o  > urls.txt

curl -H 'Content-Type:text/plain' --data-binary @urls.txt "http://data.zz.baidu.com/urls?site=http://ytlm.github.io&token=6IHH93TjHvvymgnY"

cd ..
