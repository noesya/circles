class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find(params.expect(:id))
    @google_people = GooglePeople.new(@user.email)
  end
end
