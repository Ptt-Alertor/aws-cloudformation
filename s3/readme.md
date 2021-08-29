# S3 (Simple Storage Service)

* **change s3 bucket name before create stack**

## Transfer files from old bucket to new bucket

1. Add policy on old bucket (replace 222222222222 by new account number)

    ```json
    #Bucket policy set up in the source AWS account.
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "DelegateS3Access",
                "Effect": "Allow",
                "Principal": {"AWS": "222222222222"},
                "Action": ["s3:ListBucket","s3:GetObject"],
                "Resource": [
                    "arn:aws:s3:::ptt-alertor-2020-bucket/*",
                    "arn:aws:s3:::ptt-alertor-2020-bucket"
                ]
            }
        ]
    }
    ```

1. execute aws s3 sync command

    ```console
    aws s3 sync s3://ptt-alertor-2020-bucket s3://ptt-alertor-2021-bucket
    ```

* [transfer bucket files to another one](https://aws.amazon.com/tw/premiumsupport/knowledge-center/account-transfer-s3/)
