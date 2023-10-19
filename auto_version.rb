#!/usr/bin/env ruby

require 'semantic'
require 'yaml'
require 'fileutils'

class AutoVersion
  class << self
    def write_image_version_in_manifest(manifest)
      version = Semantic::Version.new File.read("#{KubeClient::PROJECT_PATH}/version")
      manifest_path = manifest.split("/").last

      new_manifest = YAML.load_file(manifest).tap do |manifest_hash|
        if manifest_hash['kind'] == 'Deployment' || manifest_hash['kind'] == 'Job'
          manifest_hash['spec']['template']['spec']['containers'].each do |container|
            container['image'] = container['image'].gsub("{{VERSION}}", version.to_s)
          end
        end
        if manifest_hash['kind'] == 'Pod'
          manifest_hash['spec']['containers'].each do |container|
            container['image'] = container['image'].gsub("{{VERSION}}", version.to_s)
          end
        end
      end
      temp_manifest = File.new("./tmp/#{manifest_path}", "w")
      temp_manifest << new_manifest.to_yaml
      temp_manifest.close

      temp_manifest
    end

    def upgrade_version
      current_version = Semantic::Version.new File.read("#{KubeClient::PROJECT_PATH}/version")
      new_version = current_version.increment!(:patch)
      File.write("#{KubeClient::PROJECT_PATH}/version", new_version.to_s)
    end

    def clear_temp_folder
      system('rm -rf ./tmp/*')
    end
  end
end