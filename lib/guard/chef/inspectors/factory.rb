require 'guard/chef/inspectors/simple_inspector'
require 'guard/chef/inspectors/keeping_inspector'
require 'guard/chef/inspectors/focused_inspector'

module Guard
  class Chef < Plugin
    module Inspectors
      class Factory
        class << self
          def create(options = {})
            case options[:failed_mode]
            when :focus then FocusedInspector.new(options)
            when :keep then KeepingInspector.new(options)
            else; SimpleInspector.new(options)
            end
          end

          private :new
        end
      end
    end
  end
end
