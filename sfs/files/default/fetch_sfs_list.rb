#!/usr/bin/env ruby

require 'rubygems'
require 'logger'
require 'choice'

Choice.options do
  header ''
  header 'Specific options: '

  option :url do
    short '-u'
    long '--url'
    desc "Url to download file (default \"http://www.stopforumspam.com/downloads/listed_ip_30.zip\")
"
    default "http://www.stopforumspam.com/downloads/listed_ip_30.zip"
  end

  option :tmpdir do
    short '-t'
    long '--tmp-dir'
    desc "Temporary directory (default \"/var/tmp\")"
    default "/var/tmp"
  end

  option :outputfile do
    short '-o'
    long '--output-filename'
    desc "Output filename (default \"etc/nginx/conf.d/sfs.deny.conf\")"
    default '/etc/nginx/conf.d/sfs.deny.conf'
  end
end

choices = Choice.choices

log = Logger.new(STDOUT)
log.level = Logger::INFO

begin

  filename = choices[:url].match(/.+\/(.+\.zip)/)[1]
  tmpfile = "#{choices[:tmpdir]}/#{filename}"
  txttmpfile = tmpfile.gsub(".zip",".txt")

  Dir.chdir choices[:tmpdir]

  log.debug("Deleting old files")
  File.delete tmpfile if File.exists?(tmpfile)
  File.delete txttmpfile if File.exists?(txttmpfile)

  log.debug("Fetching list from #{choices[:url]}")
  system("wget #{choices[:url]}")
  raise "wget for #{choices[:url]} failed!" if !$?.success?

  log.debug("Unzipping #{tmpfile}")
  system("unzip #{tmpfile}")
  raise "unzip of #{tmpfile} failed!" if !$?.success?

  log.debug("Creating new file #{choices[:outputfile]}")
  system("cat #{txttmpfile} | sed \'s/255\\.255\\.255\\.255,//g\' | sed -E \'s/([0-9.]*),?/deny \\1;/g\' > #{choices[:outputfile]}")
  raise "creating new file #{choices[:outputfile]} failed!" if !$?.success?

  log.debug("done!")

rescue Exception => e
  log.error(e.message)
  exit 1
end

exit 0

