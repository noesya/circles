class PersonMerge
  def initialize(source, target)
    @source = source
    @target = target
  end

  def call
    move_emails
    move_phones
    move_interactions
    source.destroy!
  end

  private

  attr_reader :source, :target

  def move_emails
    existing = target.emails.pluck(:value)
    source.emails.where.not(value: existing).update_all(person_id: target.id)
  end

  def move_phones
    existing = target.phones.pluck(:canonical)
    source.phones.where.not(canonical: existing).update_all(person_id: target.id)
  end

  # Un update_all en bloc violerait l'index unique [user_id, person_id,
  # source_id] si la cible a déjà la même interaction externe (même event/
  # mail importé sous les deux doublons) : on ne bouge que celles qui ne
  # créeraient pas de conflit, les autres restent sur source et sont
  # détruites avec elle (le doublon existe déjà côté cible).
  def move_interactions
    existing = target.interactions.pluck(:user_id, :source_id).to_set
    source.interactions.find_each do |interaction|
      next if interaction.source_id.present? && existing.include?([ interaction.user_id, interaction.source_id ])
      interaction.update_column(:person_id, target.id)
    end
  end
end
