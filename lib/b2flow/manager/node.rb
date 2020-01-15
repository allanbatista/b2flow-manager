require 'json'
require 'time'
require 'securerandom'
require 'b2flow/manager/engine'

module B2flow
  module Manager
    class Node
      attr_reader :id, :name, :engine, :dag, :config, :messages, :status

      def initialize(name, config, dag)
        @id = SecureRandom.uuid
        @name = name
        @config = config
        @dag = dag
        @parents = []
        @children = []
        @status = :pending # :running, :success, :fail, :cancel
        @engine = B2flow::Manager::Engine.build(self)
        @messages = []
      end

      def execute
        engine.submit!
      end

      def check!
        engine.check!
      end

      def cancel!
        engine.stop!

        @status = :cancel!
        puts "#{name} #{@status}"
      end

      def purge!
        engine.purge!
      end

      def metadata
        {
            dag: dag.metadata,
            job: {
                id: id,
                name: name,
                started_at: DateTime.now.to_s
            }
        }
      end

      def env
        envs = dag.config.environments.to_h.keys.map do |key|
          { "name" => key, "value" => dag.config.environments[key]}
        end

        envs << {
            "name" => "__METADATA__",
            "value" => metadata.to_json
        }

        envs
      end

      def engine_name
        @config.engine.type
      end

      def complete?
        [:success, :fail].include?(@status)
      end

      def pending?
        @status == :pending
      end

      def running?
        @status == :running
      end

      def success?
        @status == :success
      end

      def fail?
        @status == :fail
      end

      def success!
        @status = :success
        puts "#{name} #{@status}"
      end

      def running!
        @status = :running
        puts "#{name} #{@status}"
      end

      def fail!
        @status = :fail
        puts "#{name} #{@status}"
      end

      def executable?
        @parents.map(&:success?).all? && pending?
      end

      def add_parent(node)
        @parents << node
      end

      def add_children(node)
        @children << node
      end

      def depends
        if !@config[:depends].nil?
          if @config[:depends].is_a?(Array)
            return @config[:depends]
          else
            return [@config[:depends]]
          end
        else
          return []
        end
      end
    end
  end
end