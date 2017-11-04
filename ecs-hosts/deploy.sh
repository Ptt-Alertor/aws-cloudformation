Profile="Production"
Environment=$Profile
APP=$(cat variables.json | jq '.app' --raw-output)
aws --profile $Profile cloudformation create-stack --stack-name $Environment --capabilities CAPABILITY_IAM --template-body file://./cloudformation.json
