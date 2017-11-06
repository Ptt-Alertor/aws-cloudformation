require 'json'

class App
  attr_reader :environment, :home
  def initialize(environment,app_home,cf_template)
    @environment = environment
    @cf_template = cf_template
    @home = absolute_path app_home
  end
  def stack_name
    return ENV['CF_STACK_NAME'] unless ENV['CF_STACK_NAME'].nil?
    name = "#{environment}-#{deploy_variables['app']}"
    deploy_variables['stackNameSuffix'] ? name += "-#{deploy_variables['stackNameSuffix']}" : name
  end

  def cf_params(runtime_params={})
      deploy_variables[@environment]['cloudFormation'].merge! (runtime_params)
  end

  def cf_body
    cf_template = "#{home}/#{@cf_template}"
    Log.error "File: #{cf_template} is missing!!" if not File.exists? cf_template
    File.read cf_template
  end

  def deploy(credentials,runtime_params,disable_rollback=true,timeout=3600)
    Log.info "Timeout: #{timeout}"
    Log.info "Disable Rollback: #{disable_rollback}"
    cf_stack = CFStackService.new(stack_name,cf_body,cf_params(runtime_params),credentials)
    cf_stack.deploy(disable_rollback,timeout)
  end

  private
  def deploy_variables
    vars_file = "#{home}/variables.json"
    Log.error "File: variables.json is missing!!" if not File.exists? vars_file
    JSON.load(File.read vars_file)
  end
end
