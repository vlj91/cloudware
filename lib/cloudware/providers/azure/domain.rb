# frozen_string_literal: true

module Cloudware
  module Providers
    module AZURE
      class Domain < Base::Domain
        def provider
          'azure'
        end

        def resource_group_name
          "alces-flightconnector-#{name}"
        end

        private

        include Helpers::Client

        def run_create
          client.resource.deployments.create_or_update(
            resource_group.name, name, deployment_model
          )
        rescue MsRestAzure::AzureOperationError => e
          # Azure returns a `JSON` string which contains an embedded `JSON`
          # string. This embedded `JSON` contains the error message
          message = JSON.parse(
            JSON.parse(e.message)['response']['body']
          )['error']['message']
          raise InvalidAzureRequest, message
        end

        def run_destroy
          client.resource.resource_groups.delete(resource_group_name)
        end

        def resource_group
          group = client.resource.model_classes.resource_group.new
          group.location = region
          group.tags = {
            cloudware_id: id,
            cloudware_domain: name,
            region: region
          }
          client.resource.resource_groups
                .create_or_update(resource_group_name, group)
        end
        memoize :resource_group

        def deployment_model
          client.resource.model_classes.deployment.new.tap do |deployment|
            deployment.properties = deployment_properties
          end
        end
        memoize :deployment_model

        def deployment_properties
          client.resource.model_classes.deployment_properties.new.tap do |p|
            p.template = template_content
            p.parameters = convert_params_to_azure_syntax(
              cloudwareDomain: name,
              cloudwareId: id,
              networkCIDR: networkcidr,
              priSubnetCIDR: prisubnetcidr
            )
            p.mode = Azure::Resources::Profiles::Latest::Mgmt::Models::DeploymentMode::Incremental
          end
        end 

        # Azure requires the parameter hash to have syntax:
        # { :your_key => { value: 'your_value' } }
        def convert_params_to_azure_syntax(**params)
          params.map { |k, v| [k, { value: v }] }.to_h
        end

        def template_content
          JSON.parse(File.read(File.join(
            Cloudware.config.base_dir,
            "providers/azure/templates/#{template}.json"
          )))
        end
        :memoize
      end
    end
  end
end
