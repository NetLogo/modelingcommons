# Controller to deal with tagging

class TagsController < ApplicationController

  before_filter :require_login, :only => [:new, :create, :edit, :update, :destroy]

  def index
    @tags = Tag.find(:all)
  end

  def create
    @node = Node.find(params[:node_id])

    @new_tagged_nodes = [ ]

    params[:new_tag].each_with_index do |tag_name, i|
      next if tag_name.blank? or tag_name == 'tag name'

      comment = params[:new_comment][i].strip
      comment = '' if comment == '(Optional) comment about why this tag is relevant to this model'

      tag = Tag.find_or_create_by_name(tag_name.downcase.strip, :person_id => @person.id)
      tn = TaggedNode.find_or_create_by_tag_id_and_person_id_and_node_id(tag.id,
                                                                         @person.id,
                                                                         @node.id,
                                                                         :comment => comment)

      if tn.created_at < 1.minute.ago
        @new_tagged_nodes << tn
        Notifications.deliver_applied_tag(@node.people.reject { |person| person == @person}, tn.tag)
      end

      respond_to do |format|
        format.html { redirect_to :back }
        format.js
      end
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
    query = params[:q].downcase
    limit = params[:limit].to_i

    render :text => Tag.search(query)[0..limit].map { |tag| tag.name}.join("\n")
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
