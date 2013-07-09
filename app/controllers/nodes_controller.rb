# Controller to deal with nodes

class NodesController < ApplicationController

  before_filter :log_one_action
  before_filter :require_login

  def change_wants_help
    node = Node.find(params[:id])
    logger.warn "[NodesController#change_wants_help] Checking if node #{node.id} is writable by person #{@person.inspect}"
    render text: "No permission" unless node.changeable_by_user?(@person)

    wants_help = params[:wants_help].present?
    logger.warn "[NodesController#change_wants_help] wants_help = '#{wants_help}'"
    node.update_attributes!(wants_help:wants_help)
    logger.warn "[NodesController#change_wants_help] node.wants_help = '#{node.wants_help}'"
    render text: node.wants_help
  end

end
