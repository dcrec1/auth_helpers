module AuthHelpers
  module Model

    # Include validations.
    #
    # If you want to scope the validate uniqueness of, you have to set a constant
    # SCOPE in your class.
    #
    #   class Account < ActiveRecord::Base
    #     SALT  = 'my_project_salt'
    #     SCOPE = [ :company_id ]
    #
    #     include AuthHelpers::Models::Authenticable
    #     include AuthHelpers::Models::Validatable
    #   end
    #
    # Another hook provided is the password_required? method. It always returns
    # true, but you can overwrite it to add custom logic.
    #
    module Validatable
      EMAIL_REGEXP = /^([^@"'><&\s\,\;]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i

      def self.included(base)
        base.class_eval do
          validates_presence_of     :email
          validates_length_of       :email, :maximum => 100,          :allow_blank => true
          validates_format_of       :email, :with => EMAIL_REGEXP,    :allow_blank => true
          validates_uniqueness_of   :email, :case_sensitive => false, :allow_blank => true,
                                            :scope => (defined?(base::SCOPE) ? base::SCOPE : [])
          validates_confirmation_of :email

          validates_presence_of     :password, :if => :password_required?
          validates_length_of       :password, :within => 6..20, :allow_blank => true
          validates_confirmation_of :password

          # Overwrite if password is not required or implement custom logic
          def password_required?; true; end
        end
      end
    end

  end
end
