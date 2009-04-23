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

            it { should_not allow_mass_assignment_of(:confirmation_code) }

            it 'should remove confirmation code' do
              @confirmable.confirm!
              @confirmable.confirmation_code.should be_nil
            end

            it 'should set the date account was confirmed' do
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
              it "should set confirmation_code" do
                @confirmable.confirmation_code.length.should == 40
              end

              it "should set confirmation_sent_at" do
                @confirmable.confirmation_sent_at.should_not be_blank
              end

              it "should send a new account notification" do
                ActionMailer::Base.deliveries.length.should == 1
              end
            end

            describe 'with a valid confirmation code' do
              it "should confirm his account" do
                record = base.described_class.find_and_confirm(@confirmable.confirmation_code)
                record.errors.should be_empty
              end

              it "should clean confirmation code" do
                base.described_class.find_and_confirm(@confirmable.confirmation_code)
                @confirmable.reload
                @confirmable.confirmation_code.should be_nil
              end

              it "should set confirmed_at date" do
                record = base.described_class.find_and_confirm(@confirmable.confirmation_code)
                record.confirmed_at.should_not be_nil
              end
            end

            describe 'with an invalid confirmation code' do
              it "should set an error message" do
                record = base.described_class.find_and_confirm('invalid_code')
                record.errors.on(:confirmation_code).should == record.errors.generate_message(:confirmation_code, :invalid)
              end
            end

            describe 'when lost confirmation code' do
              before(:each){ ActionMailer::Base.deliveries = [] }

              it "should resend confirmation code if account is not confirmed" do
                record = base.described_class.find_and_resend_confirmation_code(:email => @confirmable.email)
                record.errors.should be_empty
                ActionMailer::Base.deliveries.length.should == 1
              end

              it "should not resend confirmation code if account is confirmed" do
                @confirmable.confirm!
                record = base.described_class.find_and_resend_confirmation_code(:email => @confirmable.email)
                record.errors.on(:email).should == record.errors.generate_message(:email, :already_confirmed)
                ActionMailer::Base.deliveries.length.should == 0
              end

              it "should show a error message on resend confirmation code if e-mail is not valid" do
                record = base.described_class.find_and_resend_confirmation_code(:email => 'invalid')
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
