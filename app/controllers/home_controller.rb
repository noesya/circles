class HomeController < ApplicationController
  def index
    @people = current_user.people_in_circle.page(params[:page])
    @people_to_contact = current_user.people_in_circle.interaction_too_old.page(params[:page_people_to_contact])
    @needs_cleaning = Person.visible.dirty.any?
  end
end
