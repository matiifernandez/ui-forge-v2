class ChatsController < ApplicationController
  def show
    @chat = Chat.find(params[:id])
    @component = @chat.component
    @project = @component.project
    @message = Message.new
  end
end
