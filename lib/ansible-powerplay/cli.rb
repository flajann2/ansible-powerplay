require 'ansible-powerplay'

include Powerplay::DSL

module Powerplay
  module Cli
    class Main < Thor
      class_option :verbose, type: :numeric, banner: '[1|2|3]', aliases: '-v', default: 0

      desc 'play <script>', 'Run the powerplay script.'
      long_desc <<-LONGDESC
        Plays a powerscript. The entries in the
        script, as specified, are run in parallel
        by default. 
      LONGDESC
      option :tmux, type: :boolean, aliases: '-m', banner: "send output to all tmux panes in the current window"
      option :play, type: :string, banner: "Which playbook shelf"
      option :dryrun, type: :boolean, banner: "Dry run, do not actually execute."
      def play(script)
        puts "script %s " % [script]
        DSL::_global[:options] = options
        load script, true
        pp DSL::_global if DSL::_global[:options][:verbose] >= 3
      end
      
      desc 'ttys', 'list all the TMUX ptys on the current window.'
      def ttys
        puts Play::Tmux::get_pane_ptys
      end
    end
  end
end
