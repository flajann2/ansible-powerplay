module Powerplay
  module DSL
    @@config_stack = [{}]

    def _bump
      @@config_stack.push @@config_stack.clone
    end

    def _dip
      @@config_stack.pop
    end

    def _config
      @@config_stack.last
    end

    class DslConfiguration 
      def method_missing(name, *args, &block)
        puts "missing: %s %s " % [name, args]
        DSL::_config[name] = args
      end

      def self.respond_to?(name, include_private = false)
        true
      end

      def initialize (type, desc, &block)
        block.(self)
      end
    end

    def configuration(type=:vars, desc=nil, &block)
      DslConfiguration.new type, desc, &block
    end

    def playbooks(type=:vars, desc=nil, &block)
      _bump
      block.()
    end
  end
end
