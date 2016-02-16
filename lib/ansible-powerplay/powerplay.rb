# -*- coding: utf-8 -*-
require 'ansible-powerplay'

module Powerplay
  module Play
    module Tmux
      # get a list of the ptys 
      def self.pane_ptys
        @ptys ||= %x[tmux list-panes -F '\#{pane_tty},']
          .inspect
          .chop
          .split(",")
          .map{ |s| s.strip.sub(/\\n|\"/, '') }
      end
    end

    module Ansible
      PLAYBOOK = "ansible-playbook"
      OPTS = ""
      def self.playbooks
        play = DSL::_global[:options][:play].to_sym
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
        playbook.groups.each do |group|
          yield group
        end
      end

      def self.power_run
        playbooks do |pname, playbook|
          puts "PLAYBOOK #{pname} -->"
          groups playbook do |group|
            puts "    GROUP #{group.type} -->"
            thrs = []
            errors = []
            group.books.zip(Tmux.pane_ptys) do |book, tty|
              tty ||= Tmux.pane_ptys.last 
              apcmd = %|#{PLAYBOOK} #{OPTS} #{book.config[:playbook_directory].first}/#{book.yaml} --extra-vars "#{book.aparams}" >#{tty}|
              thrs << Thread.new {
                std, status = Open3.capture2e apcmd
                errors << [book.yaml, apcmd, std] unless status.success?
              }
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
end
