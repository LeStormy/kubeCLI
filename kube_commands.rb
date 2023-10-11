#!/usr/bin/env ruby

require_relative 'kube_client'

class KubeCommands
  class << self
    def apply(cluster, manifest)
      system("#{kubectl(cluster)} apply -f #{full_config_path}/#{manifest}.yml")
    end

    def scale(cluster, args)
      manifest, replicas = args
      system("#{kubectl(cluster)} scale -f #{full_config_path}/#{manifest}.yml --replicas=#{replicas}")
    end

    def delete
      system("#{kubectl(cluster)} delete -f #{full_config_path}/#{manifest}.yml")
    end

    def rollout

    end

    def setup(cluster)
      # apply NGINX Ingress Controller
      system("#{kubectl(cluster)} apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml")
      # apply Cert-Manager
      system("#{kubectl(cluster)} apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.yaml")
      # create regcred secret
      system("#{kubectl(cluster)} create secret generic regcred --from-file=.dockerconfigjson=#{full_config_path}/secrets/docker-config.json --type=kubernetes.io/dockerconfigjson")
      # apply rails secret
      system("#{kubectl(cluster)} apply -f #{full_config_path}/secrets/rails-secrets.yml")
      # apply config map
      system("#{kubectl(cluster)} apply -f #{full_config_path}/config-map.yml") 
      # apply postgres
      system("#{kubectl(cluster)} apply -f #{full_config_path}/postgres.yml") 
      # apply postgres service
      system("#{kubectl(cluster)} apply -f #{full_config_path}/postgres-service.yml")
      # apply redis
      system("#{kubectl(cluster)} apply -f #{full_config_path}/redis.yml")
      # apply redis service
      system("#{kubectl(cluster)} apply -f #{full_config_path}/redis-service.yml")
      # apply Ingress Resource
      system("#{kubectl(cluster)} apply -f #{full_config_path}/ingress.yml")
      # apply ClusterIssuer
      system("#{kubectl(cluster)} apply -f #{full_config_path}/cluster-issuer.yml")  
      # apply Certficate
      system("#{kubectl(cluster)} apply -f #{full_config_path}/certificate.yml")  
      # apply web deployment
      system("#{kubectl(cluster)} apply -f #{full_config_path}/web-deployment.yml")
      # apply worker deployment
      system("#{kubectl(cluster)} apply -f #{full_config_path}/worker-deployment.yml")
      # apply web service
      system("#{kubectl(cluster)} apply -f #{full_config_path}/web-service.yml")
      # apply terminal
      system("#{kubectl(cluster)} apply -f #{full_config_path}/terminal.yml")
      # apply initializer
      system("#{kubectl(cluster)} apply -f #{full_config_path}/initializer.yml")
      # apply postgres backup cron job
  
      # apply applicative cron jobs
  
      # monitoring stack
  
      #
      # Get IP from Ingress Controller
      # set DNS with IP
    end

    def exec(cluster, args)
      system("#{kubectl(cluster)} exec -it pod/terminal -- #{args.join(" ")}")
    end

    def dockerize_app(project_path, docker_hub_uname, app, version)
      system("cd #{project_path}")
      system("docker buildx build --platform linux/amd64 -t #{docker_hub_uname}/#{app}:#{version} . --build-arg RAILS_MASTER_KEY=`cat config/credentials/production.key`")
      system("docker push #{docker_hub_uname}/#{app}:#{version}")
    end

    def full_config_path
      "#{KubeClient::PROJECT_PATH}/#{KubeClient::CONFIG_PATH}"
    end

    def kubectl(cluster)
      "KUBECONFIG=#{KubeClient::HOME_PATH}/.kube/#{cluster}.conf kubectl"
    end
  end
end