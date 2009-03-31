class MembershipController < ApplicationController

  def leave
    if params[:id].empty?
      flash[:notice] = "No such membership."

    else

      membership = Membership.find(params[:id])
      membership.destroy

      if membership.person == @person
        flash[:notice] = "You have left the group."
      else
        flash[:notice] = "#{membership.person.fullname} is no longer a member of #{membership.group.name}."
      end
    end

    redirect_to :back

  end

  def make_administrator

    if params[:id].empty?
      flash[:notice] = "No such membership."
    else
      membership = Membership.find(params[:id])
      membership.is_administrator = true
      membership.status = 'approved'
      membership.save!
      flash[:notice] = "User '#{membership.person.fullname}' is now an administrator of '#{membership.group.name}'."
    end

    redirect_to :back
  end

  def remove_administrator

    if params[:id].empty?
      flash[:notice] = "No such membership."
    else
      membership = Membership.find(params[:id])
      membership.is_administrator = false
      membership.save!
      flash[:notice] = "User '#{membership.person.fullname}' is no longer an administrator of '#{membership.group.name}'."
    end

    redirect_to :back
  end

  def approve_membership

    if params[:id].empty?
      flash[:notice] = "No such membership."
    else
      membership = Membership.find(params[:id])
      membership.status = 'approved'
      membership.save!
      flash[:notice] = "User '#{membership.person.fullname}' is now a member of '#{membership.group.name}'."
    end

    redirect_to :back
  end

  def create_group
    @new_group_name = params[:group_name]

    if Group.exists?(:name => @new_group_name)

      group = Group.find_by_name(@new_group_name)

      # If the current user is a group administrator, let them add new people to the group

      flash[:notice] = "The name '#{@new_group_name}' is already taken; please try a different one."
    else

      Group.transaction do
        # Create the group
        @group = Group.create(:name => @new_group_name)
        @group.save!

        # Add the group owner as a member (and administrator) of this group
        m = Membership.create(:person => @person,
                              :group => @group,
                              :is_administrator => true,
                              :status => 'approved')

        flash[:notice] = "Successfully created the group '#{@group.name}'."
      end
    end

    redirect_to :back

  end

  def confirm_group_membership
    person_id = params[:person_id]
    group_id = params[:group_id]
  end

  def invite_people
    group = Group.find(params[:group][:id])
    email_addresses = params[:invitees]

    notice = ''

    email_addresses.split(',').each do |address|
      invitee = Person.find_by_email_address(address.downcase.strip)

      if invitee.nil?
        notice << "Could not invite '#{address}', since they are not in the system. "
      else

        already_invited = Membership.find_by_group_id_and_person_id(group.id,
                                                                    invitee.id)

        if  already_invited

          notice << "User '#{invitee.fullname}' has already been invited to join group '#{group.name}'. "

        else
          # Make them pending
          m = Membership.create(:person => invitee,
                                :group => group,
                                :is_administrator => false,
                                :status => 'invited')

          # Send them e-mail
          Notifications.deliver_invited_to_group(invitee, m)

        end

      end

    end

    flash[:notice] = notice
    redirect_to :back
  end

  def accept_invitation
    membership = Membership.find(params[:id])

    if @person != membership.person
      flash[:notice] = "This is not your invitation.  Sorry!"

    else
      membership.status = 'pending'
      membership.save

      flash[:notice] = "You will be a member as soon as the administrator confirms your membership."
    end

    redirect_to :controller => 'account', :action => 'mypage'
    return
  end

  def find_group
    group_name_to_find = params[:group_name].downcase

    if group_name_to_find.empty?
      flash[:notice] = "You must enter a group name to search.  Please try again."
      redirect_to :back
      return
    end

    group_name_to_find_ilike = '%' + group_name_to_find + '%'
    @groups = Group.find(:all,
                         :conditions => ["lower(name) ilike ? ", group_name_to_find_ilike])

    if @groups.empty?
      flash[:notice] = "Sorry, but no groups have the name '#{group_name_to_find}'."
      redirect_to :back
      return
    end

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

end
