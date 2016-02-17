# -*- coding: utf-8 -*-
require 'ansible-powerplay'

module Powerplay
  module Play
    DEFOUT = "&1" # default non-tmux output

    def self.clopts
      @cliots ||= DSL::_global[:options]
    end

    module Tmux
      # get a list of the ptys 
      def self.pane_ptys
        @ptys ||= if Play::clopts[:tmux]
                    %x[tmux list-panes -F '\#{pane_tty},']
                      .inspect
                      .chop
                      .split(",")
                      .map{ |s| s.strip.sub(/\\n|\"/, '') }
                  else
                    [Play::DEFOUT]
                  end
      end
    end

    module Ansible
      PLAYBOOK = "ansible-playbook"
      OPTS = ""

      def self.playbooks
        play = Play::clopts[:play].to_sym
        if play == :all
          DSL::_global[:playbooks].each do |play, group|
            yield play, group
          end
        else
          yield play, DSL::_global[:playbooks][play]
        end
      end
      
      # groups are serial
      def self.groups(playbook)
        grp = Play::clopts[:group].to_sym
        playbook.groups.each do |group|
          yield group if grp == :all or grp == group.type  
        end
      end

      def self.power_run
        buch = Play::clopts[:book].to_sym
        dryrun = Play::clopts[:dryrun]
        
        playbooks do |pname, playbook|
          puts "PLAYBOOK #{pname} (group=#{Play::clopts[:group]}) -->"
          groups playbook do |group|
            puts "    GROUP #{group.type} (book=#{buch}) -->"
            thrs = []
            errors = []
            group.books.zip(Tmux.pane_ptys) do |book, tty|
              tty ||= Tmux.pane_ptys.last
              if buch == :all or book.type == buch
                puts "        BOOK #{book.type}"
                apcmd = %|#{PLAYBOOK} #{OPTS} #{book.config[:playbook_directory].first}/#{book.yaml} --extra-vars "#{book.aparams}" >#{tty}|
                thrs << Thread.new {
                  std, status = Open3.capture2e apcmd
                  errors << [book.yaml, apcmd, std] unless status.success?
                } unless dryrun
              end
            end
            thrs.each{ |t| t.join }
            unless errors.empty?
              errors.each do |yaml, cmd, txt|
                puts '=' * 30
                puts ('*' * 10) + ' ' + yaml
                puts txt
                puts '-' * 30
                puts cmd
              end
              exit 10
            end
          end
        end
      end
    end
  end
end
