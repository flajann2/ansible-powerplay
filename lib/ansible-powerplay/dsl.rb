# -*- coding: utf-8 -*-
module Powerplay
  module DSL
    @@config_stack = [{}]
    @@global_config = {}
    @@planning_queue = []
    
    SPECIAL_PARAMS = [:playbook_directory, :inventory]

    # bump the config stack because we are in a child node context
    def _bump
      @@config_stack.push @@config_stack.last.clone
    end

    # pop the config stack, as we have left the child node context
    def _dip
      @@config_stack.pop
    end

    # Get the current config
    def _config
      @@config_stack.last
    end

    # This can be called from the powerplay, but we advise
    # against it.
    def config_var(var)
      _config[var.to_sym].first
    end
    
    def _global
      @@global_config
    end

    def _verbosity
      _global[:options][:verbose]
    end

    def _enqueue book
      @@planning_queue << book
    end

    def _dequeue
      @@planning_queue.shift
    end

    def _peek
      @@planning_queue.first
    end
    
    def _sneak
      @@planning_queue.last
    end

    # do NOT modify this directly. use the API above.
    def _planning
      @@planning_queue
    end
    
    class Dsl
      attr :config, :type, :desc

      def method_missing(name, *args, &block)
        unless args.first.is_a? Proc
          DSL::_config[name] = args
        else
          DSL::_config[name] = [args.first.()]
        end
      end

      def respond_to?(name, include_private = false)
        true
      end

      def configuration(type=:vars, desc=nil, &block)
        @config[type] = DslConfiguration.new(type, desc, &block).config
      end

      def book(type, yaml, desc = nil, plan: :sync, &block)
        @books ||= []
        _enqueue DslBook.new(type, yaml, desc: desc, plan: plan, &block)
      end

      def initialize(type, desc, &ignore)
        @type = type
        @desc = desc
        @config = {}
      end
    end

    class DslConfiguration < Dsl
      def initialize(type, desc, &block)
        super
        instance_eval( &block )
        @config = _config.clone
      end
    end

    # We do allow for noop books
    class DslBook < Dsl
      attr :yaml, :plan, :group

      def initialize(type, yaml, desc: nil, plan: nil, group: nil, &block)
        super(type, desc, &block)
        @yaml = yaml
        @plan = plan
        @group = group
        _bump
        instance_eval(&block) if block_given?
        @config = _dip
      end

      # Ansible playbook parameters.
      # Additional is a string of key=value pairs that is appended.
      # In the case of JSON output, it is appended in the JSON structure.
      def aparams(additional = '')
        unless Play.clopts[:nojson]
          config
            .map{ |k, v| [k, v.first] }
            .to_h
            .reject{ |k, v| DSL::SPECIAL_PARAMS.member?(k) }
            .merge(additional
                    .split
                    .map{|s| s.split('=')}.to_h)
            .to_json
        else
          config.map{ |k,v|          
            "#{k}=#{v.first}" unless DSL::SPECIAL_PARAMS.member?(k)
          }.compact.join(' ') + ' ' + additional
        end
      end

      def family
        unless @group.nil?
          @group.family
        else
          []
        end
      end
    end

    class DslGroup < Dsl
      # The entries here may either be books or groups.
      attr_reader :exec, :parent

      def group name, desc = nil, plan = :async, seq: nil, &block
        if seq.nil?
          DslGroup.new(name, desc, plan, self, &block)
          _enqueue DslBook.new(:noop, nil, plan: @exec) unless @exec == :async or _sneak.type == :sync
        else
          seq.each do |var, list|
            unless list.is_a? Array
              config[:vars][list].first
            else
              list
            end.each do |value|
              _bump
              _config[var] = [value]
              DslGroup.new(name, desc, plan, self, &block)
              _enqueue DslBook.new(:noop, nil, plan: @exec) unless @exec == :async or _sneak.type == :sync
              _dip
            end
          end
        end
      end

      def book(type, yaml, desc = nil, plan: @exec, &block)
        raise ":noop is a reserved book type and cannot be used." if type == :noop
        _enqueue DslBook.new(type, yaml,
                             desc: desc,
                             plan: plan,
                             group: self, &block)
      end

      def initialize(type, desc, plan, parent=nil, &block)
        super(type, desc, &block)
        @exec = plan
        @parent = parent
        _bump
        instance_eval( &block ) 
        @config = _dip
      end

      # return a list including ourselves and our parents
      def family
        fam = []
        g = self
        while g
          fam << g.type
          g = g.parent
        end
        fam
      end
    end

    class DslPlaybook < Dsl
      attr :groups

      def group name, desc = nil, plan = :async, &block
        @groups ||= []
        groups << DslGroup.new(name, desc, plan, &block)
      end

      def initialize (type, desc, &block)
        super
        _bump
        instance_eval( &block )
        @config = _dip
      end
    end

    def configuration(type=:vars, desc=nil, &block)
      _global[type] = DslConfiguration.new(type, desc, &block).config
    end

    def playbooks(type=:vars, desc=nil, &block)
      _global[:playbooks] ||= {}
      
      if Play::clopts[:play].member? type.to_s
        _global[:playbooks][type] = DslPlaybook.new type, desc, &block
      end
    end
  end
end
