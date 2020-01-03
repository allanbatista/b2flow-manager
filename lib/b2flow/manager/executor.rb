require 'json'
require 'recursive-open-struct'
require 'b2flow/service/kube'
require 'b2flow/manager/dag'

module B2flow
  module Manager
    class Executor
      attr_reader :dag

      def initialize
        @dag = B2flow::Manager::Dag.new(RecursiveOpenStruct.new(JSON.parse(ENV['B2FLOW__DAG__CONFIG']), recurse_over_arrays: true))
      end

      def run
        dag.execute
      end
    end
  end
end
