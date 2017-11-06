require 'cfndsl'
require_relative '../lib/template'

namespace :cf do
  desc 'JSON CF template, Usage:- bundle exec rake cf:template_json[UAT,src/apps/www-casino]'
  task :template_json, [:environment, :app_home, :cfndsl_template] do |t, args|
    exit_on_mandatory_rake_arguments args, :environment, :app_home
    template = Template.new(args[:environment], args[:app_home], args[:cfndsl_template] || 'cloudformation.rb')
    template.generate_json
  end
  desc 'YAML CF template, Usage:- bundle exec rake cf:template_yaml[UAT,src/apps/www-casino]'
  task :template_yaml, [:environment, :app_home, :cfndsl_template] do |t, args|
    exit_on_mandatory_rake_arguments args, :environment, :app_home
    template = Template.new(args[:environment], args[:app_home], args[:cfndsl_template] || 'cloudformation.rb')
    template.generate_yaml
  end
end
