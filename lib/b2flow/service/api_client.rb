require 'b2flow/service/api_request'
require 'b2flow/service/api_response'

module B2flow
  module Service
    class ApiClient
      attr_reader :client

      DEFAULTS = {path: "/", params: {}, headers: {}, body: {}}

      def initialize(client, options = {})
        @client = client
        @arguments = DEFAULTS.merge(options)
      end

      def route(path)
        _path = @arguments[:path]
        _path = File.join(@arguments[:path], path) if !(path.nil? || path == "")

        B2flow::Service::ApiClient.new(client, @arguments.merge({path: _path}))
      end

      def params(params)
        _params = @arguments[:params]
        _params = @arguments[:params].merge(params) if !(params.nil? || params.empty?)

        B2flow::Service::ApiClient.new(client, @arguments.merge({params: _params}))
      end

      def headers(headers)
        _headers = @arguments[:headers]
        _headers = @arguments[:headers].merge(headers) if !(headers.nil? || headers.emtpy?)

        B2flow::Service::ApiClient.new(client, @arguments.merge({headers: _headers}))
      end

      def body(body)
        _body = @arguments[:body]
        _body = @arguments[:body].merge(body) if !(body.nil? || body.empty?)

        B2flow::Service::ApiClient.new(client, @arguments.merge({body: _body}))
      end

      def get
        action(:get)
      end

      def post
        action(:post)
      end

      def patch
        action(:patch)
      end

      def put
        action(:put)
      end

      def delete
        action(:delete)
      end

      private

      def action(method)
        request = B2flow::Service::ApiRequest.new(client, @arguments.merge(method: method))
        request.execute
      end
    end
  end
end
