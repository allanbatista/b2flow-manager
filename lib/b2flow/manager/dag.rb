require 'time'
require 'b2flow/manager/node'

module B2flow
  module Manager
    class Dag
      attr_reader :config, :graph, :id

      def initialize(config)
        @id = SecureRandom.uuid
        @config = config
        @graph = build_graph
      end

      def metadata
        {
            id: @id,
            started_at: DateTime.now.to_s
        }
      end

      def executable_nodes
        @graph.values.select(&:executable?)
      end

      def running_nodes
        @graph.values.select(&:running?)
      end

      def pending_nodes
        @graph.values.select(&:pending?)
      end

      def any_error?
        @graph.values.map(&:fail?).any?
      end

      def execute
        loop do
          executable_nodes.each do |node|
            puts "executing #{node.name}"
            node.execute
          end

          running_nodes.each do |node|
            node.check!
          end

          if any_error?
            puts "Any Fail"
            pending_nodes.map(&:cancel!)
            running_nodes.map(&:cancel!)
            break
          end

          break if all_complete?

          puts "Waiting next round!"
          sleep 1
        end


        puts " ================== EXECUTE RESUME (#{success? ? "success" : "fail"}) =================="
        @graph.each do |job_name, node|
          # node.purge!
          puts "#{job_name}: #{node.status}"
        end
      end

      def success?
        @graph.values.map(&:success?).all?
      end

      def all_complete?
        @graph.values.each do |node|
          return true if node.fail?
          return false if node.pending? or node.running?
        end

        return true
      end

      def build_graph
        graphs = {}

        config.jobs.each do |job|
          node = Node.new(job.name, job, self)
          graphs[job.name] = node
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
    end
  end
end