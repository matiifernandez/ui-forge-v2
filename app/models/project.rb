class Project < ApplicationRecord
  belongs_to :user
  has_many :components, dependent: :destroy
  validates :title, presence: true, uniqueness: {scope: :user_id}, length: {maximum: 50}
  validates :description, presence: true
  attribute :primary_color, :string, default: "#5f617e"
  attribute :secondary_color, :string, default: "#E5E5E5"

  after_create_commit :generate_default_components

  private

  def generate_default_components
    @ruby_llm_chat = RubyLLM.chat

    components = ['banner', 'navbar', 'button']

    components.each do |comp_name|
      generate_component_and_chat(comp_name)
    end
  end

  def generate_component_and_chat(comp_name)
    component = self.components.create!(name: comp_name.capitalize)
    chat = component.create_chat!
    system_instructions = create_prompt_for(comp_name)
    user_prompt_content = message_prompt(comp_name)
    user_message = chat.messages.create!(
      role: 'user',
      content: user_prompt_content
    )

    llm_response = @ruby_llm_chat.with_instructions(system_instructions).ask(user_message.content)
    assistant_message = chat.messages.create!(
      role: "assistant",
      content: llm_response.content
    )
    update_component_from_response(component, assistant_message.content)
  end

  def update_component_from_response(component, json_string)
    parsed_json = JSON.parse(json_string)
    component.update!(
      html_code: parsed_json['html'],
      css_code: parsed_json['css'],
    )
  end

  def message_prompt(component_name)
    "You are generating a #{component_name} based on the #{primary_color} for background and #{secondary_color} for accents.
    the component has to rely in the #{self.description} to know what the user wants.
    If the #{component_name} is a banner, you want to add the #{self.title} having into account the readability and contrast."
  end

  def create_prompt_for(component)
    <<~PROMPT
  "You are an expert Front-end Developer.
  Your job is to generate UI components based on the user’s description.

  Always return your answer as a strict JSON object with this exact structure:

  {
    "html": "",
    "css": "/* CSS code here, no markdown, no backticks */"
  }

  Requirements:
  - Do NOT use markdown.
  - Do NOT use code fences (no ```).
  - Do NOT add commentary or explanations.
  - Only return valid JSON.
  - Escape quotes inside the HTML and CSS values."
  PROMPT
  end
end
