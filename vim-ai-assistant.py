#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "openai",
# ]
# ///

import os
import sys
import json
import argparse
import tempfile
import openai

def get_api_key():
    """Get API key from environment or config file"""
    return ""

def get_suggestions(text, model, mode, persona):
    """Get suggestions from AI model with specific persona"""
    client = openai.OpenAI(api_key=get_api_key(), base_url='')
    
    # Define personas
    persona_prompts = {
        "hemingway": "You are Ernest Hemingway providing writing feedback. Use short, direct sentences. Be straightforward. Focus on clarity and brevity. Cut unnecessary words.",
        "formal": "You are a formal writing coach focused on professional communication. Emphasize proper structure, sophisticated vocabulary, and adherence to style guides.",
        "academic": "You are an academic writing consultant. Focus on precise terminology, logical structure, proper citations, and scholarly tone appropriate for academic publications.",
        "creative": "You are a creative writing mentor. Emphasize vivid imagery, engaging narrative, character development, and emotional impact.",
        "general": "You are a helpful writing assistant providing constructive feedback."
    }
    
    # Get system prompt for selected persona
    system_prompt = persona_prompts.get(persona, persona_prompts["general"])
    
    # Add persona identifier prefix for quickfix filtering
    prefix = f"[{persona.upper()}] " if mode == "inline" else ""
    
    # Define prompts by mode
    prompt_by_mode = {
        "inline": f"Review this text and suggest specific improvements. Format each suggestion as: 'LINE_NUMBER: {prefix}SUGGESTION'",
        "comments": "Review this text and provide 3-5 helpful comments on how it could be improved. Be specific and concise.",
        "summary": "Provide a brief summary of the strengths and weaknesses of this text, along with 2-3 key recommendations."
    }
    
    prompt = prompt_by_mode.get(mode, prompt_by_mode["comments"])
    
    try:
        message = client.chat.completions.create(
            model=model,
            max_tokens=1000,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": f"{prompt}\n\nTEXT:\n{text}"}
            ]
        )
        return message.choices[0].message.content
    except Exception as e:
        return f"Error getting suggestions: {str(e)}"

def format_inline_suggestions(suggestions, filename, persona):
    """Format suggestions for Vim quickfix list with persona-specific types"""
    lines = suggestions.strip().split("\n")
    quickfix_entries = []
    
    # Map personas to quickfix entry types
    # Vim recognizes these types: E (error), W (warning), I (info), N (note)
    persona_types = {
        "hemingway": "E",  # Red for direct Hemingway style
        "formal": "W",     # Yellow/Orange for formal suggestions
        "academic": "I",   # Blue for academic style
        "creative": "N",   # Green/Cyan for creative suggestions
        "general": "I"     # Default blue for general suggestions
    }
    
    # Get the type for this persona
    entry_type = persona_types.get(persona, "I")
    
    for line in lines:
        if ":" in line:
            try:
                line_num, suggestion = line.split(":", 1)
                line_num = int(line_num.strip())
                
                # Check if the suggestion already has a persona prefix
                if "[" in suggestion and "]" in suggestion:
                    # Keep the suggestion text as is
                    display_text = suggestion.strip()
                else:
                    # Add persona prefix
                    display_text = f"[{persona.upper()}] {suggestion.strip()}"
                
                quickfix_entries.append({
                    "filename": filename,
                    "lnum": line_num,
                    "text": display_text,
                    "type": entry_type
                })
            except ValueError:
                continue
    
    return json.dumps(quickfix_entries)

def main():
    """Main function"""
    parser = argparse.ArgumentParser(description='Process text and provide AI suggestions for Vim')
    parser.add_argument('file', help='File to analyze')
    parser.add_argument('--mode', default='comments', choices=['inline', 'comments', 'summary'],
                        help='Suggestion mode: inline, comments, summary (default: comments)')
    parser.add_argument('--persona', default='general', 
                        choices=['general', 'hemingway', 'formal', 'academic', 'creative'],
                        help='Writing style to emulate (default: general)')
    
    args = parser.parse_args()

    
    model = 'gpt-4.1-mini'
    
    if not args.file or not os.path.exists(args.file):
        print(f"Error: File not found: {args.file}")
        sys.exit(1)
    
    with open(args.file, "r") as f:
        text = f.read()
    
    suggestions = get_suggestions(text, model, args.mode, args.persona)
    
    if args.mode == "inline":
        # Output in quickfix format for Vim
        print(format_inline_suggestions(suggestions, args.file, args.persona))
    else:
        # Create a temporary file with suggestions
        with tempfile.NamedTemporaryFile(delete=False, mode="w", suffix=".md") as tmp:
            tmp.write(f"# AI Suggestions for {os.path.basename(args.file)} - {args.persona.title()} Style\n\n")
            tmp.write(suggestions)
            print(tmp.name, end='')

if __name__ == "__main__":
    main()
