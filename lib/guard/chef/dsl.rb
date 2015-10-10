require 'ostruct'
require_relative 'dsl/chefspec'

module Guard
  class Chef < Plugin
    class Dsl
      attr_accessor :options
      def initialize(dsl, options = {})
        @dsl = dsl
        @options = { spec_dir: 'spec', test_dir: 'test' }.update(options)
      end

      def watch_spec_files_for(expr)
        @dsl.send(:watch, expr) { |m| chefspec.spec.(m[1]) }
      end

      def self.detect_spec_file_for(chefspec, file)
        # TODO: when spec not found ... run specs in topmost found path?
        # or show warning?
        #
        unit_path = "#{chefspec.unit_spec_dir}/#{file}_spec.rb"
        unit_path.sub!(/attributes/, 'recipes')
        path = "#{chefspec.spec_dir}/#{file}_spec.rb"
        return unit_path unless file.start_with?('lib/')
        return path if Dir.exist?("#{chefspec.spec_dir}/lib")

        without_lib = file.sub(%r{^lib/}, '')
        "#{chefspec.spec_dir}/#{without_lib}_spec.rb"
      end

      def chefspec
        @chefspec ||= Dsl::ChefSpec.new(options)
      end

      def ruby
        @ruby ||= OpenStruct.new.tap do |ruby|
          ruby.lib_files = %r{^(lib/.+)\.rb$}
        end
      end

      def cookbook
        @cookbook ||= OpenStruct.new.tap do |cookbook|
          cookbook.recipes = %r{(^recipes/.+)\.rb$}
          cookbook.attributes = %r{(^attributes/.+)\.rb$}
          cookbook.libraries = %r{(^libraries/.+)\.rb$}
          cookbook.providers = %r{(^providers/.+)\.rb$}
          cookbook.resources = %r{(^resources/.+)\.rb$}
        end
      end
    end
  end
end
