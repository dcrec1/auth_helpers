module AuthHelpers
  module Spec

    module Rememberable
      def self.included(base)
        base.class_eval do
          describe 'when authenticating' do
            before(:each){ @rememberable = base.described_class.create!(@valid_attributes) }

            it 'should set the remember me token' do
              @rememberable.remember_me!
              @rememberable.token.should_not be_nil
            end

            it 'should set the remember me token creation date' do
              @rememberable.remember_me!
              @rememberable.token_expires_at.should_not be_nil
            end

            it 'should return a remember_me cookie hash' do
              @rememberable.remember_me!
              @rememberable.remember_me_cookie_hash[:value].should == @rememberable.token
              @rememberable.remember_me_cookie_hash[:expires].should == @rememberable.token_expires_at
            end

            it 'should forget the remember me token' do
              @rememberable.remember_me!
              @rememberable.forget_me!
              @rememberable.token.should be_nil
            end

            it 'should forget the remember me token creation date' do
              @rememberable.remember_me!
              @rememberable.forget_me!
              @rememberable.token_expires_at.should be_nil
            end

            if base.described_class.ancestors.include?(::AuthHelpers::Model::Authenticable)
              it 'should find, authenticate and set token if remember me is true' do
                base.described_class.find_and_authenticate(:email => @valid_attributes[:email], :password => @valid_attributes[:password], :remember_me => "1")
                @rememberable.reload
                @rememberable.token.should_not be_nil
              end

              it 'should find, authenticate and clear token if remember me is false' do
                @rememberable.remember_me!
                base.described_class.find_and_authenticate(:email => @valid_attributes[:email], :password => @valid_attributes[:password], :remember_me => "0")
                @rememberable.reload
                @rememberable.token.should be_nil
              end

              it 'should not set or clear token if remember me is not set' do
                @rememberable.remember_me!
                base.described_class.find_and_authenticate(:email => @valid_attributes[:email], :password => @valid_attributes[:password])
                @rememberable.reload
                @rememberable.token.should_not be_nil
              end

              it 'should not set or clear token if user cannot authenticate' do
                base.described_class.find_and_authenticate(:email => @valid_attributes[:email], :password => @valid_attributes[:password].to_s.next, :remember_me => "1")
                @rememberable.reload
                @rememberable.token.should be_nil
              end
            end

            it 'should be found by remember me token' do
              @rememberable.remember_me!
              base.described_class.find_by_remember_me_token(@rememberable.token).should_not be_nil
              base.described_class.find_by_remember_me_token(@rememberable.token.next).should be_nil
            end

            it 'should not be found if remember me token is expired' do
              @rememberable.remember_me!
              @rememberable.update_attribute(:token_expires_at, 1.day.ago)
              base.described_class.find_by_remember_me_token(@rememberable.token).should be_nil
            end
          end
        end
      end
    end

  end
end
