require 'spec_helper'

describe Bahtera do
  describe '#lookup' do
    it 'should respond to #lookup' do
      Bahtera.should respond_to(:lookup)
    end

    it 'should send request to the correct address' do
      Kernel.stub(:open).and_return(fixture_file('bahtera_kata_valid'))
      Kernel.should_receive(:open).
              with("http://kateglo.bahtera.org/api.php?format=json&phrase=kata")
      Bahtera.lookup('kata')
    end
  end
end