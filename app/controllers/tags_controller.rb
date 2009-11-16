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

        if !tag.save
          flash[:notice] << "Error saving newly created tag '#{tag_name}': '#{e.message}'"
          next
        end
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
          flash[:notice] << "Successfully tagged this model as '#{tag_name}'.  "

          # Now send e-mail notification
          tag_people = tn.node.people
          tag_people.delete_if {|p| p == @person}

          if not tag_people.empty?
            Notifications.deliver_applied_tag(tag_people, tn.tag)
          end

        rescue Exception => e
          flash[:notice] << "Error associating tag/person/node: '#{e.message}'"
          next
        end
      else
        flash[:notice] << "You already applied tag '#{tag_name}' to this node."
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
                         :limit => limit).map { |t| t.name}

    render :text => tag_names.join("\n")
  end
end
