module Guard
  class Chef < Plugin
    class Dsl
      class ChefSpec
        attr_accessor :options
        attr_reader :spec_dir, :spec_helper
        def initialize(options = {})
          @options = options
          @spec_dir = options[:spec_dir]
          @spec_helper = "#{@spec_dir}/spec_helper.rb"
        end

        def spec
          ->(m) { Dsl.detect_spec_file_for(self, m) }
        end

        def spec_files
          %r{^#{spec_dir}/.+_spec\.rb$}
        end

        def unit_spec_dir
          "#{spec_dir}/unit"
        end

        def spec_support
          %r{^#{spec_dir}/support/(.+)\.rb$}
        end

        def to_s
          'spec'
        end
      end
    end
  end
end
