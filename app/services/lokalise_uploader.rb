require 'ruby-lokalise-api'

class LokaliseUploader
  include LokalizeEnv

  attr_accessor :json_spec, :name, :language

  def initialize(json_spec, name, language)
    @json_spec = json_spec
    @name = name
    @language = language
  end

  class << self
    def upload(*args)
      new(*args).upload
    end
  end

  # upload translatable keys and values to lokalise with api
  def upload
    client.upload_file project_id, data: json_spec_base64, filename: "#{name}_#{language}_json_spec.json", lang_iso: language
  end

  private

  def json_spec_base64
    Base64.strict_encode64(json_spec.to_json)
  end
end
