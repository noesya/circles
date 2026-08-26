# == Schema Information
#
# Table name: interactions
#
#  id           :uuid             not null, primary key
#  description  :text
#  external_url :string
#  kind         :integer          not null
#  occurred_at  :datetime         not null
#  title        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  person_id    :uuid             not null
#  source_id    :string
#  user_id      :uuid             not null
#
# Indexes
#
#  index_interactions_on_occurred_at                          (occurred_at)
#  index_interactions_on_person_id                            (person_id)
#  index_interactions_on_user_id                              (user_id)
#  index_interactions_on_user_id_and_person_id_and_source_id  (user_id,person_id,source_id) UNIQUE WHERE (source_id IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...  (person_id => people.id)
#  fk_rails_...  (user_id => users.id)
#
class Interaction < ApplicationRecord
  ICONS = {
    call: 'telephone-fill',
    calendar_event: 'calendar-event-fill',
    email: 'envelope-fill'
  }

  enum :kind, [:call, :calendar_event, :email]

  belongs_to :person
  belongs_to :user

  validates :kind, presence: true
  validates :occurred_at, presence: true

  after_save :update_person_last_interacted_at

  scope :ordered, -> { order(occurred_at: :desc) }

  def self.kind_options
    kinds.keys.map { |k| [ I18n.t(k, scope: "activerecord.values.interaction.kind"), k ] }
  end

  def kind_label
    I18n.t(kind, scope: "activerecord.values.interaction.kind")
  end

  def to_s
    "#{title}"
  end

  protected

  def update_person_last_interacted_at
    if person.last_interaction_at.nil? || occurred_at > person.last_interaction_at
      person.update_column :last_interaction_at, occurred_at
    end
  end
end
