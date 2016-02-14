# -*- coding: utf-8 -*-
module Powerplay
  module DSL
    @@config_stack = [{}]

    def _bump
      @@config_stack.push @@config_stack.last.clone
    end

    def _dip
      @@config_stack.pop
    end

    def _config
      @@config_stack.last
    end

    class Dsl
      def method_missing(name, *args, &block)
        puts "missing: %s %s " % [name, args]
        DSL::_config[name] = args
      end

      def self.respond_to?(name, include_private = false)
        true
      end
    end

    class DslConfiguration < Dsl
      def initialize (type, desc, &block)
        instance_eval &block
      end
    end

    class DslPlaybooks < Dsl
      def group name, desc=nil, &block
      end

      def initialize (type, desc, &block)
        instance_eval &block
      end
    end

    def configuration(type=:vars, desc=nil, &block)
      DslConfiguration.new type, desc, &block
    end

    def playbooks(type=:vars, desc=nil, &block)
      _bump
      DslPlaybooks.new type, desc, &block
      _dip
    end
  end
end
