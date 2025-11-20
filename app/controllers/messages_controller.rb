require 'ruby_llm/schema'
class MessagesController < ApplicationController
  include RubyLLM::Helpers
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
- Do NOT add comments to the code.
- Only return valid JSON.
- Escape quotes inside the HTML and CSS values."
- Do not add newline characters. e.g. \n
- If you import a font, make sure you put it at the top of the css.
PROMPT

  def create
    @chat = Chat.find(params[:chat_id])
    @component = @chat.component
    @message = Message.new(message_params)
    @project = @component.project
    @message.chat = @chat
    @message.role = "user"
    if @message.save
      @ruby_llm_chat = RubyLLM.chat
      build_conversation_history
      response = @ruby_llm_chat.with_instructions(instructions).with_schema(response_schema).ask(@message.content)
      Message.create(role: "assistant", content: response.content.to_json, chat: @chat)
      respond_to do |format|
        format.html { redirect_to chat_messages_path(@chat) }
        format.turbo_stream { render 'create' }
      end
    else
      respond_to do |format|
        # Fallback for non-Turbo requests (optional, but good practice)
        format.html { render 'chats/show', status: :unprocessable_entity }

        # Turbo Stream for handling validation errors
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            # NOTE: Use the ID of the container you wrapped your form in (e.g., <div id="message_form">)
            "message_form",
            partial: "messages/form",
            locals: { chat: @chat, message: @message, project: @project }
          ), status: :unprocessable_entity
        end
      end
    end
  end

  private

  def build_conversation_history
    @chat.messages.each do |message|
      @ruby_llm_chat.add_message({
        role: message.role,
        content: message.content
      })
    end
  end

  def response_schema
    schema "html_and_css", description: "An object with html and css code" do
      string :html, description: "Plain html code"
      string :css, description: "Plain css code"
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def instructions
    SYSTEM_PROMPT
  end
end
