module B2flow
  module Service
    class ApiResponse
      def initialize(response)
        @response = response
      end

      def result
        @result ||= RecursiveOpenStruct.new(JSON.parse(@response.body), recurse_over_arrays: true)
      end

      def success?
        @response.status <= 200
      end
    end
  end
end