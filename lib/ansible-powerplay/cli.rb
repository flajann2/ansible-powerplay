# -*- coding: utf-8 -*-
require 'ansible-powerplay'

include Powerplay::DSL

module Powerplay
  module Cli
    class Main < Thor
      class_option :verbose, type: :numeric, banner: '[1|2|3]', aliases: '-v', default: 0

      desc 'play [script]', 'Run the powerplay script.'
      long_desc <<-LONGDESC
        Plays a PowerPlay script. The entries in the
        script, as specified inside of a group, are run
        in parallel by default.

        if [script] is not given, it defaults to 'stack.play'
        in the current directory.
      LONGDESC
      option :tmux,      type: :numeric, aliases: '-m', banner: "[WINDOWNUMBERopt]", lazy_default: 0,
                                                        desc: ' Send output to all tmux panes in the current window, or the numeric window specified.'
      option :play,      type: :array,   aliases: ['-p', '--power'], banner: "[NAME[ NAME2...]|all]", required: true,
                                                        desc: 'Which PowerPlay playbooks (as opposed to Ansible playbooks) to specifically execute.'
      option :group,     type: :array,   aliases: '-g', banner: "[NAME[ NAME2...]|all]", default: [:all],
                                                        desc: ' Which groups to execute.'
      option :congroups, type: :boolean, aliases: '-c', desc: "[deprecated] Run the groups themselves concurrently. This option is deprecated and will be removed shortly. Use :sync or :async on your group directives instead. See docs."
      option :book,      type: :array,   aliases: '-b', banner: "[NAME[ NAME2...]|all]", default: [:all],
                                                        desc: 'Which books to execute.'
      option :dryrun,    type: :boolean, aliases: '-u', desc: "Dry run, do not actually execute."
      option :extra,     type: :array,   aliases: ['-x', '--extra-vars'],
                                                        banner: %(<BOOKNAME|all>:"key1a=value1a key2a=value2a... " [BOOKNAME2:"key1b=value1b key2b=value2b... "]), default: [],
                                                        desc: 'Pass custom parameters directly to playbooks. You may either pass parameters to all playbooks or specific ones.'
      option :tags,      type: :array,   aliases: '-t',
                                                        banner: %(<TAG1>[ TAG2 TAG3...]), 
                                                        desc: "Ansible tags to only run - mutually exclusive with --skip-tags"
      option :sktags,    type: :array,   aliases: ['--skip-tags', '-T'],
                                                        banner: %(<TAG1>[ TAG2 TAG3...]), 
                                                        desc: "Ansible tags to skip - mutually exclusive with --tags"
      def play(script = 'stack.play')
        DSL::_global[:options] = massage options
        puts "script %s " % [script] if DSL::_global[:options][:verbose] >= 1
        load script, true
        pp DSL::_global if DSL::_verbosity >= 3
        Play::Ansible::power_run
      end
      default_task :play if $PP_BASENAME == 'pp'
      
      desc 'version', 'display the version of this PowerPlay install'
      def version
        puts s_version
      end
      
      desc 'ttys', 'list all the TMUX ptys on the current window.'
      def ttys
        puts Play::Tmux::pane_ptys
      end

      no_commands do
        def massage(options)
          opt = Thor::CoreExt::HashWithIndifferentAccess.new options
          opt[:extra] = Thor::CoreExt::HashWithIndifferentAccess.new opt[:extra].map{ |s| s.split(':', 2)}.to_h
          opt[:tags] = opt[:tags].join(',') unless opt[:tags].nil?
          opt[:sktags] = opt[:sktags].join(',') unless opt[:sktags].nil?
          opt
        end
      end
    end
  end
end
 
