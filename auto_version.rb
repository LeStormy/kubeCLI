#!/usr/bin/env ruby

require 'semantic'
require 'yaml'
require 'tempfile'

class AutoVersion
  class << self
    def write_image_version_in_manifest(manifest)
      version = Semantic::Version.new File.read("#{KubeClient::PROJECT_PATH}/version")

      new_manifest = YAML.load_file(manifest).tap do |manifest_hash|
        manifest_hash['spec']['template']['spec']['containers'].each do |container|
          container['image'] = container['image'].gsub("{{VERSION}}", version.to_s)
        end
      end
      temp_manifest = Tempfile.new('manifest')
      temp_manifest << new_manifest.to_yaml

      puts new_manifest.to_yaml

      puts temp_manifest.path
    end
  end

  def upgrade_version
    current_version = Semantic::Version.new File.read("#{KubeClient::PROJECT_PATH}/version")
    new_version = current_version.increment!(:patch)
    File.write("#{KubeClient::PROJECT_PATH}/version", new_version.to_s)
  end
end