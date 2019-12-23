require 'json'
require 'zip'
require 'b2flow/service/kube'
require 'b2flow/manager/dag'

module B2flow
  module Manager
    class Executor
      attr_reader :config

      def initialize
        @name = ENV['B2FLOW__DAG__NAME']
        @config = JSON.parse(ENV['B2FLOW__DAG__CONFIG'])
      end

      def read_python(job_name)
        Zip::File.open(ENV['B2FLOW__STORAGE_PATH']) do |zipfile|
          zipfile.each do |entry|
            if entry.name.include?("#{job_name}/main.py")
              return entry.get_input_stream.read
            end
          end
        end
      end

      def run
        dag = B2flow::Manager::Dag.new(@config['jobs'])

        loop do
          break if dag.execute
        end
      end

      def submit(job_name)
        job = {
            "apiVersion": "batch/v1",
            "kind": "Job",
            "metadata": {
                "name": "#{@name}-#{job_name}"
            },
            "spec": {
                "template": {
                    "spec": {
                        "containers": [
                            {
                                "name": "#{@name}-#{job_name}",
                                "image": "python:3",
                                "command": [
                                    "python",
                                    read_python(job_name)
                                ]
                            }
                        ],
                        "restartPolicy": "Never"
                    }
                }
            }
        }

        puts B2flow::Service::Kube.jobs.create(job)
      end
    end
  end
end
