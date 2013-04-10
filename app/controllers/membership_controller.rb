# Controller that handles membership

class MembershipController < ApplicationController

  before_filter :require_login, :except => [:find, :find_group]
  before_filter :get_membership, :only => [:leave, :accept_invitation]

  def get_membership
    @membership = Membership.find(params[:id])
  end

  def leave
    @membership.destroy

    if @membership.person == @person
      flash[:notice] = "You have left the group."
    else
      flash[:notice] = "#{@membership.person_fullname} is no longer a member of #{@membership.group_name}."
    end

    if @membership.group_empty?
      flash[:notice] << " The group has also been removed from the system, as you were the last member."
    end

    redirect_to :back
  end

  def make_administrator
    membership = Membership.find(params[:id])
    membership.update_attributes(:is_administrator => true, :status => 'approved')
    flash[:notice] = "User '#{membership.person_fullname}' is now an administrator of '#{membership.group_name}'."
    redirect_to :controller => :account, :action => :groups, :anchor => 'manage'
  end

  def remove_administrator
    membership = Membership.find(params[:id])
    membership.update_attributes(:is_administrator => false)
    flash[:notice] = "User '#{membership.person_fullname}' is no longer an administrator of '#{membership.group_name}'."
    redirect_to :controller => :account, :action => :groups, :anchor => 'manage'
  end

  def approve_membership
    membership = Membership.find(params[:id])
    membership.update_attributes(:status => 'approved')
    flash[:notice] = "User '#{membership.person_fullname}' is now a member of '#{membership.group_name}'."
    redirect_to :back
  end

  def create_group
    group_name = params[:group_name]
    group = Group.find_by_name(group_name)

    flash[:notice] = group ? "The name '#{group_name}' is already taken; please try a different one." :
      Group.transaction do
      group = Group.create!(:name => group_name)
      Membership.create!(:person => @person,
                         :group => group,
                         :is_administrator => true,
                         :status => 'approved')
      "Successfully created the group '#{group_name}'."
    end

    redirect_to :controller => :account, :action => :groups, :anchor => "create"
  end

  def confirm_group_membership
    person_id = params[:person_id]
    group_id = params[:group_id]
  end

  def invite_people
    if params[:group][:id].blank?
      flash[:notice] = "You must specify a group to which people will be invited."
      redirect_to :controller => :account, :action => :groups, :anchor => "invite"
      return
    end

    group = Group.find(params[:group][:id])
    invitees = params[:invitees][:id]

    counter = 0

    invitees.each do |person_id|

      already_invited = Membership.find_by_group_id_and_person_id(group.id, person_id)

      if already_invited
        logger.warn "Ignoring person ID '#{person_id}', who was already invited go group '#{group.id}'."

      else
        # Invite them to the group
        membership = Membership.create(:person_id => person_id,
                                       :group => group,
                                       :is_administrator => false,
                                       :status => 'approved')

        # Send them e-mail
        Notifications.invited_to_group(Person.find(person_id), membership).deliver
        counter = counter + 1
      end

    end

    flash[:notice] = "Sent #{counter} invitation(s) to the '#{group.name}' group."
    redirect_to :controller => :account, :action => :groups, :anchor => "invite"
  end

  def accept_invitation
    if @person != @membership.person
      flash[:notice] = "This is not your invitation.  Sorry!"

    else
      @membership.update_attributes(:status => 'pending')
      flash[:notice] = "Congratulations!  You're now a member of the '#{@membership.group_name}' group."
    end

    redirect_to :controller => :account, :action => :mypage
    return
  end

  def find
    render :layout => 'plain'
  end

  def find_action
    if params[:group_name].strip.blank?
      render :text => "You must enter a group name to search.  Please try again."
      return
    else
      @groups = Group.search('%' + params[:group_name].downcase.strip + '%')
      if @groups.empty?
        render :text => "No groups contain '#{params[:group_name]}'. Please try again."
        return
      end
    end

    render :layout => 'plain'
  end

  def one_group
    if params[:id].blank?
      flash[:notice] = "Sorry, but you must indicate a group ID."
      redirect_to :back
    end

    @group = Group.find(params[:id])

  rescue
    flash[:notice] = "Sorry, but no group has an ID of '#{params[:id]}'."
    redirect_to :controller => :account, :action => :mypage
  end

  def list_models
    if params[:id].blank?
      @group_ids = @person.groups.map {|group| group.id}.join(',')
      @title = "List of models in all of your groups"
    else
      @group_ids = params[:id]
      @group = Group.find(@group_ids)
      @title = "List of models in the '#{@group.name}' group"
    end

    if @group_ids.empty?
      @models = [ ]
    else
      @models = Node.paginate(:page => params[:page],
                              :order => 'name ASC',
                              :conditions => "group_id in (#{@group_ids}) ")
    end
  end

  
  def download
    group = Group.find(params[:id])

    send_file(group.create_zipfile(@person), :filename => group.zipfile_name, :type => 'application/zip', :disposition => "inline")
  end


end
