require 'spec_helper'

describe Kateglo do
  describe '#lookup' do
    it 'should respond to #lookup' do
      expect(Kateglo).to respond_to(:lookup)
    end

    it 'should send request to the correct address' do
      word = 'makan'
      expect(Net::HTTP).to receive(:get_response).
              with(URI.parse("#{Kateglo.singleton_class::BASE_URL}?format=json&phrase=#{word}")).
              and_return(
                stub_net_http_success('kateglo_phrase_valid')['kateglo'].
                  tap{|res| res.delete('phrase') }
              )
      Kateglo.lookup word
    end

    describe '#lookup valid words' do
      before do
        stub_net_http('kateglo_phrase_valid')
      end

      it '#lookup a valid word should return an instance of Kateglo::Phrase' do
        word = 'kata'
        expect(Kateglo.lookup(word)).to be_kind_of(Kateglo::Phrase)
      end
    end

    it '#lookup invalid words should raise MultiJson::LoadError' do
      stub_net_http('kateglo_phrase_invalid')
      word = 'invalid_kata'
      expect(Kateglo.lookup(word)).to be_kind_of(Kateglo::PhraseNotFound)
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
