require 'ansible-powerplay'

module Powerplay
  module Play
    module Tmux
      # get a list of the ptys 
      def self.get_pane_ptys
        %x[tmux list-panes -F '\#{pane_tty},'].inspect.chop.split(",")
        .map{ |s| s.strip.sub(/\\n|\"/, '') }
      end
    end
  end
end
