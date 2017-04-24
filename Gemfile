source 'https://rubygems.org'

gemspec


# To use in development
group :development do
  gem 'guard'
  gem 'guard-rspec'
  gem 'pry', require: true

  if RbConfig::CONFIG['host_os'] =~ /darwin/
    gem 'growl'
    gem 'rb-fsevent', require: false
  end
end
