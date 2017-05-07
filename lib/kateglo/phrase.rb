require 'kateglo/word'

module Kateglo
  class Phrase < Word
    def initialize(hash)
      assign_attribute_names hash
    end

    private
      def assign_attribute_names(hash_response)
        super hash_response
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
                (hash_attr.is_a?(Hash))? Word.new(hash_attr) : hash_attr
              end
            end
            self.class.send :define_method, "has_#{method_name}?" do
              self.send(method_name).any?
            end
          end
        end
      end
  end
end
