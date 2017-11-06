require 'cloudformation_stack'
require_relative '../lib/app'

namespace :cf do
  desc 'Deploy in case of no Parameter'
  task :deploy_default, [:environment, :aws_profile, :region, :app_home, :cf_template] do |t, args|
    exit_on_mandatory_rake_arguments args, :environment, :aws_profile, :region, :app_home
    runtime_params = {}
    deploy_params = {
      environment: args[:environment],
      aws_profile: args[:aws_profile],
      region: args[:region],
      app_home: args[:app_home],
      disable_rollback: true,
      timeout: 3600
    }
    app_deploy(deploy_params,runtime_params,args[:cf_template] || 'cloudformation.json')
  end
end
