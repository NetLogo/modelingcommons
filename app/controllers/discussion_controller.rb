class DiscussionController < ApplicationController

  def new
    params[:new_posting][:person_id] = @person.id
    @posting = Posting.create(params[:new_posting])

    if @posting.save
      flash[:notice] = "Thanks for contributing to our discussion!"
    else
      flash[:notice] = "Error saving your posting.  Sorry!"
    end

    # Now send e-mail notification
    # discussion_people = @posting.nlmodel.postings.map { |p| p.person}
    # discussion_people << @posting.nlmodel.all_people
    # discussion_people = discussion_people.flatten.uniq

    # discussion_people.delete_if {|p| p == @person}

    # if not discussion_people.empty?
      # Notifications.deliver_updated_discussion(discussion_people, @posting.nlmodel)
    # end

    redirect_to :back, :anchor => "discuss-div"
  end

  def create
  end

  def delete
  end
end
