# Controller to deal with nodes

class NodesController < ApplicationController

  before_filter :log_one_action
  before_filter :require_login

  def change_wants_help
    node = Node.find(params[:id])
    node.update_attributes!(wants_help:params[:wants_help].present?)
    render text: node.wants_help
  end

end
