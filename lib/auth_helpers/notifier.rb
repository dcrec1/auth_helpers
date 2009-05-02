module AuthHelpers
  # The class responsable to send e-mails.
  #
  # It uses default views in the auth_helpers/views. If you want to customize
  # them, just do:
  #
  #   AuthHelpers::Notifier.template_root = "#{RAILS_ROOT}/app/views"
  #
  # And put your new views at: "RAILS_ROOT/app/views/auth_helpers/notifier/"
  #
  # You should also configure the sender and content_type:
  #
  #   AuthHelpers::Notifier.sender = %("José Valim" <jose.valim@gmail.com>)
  #   AuthHelpers::Notifier.content_type = 'text/html'
  #
  class Notifier < ActionMailer::Base
    class << self; attr_accessor :sender, :content_type end

    def create_confirmation(record)
      @subject = I18n.t 'actionmailer.auth_helpers.create_confirmation', :default => 'Create confirmation'
      set_ivars!(record)
    end

    def update_confirmation(record)
      @subject = I18n.t 'actionmailer.auth_helpers.update_confirmation', :default => 'Update e-mail confirmation'
      set_ivars!(record)
    end

    def reset_password(record)
      @subject = I18n.t 'actionmailer.auth_helpers.reset_password', :default => 'Reset password'
      set_ivars!(record)
    end

    def resend_confirmation(record)
      @subject = I18n.t 'actionmailer.auth_helpers.resend_confirmation', :default => 'Confirmation code'
      set_ivars!(record)
    end

    protected

      def set_ivars!(record)
        @from          = self.class.sender
        @content_type  = self.class.content_type
        @recipients    = record.email
        @sent_on       = Time.now.utc
        @headers       = {}
        @body[:record] = record
        @body[record.class.name.downcase] = record
      end

  end
end

AuthHelpers::Notifier.content_type  ||= 'text/html'
AuthHelpers::Notifier.template_root ||= File.join(File.dirname(__FILE__), '..', '..', 'views')
