class HomeController < ApplicationController
  def index
    @people = current_user.people_in_circle.page(params[:page])
  end
end
