#!/usr/bin/env ruby

class KubeCommands
  class << self
    def apply(namespace, manifest)
      system("kubectl apply -n #{namespace} -f #{manifest}.yml")
    end

    def scale

    end

    def delete

    end

    def rollout

    end

    def setup(namespace)
      system("kubectl apply -n #{namespace} -f postgres.yml")
      system("kubectl apply -n #{namespace} -f postgres-service.yml")
      system("kubectl apply -n #{namespace} -f redis-service.yml")
      system("kubectl apply -n #{namespace} -f redis-service.yml")
      system("kubectl apply -n #{namespace} -f web-deployment.yml")
      system("kubectl apply -n #{namespace} -f worker-deployment.yml")
      system("kubectl apply -n #{namespace} -f load-balancer.yml")
      system("kubectl apply -n #{namespace} -f terminal.yml")
      
      ## schema load, migrate
    end

    def exec(namespace, command)
      system("kubectl exec -it -n #{namespace} pod/terminal -- #{command}")
    end
  end
end