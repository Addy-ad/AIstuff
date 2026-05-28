## My first Agentic coding project

This is a simple, canvas-based implementation of the classic Flappy Bird game, built with pure JavaScript in VSCode (using VSCode/VScodium). 
It demonstrates fundamental game loop structure, collision detection, scoring, and basic asset management within a single HTML file.

- **Local LLM Integration:** The core logic and structure of this game were heavily guided by a local Large Language Model.
- **Model Used:** `Ministral 3B`
- **Role:** The LLM was instrumental in generating the initial structure, defining the object properties (bird physics, pipe generation), implementing the complex drawing routines, and debugging the collision logic.

> *This project showcases the potential of local LLMs for rapidly prototyping game mechanics when guided by an agentic process.*
> 

<img width="2052" height="1061" alt="image" src="https://github.com/user-attachments/assets/c944d821-a88a-418b-ac38-bd7db8ca0f36" />


### 💻 Technology Stack

- **Language:** JavaScript
- **Rendering:** HTML Canvas API
- **Logic:** Pure JavaScript implementation
- **Styling:** Embedded CSS for presentation and game container layout.

### 🛠️ How to Run Locally

1. **Save the Code:** Save the provided HTML code as an `Addysflappybird.html` file.
2. **Open:** Open `Addysflappybird.html` in any modern web browser.
3. **Play:** Use the SPACEBAR or left click the mouse or touchscreen (in mobile) to jump!

### 📊 Game Mechanics Breakdown

- **Bird Physics:** The bird has basic velocity, gravity, and a strongjump force.
- **Pipes:** Pipes move from right to left. New pipes spawn periodically when the screen scrolls past the current set.
- **Scoring:** The score is incremented when the bird successfully passes a pipe.
- **Difficulty Scaling:** The `pipeSpeed` increases over time to ramp up the challenge.
