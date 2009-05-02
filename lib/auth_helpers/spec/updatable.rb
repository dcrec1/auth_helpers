module AuthHelpers
  module Spec

    module Updatable
      def self.included(base)
        base.class_eval do
          describe "on update" do
            before(:each) do
              @authenticable = base.described_class.create!(@valid_attributes)
              ActionMailer::Base.deliveries = []
            end

            it "should ignore e-mail confirmation if e-mail has not changed" do
              attributes = { :email => @authenticable.email, :email_confirmation => '' }
              @authenticable.update_attributes(attributes).should be_true
            end

            it "should ignore password confirmation if password has not changed" do
              attributes = { :password => @valid_attributes[:password], :password_confirmation => '' }
              @authenticable.update_attributes(attributes).should be_true
            end

            if base.described_class.new.respond_to?(:set_confirmation_code, true)
              it "should send an e-mail if e-mail changes" do
                attributes = { :email => @valid_attributes[:email].to_s.next, :email_confirmation => @valid_attributes[:email].to_s.next }
                @authenticable.update_attributes(attributes).should be_true
                @authenticable.email.should == @valid_attributes[:email].to_s.next
                ActionMailer::Base.deliveries.length.should == 1
              end
            end
          end
        end
      end
    end

  end
end
