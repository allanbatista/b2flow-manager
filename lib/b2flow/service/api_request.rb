require 'json'
require 'recursive-open-struct'

module B2flow
  module Service
    class ApiRequest
      attr_reader :client

      DEFAULTS = {path: "/", params: {}, headers: {}, body: {}, method: :get}

      def initialize(client, arguments={})
        @client = client
        @arguments = DEFAULTS.merge(arguments)
      end

      def execute
        puts self

        response = client.send(method, final_uri) do |f|
          f.headers = f.headers.merge(headers)
          f.body = JSON.pretty_generate(body) if body_present?
        end

        r = B2flow::Service::ApiResponse.new(response, self)

        puts r

        r
      end

      def to_s
        message = ["#{method.to_s.upcase} #{final_uri}"]
        message += client.headers.merge(headers).map {|k, v| "#{k}: #{v}" }
        if body_present?
          message << "\n" + JSON.pretty_generate(body)
        else
          message << "\n"
        end
        message.join("\n")
      end

      def body_present?
        body.is_a?(Hash) and body.size > 0
      end

      def params_present?
        params.is_a?(Hash) and params.size > 0
      end

      def final_uri
        if params_present?
          "#{path}?#{URI.encode_www_form(params)}"
        else
          path
        end
      end

      def method
        @arguments[:method]
      end

      def path
        @arguments[:path]
      end

      def params
        @arguments[:params]
      end

      def body
        @arguments[:body]
      end

      def headers
        @arguments[:headers]
      end
    end
  end
end