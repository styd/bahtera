source 'https://rubygems.org'

# Specify your gem's dependencies in bahtera.gemspec
gemspec


# To use in development
group :development do
  gem 'guard'
  gem 'guard-rspec'
  gem 'pry', require: true
  gem 'pry-debugger'

  if RbConfig::CONFIG['host_os'] =~ /darwin/
    gem 'growl'
    gem 'rb-fsevent', require: false
  end
end