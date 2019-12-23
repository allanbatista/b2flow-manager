require 'b2flow/manager/node'

module B2flow
  module Manager
    class Dag
      def initialize(jobs)
        @graph = build_graph(jobs)
      end

      def executable_nodes
        @graph.values.select(&:executable?)
      end

      def execute
        executable_nodes.each do |node|
          sleep 1
          puts "executed #{node.name}"
          node.success!
        end

        all_complete?
      end

      def all_complete?
        @graph.values.each do |node|
          return true if node.fail?
          return false if node.pending? or node.running?
        end

        return true
      end

      def build_graph(jobs)
        graphs = {}

        jobs.keys.each do |name|
          inject_build(jobs, name)
        end

        jobs.keys.each do |name|
          node = Node.new(name.to_s, jobs[name])
          graphs[name.to_s] = node
        end

        graphs.values.each do |node|
          node.depends.each do |name|
            parent = graphs[name]
            node.add_parent(parent)
            parent.add_children(node)
          end
        end

        graphs
      end

      def inject_build(jobs, name)
        build_name = "__build_#{name}"

        jobs[build_name] = {
            engine: '__build'
        }

        if jobs[name][:depends].nil?
          jobs[name][:depends] = [build_name]
        elsif jobs[name][:depends].is_a?(Array)
          jobs[name][:depends] = [build_name] + jobs[name][:depends]
        else
          jobs[name][:depends] = [build_name, jobs[name][:depends]]
        end
      end
    end
  end
end