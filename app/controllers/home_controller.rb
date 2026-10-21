class HomeController < ApplicationController
  def index
    @people = current_user.people_in_circle.page(params[:page])
    @people_to_contact = current_user.people_in_circle
                                     .interaction_too_old
                                     .ordered_by_interaction
                                     .page(params[:page_people_to_contact])
    @people_to_clean = Person.visible.dirty
  end
end
