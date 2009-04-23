module AuthHelpers
  module Spec

    module Authenticable
      def self.included(base)
        base.class_eval do
          describe 'on authentication' do
            it { should_not allow_mass_assignment_of(:salt, :hashed_password) }

            it "should set a salt and hashed_password when assigning password" do
              salt_value            = '0123456789'
              password_value        = 'abcdef'
              hashed_password_value = 'nice' * 10

              AuthHelpers.should_receive(:random_string).with(10).and_return(salt_value)
              base.described_class.should_receive(:encrypt).with(password_value, salt_value).and_return(hashed_password_value)

              authenticable = base.described_class.new
              authenticable.password = password_value

              authenticable.salt.should            == salt_value
              authenticable.hashed_password.should == hashed_password_value
            end

            it "should authenticate users with valid password" do
              authenticable = base.described_class.new
              authenticable.authenticate?('abcdef').should be_false

              authenticable.password = 'abcdef'
              authenticable.authenticate?(nil).should be_false
              authenticable.authenticate?('notvalid').should be_false
              authenticable.authenticate?('abcdef').should be_true
            end

            it "should find and authenticate an account by email" do
              base.described_class.create!(@valid_attributes)

              authenticable = base.described_class.find_and_authenticate(:email => @valid_attributes[:email], :password => @valid_attributes[:password])
              authenticable.errors.should be_empty

              authenticable = base.described_class.find_and_authenticate(:email => @valid_attributes[:email], :password => @valid_attributes[:password].to_s.reverse)
              authenticable.errors.on(:password).should == authenticable.errors.generate_message(:password, :invalid, @valid_attributes)

              authenticable = base.described_class.find_and_authenticate(:email => @valid_attributes[:email], :password => '')
              authenticable.errors.on(:password).should == authenticable.errors.generate_message(:password, :blank)

              authenticable = base.described_class.find_and_authenticate(:email => 'does.not.exist@email.com', :password => @valid_attributes[:password].to_s.reverse)
              authenticable.new_record?.should be_true
              authenticable.errors.on(:email).should == authenticable.errors.generate_message(:email, :not_found)

              authenticable = base.described_class.find_and_authenticate(:email => '', :password => 'notvalid')
              authenticable.new_record?.should be_true
              authenticable.errors.on(:email).should == authenticable.errors.generate_message(:email, :blank)
            end

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
end
