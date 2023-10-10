#!/usr/bin/env ruby

require './kube_client.rb'

class KubeCommands
  FULL_CONFIG_PATH = "#{KubeClient::PROJECT_PATH}/#{KubeClient::CONFIG_PATH}"

  class << self
    def apply(namespace, manifest)
      system("kubectl apply -n #{namespace} -f #{FULL_CONFIG_PATH}/#{manifest}.yml")
    end

    def scale(namespace, args)
      manifest, replicas = args
      system("kubectl scale -n #{namespace} -f #{FULL_CONFIG_PATH}/#{manifest}.yml --replicas=#{replicas}")
    end

    def delete
      system("kubectl delete -n #{namespace} -f #{FULL_CONFIG_PATH}/#{manifest}.yml")
    end

    def rollout

    end

    def setup(namespace)
      system("kubectl create namespace #{namespace}")
      system("kubectl create secret generic regcred --from-file=.dockerconfigjson=#{FULL_CONFIG_PATH}/secrets/docker-config.json --type=kubernetes.io/dockerconfigjson -n #{namespace}")
      system("kubectl apply -n #{namespace} -f #{FULL_CONFIG_PATH}/secrets/rails-secrets.yml")
      system("kubectl apply -n #{namespace} -f #{FULL_CONFIG_PATH}/postgres.yml")
      system("kubectl apply -n #{namespace} -f #{FULL_CONFIG_PATH}/postgres.yml")
      system("kubectl apply -n #{namespace} -f #{FULL_CONFIG_PATH}/postgres-service.yml")
      system("kubectl apply -n #{namespace} -f #{FULL_CONFIG_PATH}/redis.yml")
      system("kubectl apply -n #{namespace} -f #{FULL_CONFIG_PATH}/redis-service.yml")
      system("kubectl apply -n #{namespace} -f #{FULL_CONFIG_PATH}/web-deployment.yml")
      system("kubectl apply -n #{namespace} -f #{FULL_CONFIG_PATH}/worker-deployment.yml")
      system("kubectl apply -n #{namespace} -f #{FULL_CONFIG_PATH}/load-balancer.yml")
      system("kubectl apply -n #{namespace} -f #{FULL_CONFIG_PATH}/terminal.yml")
      system("kubectl apply -n #{namespace} -f #{FULL_CONFIG_PATH}/initializer.yml")
    end

    def exec(namespace, args)
      system("kubectl exec -it -n #{namespace} pod/terminal -- #{args.join(" ")}")
    end

    def dockerize_app(project_path, docker_hub_uname, app, version)
      system("cd #{project_path}")
      system("docker buildx build --platform linux/amd64 -t #{docker_hub_uname}/#{app}:#{version} . --build-arg RAILS_MASTER_KEY=`cat config/credentials/production.key`")
      system("docker push #{docker_hub_uname}/#{app}:#{version}")
    end
  end
end