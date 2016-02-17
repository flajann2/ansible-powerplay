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
      option :play, type: :string, banner: "[NAME|all] Which playbook shelf", required: true
      option :group, type: :string, banner: "[NAME|all] Which group to execute", default: "all"
      option :book, type: :string, banner: "[NAME|all] Which book to execute", default: "all"
      option :dryrun, type: :boolean, banner: "Dry run, do not actually execute."
      def play(script)
        DSL::_global[:options] = options
        puts "script %s " % [script] if DSL::_global[:options][:verbose] >= 1
        load script, true
        pp DSL::_global if DSL::_global[:options][:verbose] >= 3
        Play::Ansible::power_run
      end
      
      desc 'ttys', 'list all the TMUX ptys on the current window.'
      def ttys
        puts Play::Tmux::pane_ptys
      end
    end
  end
end
