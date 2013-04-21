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

      array_attributes = {}
      parsed_response['kateglo'].keys.each do |attr_name|
        if parsed_response['kateglo'][attr_name].is_a?(Array)
          array_attributes[attr_name] = parsed_response['kateglo'][attr_name]
          next
        end
        it "should assign ##{attr_name} correctly" do
          @kata.send(attr_name).should == @expected_attributes[attr_name]
        end
      end

      array_attributes.each do |attr_name, array|
        it "##{attr_name} should transform to the array of Bahtera::BaseKata" do
          @kata.send(attr_name).all? do |entry|
            entry.is_a?(Bahtera::BaseKata)
          end.should be_true
        end

        it "should respond_to #has_#{attr_name}?" do
          method_name = "has_#{attr_name}?"
          @kata.should respond_to(method_name)
          @kata.send(method_name).should == @expected_attributes[attr_name].any?
        end
      end

      describe 'assigning relation methods' do
        %w( sinonim antonim berkaitan turunan gabungan_kata peribahasa).each do |attr_name|
          has_method_name = "has_#{attr_name}?"

          it "should respond to ##{attr_name} & ##{has_method_name}" do
            @kata.should respond_to(attr_name)
            @kata.should respond_to(has_method_name)
          end
        end
      end
    end
  end
end