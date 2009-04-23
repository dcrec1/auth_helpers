module AuthHelpers
  module Spec

    module Associatable
      def self.included(base)
        klass = base.described_class

        column = klass.columns.detect{|c| c.name =~ /_id$/ }
        raise ScriptError, "Could not find a column that ends with id in #{base.name.tableize}" unless column

        association = column.name.gsub(/_id$/, '').to_sym
        polymorphic = !!klass.columns.detect{ |c| c.name == "#{association}_type" }

        base.class_eval do
          should_belong_to association, :validate => true, :dependent => :destroy,
                                        :autosave => true, :polymorphic => polymorphic

          it "should validate associated #{association}" do
            associatable = base.described_class.create(@valid_attributes.merge(:"#{association}_attributes" => {}))
            associatable.should_not be_valid

            unless associatable.send(association).errors.empty?
              associatable.errors.should be_empty # this should be blank since errors is
                                                  # on the associated object.

              associatable.send(association).errors.should_not be_empty
            end
          end
        end
      end
    end

  end
end
