#!/usr/bin/env ruby

require_relative 'kube_client'
require 'colorize'

class KubeCommands
  class << self
    def apply(cluster, manifest)
      updated_file = AutoVersion.write_image_version_in_manifest("#{full_config_path}/#{manifest}.yml")
      system("#{kubectl(cluster)} apply -f #{updated_file.path}")
    end

    def scale(cluster, args)
      manifest, replicas = args
      system("#{kubectl(cluster)} scale -f #{full_config_path}/#{manifest}.yml --replicas=#{replicas}")
    end

    def delete
      updated_file = AutoVersion.write_image_version_in_manifest("#{full_config_path}/#{manifest}.yml")
      system("#{kubectl(cluster)} delete -f #{updated_file.path}")
    end

    def rollout

    end

    def setup(cluster)
      
      info_string "Downloading and creating NGINX Ingress Controller..."
      system("#{kubectl(cluster)} apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml")
      
      info_string "Downloading and creating Cert Manager..."
      system("#{kubectl(cluster)} apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.yaml")
     
     
     
      
      info_string "Downloading and creating Postgres Operator..."
      
      
      
      
      
      info_string "Creating regcred secret..."
      system("#{kubectl(cluster)} create secret generic regcred --from-file=.dockerconfigjson=#{full_config_path}/secrets/docker-config.json --type=kubernetes.io/dockerconfigjson")
      
      info_string "Creating Rails secrets..."
      apply("secrets/rails-secrets.yml")
      
      info_string "Creating Postgres secrets..."
      apply("secrets/postgres-secrets.yml")
      
      info_string "Creating TLS secrets..."
      system("#{kubectl(cluster)} create secret tls tls-secret \
        --key /Users/stormy/Work/certif/klara.key \
        --cert /Users/stormy/Work/certif/klara.crt")
      
        info_string "Applying config map..."
      apply("config-map.yml") 
      
      info_string "Applying KubeGres configuration..."
      apply("kubegres.yml")
      
      info_string "Creating Redis pod..."
      apply("redis.yml")
      
      info_string "Creating Redis service..."
      apply("redis-service.yml")
      
      info_string "Creating Ingress Resource..."
      apply("ingress.yml")
      
      info_string "Creating Cluster Issuer..."
      apply("cluster-issuer.yml")  
      
      info_string "Applying Certificate configuration..."
      apply("certificate.yml")  
      
      info_string "Deploying Web Application (web pods)..."
      apply("web-deployment.yml")
      
      info_string "Deploying Web Application (worker pods)..."
      apply("worker-deployment.yml")
      
      info_string "Deploying Web Service..."
      apply("web-service.yml")
      
      info_string "Creating Application Terminal pod..."
      apply("terminal.yml")
      
      info_string "Running DB Initializer Script..."
      apply("db-initializer.yml")
      system("#{kubectl(cluster)} wait --for=condition=complete job/db-initializer")
      
      info_string "Running DB Loader Script..."
      apply("db-loader.yml")
      system("#{kubectl(cluster)} wait --for=condition=complete job/db-loader")
      
      info_string "Running DB Migrate Script..."
      apply("db-migrate.yml")
      system("#{kubectl(cluster)} wait --for=condition=complete job/db-migrate")
      # apply postgres backup cron job
  
      # apply applicative cron jobs
  
      # monitoring stack
  
      # Get IP from Ingress Controller
      # set DNS with IP
    end

    def destroy(cluster)
      system("#{kubectl(cluster)} delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml")
      system("#{kubectl(cluster)} delete -f https://raw.githubusercontent.com/reactive-tech/kubegres/v1.16/kubegres.yaml")
      system("#{kubectl(cluster)} delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.yaml")
      system("#{kubectl(cluster)} delete secret regcred")
      delete("/secrets/rails-secrets.yml")
      delete("/secrets/postgres-secrets.yml")
      delete("/config-map.yml") 
      delete("/redis.yml")
      delete("/redis-service.yml")
      delete("/ingress.yml")
      delete("/cluster-issuer.yml")  
      delete("/certificate.yml")  
      delete("/web-deployment.yml")
      delete("/worker-deployment.yml")
      delete("/web-service.yml")
      delete("/terminal.yml")
      delete("/initializer.yml")
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

    def info_string(str)
      puts str.green.bold
    end
  end
end