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

    self.content_type  = 'text/html'
    self.template_root = File.join(File.dirname(__FILE__), '..', '..', 'views')

    def new_account(record)
      @subject = I18n.t 'actionmailer.auth_helpers.new_account', :default => 'New account'
      set_ivars!(:confirmable, record)
    end

    def email_changed(record)
      @subject = I18n.t 'actionmailer.auth_helpers.email_changed', :default => 'You changed your e-mail'
      set_ivars!(:confirmable, record)
    end

    def reset_password(record)
      @subject = I18n.t 'actionmailer.auth_helpers.reset_password', :default => 'Reset password'
      set_ivars!(:recoverable, record)
    end

    def confirmation_code(record)
      @subject = I18n.t 'actionmailer.auth_helpers.confirmation_code', :default => 'Confirmation code'
      set_ivars!(:confirmable, record)
    end

    protected

      def set_ivars!(assign, record)
        @from         = self.class.sender
        @content_type = self.class.content_type
        @body[assign] = record
        @recipients   = record.email
        @sent_on      = Time.now.utc
        @headers      = {}
      end

  end
end
