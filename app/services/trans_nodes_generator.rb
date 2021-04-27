class TransNodesGenerator
  attr_accessor :json_spec, :name

  def initialize(json_spec, name)
    @json_spec = json_spec
    @name = name
  end

  class << self
    def call(*args)
      new(*args).call
    end
  end

  def call
    json_spec.except!('version', 'tool_version', 'id')
    get_nodes(json_spec)
  end

  private

  # generate translatable nodes and string values
  def get_nodes(json_spec, key_pref = name, result = {})
    json_spec.each do |key, value|
      case value.class.name
      when 'String'
        result["#{key_pref}_#{key}"] = value
      when 'Hash'
        get_nodes(json_spec[key], "#{key_pref}_#{key}", result)
      else
        next
      end
    end
    result
  end
end
