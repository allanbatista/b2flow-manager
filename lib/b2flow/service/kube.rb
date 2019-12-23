require 'faraday'
require 'b2flow/service/api_sdl'
require 'b2flow/service/kube_resource'

module B2flow
  module Service
    class Kube
      include Singleton
      attr_reader :connection

      def initialize
        @connection = Faraday.new(ENV['B2FLOW__KUBERNETES__URI'], {ssl: { verify: false }, headers: { 'content-type': 'application/json' }} )

        if AppConfig.B2FLOW__KUBERNETES__USERNAME.present? and AppConfig.B2FLOW__KUBERNETES__PASSWORD.present?
          @connection.basic_auth(AppConfig.B2FLOW__KUBERNETES__USERNAME, AppConfig.B2FLOW__KUBERNETES__PASSWORD)
        end
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
        @pods ||= B2flow::Service::KubeResource.new(client,"/apis/batch/v1", "default", "jobs")
      end

      private

      def client
        ApiSdl.new(connection)
      end
    end
  end
end