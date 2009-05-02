module AuthHelpers
  module Spec

    module Confirmable
      def self.included(base)
        base.class_eval do
          describe 'confirmation' do
            before(:each) do
              ActionMailer::Base.deliveries = []
              @confirmable = base.described_class.create!(@valid_attributes)
            end

            it 'should set the confirmation date on #confirm!' do
              @confirmable.confirmed_at.should be_nil
              @confirmable.confirm!
              @confirmable.confirmed_at.should_not be_nil
            end

            it "should say when a record is confirmed or not" do
              base.described_class.new.confirmed?.should be_false
              @confirmable.confirmed?.should be_false

              @confirmable.confirm!
              @confirmable.confirmed?.should be_true
            end

            describe 'on create' do
              it "should set confirmed_at to nil" do
                @confirmable.confirmed_at.should be_nil
              end

              it "should set confirmation_sent_at" do
                @confirmable.confirmation_sent_at.should_not be_blank
              end

              it "should send create confirmation notification" do
                ActionMailer::Base.deliveries.length.should == 1
              end
            end

            describe 'with a valid perishable token' do
              it "should confirm his account" do
                record = base.described_class.find_and_confirm(:perishable_token => @confirmable.perishable_token)
                record.errors.should be_empty
              end

              it "should set confirmation date" do
                record = base.described_class.find_and_confirm(:perishable_token => @confirmable.perishable_token)
                @confirmable.reload
                @confirmable.confirmed_at.should_not be_nil
              end
            end

            describe 'with an invalid perishable token' do
              it "should set an error message" do
                record = base.described_class.find_and_confirm(:perishable_token => "invalid token")
                record.errors.on(:perishable_token).should == record.errors.generate_message(:perishable_token, :invalid_confirmation, :default => :invalid)
              end

              it "should return a new record with the perishable token set" do
                record = base.described_class.find_and_confirm(:perishable_token => "invalid token")
                record.should be_new_record
                record.perishable_token.should == "invalid token"
              end
            end

            describe 'when lost confirmation code' do
              before(:each){ ActionMailer::Base.deliveries = [] }

              it "should resend confirmation instructions if account is not confirmed" do
                record = base.described_class.find_and_resend_confirmation_instructions(:email => @confirmable.email)
                record.errors.should be_empty
                ActionMailer::Base.deliveries.length.should == 1
              end

              it "should not resend confirmation instructions if account is confirmed" do
                @confirmable.confirm!
                record = base.described_class.find_and_resend_confirmation_instructions(:email => @confirmable.email)
                record.errors.on(:email).should == record.errors.generate_message(:email, :already_confirmed)
                ActionMailer::Base.deliveries.length.should == 0
              end

              it "should show a error message on resend confirmation instructions if e-mail is not valid" do
                record = base.described_class.find_and_resend_confirmation_instructions(:email => 'invalid')
                record.errors.on(:email).should == record.errors.generate_message(:email, :not_found)
                ActionMailer::Base.deliveries.length.should == 0
              end
            end
          end
        end
      end
    end

  end
end
