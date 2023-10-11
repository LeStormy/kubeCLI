#!/usr/bin/env ruby

require_relative 'kube_client'
require_relative 'kube_commands'

if ARGV.empty?
  puts "Usage: kube [namespace] command [args]"
  puts "Available commands:"
  KubeClient::COMMANDS.each do |cmd, description|
    puts "  #{cmd}: #{description}"
  end
  exit(1)
end

namespace = ARGV.shift
namespaces_to_run = []
if namespace == 'all'
  namespaces_to_run = KubeClient::NAMESPACES
else
  namespaces_to_run << namespace
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

namespaces_to_run.each do |namespace|
  action = KubeClient::COMMANDS_MAPPING[command]
  action.call(namespace, args) if action
end

unless command && KubeClient::COMMANDS.key?(command)
  puts "Invalid command. Available commands:"
  KubeClient::COMMANDS.each do |cmd, description|
    puts "  #{cmd}: #{description}"
  end
  exit(1)
end