require 'ostruct'

module AuthHelpers
  module Spec
    module Notifier
      def self.included(base)
        base.class_eval do
          before(:each) do
            @record = OpenStruct.new(:email            => 'recipient@email.com',
                                     :perishable_token => '0123456789')
          end

          it "should deliver new account notification" do
            email = ::AuthHelpers::Notifier.create_create_confirmation(@record)
            email.to.should == [ 'recipient@email.com' ]
            email.body.should match(/#{@record.perishable_token}/)
          end

          it "should deliver email changed notification" do
            email = ::AuthHelpers::Notifier.create_update_confirmation(@record)
            email.to.should == [ 'recipient@email.com' ]
            email.body.should match(/#{@record.perishable_token}/)
          end

          it "should deliver reset password code" do
            email = ::AuthHelpers::Notifier.create_reset_password(@record)
            email.to.should == [ 'recipient@email.com' ]
            email.body.should match(/#{@record.perishable_token}/)
          end

          it "should resend confirmation code" do
            email = ::AuthHelpers::Notifier.create_resend_confirmation(@record)
            email.to.should == [ 'recipient@email.com' ]
            email.body.should match(/#{@record.perishable_token}/)
          end
        end
      end
    end
  end
end


