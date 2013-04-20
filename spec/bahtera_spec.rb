require 'spec_helper'

describe Bahtera do
  describe '#lookup' do
    it 'should respond to #lookup' do
      Bahtera.should respond_to(:lookup)
    end

    it 'should send request to the correct address' do
      word = 'makan'
      Net::HTTP.should_receive(:get_response).
              with(Addressable::URI.parse("http://kateglo.bahtera.org/api.php?format=json&phrase=#{word}")).
              and_return(stub_net_http_success('bahtera_kata_valid'))
      Bahtera.lookup word
    end

    describe '#lookup valid words' do
      before do
        stub_net_http('bahtera_kata_valid')
      end

      it '#lookup a valid word should return an instance of Bahtera::Kata' do
        word = 'kata'
        Bahtera.lookup(word).should be_a(Bahtera::Kata)
      end

      it '#lookup many valid words should return an array of Bahtera::Kata instances' do
        results = Bahtera.lookup('minum makan belajar')
        results.should be_a(Array)
        results.all? { |r| r.is_a?(Bahtera::Kata) }.should be_true
      end
    end

    it '#lookup invalid words should raise MultiJson::LoadError' do
      stub_net_http('bahtera_kata_invalid')
      word = 'invalid_kata'
      expect { Bahtera.lookup(word) }.to raise_error(MultiJson::LoadError)
    end

    it '#lookup mix of invalid & valid words should return an array of nil & Bahtera::Kata' do
      word_hash = {
        kata:     'bahtera_kata_valid',
        gwempor:  'bahtera_kata_invalid'
      }
      word_hash.each do |word, filename|
        Net::HTTP.stub(:get_response).
          with(Addressable::URI.parse("http://kateglo.bahtera.org/api.php?format=json&phrase=#{word}")).
          and_return(stub_net_http_success(filename))
      end
      results = Bahtera.lookup('kata gwempor')
      results.should be_a(Array)
      results.first.should be_a(Bahtera::Kata)
      results.last.should be_nil
    end

    describe 'should raise Bahtera::RequestError when' do
      it 'returning request is a client error' do
        stub_net_http(nil, '404')
        expect {
          Bahtera.lookup('that_throws_error')
          }.to raise_error(Bahtera::RequestError)
      end
    end
  end
end