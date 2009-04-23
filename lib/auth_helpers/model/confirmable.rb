require File.join(File.dirname(__FILE__), '..', 'notifier')

module AuthHelpers
  module Model

    # Adds a module that deals with confirmations.
    #
    module Confirmable
      def self.included(base)
        base.extend ClassMethods
        base.send :before_create, :set_confirmation_code
        base.send :after_create,  :send_new_account_notification
      end

      # Returns true if is not a new record and the confirmation code is blank.
      #
      def confirmed?
        !self.new_record? && self.confirmation_code.blank?
      end

      # Confirms an account by setting :confirmation_code to nil and setting the
      # confirmed_at field.
      #
      def confirm!
        self.confirmation_code = nil
        self.confirmed_at = Time.now.utc
        return self.save(false)
      end

      protected

        # Generates a confirmation_code and sets confirmation_sent_at.
        # Does not save the object because it's used as a filter.
        #
        def set_confirmation_code
          self.confirmation_code    = AuthHelpers.generate_unique_string_for(self.class, :confirmation_code, 40)
          self.confirmation_sent_at = Time.now.utc
          return true
        end

        # Send a notification to new account. Used as filter.
        #
        def send_new_account_notification
          AuthHelpers::Notifier.deliver_new_account(self)
        end

      module ClassMethods

        # Receives a confirmation code, find the respective account and tries to set its confirmation code to nil.
        # If something goes wrong, return an account object with errors.
        #
        def find_and_confirm(sent_confirmation_code)
          confirmable = AuthHelpers.find_or_initialize_by_unless_blank(self, :confirmation_code, sent_confirmation_code)

          if confirmable.new_record?
            confirmable.errors.add :confirmation_code, :invalid
          else
            confirmable.confirm!
          end

          return confirmable
        end

        # Receives a hash with email and tries to find the account to resend the confirmation code.
        # If the e-mail can't be found or the account is already confirmed, return an account object
        # with errors.
        #
        def find_and_resend_confirmation_code(options = {})
          confirmable = AuthHelpers.find_or_initialize_by_unless_blank(self, :email, options[:email])

          if confirmable.new_record?
            confirmable.errors.add :email, :not_found
          elsif confirmable.confirmed?
            confirmable.errors.add :email, :already_confirmed
          else
            AuthHelpers::Notifier.deliver_confirmation_code(confirmable)
          end

          return confirmable
        end
      end

    end
  end
end
