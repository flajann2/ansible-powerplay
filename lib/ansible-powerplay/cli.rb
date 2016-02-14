require 'ansible-powerplay'

include Powerplay::DSL

module Powerplay
  module Cli
    class Main < Thor
      class_option :verbose, type: :numeric, banner: '[1|2|3]', aliases: '-v'

      desc 'play <script>', 'Run the powerplay script.'
      long_desc <<-LONGDESC
        Plays a powerscript. The entries in the
        script, as specified, are run in parallel
        by default. 
      LONGDESC
      option :tmux, type: :boolean, aliases: '-m', banner: "send output to all tmux panes in the current window"
      def play(script)
        puts "script %s " % [script]
        load script, true
      end
    end
  end
end
