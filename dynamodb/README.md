# DynamoDB


## Mirgrate from old account to new account

```sh
aws cloudformation deploy --stack-name Glue --template-file glue.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides OldAccountId=${OldAccountId}
```

```sh
aws glue start-job-run --job-name migrate-dynamodb --arguments='--table_name="articles"'
```

```sh
aws glue start-job-run --job-name migrate-dynamodb --arguments='--table_name="boards"'
```
