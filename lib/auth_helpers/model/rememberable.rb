require File.join(File.dirname(__FILE__), '..', 'notifier')

module AuthHelpers
  module Model

    # Adds remember_me to the model. The token is valid for two weeks, you can
    # can change this by overwriting the token_expiration_interval method.
    #
    module Rememberable
      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          attr_accessor   :remember_me
          attr_accessible :remember_me
          alias :remember_me? :remember_me
        end
      end

      # Call to set and save a remember me token
      #
      def remember_me!
        self.token = AuthHelpers.generate_unique_string_for(self.class, :token, 40)
        self.token_expires_at = token_expiration_interval
        self.save(false)
      end

      # Call to forget and save the token
      #
      def forget_me!
        self.token = nil
        self.token_expires_at = nil
        self.save(false)
      end

      # Returns a hash to be store in session
      #
      def remember_me_cookie_hash
        { :value => self.token, :expires => self.token_expires_at }
      end

      # Change if you want to set another token_expiration_interval or add
      # custom logic (admin has one day token, clients have 2 weeks).
      #
      def token_expiration_interval
        2.weeks.from_now
      end

      module ClassMethods
        # Find the user with the given token only if it has not expired at.
        #
        def find_by_remember_me_token(token)
          self.find(:first, :conditions => [ "token = ? AND token_expires_at > CURRENT_TIMESTAMP", token ])
        end

        # Overwrites find and authenticate to deal with the remember me key.
        #
        def find_and_authenticate(options={})
          rememberable, remember_me = options.key?(:remember_me), options.delete(:remember_me)
          authenticable = super(options)

          if rememberable && authenticable.errors.empty?
            remember_me == '1' ? authenticable.remember_me! : authenticable.forget_me!
          end

          authenticable
        end
      end

    end
  end
end
