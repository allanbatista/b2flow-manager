require 'faraday'
require 'singleton'
require 'b2flow/service/api_client'
require 'b2flow/service/kube_resource'

module B2flow
  module Service
    class Kube
      include Singleton
      attr_reader :connection, :client

      def initialize
        @connection = Faraday.new(ENV['B2FLOW__KUBERNETES__URI'], {ssl: {verify: false }, headers: {'content-type': 'application/json' }} )

        if !ENV['B2FLOW__KUBERNETES__USERNAME'].nil? and !ENV['B2FLOW__KUBERNETES__PASSWORD'].nil?
          @connection.basic_auth(ENV['B2FLOW__KUBERNETES__USERNAME'], ENV['B2FLOW__KUBERNETES__PASSWORD'])
        end

        @client = B2flow::Service::ApiClient.new(@connection)
      end

      class << self
        def cronjobs
          self.instance.cronjobs
        end

        def pods
          self.instance.pods
        end

        def jobs
          self.instance.jobs
        end
      end

      def cronjobs
        @cronjobs ||= B2flow::Service::KubeResource.new(client,"/apis/batch/v1beta1", "default", "cronjobs")
      end

      def pods
        @pods ||= B2flow::Service::KubeResource.new(client,"/api/v1", "default", "pods")
      end

      def jobs
        @jobs ||= B2flow::Service::KubeResource.new(client,"/apis/batch/v1", "default", "jobs")
      end
    end
  end
end