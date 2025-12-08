# UIForge

AI-powered UI component generator built with Ruby on Rails. Describe what you need, get production-ready HTML + CSS code.

## Features

- **AI Component Generation**: Describe components in plain language and get instant HTML/CSS
- **Project Context**: AI understands your project colors and description to match your design system
- **Live Preview**: Real-time component preview with iframe rendering
- **Component Library**: Organize components by project
- **Iterative Editing**: Chat-based interface to refine components

## Tech Stack

- Ruby on Rails 7.1
- PostgreSQL
- Hotwire (Turbo + Stimulus)
- Bootstrap 5
- RubyLLM gem with Groq API

## Setup

### Prerequisites

- Ruby 3.3+
- PostgreSQL
- Node.js & Yarn

### Installation

```bash
# Clone the repository
git clone https://github.com/matiifernandez/ui-forge.git
cd ui-forge

# Install dependencies
bundle install
yarn install

# Setup database
rails db:create db:migrate

# Set environment variables
cp .env.example .env
# Edit .env with your credentials
```

### Environment Variables

```
GROQ_API_KEY=your_groq_api_key
AI_MODEL=llama-3.3-70b-versatile
```

### Running

```bash
bin/dev
```

Visit `http://localhost:3000`

## Usage

1. **Create a Project**: Define your project with title, description, and color palette
2. **Generate Components**: The AI automatically creates banner, navbar, and button components
3. **Iterate**: Use the chat interface to refine components with natural language
4. **Export**: Copy the generated HTML/CSS for use in your projects

## License

MIT
