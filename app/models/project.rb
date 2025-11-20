require 'ruby_llm/schema'
class Project < ApplicationRecord
  include RubyLLM::Helpers
  belongs_to :user
  has_many :components, dependent: :destroy
  has_one_attached :photo
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
    system_instructions = create_system_prompt
    user_prompt_content = message_prompt(comp_name)
    user_message = chat.messages.create!(
      role: 'user',
      content: user_prompt_content
    )

    llm_response = @ruby_llm_chat.with_instructions(system_instructions).with_schema(response_schema).ask(user_message.content)
      chat.messages.create!(
      role: "assistant",
      content: llm_response.content.to_json
    )
    update_component_from_response(component, llm_response.content)
  end

  def update_component_from_response(component, html_and_css)
    component.update!(
      html_code: html_and_css['html'],
      css_code: html_and_css['css'],
    )
  end

  def message_prompt(component_name)
    "You are generating a #{component_name} based on the #{primary_color} for background and #{secondary_color} for accents.
    the component has to rely in the #{self.description} to know what the user wants.
    If the #{component_name} is a banner, you want to add the #{self.title} having into account the readability and contrast."
  end

  def create_system_prompt
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
  - Do NOT add comments to the code.
  - Only return valid JSON.
  - Escape quotes inside the HTML and CSS values."
  - Do not add newline characters. e.g. \n
  - If you import a font, make sure you put it at the top of the css.
  PROMPT
  end

  def response_schema
    schema "html_and_css", description: "An object with html and css code" do
      string :html, description: "Plain html code"
      string :css, description: "Plain css code"
    end
  end
end
