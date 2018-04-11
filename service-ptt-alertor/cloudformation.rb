# Uses https://github.com/stevenjack/cfndsl
# TODO: Rename LogsGroup to LogGroup, Cloudwatch to CloudWatch, Ptt-Aletor to Ptt-Alertor
absolute_path = File.dirname(__FILE__)
variables = JSON.load(File.read("#{absolute_path}/variables.json"))
environment=extras[:environment]
# get mappings from variables.json
mapping = variables[environment]
stack = mapping['Stack']

CloudFormation {
  Description "ECS Service #{mapping['app']}"

  Resource('EcsServiceRole'){
    Type 'AWS::IAM::Role'
    Property 'AssumeRolePolicyDocument', {
      Statement: [ {
        Effect: 'Allow',
        Principal: { Service: 'ecs.amazonaws.com' },
        Action: [ 'sts:AssumeRole' ]
      } ]
    }
    Property 'Path', '/'
    Property 'Policies', [{
      PolicyName: 'ecs-service',
      PolicyDocument: {
        Statement: [{
          Effect: 'Allow',
          Action: [
           "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
           "elasticloadbalancing:DeregisterTargets",
           "elasticloadbalancing:Describe*",
           "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
           "elasticloadbalancing:RegisterTargets",
           "ec2:Describe*",
           "ec2:AuthorizeSecurityGroupIngress"
          ],
          Resource: "*"
        }]
      }
    }]
  }

  Resource('SecurityGroup'){
    Type 'AWS::EC2::SecurityGroup'
    Property 'GroupDescription', 'EC2 security group for Application Load Balancer'
    Property 'VpcId', FnImportValue(FnSub("#{stack['VPC']}-VpcId"))
    Property 'SecurityGroupIngress', [
      {
        IpProtocol: 'tcp',
        FromPort:   1,
        ToPort:     65535,
        CidrIp:     "0.0.0.0/0"
      }
    ]
    Property 'SecurityGroupEgress', [
      {
        IpProtocol: -1,
        FromPort:   1,
        ToPort:     65535,
        CidrIp:     "0.0.0.0/0"
      }
    ]
    Property 'Tags', [ {
          Key: 'Name',
          Value: FnJoin('', [ environment, "-#{variables['app']}", "-SG"])
    } ]
  }

  Resource('CloudwatchLogsGroup'){
    Type "AWS::Logs::LogGroup"
    Property 'LogGroupName', FnJoin('',[ environment, '-', variables['app'] ])
    Property 'RetentionInDays', '400'
  }

  Resource('TaskDefinition'){
    Type "AWS::ECS::TaskDefinition"
    Property 'Family', FnJoin('',[ environment, '-', variables['app'] ])
    Property 'Volumes', [{
      Name: 'env',
      Host: {
        SourcePath: '/etc/ecs/.env'
      }
    }]
    Property 'ContainerDefinitions', [{
      Name: variables['app'],
      Image: variables['ContainerImage'],
      Essential: true,
      Cpu: mapping['CPU'],
      Memory: mapping['MEM'],
      PortMappings: [{
          ContainerPort: variables['Port']['HTTP']['Container'],
          HostPort: variables['Port']['HTTP']['Host'],
        },
        {
          ContainerPort: variables['Port']['Redis']['Container'],
          HostPort: variables['Port']['Redis']['Host'],
        },
        {
          ContainerPort: variables['Port']['WebSocket']['Container'],
          HostPort: variables['Port']['WebSocket']['Host'],
        }
      ],
      MountPoints: [
        ContainerPath: "/.env",
        SourceVolume: "env",
        ReadOnly: true
      ],
      Environment: [
        { Name: 'APP_ENV', Value: environment },
        { Name: 'Redis_EndPoint', Value: FnImportValue(FnSub("#{stack['Redis']}-EndPoint")) },
        { Name: 'Redis_Port', Value: FnImportValue(FnSub("#{stack['Redis']}-Port")) }
      ],
      EntryPoint: [
        "sh",
        "-c"
      ],
      Command: [
        "export $(cat /.env | grep -v ^# | xargs);./ptt-alertor"
      ]
      LogConfiguration: {
        LogDriver: 'awslogs',
        Options: {
          'awslogs-group': Ref('CloudwatchLogsGroup'),
          'awslogs-region': Ref("AWS::Region"),
          'awslogs-stream-prefix': environment
        }
      }
    }]
  }

  Resource('EcsService'){
    Type "AWS::ECS::Service"
    Property 'ServiceName', variables['app']
    Property 'Cluster', FnImportValue(FnSub("#{stack['ECSCluster']}"))
    Property 'DesiredCount', mapping['DesiredCount']
    Property 'TaskDefinition', Ref('TaskDefinition')
    Property 'Role', Ref('EcsServiceRole')
    Property 'LoadBalancers', [{
      ContainerName: variables['app'],
      ContainerPort: variables['Port']['HTTP']['Container'],
      LoadBalancerName: Ref('ElasticLoadBalancer')
    }]
  }

  Resource('ElasticLoadBalancer') {
    Type 'AWS::ElasticLoadBalancing::LoadBalancer'
    Property 'SecurityGroups', [ Ref('SecurityGroup') ]
    Property 'CrossZone', true
    Property 'Subnets', [
      FnImportValue(FnSub("#{stack['VPC']}-PublicSubnet-A")),
      FnImportValue(FnSub("#{stack['VPC']}-PublicSubnet-B")),
      FnImportValue(FnSub("#{stack['VPC']}-PublicSubnet-C")),
    ]
    Property 'Scheme', 'internet-facing'
    Property 'Listeners', [
      {
        LoadBalancerPort: 80,
        InstancePort: variables['Port']['HTTP']['Host'],
        Protocol: 'HTTP',
        InstanceProtocol: 'HTTP'
      },
      {
        LoadBalancerPort: 443,
        InstancePort: variables['Port']['HTTP']['Host'],
        Protocol: 'SSL',
        InstanceProtocol: 'TCP',
        SSLCertificateId: FnImportValue("Production-PttAlertor-Cert-Arn")
      }
    ]
    Property 'HealthCheck', {
      Target: FnFormat("HTTP:80/"),
      HealthyThreshold: 10,
      UnhealthyThreshold: 2,
      Interval: 30,
      Timeout: 5
    }
    Property 'LoadBalancerName', FnJoin('', [ environment, "-#{variables['app']}", "-LB"])
    Property 'Tags', [ {
      Key: 'Name',
      Value: FnJoin('', [ environment, "-#{variables['app']}", "-SG"])
    } ]
  }
  Output("EcsService"){
    Description 'name of ecs service'
    Value FnGetAtt('EcsService', 'Name')
    Export "Production-ECS-Service-Name"
  }
  Output("ElasticLoadBalancer"){
    Description 'name of elb'
    Value Ref("ElasticLoadBalancer")
    Export FnJoin("", [Ref("AWS::StackName"), "-ELB"])
  }
  Output("CloudwatchLogsGroup"){
    Description 'name of log group'
    Value Ref("CloudwatchLogsGroup")
    Export FnJoin("", [Ref("AWS::StackName"), "-LogGroup"])
  }
  Output("CloudwatchLogsGroupArn"){
    Description 'arn of log group'
    Value FnGetAtt('CloudwatchLogsGroup', 'Arn')
    Export FnJoin("", [Ref("AWS::StackName"), "-LogGroup-Arn"])
  }
}
