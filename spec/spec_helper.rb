require 'bahtera'

class SocketStub
  def initialize(body)
    @body = body
  end

  def closed?
    false
  end

  def read_all(from)
    @body
  end
end

def stub_net_http_response(filename)
  body = fixture_file(filename)
  response = Net::HTTPOK.new(Net::HTTP.version_1_2, '200', '')
  response.reading_body(SocketStub.new(body), true){}
  response.body = body
  response
end

def fixture_file(filename)
  file_path = File.join(File.expand_path(File.dirname(__FILE__)),
                        'fixtures', "#{filename}.json" )
  File.read file_path
end