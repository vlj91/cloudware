# frozen_string_literal: true

module Cloudware
  module Commands
    module Machine
      module Power
        class Off < Command
          def run
            machine = run_whirly('Fetching machine') do
              Providers.find_machine(
                options.provider,
                options.region,
                options.domain,
                name,
                missing_error: true
              )
            end
            run_whirly('Powering machine off') { machine.power_off }
          end

          private

          attr_reader :name

          def required_options
            [:domain]
          end

          def unpack_args
            @name = args.first
          end
        end
      end
    end
  end
end