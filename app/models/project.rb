class Project < ApplicationRecord
  belongs_to :user
  has_many :components, dependent: :destroy
  has_one_attached :photo
  validates :title, presence: true, uniqueness: {scope: :user_id}, length: {maximum: 50}
  validates :description, presence: true
  attribute :primary_color, :string, default: "#5f617e"
  attribute :secondary_color, :string, default: "#E5E5E5"

  after_create :generate_default_components

  private

  def generate_default_components
    components = ['banner', 'navbar', 'button']

    components.each do |comp_name|
      # Create fresh chat for each component to avoid context pollution
      generate_component_and_chat(comp_name)
    rescue StandardError => e
      Rails.logger.error "Failed to generate #{comp_name}: #{e.message}"
    end
  rescue StandardError => e
    Rails.logger.error "Error in generate_default_components: #{e.class} - #{e.message}"
  end

  def generate_component_and_chat(comp_name)
    component = self.components.create!(name: comp_name.capitalize)
    chat = component.chat # Chat is created automatically by Component callback
    system_instructions = create_system_prompt
    user_prompt_content = message_prompt(comp_name)
    user_message = chat.messages.create!(
      role: 'user',
      content: user_prompt_content
    )

    # Create fresh LLM chat for each component with JSON mode
    ruby_llm_chat = RubyLLM.chat(model: ENV["AI_MODEL"], provider: :openai, assume_model_exists: true)
    ruby_llm_chat.with_params(response_format: { type: 'json_object' })
    llm_response = ruby_llm_chat.with_instructions(system_instructions).ask(user_message.content)

    parsed_content = parse_ai_response(llm_response&.content)

    if parsed_content && parsed_content['html'].present?
      chat.messages.create!(
        role: "assistant",
        content: parsed_content.to_json
      )
      update_component_from_response(component, parsed_content)
    else
      Rails.logger.error "Invalid AI response for #{comp_name}: #{llm_response&.content.inspect}"
      create_placeholder_component(component, chat, comp_name)
    end
  rescue StandardError => e
    Rails.logger.error "Error generating #{comp_name}: #{e.class} - #{e.message}"
    create_placeholder_component(component, chat, comp_name) if component&.persisted?
  end

  def create_placeholder_component(component, chat, comp_name)
    placeholder_html = "<div class=\"#{comp_name}-placeholder\">#{comp_name.capitalize} - Edit to customize</div>"
    placeholder_css = ".#{comp_name}-placeholder { padding: 2rem; background: #f0f0f0; border: 2px dashed #ccc; text-align: center; color: #666; font-family: sans-serif; }"

    component.update!(html_code: placeholder_html, css_code: placeholder_css, bootstrap: false)
    chat&.messages&.create(role: "assistant", content: { html: placeholder_html, css: placeholder_css, bootstrap: false }.to_json)
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

  def update_component_from_response(component, html_and_css)
    component.update!(
      html_code: clean_escaped_quotes(html_and_css['html']),
      css_code: clean_escaped_quotes(html_and_css['css']),
      bootstrap: html_and_css['bootstrap'] || false,
    )
  end

  def clean_escaped_quotes(str)
    return str if str.nil?
    # Remove double-escaped quotes that AI sometimes produces
    str.gsub(/\\"/, '"').gsub(/\\'/, "'")
  end

  def message_prompt(component_name)
    <<~PROMPT
      Generate a #{component_name} component.
      Background color: #{primary_color}
      Accent color: #{secondary_color}
      Project: #{self.title} - #{self.description}

      RESPOND WITH ONLY THIS JSON FORMAT, NOTHING ELSE:
      {"html": "<your html here>", "css": "<your css here>", "bootstrap": false}

      Your response must start with { and end with }. No explanations.
    PROMPT
  end

  def create_system_prompt
    'You output only valid JSON. No explanations. No markdown. Response format: {"html": "...", "css": "...", "bootstrap": false}'
  end
end
