module AuthHelpers
  module Controller
    class Recoverable < ::ApplicationController
      unloadable

      include ::InheritedResources::BaseHelpers
      include ::AuthHelpers::Controller::Helpers

      class << self
        alias :has_recoverable :set_class_accessors_with_class
      end

      # GET /account/password/new
      def new(&block)
        object = get_or_set_with_send(:new)
        respond_to(:with => object, &block)
      end
      alias :new! :new

      # POST /account/password
      # POST /account/password.xml
      def create(&block)
        object = get_or_set_with_send(:find_and_send_reset_password_instructions, params[self.instance_name])
        respond_block, redirect_block = select_block_by_arity(block)

        if object.errors.empty?
          set_flash_message!(:notice, 'We sent instruction to reset your password, please check your inbox.')

          respond_to_with_dual_blocks(true, block) do |format|
            format.html { redirect_to_block_or_scope_to(redirect_block, :session) }
            format.all  { head :ok }
          end
        else
          set_flash_message!(:error)
          options = { :with => object.errors, :status => :unprocessable_entity }

          respond_to_with_dual_blocks(false, block, options) do |format|
            format.html { render :action => 'new' }
          end
        end
      end
      alias :create! :create

      # GET /account/password/edit?account[perishable_token]=xxxx
      def edit(&block)
        object = get_or_set_with_send(:new)
        object.perishable_token = params[self.instance_name].try(:fetch, :perishable_token)
        respond_to(:with => object, &block)
      end
      alias :edit! :edit

      # PUT /account/password
      # PUT /account/password.xml
      def update(&block)
        object = get_or_set_with_send(:find_and_reset_password, params[self.instance_name])
        respond_block, redirect_block = select_block_by_arity(block)

        if object.errors.empty?
          set_flash_message!(:notice, 'Your password was successfully reset.')

          respond_to_with_dual_blocks(true, block) do |format|
            format.html { redirect_to_block_or_scope_to(redirect_block, :session) }
            format.all  { head :ok }
          end
        else
          set_flash_message!(:error)
          options = { :with => object.errors, :status => :unprocessable_entity }

          respond_to_with_dual_blocks(false, block, options) do |format|
            format.html { render :action => 'edit' }
          end
        end
      end
      alias :update! :update

      protected :new!, :create!, :edit!, :update!
    end
  endend

