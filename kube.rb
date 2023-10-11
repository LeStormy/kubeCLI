#!/usr/bin/env ruby

require_relative 'kube_client'
require_relative 'kube_commands'

if ARGV.empty?
  puts "Usage: kube [cluster] command [args]"
  puts "Available commands:"
  KubeClient::COMMANDS.each do |cmd, description|
    puts "  #{cmd}: #{description}"
  end
  exit(1)
end

cluster = ARGV.shift
clusters_to_run = []
if cluster == 'all'
  clusters_to_run = KubeClient::CLUSTERS
else
  clusters_to_run << cluster
end

command = ARGV.shift
unless command && KubeClient::COMMANDS.key?(command)
  puts "Invalid command. Available commands:"
  COMMANDS.each do |cmd, description|
    puts "  #{cmd}: #{description}"
  end
  exit(1)
end

args = ARGV.join(" ")

clusters_to_run.each do |cluster|
  action = KubeClient::COMMANDS_MAPPING[command]
  action.call(cluster, args) if action
end

unless command && KubeClient::COMMANDS.key?(command)
  puts "Invalid command. Available commands:"
  KubeClient::COMMANDS.each do |cmd, description|
    puts "  #{cmd}: #{description}"
  end
  exit(1)
end