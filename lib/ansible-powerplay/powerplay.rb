require 'ansible-powerplay'

module Powerplay
  module Play
    module Tmux
      # get a list of the ptys 
      def self.get_pane_ptys
        %x[tmux list-panes -F '\#{pane_tty},']
          .inspect
          .chop
          .split(",")
          .map{ |s| s.strip.sub(/\\n|\"/, '') }
      end
    end

    module Ansible

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
            
          end
        end
      end
    end
  end
end
