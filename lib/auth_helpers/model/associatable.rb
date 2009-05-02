module AuthHelpers
  module Model

    # Checks for a column that ends with _id in the included model. Then it adds
    # a belongs_to association, accepts_nested_attributes_for and make the nested
    # attributes accessible.
    #
    # Also includes a hook called remove_association_error, that removes the nested
    # attribute errors from the parent object.
    #
    # Finally, if the *_id in the table has also *_type. It considers a polymorphic
    # association.
    #
    # Whenever using this method with polymorphic association, don't forget to
    # set the validation scope in AuthLogic.
    #
    #   a.validations_scope = :accountable_type
    #
    module Associatable
      def self.included(base)
        column = base.columns.detect{|c| c.name =~ /_id$/ }
        raise ScriptError, "Could not find a column that ends with id in #{base.name.tableize}" unless column

        association = column.name.gsub(/_id$/, '').to_sym
        polymorphic = !!base.columns.detect{ |c| c.name == "#{association}_type" }

        base.class_eval do
          belongs_to association, :validate => true, :dependent => :destroy,
                                  :autosave => true, :polymorphic => polymorphic

          accepts_nested_attributes_for association
          attr_accessible :"#{association}_attributes"

          after_validation :remove_association_error
        end

        base.class_eval <<-ASSOCIATION
          # Remove association errors from the message
          #
          def remove_association_error
            self.errors.each do |key, value|
              next unless key.to_s =~ /^#{association}_/
              self.errors.instance_variable_get('@errors').delete(key)
            end
          end
          protected :remove_association_error
        ASSOCIATION
      end
    end

  end
end
