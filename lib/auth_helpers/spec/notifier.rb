require 'ostruct'

module AuthHelpers
  module Spec
    module Notifier
      def self.included(base)
        base.class_eval do
          before(:each) do
            @member = OpenStruct.new(:email               => 'recipient@email.com',
                                     :confirmation_code   => '0123456789',
                                     :reset_password_code => 'abcdefghij')
          end

          it "should deliver new account notification" do
            email = ::AuthHelpers::Notifier.create_new_account(@member)
            email.to.should == [ 'recipient@email.com' ]
            email.body.should match(/#{@member.confirmation_code}/)
          end

          it "should deliver email changed notification" do
            email = ::AuthHelpers::Notifier.create_email_changed(@member)
            email.to.should == [ 'recipient@email.com' ]
            email.body.should match(/#{@member.confirmation_code}/)
          end

          it "should deliver reset password code" do
            email = ::AuthHelpers::Notifier.create_reset_password(@member)
            email.to.should == [ 'recipient@email.com' ]
            email.body.should match(/#{@member.reset_password_code}/)
          end

          it "should resend confirmation code" do
            email = ::AuthHelpers::Notifier.create_confirmation_code(@member)
            email.to.should == [ 'recipient@email.com' ]
            email.body.should match(/#{@member.confirmation_code}/)
          end
        end
      end
    end
  end
end


