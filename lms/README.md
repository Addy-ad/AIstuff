# LM Studio Reasoning & Context Control Tool

A specialized utility for local LLM users to inject "Think" and "Truncate Thinking" toggles into LM Studio models. This script automates the creation of metadata overrides, allowing users to control internal reasoning blocks and optimize VRAM/Context usage via the LM Studio UI.
This tool runs based on the ~.lmstudio\.internal\model-index-cache.json file in the lm studio folder.

## Overview

Reasoning models (like Qwen 2.5/3.5 and DeepSeek) generate long internal monologues that consume significant context tokens. This tool generates a custom configuration for your local models to:

1.  **Enable/Disable Thinking**: Toggle the visibility of the <think> block during generation.
2.  **Truncate History Thinking**: Automatically strip <think> blocks from previous chat turns to prevent the context window from filling up with old reasoning.

## How It Works

The script performs the following actions:
- Scans the `model-index-cache.json` to find your local GGUF models.
- Allows you to select a model and assign it a custom configuration name.
- Generates a `model.yaml` containing specific `customFields` that map UI toggles to Jinja variables (`enable_thinking` and `truncate_history_thinking`).

## Setup

1. Run the `.bat` script.
2. Select your target model from the list.
3. Provide a name for the new configuration.
4. The script will create the necessary directory and `model.yaml` file in your LM Studio hub folder.
5. In LM Studio, select the newly created model entry and apply a compatible Jinja template.

## Requirements

- Windows OS
- LM Studio (v0.3.0+)
- A Jinja template configured to recognize the variables `enable_thinking` and `truncate_history_thinking`.

## Technical Specifications

The generated `model.yaml` uses the following structure:
- **metadataOverrides**: Forces `reasoning: true`.
- **customFields**: Injects boolean toggles into the "Model Settings" sidebar with `setJinjaVariable` effects.


---

### Implementation Guide: Jinja Template Integration

To utilize the toggles created by this tool, your LM Studio Jinja template must be updated with the following logic.

#### 1. Define the History Boundary
Add this to the **very top** of your template. It calculates the index of the most recent user message so the template knows which "thoughts" belong to the past.

\```jinja
{%- set ns = namespace(last_user_idx=-1) -%}
{%- for m in messages -%}
    {%- if m.role == "user" -%}{%- set ns.last_user_idx = loop.index0 -%}{%- endif -%}
{%- endfor -%}
\```

#### 2. Update the Assistant Logic
Locate the section of your template handling the `assistant` role and replace it with the logic below.

\```jinja
{%- elif message.role == "assistant" -%}
    {{- '<|im_start|>assistant\n' -}}
    {%- set content = message.content | default('', true) -%}
    {%- set reasoning = message.reasoning_content or '' -%}
    
    {#- Optimization Logic -#}
    {%- if truncate_history_thinking and loop.index0 < ns.last_user_idx -%}
        {{- '<think></think>\n' -}}
    {%- elif (enable_thinking is not defined or enable_thinking == true) and reasoning -%}
        {{- '<think>\n' + reasoning.strip() + '\n</think>\n\n' -}}
    {%- endif -%}
    
    {{- content.strip() -}}
    {{- '<|im_end|>\n' -}}
\```

#### 3. Update the Generation Prompt
To ensure the `enable_thinking` toggle works for the current (active) response, use this block at the end of your template:

\```jinja
{%- if add_generation_prompt -%}
    {{- '<|im_start|>assistant\n' -}}
    {%- if enable_thinking is defined and enable_thinking == false -%}
        {{- '<think></think>\n' -}}
    {%- else -%}
        {{- '<think>\n' -}}
    {%- endif -%}
{%- endif -%}
\```
