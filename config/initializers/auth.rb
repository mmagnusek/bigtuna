filename = File.join(File.dirname(__FILE__), '..', 'auth.yml')
AUTH = if File.file?(filename)
  YAML::load_file(filename)
else
  []
end
