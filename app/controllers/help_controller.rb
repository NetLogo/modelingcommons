class HelpController < ApplicationController

  before_filter :require_login, :except => [:index, :screencasts]

  def index
  end

  def screencasts
  end

end
