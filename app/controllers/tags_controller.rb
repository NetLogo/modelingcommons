# Controller to deal with tagging

class TagsController < ApplicationController

  caches_page :image

  before_filter :require_login, :only => [:new, :create, :edit, :update, :destroy]

  def index
    @tags = Tag.all
  end

  def create
    @node = Node.find(params[:node_id])
    @new_tagged_nodes = [ ]
    params[:new_tag].each_with_index do |tag_name, index|
      next if tag_name.blank?
      comment = params[:new_comment][index].strip
      tag = Tag.find_or_create_by_name(tag_name.downcase.strip, :person_id => @person.id)
      tn = TaggedNode.find_or_create_by_tag_id_and_person_id_and_node_id(tag.id,
                                                                         @person.id,
                                                                         @node.id,
                                                                         :comment => comment
      )
      if tn.created_at < 1.minute.ago
        @new_tagged_nodes << tn
        notification_recipients = @node.people.reject { |person| person == @person}
        if notification_recipients.empty?
          logger.warn "No recipients; not sending the notification"
        else
          logger.warn "Notification recipients = '#{notification_recipients}'"
          Notifications.applied_tag(notification_recipients, tn.tag).deliver
        end
      end
    end
    html = render_to_string(:partial => "tags/tag_cloud", :layout => false, :formats => 'html', :locals => {:model => Node.find(params[:node_id])})
    respond_to do |format|
      format.html do
        render :text => html
      end
      format.json do
        render :json => {:success => true, :html => html, :message => '' + params[:new_tag].length + ' tags added'}
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
      render :json => {:success => true, :message => "Tag '#{tn.tag.name}' removed from the '#{model.name}' model"}
    else
      render :json => {:success => false, :message => "You are not authorized to remove this tag"}
    end
  end

  def download
    tag = Tag.find(params[:id])
    send_file(tag.create_zipfile(@person), :filename => tag.zipfile_name, :type => 'application/zip', :disposition => "inline")
  end

  def image
    expires_in 12.hours
    num_to_fetch_from_db = 10 #limit number of tagged nodes to fetch from db to increase speed
    
    tag = Tag.find(params[:id])
    nodes = tag.tagged_nodes.all(:order => 'updated_at DESC',
                                 :limit => num_to_fetch_from_db).map{|tn| tn.node}.select{|node| node.visible_to_user?(@person) && !node.preview.blank?}[0..3]
    size = 152
    list = Magick::ImageList.new
    
    if nodes.length > 0
      nodes.each do |model| 
        if !model.preview.blank?
          list.from_blob(model.preview.contents.to_s)
        end
        if list.length  >= 4
          break
        end
      end
    end
    
    if list.length == 4
      list.each do |image| 
        image.resize_to_fill!(size/2, size/2, Magick::CenterGravity)
      end
      
      m = list.montage {
        self.geometry = "#{size/2}x#{size/2}+0+0"
        self.tile = '2x2'
      } .first
    elsif list.length == 3
      list[0..1].each { |image|
        image.resize_to_fill!(size/2, size/2, Magick::CenterGravity)
      }
      top = list[0..1].montage {
        self.geometry = "#{size/2}x#{size/2}+0+0"
        self.tile = '2x1'
      } .first
      
      bottom = list[2]
      bottom.resize_to_fill!(size, size/2, Magick::CenterGravity)
      list = Magick::ImageList.new
      list.push(top)
      list.push(bottom)
      
      m = list.montage {
        self.geometry = "#{size}x#{size/2}+0+0"
        self.tile = '1x2'
      } .first
    elsif list.length == 2
      list.each do |image| 
        image.resize_to_fill!(size, size/2, Magick::CenterGravity)
      end
      
      m = list.montage {
        self.geometry = "#{size}x#{size/2}+0+0"
        self.tile = '1x2'
      } .first
    elsif list.length == 1
      m = list.first.resize_to_fill!(size, size, Magick::CenterGravity)
    else
      m = Magick::Image.new(1,1) {
        self.background_color = 'rgba(255, 255, 255, 0)'
      }
    end
    
    m.format = 'png'
    send_data(m.to_blob, :type => 'image/png', :disposition => 'inline')
    #render :json => {:count => list.length}
  end
  
end
