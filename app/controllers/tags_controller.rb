# Controller to deal with tagging

class TagsController < ApplicationController

  before_filter :require_login, :only => [:new, :create, :edit, :update, :destroy]

  def index
    @tags = Tag.find(:all)
  end

  def create
    new_tags = params[:new_tag]
    new_comments = params[:new_comment]

    # Get the model that we want to tag
    @node = Node.find(params[:node_id])

    @new_tagged_nodes = [ ]

    new_tags.each_with_index do |tag_name, i|
      tag_name = tag_name.downcase.strip
      comment = new_comments[i].strip

      # Default text for the tag or comment?  Blank it out.
      next if tag_name == 'tag name'

      if comment == '(Optional) comment about why this tag is relevant to this model'
        comment = ''
      end

      # Blank tag?  Ignore it.
      next if tag_name.blank?

      # If this tag exists, get it.  If not, create it
      tag = Tag.find_by_name(tag_name)

      if tag.nil?
        tag = Tag.new(:name => tag_name, :person_id => @person.id)

        next if !tag.save
      end

      # Now that we have a tag, we can create a TaggedModel -- but only
      # if this user has not yet tagged this model with this tag.
      tn =
        TaggedNode.find_by_tag_id_and_person_id_and_node_id(tag.id,
                                                            @person.id,
                                                            @node.id)

      if tn.nil?
        logger.warn "Creating new TaggedModel, since this combination (tag ID '#{tag.id}', person ID '#{@person.id}, model ID '#{@node.id}') doesn't yet exist."

        tn = TaggedNode.create(:tag_id => tag.id,
                               :person_id => @person.id,
                               :node_id => @node.id,
                               :comment => comment)
        @new_tagged_nodes << tn

        begin
          tn.save!

          flash[:notice] = "Successfully tagged this model as '#{tag_name}'.  "

          # Now send e-mail notification
          Notifications.deliver_applied_tag(tn.node.people.reject {|person| person == @person}, tn.tag)

        rescue Exception => exception
          next
        end
      else
        next
      end
    end

    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  def one_tag
    tag_id = params[:id]

    if tag_id.blank?
      flash[:notice] = "No tag ID was provided; can't view this tag."
      redirect_to :back
      return
    end

    @tag = Tag.find(tag_id)
  end

  def follow
    @tag = Tag.find(params[:id])
    @tagged_nodes = @tag.tagged_nodes.sort_by { |tn| tn.created_at }

    respond_to do |format|
      format.atom { @tagged_nodes }
    end
  end

  def complete_tags
    # Parameters: {"timestamp"=>"1235989842305", "q"=>"ab", "limit"=>"150"}
    query = params[:q]
    query_like = "#{query}%"

    limit = params[:limit]

    tag_names = Tag.find(:all,
                         :conditions => [ "name ilike ? ", query_like] ,
                         :limit => limit).map { |tag| tag.name}

    render :text => tag_names.join("\n")
  end

  def destroy
    tn = TaggedNode.find(params[:id])
    model = tn.node

    if tn.person == @person or @person.administrator?
      tn.destroy
      flash[:notice] = "Tag '#{tn.tag.name}' removed from the '#{model.name}' model."
    else
      flash[:notice] = "You are not authorized to remove this tag."
    end

    redirect_to :controller => :browse, :action => :one_model, :id => model.id
  end

end
