#!/usr/bin/env ruby

require_relative 'kube_client'
require 'colorize'

class KubeCommands
  class << self
    def apply(cluster, manifest)
      updated_file = AutoVersion.write_image_version_in_manifest("#{full_config_path}/#{manifest}")
      result = system("#{kubectl(cluster)} apply -f #{updated_file.path}")
      if !result
        warning_string "Error while applying #{manifest}"
      end
    end

    def scale(cluster, args)
      manifest, replicas = args
      system("#{kubectl(cluster)} scale -f #{full_config_path}/#{manifest}.yml --replicas=#{replicas}")
    end

    def delete(cluster, manifest)
      updated_file = AutoVersion.write_image_version_in_manifest("#{full_config_path}/#{manifest}")
      system("#{kubectl(cluster)} delete -f #{updated_file.path}")
    end

    def rollout

    end

    def setup(cluster)
      info_string "Setting up cluster #{cluster}..."
      system"#{kubectl(cluster)} create configmap clusterdata --from-literal=cluster_name=#{cluster}"
      
      info_string "Downloading and creating NGINX Ingress Controller..."
      system("#{kubectl(cluster)} apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml")
      
      info_string "Downloading and creating Cert Manager..."
      system("#{kubectl(cluster)} apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.yaml")
     
      info_string "Waiting for Cert Manager API to be available..."
      system("cmctl check api --wait=2m")
      


      # info_string "Downloading and creating Postgres Operator..."
      
      
      
      info_string "Creating regcred secret..."
      system("#{kubectl(cluster)} create secret generic regcred --from-file=.dockerconfigjson=#{full_config_path}/secrets/docker-config.json --type=kubernetes.io/dockerconfigjson")
      
      info_string "Creating Rails secrets..."
      apply(cluster, "secrets/rails-secrets.yml")
      
      info_string "Creating Postgres secrets..."
      apply(cluster, "secrets/postgres-secrets.yml")
      
      info_string "Creating TLS secret..."
      result = system("#{kubectl(cluster)} create secret tls tls-secret \
        --key /Users/stormy/Work/certif/klara.key \
        --cert /Users/stormy/Work/certif/klara.crt")
      
      # info_string "Applying config map..."
      # apply(cluster, "config-map.yml") 

      info_string "Creating Postgres pod..."
      apply(cluster, "postgres.yml")
      
      info_string "Creating Postgres service..."
      apply(cluster, "postgres-service.yml")
      
      info_string "Creating Redis pod..."
      apply(cluster, "redis.yml")
      
      info_string "Creating Redis service..."
      apply(cluster, "redis-service.yml")
      
      info_string "Creating Ingress Resource..."
      apply(cluster, "ingress.yml")
      
      info_string "Creating Cluster Issuer..."
      apply(cluster, "cluster-issuer.yml")  
      
      info_string "Applying Certificate configuration..."
      apply(cluster, "certificate.yml")  
      
      info_string "Deploying Web Application (web pods)..."
      apply(cluster, "web-deployment.yml")
      
      info_string "Deploying Web Application (worker pods)..."
      apply(cluster, "worker-deployment.yml")
      
      info_string "Deploying Web Service..."
      apply(cluster, "web-service.yml")
      
      info_string "Creating Application Terminal pod..."
      apply(cluster, "terminal.yml")
      
      info_string "Running DB Loader Script..."
      apply(cluster, "db-loader.yml")
      system("#{kubectl(cluster)} wait --timeout=5m --for=condition=complete job/db-loader")
      
      info_string "Running DB Migrate Script..."
      apply(cluster, "db-migrate.yml")
      system("#{kubectl(cluster)} wait --timeout=5m --for=condition=complete job/db-migrate")
   
      # apply postgres backup cron job
  
      # apply applicative cron jobs
  
      # monitoring stack
  
      blue_string "Your application is now deployed"
      blue_string "Get IP from NGINX Ingress Controller and set DNS with IP"
    end

    def destroy(cluster)
      system("#{kubectl(cluster)} delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml")
      system("#{kubectl(cluster)} delete -f https://raw.githubusercontent.com/reactive-tech/kubegres/v1.16/kubegres.yaml")
      system("#{kubectl(cluster)} delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.yaml")
      system("#{kubectl(cluster)} delete secret regcred")
      system("#{kubectl(cluster)} delete secret tls-secret")
      delete(cluster, "secrets/rails-secrets.yml")
      delete(cluster, "secrets/postgres-secrets.yml")
      # delete(cluster, "config-map.yml") 
      delete(cluster, "postgres.yml")
      delete(cluster, "postgres-service.yml")
      delete(cluster, "redis.yml")
      delete(cluster, "redis-service.yml")
      delete(cluster, "ingress.yml")
      delete(cluster, "cluster-issuer.yml")  
      delete(cluster, "certificate.yml")  
      delete(cluster, "web-deployment.yml")
      delete(cluster, "worker-deployment.yml")
      delete(cluster, "web-service.yml")
      delete(cluster, "terminal.yml")
      delete(cluster, "db-loader.yml")
      delete(cluster, "db-migrate.yml")
    end

    def exec(cluster, args)
      system("#{kubectl(cluster)} exec -it pod/terminal -- #{args.join(" ")}")
    end

    def dockerize_app(project_path, docker_hub_uname, app)
      version = File.read("#{project_path}/version")
      Dir.chdir(project_path) do
        system("docker buildx build --platform linux/amd64 -t \
          #{docker_hub_uname}/#{app}:#{version} . \
          --build-arg RAILS_MASTER_KEY=`cat config/credentials/production.key`
        ")
        system("docker push #{docker_hub_uname}/#{app}:#{version}")
      end
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

    def warning_string(str)
      puts str.yellow.bold
    end

    def blue_string(str)
      puts str.cyan.bold
    end
  end
end