class Hash
  class Transformer
    attr_accessor :mappings, :key_action, :value_action

    def initialize(mappings = {}, *args)
      @mappings = mappings
      default_key_action!
      args.first == :deep ? deep_value_action! : default_value_action!
    end

    def defaults
      default_key_action!
      default_value_action!
    end

    def default_key_action!
      self.key_action = default_key_action
    end

    def default_key_action
      proc { |k, _v| mappings[k] || k }
    end

    def default_value_action!
      self.value_action = default_value_action
    end

    def default_value_action
      proc { |_k, v| v }
    end

    def deep_value_action!
      self.value_action = deep_value_action
    end

    def deep_value_action
      proc { |_k, v| analyse(v) }
    end

    def transform(input_hash)
      Hash[input_hash.map { |k, v| [key_action.call(k, v), value_action.call(k, v)] }]
    end

    private

    def analyse(value)
      if value.is_a?(Hash)
        transform(value)
      elsif value.is_a?(Array)
        value.map { |e| transform(e) if e.is_a?(Hash) }
      else
        value
      end
    end
  end
end
