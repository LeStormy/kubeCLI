#!/usr/bin/env ruby

require './kube_commands.rb'

class KubeClient
  COMMANDS = {
    'migrate' => 'Apply a migration manifest',
    'deploy' => 'Apply a deployment manifest',
    'scale' => 'Scale a deployment',
    'setup' => 'Setup a new namespace with an app stack',
    'console' => 'Connect to a shell on a pod and run bin/rails c',
    'exec' => 'Execute a command inside a pod'
  }

  COMMANDS_MAPPING = {
    'migrate' => -> (namespac, args) { migrate(namespace) },
    'deploy' => -> (namespace, args) { deploy(namespace) },
    'scale' => -> (namespace, args) { scale(namespace) },
    'setup' => -> (namespace, args) { setup(namespace) },
    'console' => -> (namespace, args) { console(namespace) },
    'exec' => -> (namespace, args) { exec(namespace, args) }
  }

  NAMESPACES = ["default", "app", "app2", "app3"]

  class << self
    def deploy(namespace)
      KubeCommands.apply(namespace, "web-deployment")
      KubeCommands.apply(namespace, "worker-deployment")
    end

    def migrate(namespace)
      KubeCommands.apply(namespace, "migrate")
    end

    def scale(namespace)

    end

    def setup(namespace)
      KubeCommands.setup(namespace)
    end

    def console(namespace)
      KubeCommands.exec(namespace, "bin/rails c")
    end

    def exec(namespace, args)
      KubeCommands.exec(namespace, args)
    end
  end
end