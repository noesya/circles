class PeopleController < ApplicationController
  before_action :set_person, only: %i[ show edit update destroy hide merge merge_into ]

  def index
    @people = Person.visible.ordered.page(params[:page])
  end

  def please_clean
    @people = Person.visible.dirty.ordered.page(params[:page])
  end

  def show
    @interactions = @person.interactions.ordered.page(params[:page])
  end

  def new
    @person = Person.new
  end

  def edit
  end

  def create
    @person = Person.new(person_params)

    respond_to do |format|
      if @person.save
        format.html { redirect_to @person, notice: "Person was successfully created." }
        format.json { render :show, status: :created, location: @person }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @person.errors, status: :unprocessable_content }
      end
    end
  end

  def update
    respond_to do |format|
      if @person.update(person_params)
        format.html { redirect_to @person, notice: "Person was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @person }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @person.errors, status: :unprocessable_content }
      end
    end
  end

  def destroy
    @person.destroy!

    respond_to do |format|
      format.html { redirect_to people_path, notice: "Person was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def hide
    @person.update(hidden: true)
    redirect_to people_path, notice: "Personne masquée."
  end

  def search
    @people = Person.visible
      .where("first_name ILIKE :q OR last_name ILIKE :q", q: "%#{params[:q]}%")
      .ordered
      .limit(10)
  end

  def merge
  end

  def merge_into
    target = Person.find(params.expect(:target_id))

    if target == @person
      redirect_to merge_person_path(@person), alert: "Choisissez une personne différente."
      return
    end

    PersonMerge.new(@person, target).call
    redirect_to target, notice: "Personnes fusionnées."
  end

  private

    def set_person
      @person = Person.find(params.expect(:id))
    end

    def person_params
      params.expect(person: [ :first_name, :last_name, :avatar, :company, :job_title ])
    end
end
