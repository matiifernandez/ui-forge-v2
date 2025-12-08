RubyLLM.configure do |config|
  # Use Groq as the AI provider (OpenAI-compatible API)
  config.openai_api_base = 'https://api.groq.com/openai/v1'
  config.openai_api_key = ENV["GROQ_API_KEY"]
end
