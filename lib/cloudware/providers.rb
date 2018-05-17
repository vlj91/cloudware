
# frozen_string_literal: true

require_all 'lib/cloudware/providers/base/*.rb'
require_all 'lib/cloudware/providers/**/*.rb'

module Cloudware
  module Providers
    class << self
      def select(provider)
        case provider
        when 'aws'
          AWS
        when 'azure'
          raise NotImplementedError
        else
          raise InvalidInput, "Unrecognised provider: #{provider}"
        end
      end

      def find_domain(provider, region, name)
        select(provider)::Domains.by_region(region).find_by_name(name)
      end

      def find_machine(provider, region, domain, name, missing_error: false)
        select(provider)::Machines.by_region(region)
          .find_machine(domain, name)
          .tap { |m| raise_if_missing(m, 'machine', name) if missing_error }
      end

      private

      def raise_if_missing(model, type, name)
        return if model
        raise InvalidInput, "Can not find #{type}: #{name}"
      end
    end
  end
end
