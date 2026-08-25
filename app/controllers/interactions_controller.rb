class InteractionsController < ApplicationController
  before_action :set_person, only: %i[ new create ]
  before_action :set_interaction, only: %i[ edit update destroy ]

  def new
    @interaction = @person.interactions.new(user: current_user, occurred_at: Time.current)
  end

  def create
    @interaction = @person.interactions.new(interaction_params)
    @interaction.occurred_at = DateTime.current

    if @interaction.save
      redirect_to @interaction.person, notice: "Interaction ajoutée."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @interaction.update(interaction_params)
      redirect_to @interaction.person, notice: "Interaction modifiée."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    person = @interaction.person
    @interaction.destroy!
    redirect_to person, notice: "Interaction supprimée."
  end

  private

    def set_person
      @person = Person.find(params.expect(:person_id))
    end

    def set_interaction
      @interaction = Interaction.find(params.expect(:id))
    end

    def interaction_params
      params.expect(interaction: [ :user_id, :kind, :occurred_at, :title, :description ])
    end
end
