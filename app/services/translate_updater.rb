require 'open-uri'
require 'zip'

class TranslateUpdater
  include LokalizeEnv

  attr_accessor :name, :language

  def initialize(name, language)
    @name = name
    @language = language
  end

  class << self
    def call(*args)
      new(*args).call
    end
  end

  def call
    # get translatable bundled zip file url
    files = client.download_files project_id, format: :json
    zip_content = open(files['bundle_url'])
    translation = nil
    # unzip zip file and get translations with tool name and language
    Zip::File.open_buffer(zip_content) do |zip|
      zip.each do |entry|
        translation = entry.get_input_stream.read if entry.name.include?("#{name}_#{language}_json_spec.json")
      end
    end
    return nil if translation.nil?

    # fetch json from GitHub
    git_json_spec = JsonSpecGetter.call(name, language)
    return nil if git_json_spec.nil?

    replace_json(git_json_spec, translation)
  end

  private

  # replace values in json with translations
  def replace_json(git_json_spec, translation)
    translation_hash = JSON.parse(translation)
    translation_hash.each do |key, value, temp = git_json_spec|
      keys_array = key.split('_')
      keys_array[1..].each_with_index do |e, i|
        if i == keys_array.length - 2
          temp[e] = value
        else
          temp = temp[e]
        end
      end
    end
    git_json_spec
  end
end
