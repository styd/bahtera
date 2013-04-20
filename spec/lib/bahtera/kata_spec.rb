require 'spec_helper'

describe Bahtera::Kata do
  describe '#initialize' do
    it 'should initialize from valid json string' do
      Bahtera::Kata.new(parsed_fixture_file('bahtera_kata_valid')).should be_a(Bahtera::Kata)
    end

    it 'should raise MultiJson::LoadError when initializing from invalid json string' do
      expect {
        Bahtera::Kata.new(parsed_fixture_file('bahtera_kata_invalid'))
        }.to raise_error(MultiJson::LoadError)
    end

    describe 'assigning attribute with values' do
      parsed_response = parsed_fixture_file('bahtera_kata_valid')
      before do
        @expected_attributes = parsed_response['kateglo']
        @kata = Bahtera::Kata.new(parsed_response)
      end

      parsed_response['kateglo'].keys.each do |attr_name|
        it "should assign ##{attr_name} correctly" do
          @kata.send(attr_name).should == @expected_attributes[attr_name]
        end
      end
    end
  end
end