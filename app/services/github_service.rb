require 'rest_client'

class GithubService
  attr_accessor :json_spec, :name, :language

  def initialize(json_spec, name, language)
    @json_spec = json_spec
    @name = name
    @language = language
  end

  class << self
    def call(*args)
      new(*args).call
    end
  end

  def call
    create_new_branch
    ref = "heads/#{@new_branch_name}"
    sha_latest_commit = client.ref(repo, ref).object.sha
    sha_base_tree = client.commit(repo, sha_latest_commit).commit.tree.sha
    file_name = "#{name}.#{language}.json"
    blob_sha = client.create_blob(repo, Base64.encode64(json_spec), 'base64')
    sha_new_tree = client.create_tree(repo,
                                      [{ path: file_name,
                                         mode: '100644',
                                         type: 'blob',
                                         sha: blob_sha }],
                                      { base_tree: sha_base_tree }).sha
    commit_message = "Add #{name}.#{language}.json"
    sha_new_commit = client.create_commit(repo, commit_message, sha_new_tree, sha_latest_commit).sha
    # commit new json file to new branch with GitHub api
    client.update_ref(repo, ref, sha_new_commit)
    pr_title = "Merge translation for #{name}.#{language}.json"
    # create new pull request with GitHub api
    client.create_pull_request(repo, 'master', @new_branch_name, pr_title)
    pr_title
  end

  private

  # create new branch with GitHub api
  def create_new_branch
    @new_branch_name = "translation/#{name}_#{language}"
    ref = 'heads/master'
    sha_latest_commit = client.ref(repo, ref).object.sha
    client.create_ref repo, "heads/#{@new_branch_name}", sha_latest_commit.to_s
  rescue StandardError
    nil
  end

  def client
    @client ||= Octokit::Client.new(access_token: ENV['access_token'])
  end

  def repo
    @repo ||= 'HappyDevman/mediately'
  end
end
