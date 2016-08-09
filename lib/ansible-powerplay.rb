require 'thor'
require 'semver'
require 'pp'
require 'open3'
require 'thread'
require 'colorize'
require 'queue_ding'
require 'awesome_print'

def s_version
  SemVer.find.format "v%M.%m.%p%s"
end

include QueueDing

require_relative 'ansible-powerplay/powerplay'
require_relative 'ansible-powerplay/dsl'
require_relative 'ansible-powerplay/cli'

