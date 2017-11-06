require 'json'
require 'yaml'

class Template
  attr_reader :environment, :absolute_home

  def initialize(environment,app_home,cfndsl_template)
    @environment = environment
    @cfndsl_template = cfndsl_template
    @absolute_home = absolute_path app_home
  end
  def generate_json
    json_path = "#{absolute_home}/#{cf_template('json')}"
    File.write(json_path,JSON.pretty_generate(body))
    Log.info "JSON cloudformation template: #{json_path}"
  end
  def generate_yaml
    yaml_path = "#{absolute_home}/#{cf_template('yaml')}"
    File.write(yaml_path,body.to_yaml)
    Log.info "YAML cloudformation template: #{yaml_path}"
  end

  private
  def cf_template(extension)
    @cfndsl_template.split(".")[0] + ".#{extension}"
  end
  def body()
    extras ={}
    extras[:environment] = environment
    template_body ||= CfnDsl.eval_file_with_extras(path, extras)
  end
  def path
    absolute_home + "/#{@cfndsl_template}"
  end

end
