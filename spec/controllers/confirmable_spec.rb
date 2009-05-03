require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class Accountable::ConfirmationsController < AuthHelpers::Controller::Confirmable
  layout nil
end

describe Accountable::ConfirmationsController do
  mock_models :accountable

  describe :get => :new do
    expects :new, :on => Accountable, :returns => mock_accountable
    should_assign_to :accountable, :with => mock_accountable
  end

  describe :post => :create, :accountable => {'these' => 'params'} do
    expects :find_and_resend_confirmation_instructions, :on => Accountable, :with => {'these' => 'params'}, :returns => mock_accountable

    describe "with valid params" do
      expects :errors, :on => mock_accountable, :returns => []

      should_assign_to :accountable, :with => mock_accountable
      should_redirect_to { new_accountable_session_url }
      should_set_the_flash :notice, :to => "We sent confirmation instructions to your email, please check your inbox."
    end

    describe "with invalid params" do
      expects :errors, :on => mock_accountable, :returns => ['invalid']

      should_assign_to :accountable, :with => mock_accountable
      should_render_template 'new'
    end
  end

  describe :get => :show, :accountable => {'these' => 'params'} do
    expects :find_and_confirm, :on => Accountable, :with => {'these' => 'params'}, :returns => mock_accountable

    describe "with valid params" do
      expects :errors, :on => mock_accountable, :returns => []

      should_redirect_to proc { new_accountable_session_url }, :with_expectations => true
      should_set_the_flash :notice, :to => /accountable was successfully confirmed/im
    end

    describe "with invalid params" do
      before(:each) do
        mock_accountable.stub!(:errors).and_return(mock_error = mock("error"))
        mock_error.stub!(:empty?).and_return(false)
        mock_error.stub!(:on).with(:perishable_token).and_return("is invalid")
      end

      should_redirect_to "/accountable/confirmations/new"
      should_set_the_flash :error, :to => "is invalid"
    end
  end

end
