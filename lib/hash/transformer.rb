class Hash
  class Transformer
    attr_accessor :mappings, :key_action, :value_action

    def initialize(mappings = {})
      @mappings = mappings
      defaults
    end

    def defaults
      default_key_action!
      default_value_action!
    end

    def default_key_action!
      self.key_action = default_key_action
    end

    def default_key_action
      proc { |k| mappings[k] || k }
    end

    def default_value_action!
      self.value_action = default_value_action
    end

    def default_value_action
      proc { |v| v }
    end

    def deep
      @deep = true
      self
    end

    def deep?
      @deep.present?
    end

    def shallow
      @deep = false
      self
    end

    def transform(input_hash)
      Hash[input_hash.map { |k, v| [key_action.call(k), analyse(v)] }]
    end

    private

    def analyse(value)
      if deep?
        deep_analyse(value)
      else
        value_action.call(value)
      end
    end

    def deep_analyse(value)
      if value.is_a?(Hash)
        transform(value)
      elsif value.is_a?(Array)
        value.map { |e| e.is_a?(Hash) ? transform(e) : value_action.call(e) }
      else
        value_action.call(value)
      end
    end
  end
end
