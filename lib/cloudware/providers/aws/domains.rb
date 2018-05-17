
# frozen_string_literal: true

module Cloudware
  module Providers
    module AWS
      class Domains < Base::Domains
        class Builder
          def initialize(region)
            @region ||= region
            @ec2 = Aws::EC2::Client.new(
              region: region,
              credentials: Cloudware.config.credentials.aws
            )
          end

          def domains
            vpcs.map { |vpc| build_domain(vpc) }
          end

          private

          attr_reader :region, :ec2

          def vpcs
            @vpcs ||= ec2.describe_vpcs(
              filters: [{ name: 'tag-key', values: ['cloudware_id'] }]
            ).vpcs
          end

          def subnets
            @subnets ||= ec2.describe_subnets(
              filters: [{ name: 'tag-key', values: ['cloudware_id'] }]
            ).subnets
          end

          def find_subnet(domain_name)
            subnets.find do |net|
              tags = tags_structs(net.tags)
              tags.cloudware_domain == domain_name
            end
          end

          def build_domain(vpc)
            args = { provider: 'aws', region: region }
            Models::Domain.build(**args).tap do |domain|
              vpc_tags = tags_structs(vpc.tags)
              domain.name = vpc_tags.cloudware_domain
              domain.networkcidr = vpc_tags.cloudware_network_cidr
              domain.prisubnetcidr = vpc_tags.cloudware_pri_subnet_cidr
              subnet = find_subnet(domain.name)
            end
          end

          def tags_structs(tags_struct)
            OpenStruct.new(
              tags_struct.map { |t| [t.key, t.value] }.to_h
            )
          end
        end

        class << self
          private

          def domain_models_by_region(region)
            Builder.new(region).domains
          end
        end
      end
    end
  end
end
