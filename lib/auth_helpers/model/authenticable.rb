require 'digest/sha1'
require File.join(File.dirname(__FILE__), '..', 'notifier')

module AuthHelpers
  module Model

    # Adds methods that helps you to authenticate an user. It requires that you set
    # a constant called SALT in your model.
    #
    module Authenticable
      def self.included(base)
        base.send :attr_accessor, :email_confirmation, :password_confirmation
        base.send :attr_accessible, :email, :email_confirmation, :password, :password_confirmation
        base.extend ClassMethods
      end

      # Overwrite update attributes to deal with email, password and confirmations.
      #
      def update_attributes(options)
        # Reject email if it didn't change or is blank
        options.delete(:email)              if options[:email].blank? || options[:email] == self.email
        options.delete(:email_confirmation) if options[:email_confirmation].blank?

        # Reject password if it didn't change or is blank
        options.delete(:password)              if options[:password].blank? || self.authenticate?(options[:password])
        options.delete(:password_confirmation) if options[:password_confirmation].blank?

        # Force confirmations (if confirmation is nil, it won't validate, it has to be at least blank)
        options[:email_confirmation]    ||= '' if options[:email]
        options[:password_confirmation] ||= '' if options[:password]

        if super(options)
          # Generate a new confirmation code, save and send it. 
          if options[:email] && respond_to?(:set_confirmation_code)
            self.set_confirmation_code
            self.save(false)

            AuthHelpers::Notifier.deliver_email_changed(self)
          end

          return true
        end

        return false
      end

      # Authenticate the account by encrypting the password sent and comparing with the hashed password.
      #
      def authenticate?(auth_password)
        self.hashed_password.not_blank? && self.class.send(:encrypt, auth_password, self.salt) == self.hashed_password
      end

      # Get the password
      #
      def password
        @password
      end

      # Sets the password for this account by creating a salt and encrypting the password sent.
      #
      def password=(new_password)
        @password = new_password

        self.salt            = AuthHelpers.random_string(10)
        self.hashed_password = self.class.send(:encrypt, @password, self.salt)
      end

      module ClassMethods

        # Finds and authenticate an record, setting error messages in case the object
        # can't be authenticated.
        #
        #   Account.find_and_authenticate(:email => 'my@email.com', :password => '123456')
        #
        def find_and_authenticate(options={})
          authenticable = AuthHelpers.find_or_initialize_by_unless_blank(self, :email, options[:email])

          unless authenticable.authenticate?(options[:password])
            if options[:email].blank?
              authenticable.errors.add :email, :blank
            elsif options[:password].blank?
              authenticable.errors.add :password, :blank
            elsif authenticable.new_record?
              authenticable.errors.add :email, :not_found, :email => options[:email]
            else
              authenticable.errors.add :password, :invalid, :email => options[:email]
            end
          end

          return authenticable
        end

        protected

          # Encrypts a string using a fixed salt and a variable salt.
          #
          def encrypt(password, salt)
            return nil if password.blank? || salt.blank?
            Digest::SHA1.hexdigest(password + self::SALT + salt)
          end
      end
    end

  end
end
