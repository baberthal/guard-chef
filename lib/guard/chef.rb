require 'guard/compat/plugin'
require 'guard/chef/version'
require 'guard/chef/options'
require 'guard/chef/runner'

module Guard
  class Chef < Plugin
    attr_accessor :options, :runner

    def initialize(options = {})
      super
      @options = Options.with_defaults(options)
      @runner = Runner.new(@options)
    end

    def start
      Guard::Compat::UI.info 'Guard::Chef is running'
      run_all if options[:all_on_start]
    end

    def run_all
      _throw_if_failed { runner.run_all }
    end

    def reload
      runner.reload
    end

    def run_on_modifications(paths)
      return false if paths.empty?
      _throw_if_failed { runner.run(paths) }
    end

    private

    def _throw_if_failed
      throw :task_has_failed unless yield
    end
  end
end
