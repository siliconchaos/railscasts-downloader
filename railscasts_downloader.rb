#!/usr/bin/env ruby
require 'rss'

# requires axel (http://axel.alioth.debian.org/) to be installed
#   for osx use homebrew (http://mxcl.github.com/homebrew/) to install
#     sudo brew install axel

unless ENV['PATH'].split(":").any? {|f| File.exists?("#{f}/axel")}
  puts "axel not in path. Please install axel or correct path if installed."
  exit
end

puts "\nDownloading rss index"
puts "======================================================================="

rss_string = open('http://feeds.feedburner.com/railscasts').read
rss = RSS::Parser.parse(rss_string, false)
videos_urls = rss.items.map { |it| it.enclosure.url }.reverse

videos_filenames = videos_urls.map {|url| url.split('/').last }
incomplete_filenames = Dir.glob('*.mp4.st').collect{|f| f.sub(/.st$/, '')}
existing_filenames = Dir.glob('*.mp4') - incomplete_filenames
missing_filenames = videos_filenames - existing_filenames

puts "\nResuming #{incomplete_filenames.size} inclompletd videos"
puts "-----------------------------------------------------------------------"
incomplete_videos_urls = videos_urls.select { |video_url| incomplete_filenames.any? { |filename| video_url.match filename } }

incomplete_videos_urls.each do |video_url|
  filename = video_url.split('/').last
  puts "- #{filename}"
  %x(axel -q #{video_url} )
end

puts "\nDownloading #{missing_filenames.size} missing videos"
puts "-----------------------------------------------------------------------"
missing_videos_urls = videos_urls.select { |video_url| missing_filenames.any? { |filename| video_url.match filename } }

missing_videos_urls.each do |video_url|
  filename = video_url.split('/').last
  puts "- #{filename}"
  %x(axel -q #{video_url} )
end
puts "\n======================================================================="
puts 'Finished synchronization'
