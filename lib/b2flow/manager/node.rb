require 'json'

module B2flow
  module Manager
    class Node
      attr_reader :name

      def initialize(name, config)
        @name = name
        @config = config
        @parents = []
        @children = []
        @status = :pending # :running, :success, :fail
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