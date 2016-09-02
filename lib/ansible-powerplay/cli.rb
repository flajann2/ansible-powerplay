# -*- coding: utf-8 -*-
require 'ansible-powerplay'

include Powerplay::DSL

module Powerplay
  module Cli
    class Main < Thor
      class_option :verbose, type: :numeric, banner: '[1|2|3|4]', aliases: '-v', default: 0

      desc 'play [script]', 'Run the powerplay script.'
      long_desc <<-LONGDESC
        Plays a PowerPlay script. The entries in the
        script, as specified inside of a group, are run
        in parallel by default.

        if [script] is not given, it defaults to 'stack.play'
        in the current directory.
      LONGDESC
      option :tmux,      type: :string, aliases: '-m',  banner: "[WINDOWNUMBERopt[:PANENUMBER[,PANENUMBER...]]]", lazy_default: "0",
                                                        desc: <<-LONGDESC

Send output to all tmux panes in the current window, or the numeric
window specified. Additionally, you can precisely specify pane indices,
as are shown by the "<tmux-key> q" command (or whatever you may have
mapped it to.

Examples:
 -m       -- will send the output to "random" panes of the current TMUX
             window.
 -m=2     -- will send the output to the TMUX window two, and "randomly" 
             select panes for the output.
 -m=2:2,3 -- will send the outputs to only pane indices 2 and 3 of TMUX window 2.
 -m=0:1,4 -- will send the outputs to only pane indices 1 and 4 of the current
             TMUX window. '0' always mean 'current TMUX window'.

Note that you will need to use the '=' now, when you specify windows and panes.
It will not work properly without it.

LONGDESC
      
      option :ttys,      type: :array,   aliases: '-M', banner: "[TTY1[ TTY2 ...]]",
                                                        desc: ' Send output to specified (pseudo) ttys.'
      option :play,      type: :array,   aliases: ['-p', '--power'], banner: "[NAME[ NAME2...]|all]", required: true,
                                                        desc: 'Which PowerPlay playbooks (as opposed to Ansible playbooks) to specifically execute.'
      option :group,     type: :array,   aliases: '-g', banner: "[NAME[ NAME2...]|all]", default: [:all],
                                                        desc: ' Which groups to execute.'
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
      option :apverbose, type: :numeric, banner: '[1|2|3|4]', aliases: '-V', default: 0,
                                                        desc: "Pass to ansible-playbook -v, -vv, etc. verbosity flags"
      option :nojson,    type: :boolean, aliases: ['--no-json', '-J'],
             desc: "Submit --extra-vars as key-value pairs (old behavior), rather than JSON. Will affect new features in 1.4.0 and beyond.",
             default: false
      def play(script = 'stack.play')
        DSL::_global[:options] = massage options
        puts "script %s " % [script] if DSL::_global[:options][:verbose] >= 1
        load script, true

        if DSL::_verbosity >= 3
          puts "\n*** PLANNING FIFO QUEUE:".green
          puts DSL::_planning.map{ |book|
            [book.type, book.plan, book.yaml, book.family.map{|g| ":#{g}" }.join(' < ')]
          }.map{ |t,p,y,f|
            unless t == :noop
              ":#{t}".light_yellow
            else
              ":#{t}".red
            end +
              unless p == :async
                "\t :#{p}".light_cyan
              else
                "\t :#{p}".light_red
              end +
              "\t #{y}".magenta +
              "\t #{f}".light_black
          }
          puts
        end

        if DSL::_verbosity >= 4
          puts "\n**** PARSE TREE & GLOBAL OBJECTS:".green
          pp DSL::_global
          
          puts "\n**** PLANNING FIFO QUEUE DETAILS:".green
          pp DSL::_planning
        end

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
 
