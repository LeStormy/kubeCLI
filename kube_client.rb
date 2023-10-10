#!/usr/bin/env ruby

require './kube_commands.rb'

class KubeClient
  DOCKER_HUB_UNAME = 'lestormy'
  PROJECT_PATH = '/Users/stormy/Work/mooveo-backend'
  CONFIG_PATH = 'config/kube/infrastructure'
  APP = 'klara'
  VERSION = '1.0'

  COMMANDS = {
    'migrate' => 'Apply a migration manifest',
    'deploy' => 'Apply a deployment manifest',
    'delete' => 'Delete a kubectl object [args: manifest name]'
    'scale' => 'Scale a deployment [arg: manifest name]',
    'build-setup' => 'Build a new docker image and setup a new namespace with an app stack',
    'setup' => 'Setup a new namespace with an app stack',
    'console' => 'Connect to a shell on a pod and run bin/rails c',
    'add-job' => 'Apply a cron job manifest [arg: manifest name]',
    'delete-job' => 'Delete a cron job [arg: manifest name]',
    'exec' => 'Execute a command inside a pod [arg: command to run]'
  }

  COMMANDS_MAPPING = {
    'migrate' => -> (namespace, args) { migrate(namespace) },
    'deploy' => -> (namespace, args) { deploy(namespace) },
    'delete' => -> (namespace, args) { delete(namespace, args) },
    'scale' => -> (namespace, args) { scale(namespace, args) },
    'build-setup' => -> (namespace, args) { build_setup(namespace) },
    'setup' => -> (namespace, args) { setup(namespace) },
    'console' => -> (namespace, args) { console(namespace) },
    'add-job' => -> (namespace, args) { add_job(namespace, args) },
    'delete-job' => -> (namespace, args) { delete_job(namespace, args) },
    'exec' => -> (namespace, args) { exec(namespace, args) }
  }

  NAMESPACES = ["default", "app", "app2", "app3"]

  class << self
    def deploy(namespace)
      if yes_no_prompt
        KubeCommands.dockerize_app(PROJECT_PATH, DOCKER_HUB_UNAME, APP, VERSION)
        KubeCommands.apply(namespace, "web-deployment")
        KubeCommands.apply(namespace, "worker-deployment")
      end
    end

    def delete(namespace, args)
      if yes_no_prompt
        KubeCommands.delete(namespace, args.first)
      end
    end

    def migrate(namespace)
      KubeCommands.apply(namespace, "migrate")
    end

    def scale(namespace, args)
      KubeCommands.scale(namespace, args)
    end

    def build_setup(namespace)
      if yes_no_prompt
        KubeCommands.dockerize_app(PROJECT_PATH, DOCKER_HUB_UNAME, APP, VERSION)
        KubeCommands.setup(namespace)
      end
    end

    def setup(namespace)
      if yes_no_prompt
        KubeCommands.setup(namespace)
      end
    end

    def add_job(namespace, args)
      KubeCommands.apply(namespace, args.first)
    end

    def delete_job(namespace, args)
      if yes_no_prompt
        KubeCommands.delete(namespace, args.first)
      end
    end

    def console(namespace)
      KubeCommands.exec(namespace, ["bin/rails", "c"])
    end

    def exec(namespace, args)
      KubeCommands.exec(namespace, args)
    end

    private

    def yes_no_prompt
      loop do
        print "Do you want to continue? (y/N): "
        input = gets.chomp.downcase
    
        case input
        when "y"
          return true
        else
          puts false
        end
      end
    end    
  end
end