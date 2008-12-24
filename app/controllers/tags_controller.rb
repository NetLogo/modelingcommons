class TagsController < ApplicationController
  def index
    @tags = Tag.find(:all)
  end

  def new
    # Get the new tags
    new_tags = params[:new_tag]
    new_comments = params[:new_comment]

    # Get the model that we want to tag
    @node = Node.find(params[:node_id])

    flash[:notice] = ''

    new_tags.each_with_index do |tag_name, i|
      tag_name = tag_name.downcase.strip
      comment = new_comments[i].strip

      logger.warn "Dealing with tag '#{tag_name}', comment '#{comment}'"

      # Default text for the tag or comment?  Blank it out.
      if tag_name == 'tag name'
        flash[:notice] << "Tag had was the default text; ignoring. "
        next
      end

      if comment == '(Optional) comment about why this tag is relevant to this model'
        comment = ''
      end

      # Blank tag?  Ignore it.
      if tag_name.blank?
        flash[:notice] << "Tag '#{tag_name}' was blank; ignored. "
        next
      end

      # If this tag exists, get it.  If not, create it
      tag = Tag.find_by_name(tag_name)

      if tag.nil?
        logger.warn "Creating new tag '#{tag_name}', since it didn't exist yet"
        tag = Tag.create(:name => tag_name,
                         :person_id => @person.id)

        begin
          tag.save!
        rescue Exception => e
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

    redirect_to :back
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

  def create
    @tag = Tag.new(params[:tag])
    if @tag.save
      flash[:notice] = 'Tag was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @tag = Tag.find(:all, conditions => name = "Mousetraps" )
  end

  def update
    @tag = Tag.find(params[:id])
    if @tag.update_attributes(params[:tag])
      flash[:notice] = 'Tag was successfully updated.'
      redirect_to :action => 'show', :id => @tag
    else
      render :action => 'edit'
    end
  end

  def destroy
    Tag.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
