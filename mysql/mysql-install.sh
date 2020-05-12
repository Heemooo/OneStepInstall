#!/bin/bash
docker pull mysql:5.7.30
#/mysql/data 是数据库文件存放的地方。必须要挂载到容器外，否则容器重启一切数据消失
mkdir -p /home/mysql/data
#/mysql/log 是数据库主生的log。建议挂载到容器外。
mkdir -p /home/mysql/log
mkdir -p /home/mysql/config
#mysql/config/my.cnf 是数据库的配置文件
touch /home/mysql/config/my.cnf
#若是mysql8请加入default_authentication_plugin= mysql_native_password （这个是因应mysql8的安全机制升级而需要修改的配置，不配置的话将无法登录管理）
cat>/home/mysql/config/my.cnf<<EOF
[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
# Custom config should go here
!includedir /etc/mysql/conf.d/
EOF
#/etc/localtime:/etc/localtime:ro 是让容器的时钟与宿主机时钟同步，避免时区的问题，ro是read only的意思，就是只读。
docker run \
    -p 3306:3306 \
    -e MYSQL_ROOT_PASSWORD=yourpasswd \
    -v /home/mysql/data:/var/lib/mysql:rw \
    -v /home/mysql/log:/var/log/mysql:rw \
    -v /home/mysql/config/my.cnf:/etc/mysql/my.cnf:rw \
    -v /etc/localtime:/etc/localtime:ro \
    --name mysql5.7.30 \
    --restart=always \
    -d mysql:5.7.30