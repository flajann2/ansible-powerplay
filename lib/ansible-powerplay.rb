require 'thor'
require 'semver'
require 'pp'
require 'open3'
require 'thread'
require 'colorize'
require 'queue_ding'

require_relative 'ansible-powerplay/powerplay'
require_relative 'ansible-powerplay/dsl'

include QueueDing

def s_version
  SemVer.find.format "v%M.%m.%p%s"
end
puts $PP_BASENAME
