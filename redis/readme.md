# Elasticcache

## Backup and restore

> For Redis (cluster mode disabled) clusters, backup and restore are not supported on cache.t1.micro or cache.t2.* nodes. All other cache node types are supported.

### Solution

1. dump redis data by [node-redis-dump](https://github.com/jeremyfa/node-redis-dump)

    ```bash
    redis-dump -h {redis_endpoint} > mydb.dump.txt
    ```

1. replace unicode to char
    1. replace `\\u0026` to `&`
    1. replace `\\u003c` to `<`
    1. replace `\\u003e` to `>`
    1. replace `\u0026` to `&`
    1. replace `\u003c` to `<`
    1. replace `\u003e` to `>`

    ```bash
    sed -i 's/\\\\u0026/\&/g' mydb.dump.txt
    sed -i 's/\\\\u003c/</g' mydb.dump.txt
    sed -i 's/\\\\u003e/>/g' mydb.dump.txt
    sed -i 's/\\u0026/\&/g' mydb.dump.txt
    sed -i 's/\\u003c/</g' mydb.dump.txt
    sed -i 's/\\u003e/>/g' mydb.dump.txt
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