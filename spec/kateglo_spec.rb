require 'spec_helper'

describe Kateglo do
  describe '#lookup' do
    it 'should respond to #lookup' do
      expect(Kateglo).to respond_to(:lookup)
    end

    it 'should send request to the correct address' do
      word = 'makan'
      expect(Net::HTTP).to receive(:get_response).
              with(Addressable::URI.parse("#{Kateglo.singleton_class::BASE_URL}?format=json&phrase=#{word}")).
              and_return(stub_net_http_success('kateglo_kata_valid'))
      Kateglo.lookup word
    end

    describe '#lookup valid words' do
      before do
        stub_net_http('kateglo_kata_valid')
      end

      it '#lookup a valid word should return an instance of Kateglo::Kata' do
        word = 'kata'
        expect(Kateglo.lookup(word)).to be_kind_of(Kateglo::Kata)
      end

      it '#lookup many valid words should return an array of Kateglo::Kata instances' do
        results = Kateglo.lookup('minum makan belajar')
        expect(results).to be_kind_of(Array)
        results.each { |r| expect(r.is_a?(Kateglo::Kata)).to be true }
      end
    end

    it '#lookup invalid words should raise MultiJson::LoadError' do
      stub_net_http('kateglo_kata_invalid')
      word = 'invalid_kata'
      expect(Kateglo.lookup(word)).to be_kind_of(Kateglo::LemmaNotFound)
    end

    it '#lookup mix of invalid & valid words returns an array of LemmaNotFound & Kata instances' do
      word_hash = {
        kata:     'kateglo_kata_valid',
        gwempor:  'kateglo_kata_invalid'
      }
      word_hash.each do |word, filename|
        allow(Net::HTTP).to receive(:get_response).
          with(Addressable::URI.parse("#{Kateglo.singleton_class::BASE_URL}?format=json&phrase=#{word}")).
          and_return(stub_net_http_success(filename))
      end
      results = Kateglo.lookup('kata gwempor')
      expect(results).to be_kind_of(Array)
      expect(results.first).to be_kind_of(Kateglo::Kata)
      expect(results.last).to be_kind_of(Kateglo::LemmaNotFound)
    end

    describe 'should raise Kateglo::RequestError when' do
      it 'returning request is a client error' do
        stub_net_http(nil, '404')
        expect {
          Kateglo.lookup('that_throws_error')
        }.to raise_error(Kateglo::RequestError)
      end
    end
  end
end
