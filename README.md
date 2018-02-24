# Docker LNMP
Docker deploying Nginx Mariadb10.x PHP7.2 in one key, support mysql master/slave replication.

### Feature
* 一键部署基于Docker的LNMP环境
* 一键部署主从复制Mysql库，实现读写分离
* 清晰的目录结构，方便运维

### Usage
1. Install `git`, `docker` and `docker-compose`;
2. Clone project:
    ```
    $ git clone https://github.com/openmore/docker-lnmp.git
    ```
3. config your Php web root
    ```
    $vi conf/nginx/conf.d/site.conf
    ```
4. Start docker containers:
    ```
    $ docker-compose up
    ```
    You may need use `sudo` before this command in Linux.

5. deploy Mysql master/slave replication
    ```
    $ ./mysql_replication.sh
    ``` 

