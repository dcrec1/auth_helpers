require File.join(File.dirname(__FILE__), '..', 'notifier')

module AuthHelpers
  module Model

    # Adds a module that deals with confirmations.
    #
    module Confirmable
      def self.included(base)
        base.extend ClassMethods
        base.send :after_create, :send_confirmation_instructions
      end

      # Returns true if is not a new record and confirmed_at is not blank.
      #
      def confirmed?
        !(self.new_record? || self.confirmed_at.nil?)
      end

      # Confirms the record by setting the confirmed at.
      #
      def confirm!
        update_attribute(:confirmed_at, Time.now.utc)
      end

      # Send confirmation isntructions in different scenarios. It resets the
      # perishable token, confirmed_at date and set the confirmation_sent_at
      # datetime.
      #
      def send_confirmation_instructions(on=:create)
        self.reset_perishable_token
        self.confirmed_at = nil
        self.confirmation_sent_at = Time.now.utc
        self.save(false)
        AuthHelpers::Notifier.send(:"deliver_#{on}_confirmation", self)
      end

      module ClassMethods

        # Receives the perishable token and try to find a record to confirm the
        # account. If it can't find the record, returns a new record with an
        # error set on the perishable token.
        #
        def find_and_confirm(options={})
          if confirmable = self.find_using_perishable_token(options[:perishable_token])
            confirmable.confirm!
            confirmable
          else
            AuthHelpers.new_with_perishable_token_error(self, :invalid_confirmation, options)
          end
        end

        # Receives a hash with email and tries to find a record to resend the
        # confirmation instructions. If the record can't be found or it's already
        # confirmed, set the appropriate error messages and return the object.
        #
        def find_and_resend_confirmation_instructions(options = {})
          confirmable = AuthHelpers.find_or_initialize_by_unless_blank(self, :email, options[:email])

          if confirmable.new_record?
            confirmable.errors.add(:email, :not_found)
          elsif confirmable.confirmed?
            confirmable.errors.add(:email, :already_confirmed)
          else
            confirmable.send_confirmation_instructions(:resend)
          end

          return confirmable
        end

      end

    end
  end
end
