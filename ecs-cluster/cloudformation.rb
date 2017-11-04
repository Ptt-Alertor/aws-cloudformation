# Uses https://github.com/stevenjack/cfndsl
absolute_path = File.dirname(__FILE__)
variables = JSON.load(File.read("#{absolute_path}/variables.json"))
environment = extras[:environment]

CloudFormation {
  Description "#{environment} ECS Host Cluster"

  Resource('ECSCluster') {
    Type 'AWS::ECS::Cluster'
    Property 'ClusterName', FnJoin('',[ environment, "-Cluster" ])
  }

  Output("EcsCluster"){
    Description 'Exporting ECS-Cluster-Name'
    Value Ref('ECSCluster')
    Export FnJoin('',[ Ref('AWS::StackName')])
  }
}
