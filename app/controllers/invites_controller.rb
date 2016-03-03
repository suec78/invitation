class InvitesController < ApplicationController

  def new
    @invite = Invite.new
  end

  def create
    @invite = Invite.new(invite_params)
    @invite.sender_id = current_user.id
    if @invite.save

      #if the user already exists
      if @invite.recipient != nil

        #send a notification email
        InviteMailer.existing_user_invite(@invite).deliver

        #Add the user to the organization
        # @invite.recipient.organizations.push(@invite.organizable)
        @invite.organizable.invites_users.push(@invite.recipient)
      else
        InviteMailer.new_user_invite(@invite, new_user_registration_path(:invite_token => @invite.token)).deliver
      end
    else
      # oh no, creating an new invitation failed
    end
  end

  def invite_params
    params.require(:invite).permit(:organizable_id, :organizable_type, :email)
  end
end
