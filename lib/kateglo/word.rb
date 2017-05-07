module Kateglo
  class Word
    def initialize(hash)
      assign_attribute_names hash
    end

    private
      def assign_attribute_names(hash_response)
        attributes = hash_response.keys
        self.class.class_eval { attr_reader *attributes }
        attributes.each do |attr_name|
          attribute_value = hash_response[attr_name]
          if attribute_value
            if attribute_value.is_a?(Array)
              assign_array_attributes(attr_name, attribute_value)
            else
              instance_variable_set("@#{attr_name}", attribute_value)
            end
          end
        end
      end

      def assign_array_attributes(attr_name, hash_array)
        value = hash_array.map { |hash_attr| Word.new(hash_attr) }
        instance_variable_set("@#{attr_name}", value)
        self.class.send :define_method, "has_#{attr_name}?" do
          send(attr_name).any?
        end
      end
  end
end
