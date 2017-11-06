def exit_on_mandatory_rake_arguments args, *arguments
  error_messages = arguments.inject([]) do |messages, argument|
    if args[argument].nil?
      messages.push "Mandatory rake argument: #{argument.to_s}"
    end
    messages
  end

  if error_messages.size > 0
    Log.error 'Exiting on error. Missing mandatory rake arguments.' + "\n " + error_messages.join('\n')
  end
end

def app_deploy(deploy_params,runtime_params,cf_template)
  app = App.new(deploy_params[:environment], deploy_params[:app_home],cf_template)
  credentials = { aws_profile: deploy_params[:aws_profile], region: deploy_params[:region] }
  app.deploy(credentials,runtime_params,deploy_params[:disable_rollback],deploy_params[:timeout])
end

def update_rds_secret(environment,app_home,aws_credentials,region,stack_output)
  variables = JSON.load(File.read("#{absolute_path(app_home)}/variables.json")).to_hash
  rds_creds = JSON.load(File.read("#{absolute_path(app_home)}/#{variables['appFullName']}.json")).to_hash
  rds_creds["#{variables['app'].upcase}_DB_HOST"] = stack_output
  Log.info "DB host endpoint: #{stack_output}"
  secrets = Secrets.new(environment,aws_credentials,region,app_home)
  secrets.put(rds_creds.to_json)
end

def update_db_secret(environment,app_home,aws_credentials,region,stack_output)
  variables = JSON.load(File.read("#{absolute_path(app_home)}/variables.json")).to_hash
  db_creds = JSON.load(File.read("#{absolute_path(app_home)}/#{variables['appFullName']}.json")).to_hash
  db_creds["#{variables['appuser'].upcase}_DB_HOST"] = stack_output
  Log.info "DB host endpoint: #{stack_output}"
  secrets = Secrets.new(environment,aws_credentials,region,app_home)
  secrets.put(db_creds.to_json)
end
