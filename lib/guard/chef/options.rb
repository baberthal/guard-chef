module Guard
  class Chef < Plugin
    module Options
      DEFAULTS = {
        all_on_start:        false,
        all_after_pass:      false,
        run_all:             { message: 'Running all specs' },
        failed_mode:         :none,
        spec_paths:          %w(spec),
        cmd:                 nil,
        cmd_additional_args: nil,
        launchy:             nil,
        notification:        true,
        title:               'ChefSpec Results'
      }

      class << self
        def with_defaults(options = {})
          _deep_merge(DEFAULTS, options)
        end

        private

        def _deep_merge(hash1, hash2)
          hash1.merge(hash2) do |_key, oldval, newval|
            if oldval.instance_of?(Hash) && newval.instance_of?(Hash)
              _deep_merge(oldval, newval)
            else
              newval
            end
          end
        end
      end
    end
  end
end
