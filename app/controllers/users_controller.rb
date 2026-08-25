class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find(params.expect(:id))
    @people = @user.people.ordered.page(params[:page])
  end
  
  def sync
    @user = User.find(params.expect(:id))
    UserSyncJob.perform_later(@user)
    redirect_back(fallback_location: @user, notice: 'Synchronisation lancée')
  end
end
