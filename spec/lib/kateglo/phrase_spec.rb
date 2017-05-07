require 'spec_helper'

describe Kateglo::Phrase do
  describe '#initialize' do
    it 'should initialize from valid json string' do
      expect(Kateglo::Phrase.new(parsed_fixture_file('kateglo_phrase_valid'))).to be_kind_of(Kateglo::Phrase)
    end

    it 'should raise MultiJson::LoadError when initializing from invalid json string' do
      expect {
        Kateglo::Phrase.new(parsed_fixture_file('kateglo_phrase_invalid'))
      }.to raise_error(MultiJson::LoadError)
    end

    describe 'assigning attribute with values' do
      parsed_response = parsed_fixture_file('kateglo_phrase_valid')
      before do
        @expected_attributes = parsed_response
        @kata = Kateglo::Phrase.new(parsed_response)
      end

      array_attributes = {}
      parsed_response.keys.each do |attr_name|
        if parsed_response[attr_name].is_a?(Array)
          array_attributes[attr_name] = parsed_response[attr_name]
          next
        end
        it "should assign ##{attr_name} correctly" do
          expect(@kata.send(attr_name)).to eq(@expected_attributes[attr_name])
        end
      end

      array_attributes.each do |attr_name, array|
        it "##{attr_name} should transform to the array of Kateglo::Word" do
          @kata.send(attr_name).all? do |entry|
            expect(entry.is_a?(Kateglo::Word)).to be true
          end
        end

        it "should respond_to #has_#{attr_name}?" do
          method_name = "has_#{attr_name}?"
          expect(@kata).to respond_to(method_name)
          expect(@kata.send(method_name)).to eq(@expected_attributes[attr_name].any?)
        end
      end

      describe 'assigning relation methods' do
        %w( sinonim antonim berkaitan turunan gabungan_kata peribahasa).each do |attr_name|
          has_method_name = "has_#{attr_name}?"

          it "should respond to ##{attr_name} & ##{has_method_name}" do
            expect(@kata).to respond_to(attr_name)
            expect(@kata).to respond_to(has_method_name)
          end
        end
      end
    end
  end
end
