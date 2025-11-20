class Message < ApplicationRecord
  MAX_USER_MESSAGES = 5

  validate :user_message_limit, if: -> { role == "user" }

  acts_as_message
  belongs_to :chat
  validates :role, presence: true
  validates :chat, presence: true

  private

  def user_message_limit
    if chat.messages.where(role: "user").count >= MAX_USER_MESSAGES
      errors.add(:base, "You can only send #{MAX_USER_MESSAGES} messages per chat.")
      errors.add(:content, "too many messages")
    end
  end
end
