module AuthHelpers
  module Spec

    module Recoverable
      def self.included(base)
        base.class_eval do
          describe 'when forgot password' do
            before(:each) do
              @recoverable = base.described_class.create!(@valid_attributes)
              ActionMailer::Base.deliveries = []
            end

            it "should send a reset password instructions to the user" do
              record = base.described_class.find_and_send_reset_password_instructions(:email => @recoverable.email)
              record.errors.should be_empty
              ActionMailer::Base.deliveries.length.should == 1
            end

            describe 'and reset password code is sent' do
              before(:each) do
                base.described_class.find_and_send_reset_password_instructions(:email => @recoverable.email)
                @recoverable.reload
              end

              it "should reset password if reset password code is valid" do
                record = base.described_class.find_and_reset_password(:perishable_token => @recoverable.perishable_token, :password => '654321', :password_confirmation => '654321')
                record.errors.should be_empty

                @recoverable.reload
                @recoverable.valid_password?('654321').should be_true
              end

              it "should not reset password if the given reset password code is invalid" do
                record = base.described_class.find_and_reset_password(:perishable_token => 'invalid_token', :password => '654321', :password_confirmation => '654321')
                record.errors.on(:perishable_token).should == record.errors.generate_message(:perishable_token, :invalid_reset_password, :default => [:"messages.invalid"])
                @recoverable.reload
                @recoverable.valid_password?('654321').should be_false
              end

              it "should not reset password if password doesn't match confirmation" do
                record = base.described_class.find_and_reset_password(:perishable_token => @recoverable.perishable_token, :password => '654321', :password_confirmation => '123456')
                record.errors.on(:password).should == record.errors.generate_message(:password, :confirmation)

                @recoverable.reload
                @recoverable.valid_password?('654321').should be_false
              end
            end
          end
        end
      end
    end

  end
end
