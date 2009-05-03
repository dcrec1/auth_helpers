require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# Spec'ed controllers
class AccountablePasswordsController < AuthHelpers::Controller::Recoverable
  layout nil
end

describe AccountablePasswordsController do
  mock_models :accountable

  describe :get => :new do
    expects :new, :on => Accountable, :returns => mock_accountable
    should_assign_to :accountable, :with => mock_accountable
  end

  describe :get => :edit, :accountable => { :perishable_token => '12345' } do
    expects :new, :on => Accountable, :returns => mock_accountable
    expects :perishable_token=, :on => mock_accountable, :with => '12345'

    should_assign_to :accountable, :with => mock_accountable
  end

  describe :post => :create, :accountable => {'these' => 'params'} do
    expects :find_and_send_reset_password_instructions, :on => Accountable,
            :with => {'these' => 'params'}, :returns => mock_accountable

    describe "with valid params" do
      expects :errors, :on => mock_accountable, :returns => []

      should_assign_to :accountable, :with => mock_accountable
      should_set_the_flash :notice, :to => "We sent instruction to reset your password, please check your inbox."
    end

    describe "with invalid params" do
      expects :errors, :on => mock_accountable, :returns => ['invalid']

      should_assign_to :accountable, :with => mock_accountable
      should_render_template 'new'
    end
  end

  describe :put => :update, :accountable => {'these' => 'params'} do
    expects :find_and_reset_password, :on => Accountable, :with => {'these' => 'params'}, :returns => mock_accountable

    describe "with valid params" do
      expects :errors, :on => mock_accountable, :returns => []

      should_assign_to :accountable, :with => mock_accountable
      should_redirect_to { new_accountable_session_url }
      should_set_the_flash :notice, :to => "Your password was successfully reset."
    end

    describe "with invalid params" do
      expects :errors, :on => mock_accountable, :returns => ['invalid']

      should_assign_to :accountable, :with => mock_accountable
      should_render_template 'edit'
    end
  end
end
