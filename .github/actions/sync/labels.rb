#!/usr/bin/env ruby

require 'octokit'

CASK_REPOS = [
  'Homebrew/homebrew-cask-drivers',
  'Homebrew/homebrew-cask-eid',
  'Homebrew/homebrew-cask-fonts',
  'Homebrew/homebrew-cask-versions',
].freeze

github = Octokit::Client.new(access_token: ENV.fetch('HOMEBREW_GITHUB_API_TOKEN'))

main_labels = github.labels('Homebrew/homebrew-cask').freeze

CASK_REPOS.each do |repo|
  puts "#{repo}:"

  labels = github.labels(repo)

  deleted_labels = labels.select { |label| main_labels.none? { |main_label| main_label.name == label.name } }
  modified_labels = labels.select { |label| main_labels.any? { |main_label| main_label.name == label.name } }
  added_labels = main_labels.select { |main_label| (deleted_labels + modified_labels).none? { |label| main_label.name == label.name }  }

  added_labels.each do |added_label|
    puts "Adding label “#{added_label.name}”…"
    github.add_label(repo, added_label.name, color: added_label.color)
  end

  modified_labels.each do |modified_labels|
    puts "Updating label “#{modified_labels.name}”…"
    github.update_label(repo, modified_labels.name, color: modified_labels.color)
  end

  deleted_labels.each do |deleted_label|
    puts "Deleting label “#{deleted_label.name}”…"
    github.delete_label!(repo, deleted_label.name)
  end

  puts
end
