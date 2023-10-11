#!/usr/bin/env ruby

require_relative 'kube_client'

class KubeCommands
  class << self
    def apply(namespace, manifest)
      system("kubectl apply -n #{namespace} -f #{full_config_path}/#{manifest}.yml")
    end

    def scale(namespace, args)
      manifest, replicas = args
      system("kubectl scale -n #{namespace} -f #{full_config_path}/#{manifest}.yml --replicas=#{replicas}")
    end

    def delete
      system("kubectl delete -n #{namespace} -f #{full_config_path}/#{manifest}.yml")
    end

    def rollout

    end

    def setup(namespace)
      # apply NGINX Ingress Controller
      system("kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml")

      # create namespace
      # create regcred secret
      # apply rails secret
      # apply config map
      # apply postgres
      # apply postgres service
      # apply redis
      # apply redis service
      # apply Ingress Resource
      # apply Certficate
      # apply web deployment
      # apply worker deployment
      # apply web service
      # apply terminal
      # apply initializer
      # apply postgres backup cron job
      # apply applicative cron jobs
      # monitoring stack
      #
      # Get IP from Ingress Controller
      # set DNS with IP
      

      system("kubectl create namespace #{namespace}")
      system("kubectl create secret generic regcred --from-file=.dockerconfigjson=#{full_config_path}/secrets/docker-config.json --type=kubernetes.io/dockerconfigjson -n #{namespace}")
      system("kubectl apply -n #{namespace} -f #{full_config_path}/secrets/rails-secrets.yml")
      system("kubectl apply -n #{namespace} -f #{full_config_path}/postgres.yml")
      system("kubectl apply -n #{namespace} -f #{full_config_path}/postgres-service.yml")
      system("kubectl apply -n #{namespace} -f #{full_config_path}/redis.yml")
      system("kubectl apply -n #{namespace} -f #{full_config_path}/redis-service.yml")
      system("kubectl apply -n #{namespace} -f #{full_config_path}/web-deployment.yml")
      system("kubectl apply -n #{namespace} -f #{full_config_path}/worker-deployment.yml")
      system("kubectl apply -n #{namespace} -f #{full_config_path}/load-balancer.yml")
      system("kubectl apply -n #{namespace} -f #{full_config_path}/terminal.yml")
      system("kubectl apply -n #{namespace} -f #{full_config_path}/initializer.yml")
    end

    def exec(namespace, args)
      system("kubectl exec -it -n #{namespace} pod/terminal -- #{args.join(" ")}")
    end

    def dockerize_app(project_path, docker_hub_uname, app, version)
      system("cd #{project_path}")
      system("docker buildx build --platform linux/amd64 -t #{docker_hub_uname}/#{app}:#{version} . --build-arg RAILS_MASTER_KEY=`cat config/credentials/production.key`")
      system("docker push #{docker_hub_uname}/#{app}:#{version}")
    end

    def full_config_path
      "#{KubeClient::PROJECT_PATH}/#{KubeClient::CONFIG_PATH}"
    end
  end
end