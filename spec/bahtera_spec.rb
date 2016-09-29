require 'spec_helper'

describe Bahtera do
  describe '#lookup' do
    it 'should respond to #lookup' do
      expect(Bahtera).to respond_to(:lookup)
    end

    it 'should send request to the correct address' do
      word = 'makan'
      expect(Net::HTTP).to receive(:get_response).
              with(Addressable::URI.parse("#{Bahtera.singleton_class::BASE_URL}?format=json&phrase=#{word}")).
              and_return(stub_net_http_success('bahtera_kata_valid'))
      Bahtera.lookup word
    end

    describe '#lookup valid words' do
      before do
        stub_net_http('bahtera_kata_valid')
      end

      it '#lookup a valid word should return an instance of Bahtera::Kata' do
        word = 'kata'
        expect(Bahtera.lookup(word)).to be_kind_of(Bahtera::Kata)
      end

      it '#lookup many valid words should return an array of Bahtera::Kata instances' do
        results = Bahtera.lookup('minum makan belajar')
        expect(results).to be_kind_of(Array)
        results.each { |r| expect(r.is_a?(Bahtera::Kata)).to be true }
      end
    end

    it '#lookup invalid words should raise MultiJson::LoadError' do
      stub_net_http('bahtera_kata_invalid')
      word = 'invalid_kata'
      expect(Bahtera.lookup(word)).to be_kind_of(Bahtera::LemmaNotFound)
    end

    it '#lookup mix of invalid & valid words returns an array of LemmaNotFound & Kata instances' do
      word_hash = {
        kata:     'bahtera_kata_valid',
        gwempor:  'bahtera_kata_invalid'
      }
      word_hash.each do |word, filename|
        allow(Net::HTTP).to receive(:get_response).
          with(Addressable::URI.parse("#{Bahtera.singleton_class::BASE_URL}?format=json&phrase=#{word}")).
          and_return(stub_net_http_success(filename))
      end
      results = Bahtera.lookup('kata gwempor')
      expect(results).to be_kind_of(Array)
      expect(results.first).to be_kind_of(Bahtera::Kata)
      expect(results.last).to be_kind_of(Bahtera::LemmaNotFound)
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
