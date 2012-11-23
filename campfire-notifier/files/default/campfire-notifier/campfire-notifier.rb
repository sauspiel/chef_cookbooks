#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"
require "tinder"
require "choice"

Choice.options do
  header ''
  header 'Specific options: '

  option :domain do
    short '-d'
    long '--domain'
    desc 'Domain name'
    default ''
  end

  option :room do
    short '-r'
    long '--room'
    desc 'Room name'
    default ''
  end

  option :message do
    short '-m'
    long '--message'
    desc 'Message'
    default ''
  end

  option :paste do
    short '-p'
    long '--paste'
    desc 'Message to paste'
    default ''
  end

  option :token do
    short '-t'
    long '--token'
    desc 'Campfire API token'
    default ''
  end

  separator ''

  option :help do
    short '-h'
    long '--help'
    desc 'Show this message'
  end
end

choices = Choice.choices

campfire = Tinder::Campfire.new choices[:domain], :token => choices[:token]

room = campfire.find_room_by_name choices[:room]
room.speak choices[:message]
room.paste choices[:paste] if !choices[:paste].empty?
