class MessagesController < ApplicationController
  def create
    @chat = Chat.find(params[:chat_id])
    @component = @chat.component
    @project = @component.project

    # Handle missing message params gracefully
    begin
      @message = Message.new(message_params)
    rescue ActionController::ParameterMissing
      @message = Message.new
      @message.errors.add(:base, "Please enter a message")
      return render_error_response
    end

    @message.chat = @chat
    @message.role = "user"

    if @message.content.blank?
      @message.errors.add(:base, "Please enter a message")
      return render_error_response
    end

    if @message.save
      @ruby_llm_chat = RubyLLM.chat(model: ENV["AI_MODEL"], provider: :openai, assume_model_exists: true)
      @ruby_llm_chat.with_params(response_format: { type: 'json_object' })
      build_conversation_history
      response = @ruby_llm_chat.with_instructions(instructions).ask(@message.content)
      parsed_content = parse_ai_response(response&.content)

      if parsed_content
        @component.update(
          bootstrap: parsed_content["bootstrap"] || false,
          html_code: clean_escaped_quotes(parsed_content["html"]),
          css_code: clean_escaped_quotes(parsed_content["css"])
        )
        Message.create(role: "assistant", content: parsed_content.to_json, chat: @chat)
      else
        Message.create(role: "assistant", content: { html: @component.html_code, css: @component.css_code, bootstrap: @component.bootstrap }.to_json, chat: @chat)
        Rails.logger.error "Failed to parse AI response in messages controller"
      end

      @chat.messages.reload
      respond_to do |format|
        format.html { redirect_to chat_messages_path(@chat) }
        format.turbo_stream { render 'create' }
      end
    else
      render_error_response
    end
  end

  private

  def render_error_response
    respond_to do |format|
      format.html { render 'chats/show', status: :unprocessable_entity }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "message_form",
          partial: "messages/form",
          locals: { chat: @chat, message: @message, project: @project, component: @component }
        ), status: :unprocessable_entity
      end
    end
  end

  def build_conversation_history
    @chat.messages.each do |message|
      @ruby_llm_chat.add_message({
        role: message.role,
        content: message.content
      })
    end
  end

  def parse_ai_response(content)
    return content if content.is_a?(Hash)
    return nil if content.blank?

    json_str = content.to_s

    # First try: look for JSON object directly
    json_str_clean = json_str.gsub(/```json\s*/i, '').gsub(/```\s*/, '')
    if json_str_clean =~ /\{[\s\S]*"html"[\s\S]*"css"[\s\S]*\}/
      json_match = json_str_clean.match(/(\{[\s\S]*"html"[\s\S]*"css"[\s\S]*\})/)
      if json_match
        return JSON.parse(json_match[1])
      end
    end

    # Second try: extract HTML and CSS from markdown code blocks
    html_match = content.match(/```html\s*([\s\S]*?)```/i)
    css_match = content.match(/```css\s*([\s\S]*?)```/i)

    if html_match && html_match[1].present?
      html_code = html_match[1].strip
      css_code = css_match ? css_match[1].strip : ''
      bootstrap = html_code.include?('btn-') || html_code.include?('container') || html_code.include?('row') || html_code.include?('col-')

      return {
        'html' => html_code,
        'css' => css_code,
        'bootstrap' => bootstrap
      }
    end

    # Third try: just parse as JSON
    JSON.parse(json_str_clean)
  rescue JSON::ParserError => e
    Rails.logger.error "Failed to parse AI JSON response: #{e.message}"
    Rails.logger.error "Raw content: #{content.inspect}"
    nil
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def clean_escaped_quotes(str)
    return str if str.nil?
    str.gsub(/\\"/, '"').gsub(/\\'/, "'")
  end

  def instructions
    <<~PROMPT
      You are a code generator that modifies UI components. Output ONLY a JSON object.

      ## Context
      Project: "#{@project.title}" - #{@project.description}
      Colors: primary #{@project.primary_color}, secondary #{@project.secondary_color}

      ## Current Component: "#{@component.name}"
      HTML: #{@component.html_code}
      CSS: #{@component.css_code}

      FORMAT: {"html": "...", "css": "...", "bootstrap": false}

      ABSOLUTE RULES:
      - First character must be {, last character must be }
      - NO explanations, NO markdown, NO text outside JSON
      - Use single quotes in HTML: class='example'
      - NO img tags with local src - use CSS backgrounds, emojis, or Font Awesome icons instead
      - Put @import statements first in CSS if using fonts
      - bootstrap: true only if using Bootstrap classes
    PROMPT
  end
end
