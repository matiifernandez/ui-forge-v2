class Component < ApplicationRecord
  belongs_to :project
  has_one :chat, dependent: :destroy
  validates :name, presence: true, uniqueness: {scope: :project_id}

  after_create :ensure_chat_exists

  private

  def ensure_chat_exists
    create_chat! unless chat.present?
  end
end
