#!/bin/bash
set -e
mkdir -p data
# 首次初始化（生成默认配置和数据库）
if [ ! -f data/config.json ]; then
  timeout 15 ./alist server --data ./data || true
  sleep 2
fi
# 端口改成 Render 指定的 PORT
python3 -c "
import json, os
p = 'data/config.json'
d = json.load(open(p))
d['scheme']['http_port'] = int(os.environ.get('PORT', '5244'))
json.dump(d, open(p, 'w'))
print('port set to', d['scheme']['http_port'])
"
# 每次启动重置 admin 密码为环境变量指定值（免费版磁盘是临时的，保证总能登录）
./alist admin set "$ALIST_ADMIN_PASSWORD" --data ./data
echo "admin password set, starting server..."
exec ./alist server --data ./data
