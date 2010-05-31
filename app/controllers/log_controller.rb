# Controller that handles logging

class LogController < ApplicationController

  before_filter :require_login

  def view_one_action
  end

  def view_all_actions
  end
end
