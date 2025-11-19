class MessagesController < ApplicationController
  SYSTEM_PROMPT = <<~PROMPT
"You are an expert Front-end Developer.
Your job is to generate UI components based on the user’s description.

Always return your answer as a strict JSON object with this exact structure:

{
  "html": "<!-- HTML code here, no markdown, no backticks -->",
  "css": "/* CSS code here, no markdown, no backticks */"
}

Requirements:
- Do NOT use markdown.
- Do NOT use code fences (no ```).
- Do NOT add commentary or explanations.
- Only return valid JSON.
- Escape quotes inside the HTML and CSS values."
PROMPT

  def create
    @chat = Chat.find(params[:chat_id])
    @component = @chat.component
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"
    if @message.save
      @ruby_llm_chat = RubyLLM.chat
      response = @ruby_llm_chat.with_instructions(instructions).ask(@message.content)
      Message.create(role: "assistant", content: response.content, chat: @chat)
    else
      render chat_path(@chat), status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end

  def instructions
    SYSTEM_PROMPT
  end
end
