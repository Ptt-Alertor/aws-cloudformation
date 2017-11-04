# Uses https://github.com/stevenjack/cfndsl
absolute_path = File.dirname(__FILE__)
variables = JSON.load(File.read("#{absolute_path}/variables.json"))
environment=extras[:environment]
# get mappings from variables.json
mapping = variables[environment]
stack = mapping['Stack']

CloudFormation {
  Description "#{environment} ECS Host"

  Resource('SecurityGroup') {
    Type 'AWS::EC2::SecurityGroup'
    Property 'GroupDescription', 'EC2 security group for docker deployment'
    Property 'VpcId', FnImportValue(FnSub("#{stack['VPC']}-VpcId"))
    Property 'SecurityGroupIngress', [
      {
        IpProtocol: 'tcp',
        FromPort:   '1',
        ToPort:     '65535',
        CidrIp:     '0.0.0.0/0'
      }
    ]
    Property 'SecurityGroupEgress', [
      {
        IpProtocol: 'tcp',
        FromPort:   '0',
        ToPort:     '65535',
        CidrIp:     '0.0.0.0/0'
      },
      {
        IpProtocol: 'udp',
        FromPort:   '0',
        ToPort:     '65535',
        CidrIp:     '0.0.0.0/0'
      }
    ]
  }

  Resource('InstanceRole'){
    Type 'AWS::IAM::Role'
    Property 'AssumeRolePolicyDocument', {
      Version: '2012-10-17',
      Statement: [ {
        Effect: 'Allow',
        Principal: { Service: 'ec2.amazonaws.com' },
        Action: [ 'sts:AssumeRole' ]
      } ]
    }
    Property 'Path', '/'
    Property 'Policies', [
      {
        PolicyName: 's3ConfigReadAccess',
        PolicyDocument: {
          Version: '2012-10-17',
          Statement: [ {
            Effect: 'Allow',
            Action: [ 's3:GetObject', 's3:ListBucket'],
            Resource: [
              "arn:aws:s3:::#{mapping['ConfigBucket']}",
              "arn:aws:s3:::#{mapping['ConfigBucket']}/*"
            ],
            Sid: 'ConfigReadAccess' 
          } ]
        }
      },
      {
        PolicyName: 'ecsAccess',
        PolicyDocument: {
          Version: '2012-10-17',
          Statement: [ {
            Effect: 'Allow',
            Action: [ 
              'ecs:*',
              'ecr:*',
              'logs:CreateLogStream',
              'logs:PutLogEvents'
            ],
            Resource: "*" 
          } ]
        }
      }
    ]
  }

  Resource('IamInstanceProfile'){
    Type 'AWS::IAM::InstanceProfile'
    Property 'Path', '/'
    Property 'Roles', [ Ref('InstanceRole') ]
  }

  Resource('LaunchConfiguration') {
    Type 'AWS::AutoScaling::LaunchConfiguration'
    Property 'ImageId', mapping['ImageId']
    Property 'InstanceType', mapping['InstanceType']
    Property 'KeyName', mapping['KeyName']
    Property 'SecurityGroups', [ Ref('SecurityGroup') ]
    Property 'AssociatePublicIpAddress', true
    Property 'IamInstanceProfile', Ref('IamInstanceProfile')
    cfn_init_arguments = {
      config_bucket: mapping['ConfigBucket'],
      cluster_name: FnImportValue(FnSub("#{stack['ECSCluster']}")),
    }
    Property 'UserData', FnBase64(FnFormat(IO.read("#{absolute_path}/files/userdata"), cfn_init_arguments))
  }

  Resource('AutoScalingGroup') {
    Type 'AWS::AutoScaling::AutoScalingGroup'
    Property 'LaunchConfigurationName', Ref('LaunchConfiguration')
    Property 'AvailabilityZones', [ FnImportValue(FnSub("#{stack['VPC']}-AvailabilityZone")) ]
    Property 'VPCZoneIdentifier', [ FnImportValue(FnSub("#{stack['VPC']}-PublicSubnet")) ]
    Property 'MaxSize', mapping['MaxSize']
    Property 'MinSize', mapping['MinSize']
    Property 'DesiredCapacity', mapping['DesiredCapacity']
    Property 'HealthCheckGracePeriod', 30
    Property 'HealthCheckType', 'EC2'
    Property 'Tags', [
      {
        Key: 'Name',
        Value: FnJoin('',[ environment, "-ECS-host" ]),
        PropagateAtLaunch: true
      },
      {
        Key: 'ImageId',
        Value: mapping['ImageId'],
        PropagateAtLaunch: true
      }
    ]
    Property 'TerminationPolicies', [ 'OldestInstance' ]
  }
}
