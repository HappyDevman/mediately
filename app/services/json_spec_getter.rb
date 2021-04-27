require 'net/http'

class JsonSpecGetter
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
    # get json spec from GitHub
    raw_url = "https://raw.githubusercontent.com/HappyDevman/mediately/master/#{name}.#{language}.master.json"
    resp = Net::HTTP.get_response(URI.parse(raw_url))
    data = resp.body
    JSON.parse(data)
  rescue StandardError
    nil
  end
end
