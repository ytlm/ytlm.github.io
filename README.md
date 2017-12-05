hexo with github page

[![Build Status](https://travis-ci.org/ytlm/ytlm.github.io.svg?branch=hexo)](https://travis-ci.org/ytlm/ytlm.github.io)

### install
```shell
sudo npm install -g hexo-cli
npm install
git clone https://github.com/iissnan/hexo-theme-next themes/next
cp themes/config/_config.yml themes/next/_config.yml
```

### create new article and preview
```shell
hexo new [layout] <title>
hexo clean
hexo generate
hexo server
```
