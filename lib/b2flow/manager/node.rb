require 'json'
require 'b2flow/manager/engine'

module B2flow
  module Manager
    class Node
      attr_reader :name, :engine, :dag, :config, :messages, :status

      def initialize(name, config, dag)
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

      def env
        dag.config.config.to_h.keys.map do |key|
          { "name" => key, "value" => dag.config.config[key]}
        end
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