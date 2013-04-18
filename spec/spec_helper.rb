require 'bahtera'

def fixture_file(filename)
  file_path = File.join(File.expand_path(File.dirname(__FILE__)),
                        'fixtures', "#{filename}.json" )
  File.open(file_path).read
end