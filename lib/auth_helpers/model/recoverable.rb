require File.join(File.dirname(__FILE__), '..', 'notifier')

module AuthHelpers
  module Model

    # Adds a module that deals with forgot your password. It overwrites the
    # reset password method from authlogic for one that accepts a password. 
    #
    module Recoverable
      def self.included(base)
        base.extend ClassMethods
      end

      def reset_password(new_password, new_password_confirmation)
        self.password              = new_password || ""
        self.password_confirmation = new_password_confirmation || "" if self.respond_to?(:password_confirmation)
      end

      # Reset the password with the new_password is equals its confirmation and
      # set reset password code to nil.
      # 
      def reset_password!(new_password, new_password_confirmation)
        reset_password(new_password, new_password_confirmation)
        self.save
      end

      module ClassMethods

        # Receives a hash with email and tries to find a record to resend reset
        # password instructions. If the record can't be found, it sets the
        # appropriate error messages and return the object.
        #
        def find_and_send_reset_password_instructions(options={})
          recoverable = AuthHelpers.find_or_initialize_by_unless_blank(self, :email, options[:email])

          if recoverable.new_record?
            recoverable.errors.add(:email, :not_found, options)
          else
            recoverable.reset_perishable_token!
            AuthHelpers::Notifier.deliver_reset_password(recoverable)
          end

          return recoverable
        end

        # Receives a hash with perishable_token, password and password confirmation.
        # If the password cannot be reset (confirmation fails, for example), it
        # returns an object with errors.
        #
        def find_and_reset_password(options={})
          if recoverable = self.find_using_perishable_token(options[:perishable_token])
            recoverable.reset_password!(options[:password], options[:password_confirmation])
            recoverable
          else
            AuthHelpers.new_with_perishable_token_error(self, :invalid_reset_password, options)
          end
        end

      end

    end
  end
end
