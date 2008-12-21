class RecommendController < ApplicationController
  def email_friend
    friend_email_address = params[:email_address]
    node = Node.find(:first, params[:node_id])

    if node and not friend_email_address.blank?
      Notifications.deliver_friend_recommendation(@person, friend_email_address, node)
    end

    EmailNotification.create(:sender_id => @person.id,
                             :recipient_email_address => friend_email_address,
                             :node_id => node.id)

    flash[:notice] = "Sent e-mail to your friend."
    redirect_to :back
  end

  def add_recommendation

  end

end
