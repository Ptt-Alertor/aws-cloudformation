def absolute_path app_home_relative
  return File.expand_path("../../#{app_home_relative}",File.dirname(__FILE__))
end
