class RecommendController < ApplicationController

  prepend_before_filter :get_model_from_id_param, :except => [:email_friend, :email_friend_action]
  before_filter :require_login, :except => [:model_contents, :one_applet, :about]
  before_filter :check_visibility_permissions, :only => [:one_model, :model_contents, :one_applet ]
  before_filter :check_changeability_permissions, :only => [:revert_model]

  def email_friend
    @node = Node.find(:first, params[:node_id])
  end

  def email_friend_action
    friend_email_address = params[:email_address]
    node = Node.find(:first, params[:node_id])

    if friend_email_address.blank?
      flash[:notice] = "You must enter an e-mail address."
    elsif friend_email_address.index('@').nil?
      flash[:notice] = "You must enter a valid e-mail address."
    elsif node
      Notifications.deliver_friend_recommendation(@person, friend_email_address, node)

      EmailRecommendation.create(:sender_id => @person.id,
                                 :recipient_email_address => friend_email_address,
                                 :node_id => node.id)

      flash[:notice] = "Sent e-mail to '#{friend_email_address}'."
    else
      flash[:notice] = "Error -- something went wrong!"
    end

    redirect_to :back
  end

  def add_recommendation
    Recommendation.create(:node_id => @model.id,
                          :person_id => @person.id)

    flash[:notice] = "Added your recommendation."
    redirect_to :back
  end

  def show_recommendations
    @recommendations = Recommendation.find_all_by_node_id(@model.id,
                                                          :order => "created_at DESC") || []

    model_people = @model.people
    model_people.delete_if {|p| p == @person}
    if not model_people.empty?
      Notifications.deliver_recommended_message(model_people, @node)
    end
  end

end
