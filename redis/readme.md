# Elasticcache

## Backup and restore

> For Redis (cluster mode disabled) clusters, backup and restore are not supported on cache.t1.micro or cache.t2.* nodes. All other cache node types are supported.

### Solution

1. dump redis data by [node-redis-dump](https://github.com/jeremyfa/node-redis-dump)

    ```bash
    redis-dump -h {redis_endpoint} > mydb.dump.txt
    ```

1. copy file to new ec2 host

    ```bash
    ssh mydb.dump.txt ec2-user@host:~/
    ```

1. install redis-cli on new ec2 host

    ```bash
    yum install redis
    ```

1. restore by dump file

    ```bash
    cat mydb.dump.txt | redis-cli
    ```