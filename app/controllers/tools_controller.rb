class ToolsController < ApplicationController
  def create
    json_spec = JsonSpecGetter.call(name, language)
    translate_nodes = TransNodesGenerator.call(json_spec, name)
    LokaliseUploader.upload(translate_nodes, name, language)
    tool = Tool.new(name: name, language: language, json_spec: json_spec)
    if tool.save
      render json: { id: tool.id, language: tool.language, json_spec: json_spec }
    else
      render json: { error: tool.errors.full_messages }
    end
  end

  def update_translations
    tool = Tool.find_by(name: params[:name], language: params[:language])
    render json: { error: 'Tool is not existed' } and return if tool.nil?

    updated_json = TranslateUpdater.call(params[:name], params[:language]).to_json
    pr_title = GithubService.call(updated_json, name, language)
    # save necessary data to handle GitHub webhook
    Rails.cache.write_multi 'updated_json': updated_json, 'pr_title': pr_title, 'tool_id': tool.id
    render json: { success: true }
  rescue StandardError => e
    render json: { error: e.message }
  end

  # handle GitHub webhook request
  def handle_webhook
    params_title = params['pull_request']['title']
    cached_title = Rails.cache.fetch('pr_title')
    # check if the PR is correct one with title and if opened one
    if params_title != cached_title || params['pull_request']['state'] != 'open'
      render json: { status: 'The PR is not related with translation merge' } and return
    end

    tool = Tool.find(Rails.cache.fetch('tool_id'))
    tool.update(json_spec: Rails.cache.fetch('updated_json'))
    render json: { success: true }
  end

  private

  def name
    @name ||= params[:name]
  end

  def language
    @language ||= params[:language]
  end
end
