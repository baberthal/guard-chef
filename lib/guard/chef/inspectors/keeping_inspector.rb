require 'guard/chef/inspectors/base_inspector'

module Guard
  class Chef < Plugin
    module Inspectors
      class KeepingInspector < BaseInspector
        attr_accessor :failed_locations

        def initialize(options = {})
          super
          @failed_locations = []
        end

        def paths(paths)
          _with_failed_locations(_clean(paths))
        end

        def failed(locations)
          @failed_locations = locations
        end

        def reload
          @failed_locations = []
        end

        private

        def _with_failed_locations(paths)
          failed_paths = failed_locations.map { |l| _location_path(l) }
          (paths | failed_paths).uniq
        end

        def _location_path(location)
          location.match(%r{^(\./)?(.*?)(:\d+)?$})[2]
        end
      end
    end
  end
end
