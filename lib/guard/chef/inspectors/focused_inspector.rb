require 'guard/chef/inspectors/base_inspector'

module Guard
  class Chef < Plugin
    module Inspectors
      class FocusedInspector < BaseInspector
        attr_accessor :focused_locations

        def initialize(options = {})
          super
          @focused_locations = []
        end

        def paths(paths)
          if focused_locations.any?
            focused_locations
          else
            _clean(paths)
          end
        end

        def failed(locations)
          if locations.empty?
            @focused_locations = []
          else
            @focused_locations = locations if focused_locations.empty?
          end
        end

        def reload
          @focused_locations = []
        end
      end
    end
  end
end
