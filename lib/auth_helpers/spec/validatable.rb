module AuthHelpers
  module Spec

    module Validatable
      def self.included(base)
        base.class_eval do
          describe 'validation' do
            should_validate_presence_of :email
            should_validate_length_of :email, :within => 0..100, :allow_blank => true
            should_validate_confirmation_of :email

            it {
              base.described_class.create!(@valid_attributes)
              should validate_uniqueness_of(:email, :case_sensitive => false, :allow_blank => true,
                                                    :scope => (defined?(base.described_class::SCOPE) ? base.described_class::SCOPE : []))
            }

            should_not_allow_values_for :email, 'josevalim', 'a@a@a.com', 'jose@com'

            should_validate_presence_of :password
            should_validate_length_of :password, :within => 6..20, :allow_blank => true
            should_validate_confirmation_of :password
          end
        end
      end
    end

  end
end
