require 'guard/chefspec_defaults'
require 'guard/chef/inspectors/factory'
require 'guard/chef/command'
require 'guard/chef/notifier'
require 'guard/chef/results'
require 'guard/chef/rspec_process'

module Guard
  class Chef < Plugin
    class Runner
      class NoCmdOptionError < RuntimeError
        def initialize
          super 'No cmd option specified, unable to run specs!'
        end
      end

      TEMPORARY_FILE_PATH ||= 'tmp/chef_guard_result'
      attr_accessor :options, :inspector, :notifier

      def initialize(options = {})
        @options = options
        @inspector = Inspectors::Factory.create(@options)
        @notifier = Notifier.new(@options)
      end

      def run_all
        paths = options[:spec_paths]
        options = @options.merge(@options[:run_all])
        return true if paths.empty?
        Compat::UI.info(options[:message], reset: true)
        _run(paths, options)
      end

      def run(paths)
        paths = inspector.paths(paths)
        return true if paths.empty?
        Compat::UI.info("Running: #{paths.join(' ')}", reset: true)
        _run(paths, options) do |all_green|
          next false unless all_green
          next true unless options[:all_after_pass]
          run_all
        end
      end

      def reload
        inspector.reload
      end

      private

      def _run(paths, options, &block)
        fail NoCmdOptionError unless options[:cmd]
        command = Command.new(paths, options)
        _really_run(command, options, &block)
      rescue RSpecProcess::Failure, NoCmdOptionError => ex
        Compat::UI.error(ex.to_s)
        notifier.notify_failure
        false
      end

      def _really_run(cmd, options)
        file = _results_file(options[:results_file], options[:chdir])
        process = RSpecProcess.new(cmd, file)
        results = process.results
        inspector.failed(results.failed_paths)
        notifier.notify(results.summary)
        _open_launchy
        all_green = process.all_green?
        block_given? ? (yield all_green) : all_green
      end

      def _open_launchy
        return unless options[:launchy]
        require 'launchy'
        pn = Pathname.new(options[:launchy])
        ::Launchy.open(options[:launchy]) if pn.exist?
      end

      def _results_file(results_file, chdir)
        results_file ||= ChefSpecDefaults::TEMPORARY_FILE_PATH
        return results_file unless Pathname(results_file).relative?
        chdir ? File.join(chdir, results_file) : results_file
      end
    end
  end
end
