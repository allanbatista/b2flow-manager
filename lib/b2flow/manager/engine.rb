module B2flow::Manager::Engine
  require 'b2flow/manager/engine/docker'

  class EngineNotDefinedError < StandardError; end

  def self.build(node)
    case node.engine_name
      when "DockerEngine"
        Docker.new(node)
      else
        raise EngineNotDefinedError.new
    end
  end
end
