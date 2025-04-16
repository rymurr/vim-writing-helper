# Vim AI Suggestions

A Vim plugin that provides AI-powered writing suggestions with multiple personas, directly integrated into your editor.

## Features

- **AI-Powered Feedback**: Get intelligent writing suggestions from Claude AI
- **Multiple Personas**: Choose from different writing styles
  - Hemingway (direct, concise)
  - Formal (professional, structured)
  - Academic (scholarly, precise)
  - Creative (vivid, engaging)
  - General (balanced feedback)
- **Color-Coded Suggestions**: Each persona's suggestions appear in different colors in the quickfix list
- **Multiple Modes**:
  - Inline suggestions linked to specific lines
  - Summary feedback on the entire document
  - Detailed comments on writing style
- **Quick Access**: Keyboard shortcuts for all major functions
- **Aggregate Mode**: Combine suggestions from all personas in a single view

## Installation

### Prerequisites

- Vim 8.0+ or Neovim
- Python 3.13+
- Anthropic API key (for Claude AI access) or OpenAI compatible key (eg litellm)

### Using a Plugin Manager

#### Vim-Plug
```vim
Plug 'yourusername/vim-ai-suggestions'
```

#### Vundle
```vim
Plugin 'yourusername/vim-ai-suggestions'
```

### Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/vim-ai-suggestions.git
```

2. Set up the Python script:
```bash
mkdir -p ~/bin
cp vim-ai-suggestions/scripts/vim-ai-assistant.py ~/bin/
chmod +x ~/bin/vim-ai-assistant.py
```

3. Install the Python dependencies:
The python script uses `uv` ensure it is installed on your system and it will take care of the rest. 

4. Create a configuration file with your API key:
set in the script directly

5. Install the Vim plugin:
```bash
mkdir -p ~/.vim/plugin
cp vim-ai-suggestions/plugin/vim-ai-suggestions.vim ~/.vim/plugin/
```

## Configuration

Add to your `.vimrc`:

```vim
" Set path to the AI assistant script (adjust if needed)
let g:ai_assistant_path = expand('~/bin/vim-ai-assistant.py')

" Optional: Change default persona
let g:ai_current_persona = 'general'

" Optional: Customize available personas
let g:ai_personas = ['general', 'hemingway', 'formal', 'academic', 'creative', 'your_custom_persona']
```

## Usage

### Basic Commands

```vim
:AISuggest       " Get general suggestions in a split window
:AIInline        " Get inline suggestions in quickfix list
:AISummary       " Get a summary of feedback
:AIAll           " Get suggestions from all personas at once (combined view)
```

### Persona-Specific Commands

```vim
:HemingwaySuggest  " Get Hemingway-style suggestions
:FormalInline      " Get inline formal suggestions
:AcademicSummary   " Get summary in academic style
" etc.
```

### Changing Personas

```vim
:AIPersona hemingway  " Switch to Hemingway style
:AIPersona formal     " Switch to formal style
" etc.
```

### Keyboard Shortcuts

- `<Leader>as` - Get suggestions with current persona
- `<Leader>ai` - Get inline suggestions with current persona
- `<Leader>au` - Get summary with current persona
- `<Leader>aa` - Get suggestions from all personas
- `<Leader>ap` - Open persona selection menu

## Customizing the Plugin

### Adding a Custom Persona

1. Edit the Python script to add your persona to the `persona_prompts` dictionary:

```python
persona_prompts = {
    # ... existing personas ...
    "your_persona": "Your custom system prompt describing the personality and focus of this persona",
}
```

2. Update your Vim configuration to include the new persona:

```vim
let g:ai_personas = ['general', 'hemingway', 'formal', 'academic', 'creative', 'your_persona']
```

### Changing Colors

The colors for different personas are defined in the `s:HighlightAIPersonas()` function. You can modify these to match your colorscheme:

```vim
highlight qfPersonaHemingway ctermfg=red guifg=#FF5555
highlight qfPersonaFormal ctermfg=yellow guifg=#FFAA55
" etc.
```

## Troubleshooting

### Script Path Issues

If Vim can't find the Python script:
- Check that `g:ai_assistant_path` is set correctly in your `.vimrc`
- Ensure the script has executable permissions (`chmod +x`)

### API Response Errors

If you get errors when running commands:
- Check your internet connection
- Verify your API key is valid
- Check that the Python script can be run from the command line

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Anthropic for Claude AI
- Vim community for inspiration and support
