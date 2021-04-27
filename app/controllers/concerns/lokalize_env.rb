module LokalizeEnv
  extend ActiveSupport::Concern

  def project_id
    ENV['project_id']
  end

  def client
    Lokalise.client(ENV['project_token'])
  end
end
