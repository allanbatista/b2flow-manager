module B2flow
  module Service
    class ApiSdl
      attr_reader :connection

      DEFAULTS = {path: "/", params: {}, headers: {}, body: {}}

      def initialize(connection, options = {})
        @connection = connection
        @arguments = DEFAULTS.merge(options)
      end

      def route(path)
        _path = @arguments[:path]
        _path = File.join(@arguments[:path], path) if !(path.nil? || path == "")

        ApiSdl.new(connection, @arguments.merge({path: _path}))
      end

      def params(params)
        _params = @arguments[:params]
        _params = @arguments[:params].merge(params) if !(params.nil || params.empty?)

        ApiSdl.new(connection, @arguments.merge({params: _params}))
      end

      def headers(headers)
        _headers = @arguments[:headers]
        _headers = @arguments[:headers].merge(headers) if !(headers.nil? || headers.emtpy?)

        ApiSdl.new(connection, @arguments.merge({headers: _headers}))
      end

      def body(body)
        _body = @arguments[:body]
        _body = @arguments[:body].merge(body) if !(body.nil? || body.empty?)

        ApiSdl.new(connection, @arguments.merge({body: _body}))
      end

      def final_uri
        [@arguments[:path], @arguments[:params]].filter(&:nil?).join("?")
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
        response = connection.send(method, final_uri) do |f|
          f.headers = f.headers.merge(@arguments[:headers])
          f.body = @arguments[:body].to_json if @arguments[:body].present?
        end

        ApiResponse.new(response)
      end

    end
  end
end
