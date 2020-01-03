require 'json'
require 'recursive-open-struct'

module B2flow
  module Service
    class ApiResponse
      attr_reader :response, :result, :request

      def initialize(response, request)
        @request = request
        @response = response
        @result = RecursiveOpenStruct.new(JSON.parse(@response.body), recurse_over_arrays: true) rescue @response.body
        @success = @response.status < 300

        # puts to_s
      end

      def success?
        @success
      end

      def to_s
        message = ["status: #{response.status}"]
        message += response.headers.map {|k, v| "#{k}: #{v}" }
        if body_json?
          message << "\n" + JSON.pretty_generate(@result.to_h)
        else
          message << "\n" + @result
        end
        message.join("\n")
      end

      def body_json?
        @result.is_a?(RecursiveOpenStruct)
      end
    end
  end
end