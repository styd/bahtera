require 'kateglo'

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

def stub_net_http(filename = nil, code = nil)
  response = if filename && code.nil?
    stub_net_http_success(filename)
  else
    stub_net_http_error(code)
  end
  allow(Net::HTTP).to receive(:get_response).and_return(response)
end

def stub_net_http_success(filename)
  body = fixture_file(filename)
  response = Net::HTTPOK.new(Net::HTTP.version_1_2, '200', '')
  attach_response_body(response, body)
end

def stub_net_http_error(code)
  body = fixture_file("kateglo_phrase_error_#{code}")
  response = Net::HTTPClientError.new(Net::HTTP.version_1_2, code, '')
  attach_response_body(response, body)
end

def attach_response_body(response, body)
  response.reading_body(SocketStub.new(body), true){}
  response.body = body
  response
end

def parsed_fixture_file(filename)
  MultiJson.load fixture_file(filename)
end

def fixture_file(filename)
  file_path = File.join(File.expand_path(File.dirname(__FILE__)),
                        'fixtures', "#{filename}.json" )
  File.read file_path
end
