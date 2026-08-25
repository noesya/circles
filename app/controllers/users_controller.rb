class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find(params.expect(:id))
    @people_in_circle = @user.people_in_circle.ordered.page(params[:page])
    @people_with_interactions = @user.people_with_interactions.ordered.page(params[:page])
    @people_imported = @user.people_imported.ordered.page(params[:page])
  end
  
  def sync
    @user = User.find(params.expect(:id))
    UserSyncJob.perform_later(@user)
    redirect_back(fallback_location: @user, notice: 'Synchronisation lancée')
  end

  def add_to_my_circle
    person = Person.find(params[:person_id])
    current_user.add(person)
    redirect_back(fallback_location: @user, notice: 'Personne ajoutée')
  end

  def remove_from_my_circle
    person = Person.find(params[:person_id])
    current_user.remove(person)
    redirect_back(fallback_location: @user, notice: 'Personne retirée')
  end
end
