class MessagesController < ApplicationController
  def create
    @component = Component.find(params[:component_id])
    @message = Message.new(message_params)
    @message.chat = @component.chat
    @message.role = "user"
    if @message.save
      redirect_to
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
