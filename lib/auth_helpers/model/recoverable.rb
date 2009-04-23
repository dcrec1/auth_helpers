require File.join(File.dirname(__FILE__), '..', 'notifier')

module AuthHelpers
  module Model

    # Adds a module that deals with forgot your password.
    #
    module Recoverable
      def self.included(base)
        base.send(:attr_accessible, :reset_password_code)
        base.extend ClassMethods
      end

      # Reset the password with the new_password is equals its confirmation and
      # set reset password code to nil.
      # 
      def reset_password!(new_password, new_password_confirmation)
        self.password              = new_password
        self.password_confirmation = new_password_confirmation

        if self.valid?
          self.reset_password_code = nil
          return self.save
        end

        false
      end

      # Set a reset password code in the database and send it through e-mail
      #
      def send_reset_password_code
        new_code = AuthHelpers.generate_unique_string_for(self.class, :reset_password_code, 40)
        self.update_attribute(:reset_password_code, new_code)

        AuthHelpers::Notifier.deliver_reset_password(self)
        return true
      end

      module ClassMethods

        # Receives a hash with reset_password_code, password and password confirmation.
        # Tries to find the account with the sent password code, and then, if password and password
        # confirmation matches, changes the password. Otherwise return an account object with errors.
        #
        def find_and_reset_password(options={})
          recoverable = AuthHelpers.find_or_initialize_by_unless_blank(self, :reset_password_code, options[:reset_password_code])

          if recoverable.new_record?
            recoverable.errors.add :reset_password_code, :invalid
          else
            recoverable.reset_password!(options[:password], options[:password_confirmation])
          end

          return recoverable
        end

        # Receives a hash with email and tries to find the account to send a new reset password code.
        # If the e-mail can't be found return an account object with errors.
        #
        def find_and_send_reset_password_code(options={})
          recoverable = AuthHelpers.find_or_initialize_by_unless_blank(self, :email, options[:email])

          if recoverable.new_record?
            recoverable.errors.add :email, :not_found, options
          else
            recoverable.send_reset_password_code
          end

          return recoverable
        end
      end
    end
  end
end
