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

            it "should send a reset password code to the user" do
              record = base.described_class.find_and_send_reset_password_code(:email => @recoverable.email)
              record.errors.should be_empty
              record.reset_password_code.should_not be_blank
              ActionMailer::Base.deliveries.length.should == 1
            end

            describe 'and reset password code is sent' do
              before(:each) do
                base.described_class.find_and_send_reset_password_code(:email => @recoverable.email)
                @recoverable.reload
              end

              it "should reset password if reset password code is valid" do
                record = base.described_class.find_and_reset_password(:reset_password_code => @recoverable.reset_password_code, :password => '654321', :password_confirmation => '654321')
                record.errors.should be_empty

                record = base.described_class.find_and_authenticate(:email => @recoverable.email, :password => '654321')
                record.errors.should be_empty
              end

              it "should not reset password if the given reset password code is invalid" do
                record = base.described_class.find_and_reset_password(:reset_password_code => 'invalid_pass_code', :password => '654321', :password_confirmation => '654321')
                record.errors.on(:reset_password_code).should == record.errors.generate_message(:reset_password_code, :invalid)
                record = base.described_class.find_and_authenticate(:email => @recoverable.email, :password => '654321')
                record.errors.should_not be_empty
              end

              it "should not reset password if password doesn't match confirmation" do
                record = base.described_class.find_and_reset_password(:reset_password_code => @recoverable.reset_password_code, :password => '654321', :password_confirmation => '123456')
                record.errors.on(:password).should == record.errors.generate_message(:password, :confirmation)

                record = base.described_class.find_and_authenticate(:email => @recoverable.email, :password => '654321')
                record.errors.should_not be_empty
              end

              it "should clean reset_password_code when password is successfully reset" do
                base.described_class.find_and_reset_password(:reset_password_code => @recoverable.reset_password_code, :password => '654321', :password_confirmation => '654321')
                @recoverable.reload
                @recoverable.reset_password_code.should be_nil
              end
            end
          end
        end
      end
    end

  end
end
