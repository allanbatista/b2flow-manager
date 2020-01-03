require 'time'
require 'b2flow/service/kube'

class B2flow::Manager::Engine::Docker
  attr_reader :node, :name, :start_at

  FLAVOR_MAP = {
      "standard-1" => { "cpu" => "1", "memory" => "5Gi" },
      "standard-2" => { "cpu" => "3", "memory" => "12Gi" },
      "standard-3" => { "cpu" => "7", "memory" => "27Gi" },
      "standard-4" => { "cpu" => "15", "memory" => "57Gi" },
      "high-memory-1" => { "cpu" => "1", "memory" => "9Gi" },
      "high-memory-2" => { "cpu" => "3", "memory" => "22Gi" },
      "high-memory-3" => { "cpu" => "7", "memory" => "48Gi" },
      "high-memory-4" => { "cpu" => "15", "memory" => "100Gi" }
  }

  def initialize(node)
    @node = node
    @name = node.config.full_name.gsub(/[^a-z0-9]/, '-')
    @start_at = nil
  end

  def timeout
    ( node.config.timeout || "3600" ).to_i
  end

  def flavor
    node.config.engine.flavor || "standard-1"
  end

  def flavor_cpu
    FLAVOR_MAP[flavor]['cpu']
  end

  def flavor_memory
    FLAVOR_MAP[flavor]['memory']
  end

  def submit!
    response = B2flow::Service::Kube.jobs.delete_and_create(name, generate_config)

    node.messages << response.request.to_s
    node.messages << response.to_s

    if response.success?
      @start_at = Time.now
      @uid = response.result.metadata.uid
      node.running!
    else
      node.fail!
    end
  end

  def check!
    response = B2flow::Service::Kube.pods.list('labelSelector' => "controller-uid=#{@uid}")
    pod = response.result.items.first
    node.messages << response.to_s

    now = Time.now
    if now - start_at >= timeout
      node.messages << "Timeout"
      node.stop!
      return node.fail!
    end

    reason = pod.status.containerStatuses.first.state.waiting.reason rescue nil
    return node.fail! if ['Failed', 'Unknown'].include?(pod.status.phase) or (pod.status.phase == "Pending" and reason == 'ImagePullBackOff')
    return node.success! if ['Succeeded'].include?(pod.status.phase)
  end

  def stop!
    response = B2flow::Service::Kube.pods.list('labelSelector' => "controller-uid=#{@uid}")

    if response.result.items.any?
      pod = response.result.items.first

      B2flow::Service::Kube.pods.forceDelete(pod.metadata.name)

      while B2flow::Service::Kube.pods.find(pod.metadata.name).success?
        puts "Waiting to stop #{pod.metadata.name}"
        sleep 1
        break
      end
    end
  end

  def purge!
    stop!
    B2flow::Service::Kube.jobs.delete(name)
  end

  def generate_config
    {
      "apiVersion": "batch/v1",
      "kind": "Job",
      "metadata": {
        "name": name
      },
      "spec": {
        "activeDeadlineSeconds": timeout,
        "backoffLimit": 0,
        "template": {
          "spec": {
            "restartPolicy": "Never",
            "containers": [
              {
                "name": name,
                "image": node.config.image,
                "env": node.env,
                "resources": {
                  "limits": {
                    "cpu": flavor_cpu,
                    "memory": flavor_memory
                  },
                  "requests": {
                    "cpu": flavor_cpu,
                    "memory": flavor_memory
                  }
                }
              }
            ],
            "affinity": {
              "nodeAffinity": {
                "requiredDuringSchedulingIgnoredDuringExecution": {
                  "nodeSelectorTerms": [
                    {
                      "matchExpressions": [
                        {
                          "key": "flavor",
                          "operator": "In",
                          "values": [
                              flavor
                          ]
                        }
                      ]
                    }
                  ]
                }
              }
            }
          }
        }
      }
    }
  end
end