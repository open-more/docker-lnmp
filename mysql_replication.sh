#!/bin/bash

PWD=`pwd`

echo $PWD

MASTER_DIR=$PWD/mysql/master/
SLAVE_DIR=$PWD/mysql/slave/

## First we could rm the existed container
docker rm -f mysql_master
docker rm -f mysql_slave

## Rm the existed directory
if [ -d $MASTER_DIR ]; then
    rm -rf $MASTER_DIR
    else
    mkdir -p $MASTER_DIR
fi

if [ -d $SLAVE_DIR ]; then
    rm -rf $SLAVE_DIR
    else
    mkdir -p $SLAVE_DIR
fi

## Start instance
echo 'Create master container'
docker run --name mysql_master -v $PWD/conf/mysql/master/my.cnf:/etc/mysql/my.cnf -v $MASTER_DIR:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=123456 -d mariadb

echo 'Create slave container'
docker run --name mysql_slave -v  $PWD/conf/mysql/slave/my.cnf:/etc/mysql/my.cnf  -v $SLAVE_DIR:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=123456 --link mysql_master:mysql_master -d mariadb

## Creating a User for Replication
docker stop mysql_master mysql_slave
docker start mysql_master mysql_slave

echo 'waiting.'
sleep 1
echo 'waiting..'
sleep 1
echo 'waiting...'
sleep 1

# create replication user and grant privaliage

echo 'Create replication user and grant privaliage'
docker exec -it mysql_master mysql -e "CREATE USER 'repl'@'%' IDENTIFIED BY 'repl';GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';"

echo 'Obtaining the Replication Master Binary Log Coordinates'
## Obtaining the Replication Master Binary Log Coordinates
master_status=`docker exec -it mysql_master mysql -e "show master status\G"`
master_log_file=`echo "$master_status" | awk  'NR==2{print substr($2,1,length($2)-1)}'`
master_log_pos=`echo "$master_status" | awk 'NR==3{print $2}'`
echo $master_log_pos
master_log_file="'""$master_log_file""'"
echo $master_log_file

echo 'Setting Up Replication Slaves'
## Setting Up Replication Slaves 
docker exec -it mysql_slave mysql -e "CHANGE MASTER TO MASTER_HOST='mysql_master',MASTER_PORT=3306,MASTER_USER='repl',MASTER_PASSWORD='repl',MASTER_LOG_FILE=$master_log_file,MASTER_LOG_POS=$master_log_pos;"
docker exec -it mysql_slave mysql -e "start slave;"
docker exec -it mysql_slave mysql -e "show slave status\G"

## Creates shortcuts
# grep "alias master" /etc/profile
# if [ $? -eq 1 ];then
#     echo 'alias mysql="docker exec -it master mysql"' >> /etc/profile
#     echo 'alias master="docker exec -it master mysql -h 127.0.0.1 -P3306"' >> /etc/profile
#     echo 'alias slave="docker exec -it master mysql -h 127.0.0.1 -P3307"' >> /etc/profile
#     source /etc/profile
# fi