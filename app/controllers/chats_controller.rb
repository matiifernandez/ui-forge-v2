class ChatsController < ApplicationController
  before_action :authenticate_user!

  def show
    @chat = current_user.chats.find_by(id: params[:id])
    unless @chat
      flash[:alert] = "You are not authorized to view this chat."
      redirect_to projects_path
      return
    end
    @component = @chat.component
    @project = @component.project
    @message = Message.new
  end
end
