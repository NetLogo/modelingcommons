# encoding: UTF-8
require 'set'

module MongoMapper
  module Plugins
    module Protected
      module ClassMethods
        def attr_protected(*attrs)
          raise AccessibleOrProtected.new(name) if try(:accessible_attributes?)
          self.write_inheritable_attribute(:attr_protected, Set.new(attrs) + (protected_attributes || []))
        end

        def protected_attributes
          self.read_inheritable_attribute(:attr_protected)
        end

        def protected_attributes?
          !protected_attributes.nil?
        end

        def key(*args)
          key = super
          attr_protected key.name.to_sym if key.options[:protected]
          key
        end
      end

      module InstanceMethods
        def assign(attrs={})
          super(filter_protected_attrs(attrs))
        end

        def update_attributes(attrs={})
          super(filter_protected_attrs(attrs))
        end

        def update_attributes!(attrs={})
          super(filter_protected_attrs(attrs))
        end

        def protected_attributes
          self.class.protected_attributes
        end

        protected
          def filter_protected_attrs(attrs)
            return attrs if protected_attributes.blank? || attrs.blank?
            attrs.dup.delete_if { |key, val| protected_attributes.include?(key.to_sym) }
          end
      end
    end
  end
end
