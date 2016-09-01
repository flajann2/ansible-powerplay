# -*- coding: utf-8 -*-
require 'ansible-powerplay'

CRITICAL = Mutex.new

module Powerplay
  module Play
    def self.clopts
      @clopts ||= Thor::CoreExt::HashWithIndifferentAccess.new DSL::_global[:options]
    end

    module Tmux
      def self.current_tty
        %x[tty].chop
      end

      # Either this list is empty, or a list
      # of window indices that was passed in from command-line.
      def self.list_of_pane_indices
        @splt ||= Play::clopts[:tmux].split(':')[0]
        @lst ||= unless @splt.nil?
                   @splt
                     .split(',')
                     .map{ |n| n.to_i }
                 else
                   []
                 end
      end
      
      # Get a list of the ptys
      # Note that this code is a bit innefficient, but will only be
      # executed once in the loop.
      def self.pane_ttys
        @window = if Play::clopts.nil? or Play::clopts[:tmux].split(':').first.to_i == 0
                    {nur: ''}
                  else
                    {nur: " -t #{Play::clopts[:tmux]} "}
                  end
        @ptys ||= if Play::clopts[:ttys]
                    Play::clopts[:ttys]
                  elsif Play::clopts.nil? or Play::clopts[:tmux]
                    %x[tmux list-panes #{@window} -F '\#{pane_index}:\#{pane_tty},']
                      .inspect
                      .chop
                      .split(',')
                      .map{ |s| s.strip.sub(/\\n|\"/, '')}
                      .reject{ |pty| pty == '' }
                      .map{|s| s.split(':')}
                      .reject{ |idx,pty| pty == '' }
                      .map{|i,t|[i.to_i, t]}
                      .reject{|i,pty| not (list_of_pane_indices.empty? or list_of_pane_indices.member?(i)) }
                      .to_h
                  else
                    {nur: current_tty}
                  end
      end
      
      # thread-safe way to grab a new tty
      def self.grab_a_tty
        tty = nil
        CRITICAL.synchronize {
          @@tty_count ||= -1
          @@tty_count = (@@tty_count+1) % pane_ttys.size
          tty = pane_ttys.values.[@@tty_count]
        }
        tty
      end
    end

    module Ansible
      PLAYBOOK = "ansible-playbook"
      OPTS = ""

      # deprecated
      def self.playbooks
        plays = Play::clopts[:play].map{ |y| y.to_sym }
        DSL::_global[:playbooks].each do |pplay, group|
          yield pplay, group if plays.first == :all or plays.member? pplay
        end
      end

      # deprecated
      def self.groups(playbook)
        grps = Play::clopts[:group].map{ |g| g.to_sym}
        playbook.groups.each do |group|
          yield group if grps.first == :all or grps.member?(group.type)  
        end
      end

      def self.jobs
        @jobs ||= []
      end
      
      def self.join_jobs
        while not jobs.empty?
          jobs.shift.join
        end
      end
      
      def self.get_book_apcmd(book, bucher, grouppe)
        dryrun  = Play::clopts[:dryrun]
        extra   = Play::clopts[:extra]
        tags    = Play::clopts[:tags]
        sktags  = Play::clopts[:sktags]
        tmuxout, tmuxpanes = Play::clopts[:tmux]
        apverb  = Play::clopts[:apverbose]

        verb = (apverb == 0) ? '' : ('-' + ('v' * apverb))
        tagstr = ''
        if tags and sktags
          puts "Cannot use both --tags (#{tags}) and --skip-tags (#{sktags})"
          exit 5 
        end
        tagstr += %( --tags "#{tags}" ) unless tags.nil?
        tagstr += %( --skip-tags "#{sktags}" ) unless sktags.nil?
        tty ||= Tmux.grab_a_tty
        puts " tty == #{tty} (#{Tmux.pane_ttys.last})" unless DSL::_verbosity < 2
        if (book.type != :noop) and
          (bucher.first == :all or bucher.member?(book.type)) and
          (grouppe.first == :all or not (grouppe & book.family).empty?)
          puts "        BOOK #{book.type}"
          inv = if book.config.member? :inventory 
                  "-i #{book.config[:inventory].first}" 
                else
                  ''
                end
          xxv = [extra[book.type], extra[:all]].compact.join(' ')
          redirect = (tmuxout.nil?) ? '' : " > #{tty}"
          apcmd = %|#{PLAYBOOK} #{OPTS} #{inv} #{book.config[:playbook_directory].first}/#{book.yaml} #{tagstr} --extra-vars "#{book.aparams} #{xxv}" #{verb} #{redirect}|
          unless DSL::_verbosity < 1
            puts "==============================".green
            puts "Running #{book.plan} book ".light_yellow +
                 ":#{book.type}".light_cyan +
                 " group heirarchy [".light_yellow +
                 "#{book.family.map{|g| ':' + g.to_s}.join(' < ')}".light_cyan +
                 "]".light_yellow
            puts "\n#{apcmd}".yellow
            puts "------------------------------" 
          end
          (dryrun) ? nil : apcmd
        else
          nil
        end
      end

      # Will remove entries from the planning queue in FIFO
      # fashion, and execution them according to the algorithm
      # as described in the README.org, Implementation of
      # the Execution Planning, which is considered "authoritative"
      # on how power_run works.
      def self.power_run
        bucher = Play::clopts[:book].map{ |b| b.to_sym }
        grouppe = Play::clopts[:group].map{ |b| b.to_sym }
        errors = []

        # old-style looping, alas
        while DSL::_peek
          book = DSL::_dequeue
          apcmd = get_book_apcmd book, bucher, grouppe
          join_jobs if book.plan == :sync
          j = unless apcmd.nil?
                Thread.new(book, apcmd) { |bk, cmd|
                  std, status = Open3.capture2e cmd
                  puts "**** Playbook #{bk.yaml} ****".light_blue, std if status.success?
                  errors << [bk.yaml, cmd, std, status] unless status.success?
                }
              else
                nil
              end
          if book.plan == :sync
            puts "Sync execution of :#{book.type} => #{book.yaml}".light_magenta unless DSL::_verbosity < 2
            j.join unless j.nil?
          elsif book.plan == :async
            puts "ASync execution of :#{book.type} => #{book.yaml}".magenta unless DSL::_verbosity < 2
            jobs << j unless j.nil?
          else
            raise "Book plan error #{book.plan} for book #{book.type}"
          end
        end
        
        # finish the lot and report on any errors
        join_jobs
        unless errors.empty?
          errors.each do |yaml, cmd, txt, status|
            puts ('=' * 60).light_red
            puts (('*' * 10) + ' ' + yaml).light_red + " exit status #{status.exitstatus}".light_blue
            puts txt.light_yellow
            puts ('-' * 30).red
            puts cmd.red
          end
          exit 10
        end
      end
    end
  end
end
