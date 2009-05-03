module AuthHelpers
  module Controller
    module Helpers

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        protected

          # Writes the inherited hook for the included class based on its name.
          #
          def inherited(base) #:nodoc:
            super

            base.send :cattr_accessor, :resource_class, :instance_name, :route_name, :instance_writter => false

            resource = base.controller_path.gsub('/', '_')
            resource.gsub!(/_#{self.name.downcase}?$/, '')

            base.resource_class = begin
              resource.classify.constantize
            rescue NameError
              nil
            end

            base.route_name = resource.singularize
            base.instance_name = resource.singularize
          end

          def set_class_accessors_with_class(klass)
            self.resource_class = klass
            self.instance_name  = klass.name.downcase
            self.route_name     = klass.name.downcase
          end
      end

      protected

        # If a block is given, redirect to the url in the block, otherwise
        # try to call the url given by scope, for example:
        #
        #   new_account_session_url
        #   new_account_password_url
        #
        def redirect_to_block_or_scope_to(redirect_block, scope) #:nodoc:
          redirect_to redirect_block ? redirect_block.call : send("new_#{self.route_name}_#{scope}_url")
        end

        # Try to get the instance variable, otherwise send the args given to
        # the resource class and store the result in the same instance variable.
        #
        def get_or_set_with_send(*args) #:nodoc:
          instance_variable_get("@#{self.instance_name}") || instance_variable_set("@#{self.instance_name}", resource_class.send(*args))
        end

    end
  endend

