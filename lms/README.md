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


Example Jinja temple to utilize the enable_thinking toggle
```
{%- if add_generation_prompt -%}
    {{- '<|im_start|>assistant\n' -}}
    {%- if enable_thinking is defined and enable_thinking == false -%}
        {{- '<think></think>\n' -}}
    {%- else -%}{{- '<think>\n' -}}{%- endif -%}
{%- endif -%}
