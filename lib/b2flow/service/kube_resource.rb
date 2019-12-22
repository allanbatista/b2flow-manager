module B2flow
  module Service
    class KubeResource
      attr_reader :api_client

      def initialize(api_client, api_version, namespace_name, resource_name)
        @api_client = api_client.route("#{api_version}/namespaces/#{namespace_name}/#{resource_name}")
      end

      def list
        api_client.get
      end

      def get(name)
        api_client.route(name).get
      end

      def create(resource)
        api_client.body(resource).post
      end

      def replace(name, resource)
        api_client.route(name).body(resource).put
      end

      def delete(name)
        api_client.route(name).delete
      end

      def create_or_replace(name, resource)
        if get(name).success?
          replace(name, resource)
        else
          create(resource)
        end
      end
    end
  end
end