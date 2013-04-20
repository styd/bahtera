module Bahtera
  class Kata
    def initialize(hash)
      @hash_response = hash['kateglo']
      assign_attribute_names
    end


    private
      def assign_attribute_names
        attributes = @hash_response.keys
        self.class.class_eval { attr_reader *attributes }
        attributes.each do |attr_name|
          if @hash_response[attr_name]
            instance_variable_set("@#{attr_name}",
                                    @hash_response[attr_name])
          end
        end
      end
  end
end