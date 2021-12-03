## 高可用
https://doc.traefik.io/traefik/v1.4/benchmarks/
vm调优
```shell script
   sysctl -w fs.file-max="9999999"
   sysctl -w fs.nr_open="9999999"
   sysctl -w net.core.netdev_max_backlog="4096"
   sysctl -w net.core.rmem_max="16777216"
   sysctl -w net.core.somaxconn="65535"
   sysctl -w net.core.wmem_max="16777216"
   sysctl -w net.ipv4.ip_local_port_range="1025       65535"
   sysctl -w net.ipv4.tcp_fin_timeout="30"
   sysctl -w net.ipv4.tcp_keepalive_time="30"
   sysctl -w net.ipv4.tcp_max_syn_backlog="20480"
   sysctl -w net.ipv4.tcp_max_tw_buckets="400000"
   sysctl -w net.ipv4.tcp_no_metrics_save="1"
   sysctl -w net.ipv4.tcp_syn_retries="2"
   sysctl -w net.ipv4.tcp_synack_retries="2"
   sysctl -w net.ipv4.tcp_tw_recycle="1"
   sysctl -w net.ipv4.tcp_tw_reuse="1"
   sysctl -w vm.min_free_kbytes="65536"
   sysctl -w vm.overcommit_memory="1"
   ulimit -n 9999999
```



```
user www-data;
worker_processes auto;
worker_rlimit_nofile 200000;
pid /var/run/nginx.pid;

events {
    worker_connections 10000;
    use epoll;
    multi_accept on;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 300;
    keepalive_requests 10000;
    types_hash_max_size 2048;

    open_file_cache max=200000 inactive=300s;
    open_file_cache_valid 300s;
    open_file_cache_min_uses 2;
    open_file_cache_errors on;

    server_tokens off;
    dav_methods off;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /var/log/nginx/access.log combined;
    error_log /var/log/nginx/error.log warn;

    gzip off;
    gzip_vary off;

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*.conf;
}
```

