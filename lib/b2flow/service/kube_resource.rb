module B2flow
  module Service
    class KubeResource
      attr_reader :api_client

      def initialize(api_client, api_version, namespace_name, resource_name)
        @api_client = api_client.route("#{api_version}/namespaces/#{namespace_name}/#{resource_name}")
      end

      def list(params={})
        api_client.params(params).get
      end

      def find(name)
        api_client.route(name).get
      end

      def create(resource)
        api_client.body(resource).post
      end

      def replace(name, resource)
        api_client.route(name).body(resource).put
      end

      def delete(name, params={})
        api_client.params(params).route(name).delete
      end

      def forceDelete(name)
        delete(name, gracePeriodSeconds: 0)
      end

      def create_or_replace(name, resource)
        if find(name).success?
          replace(name, resource)
        else
          create(resource)
        end
      end

      def delete_and_create(name, resource, max_attempts=3)
        attempts = 1
        response = nil

        loop do
          puts "training to create resource - attempts #{attempts}"
          delete(name) if find(name).success?
          response = create(resource)

          attempts += 1
          break if response.success? or attempts > max_attempts
          sleep 1
        end

        response
      end
    end
  end
end