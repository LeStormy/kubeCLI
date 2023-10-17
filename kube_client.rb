#!/usr/bin/env ruby

require_relative 'kube_commands'
require_relative 'yaml_handler'
require 'colorize'

class KubeClient
  DOCKER_HUB_UNAME = 'lestormy'
  HOME_PATH = '/Users/stormy'
  PROJECT_PATH = '/Users/stormy/Work/mooveo-backend'
  CONFIG_PATH = 'config/kube/infrastructure'
  APP = 'klara'

  COMMANDS = {
    'colo' => 'Apply a migration manifest',
    'migrate' => 'Apply a migration manifest',
    'deploy' => 'Apply a deployment manifest',
    'delete' => 'Delete a kubectl object [args: manifest name]',
    'scale' => 'Scale a deployment [arg: manifest name]',
    'build-setup' => 'Build a new docker image and setup a new cluster with an app stack',
    'setup' => 'Setup a new cluster with an app stack',
    'console' => 'Connect to a shell on a pod and run bin/rails c',
    'add-job' => 'Apply a cron job manifest [arg: manifest name]',
    'delete-job' => 'Delete a cron job [arg: manifest name]',
    'destroy!' => 'Destroy an app stack',
    'exec' => 'Execute a command inside a pod [arg: command to run]'
  }

  COMMANDS_MAPPING = {
    'colo' => -> (cluster, args) { test_colorize },
    'migrate' => -> (cluster, args) { migrate(cluster) },
    'deploy' => -> (cluster, args) { deploy(cluster) },
    'delete' => -> (cluster, args) { delete(cluster, args) },
    'scale' => -> (cluster, args) { scale(cluster, args) },
    'build-setup' => -> (cluster, args) { build_setup(cluster) },
    'setup' => -> (cluster, args) { setup(cluster) },
    'console' => -> (cluster, args) { console(cluster) },
    'add-job' => -> (cluster, args) { add_job(cluster, args) },
    'delete-job' => -> (cluster, args) { delete_job(cluster, args) },
    'destroy!' => -> (cluster, args) { destroy(cluster) },
    'exec' => -> (cluster, args) { exec(cluster, args) }
  }

  CLUSTERS = ["app", "app2", "app3"]

  class << self
    def test_colorize
      puts "This is a test".green.bold
      AutoVersion.write_image_version_in_manifest("#{PROJECT_PATH}/#{CONFIG_PATH}/web-deployment.yml")
    end

    def deploy(cluster)
      if yes_no_prompt
        AutoVersion.upgrade_version
        KubeCommands.dockerize_app(PROJECT_PATH, DOCKER_HUB_UNAME, APP)
        KubeCommands.apply(cluster, "web-deployment")
        KubeCommands.apply(cluster, "worker-deployment")
      end
    end

    def delete(cluster, args)
      if yes_no_prompt
        KubeCommands.delete(cluster, args.first)
      end
    end

    def migrate(cluster)
      KubeCommands.apply(cluster, "migrate")
    end

    def scale(cluster, args)
      KubeCommands.scale(cluster, args)
    end

    def build_setup(cluster)
      if yes_no_prompt
        AutoVersion.upgrade_version
        KubeCommands.dockerize_app(PROJECT_PATH, DOCKER_HUB_UNAME, APP)
        KubeCommands.setup(cluster)
      end
    end

    def setup(cluster)
      if yes_no_prompt
        KubeCommands.setup(cluster)
      end
    end

    def destroy(cluster)
      if yes_no_prompt
        KubeCommands.destroy(cluster)
      end
    end

    def add_job(cluster, args)
      KubeCommands.apply(cluster, args.first)
    end

    def delete_job(cluster, args)
      if yes_no_prompt
        KubeCommands.delete(cluster, args.first)
      end
    end

    def console(cluster)
      KubeCommands.exec(cluster, ["bin/rails", "c"])
    end

    def exec(cluster, args)
      KubeCommands.exec(cluster, args)
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