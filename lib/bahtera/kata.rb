module Bahtera
  class BaseKata
    def initialize(hash)
      assign_attribute_names hash
    end


    private
      def assign_attribute_names(hash_response)
        attributes = hash_response.keys
        self.class.class_eval { attr_reader *attributes }
        attributes.each do |attr_name|
          if hash_response[attr_name]
            instance_variable_set("@#{attr_name}",
                                    hash_response[attr_name])
          end
        end
      end
  end

  class Kata < BaseKata
    def initialize(hash)
      assign_attribute_names hash['kateglo']
    end


    private
      def assign_attribute_names(hash_response)
        super hash_response
        %w( root definition reference proverbs translations all_relation ).each do |attribute_name|
          override_array_hash(attribute_name)
          self.class.send :define_method, "has_#{attribute_name}?" do
            send(attribute_name).any?
          end
        end
        assign_relations if relation.any?
      end

      def assign_relations
        relation_hashes = relation.keys.map do |rel_type|
          relation[rel_type] if relation[rel_type].is_a?(Hash)
        end.compact
        relation_hashes.each do |relation_hash|
          if relation_hash['name']
            method_name = relation_hash.delete('name').downcase.gsub(/\s/, '_')
            self.class.send :define_method, method_name.to_sym do
              relation_hash.values.map do |hash_attr|
                (hash_attr.is_a?(Hash))? BaseKata.new(hash_attr) : hash_attr
              end
            end
            self.class.send :define_method, "has_#{method_name}?" do
              self.send(method_name).any?
            end
          end
        end
      end

      def override_array_hash(attr_name)
        new_value = send(attr_name).map do |hash_attr|
          BaseKata.new(hash_attr)
        end
        instance_variable_set("@#{attr_name}", new_value)
      end
  end
end