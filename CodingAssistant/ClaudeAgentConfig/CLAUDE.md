# Global Claude Code Instructions



## Project Documentation Requirements



### CLAUDE.md (Project Memory)



When starting work on a new Xcode project, if no `CLAUDE.md` exists in the project root, create one with:

- Project overview and purpose
- Key architecture decisions
- Important conventions and patterns used
- Build/run instructions
- Any quirks or gotchas specific to this project

### Journal.md (Learning Journal)



**CRITICAL**: Every project MUST have a `Journal.md` file in the project root. This is a living document that should be updated throughout development.

This file should be written in an engaging, educational style - NOT boring technical documentation. Make it memorable and fun to read.

#### Required Sections:



1. **The Big Picture** - What is this app? Explain it like you're telling a friend at a coffee shop.
2. **Architecture Deep Dive** - The technical architecture explained with analogies. How do the pieces fit together? Think of it like explaining how a restaurant kitchen works, not like reading a blueprint.
3. **The Codebase Map** - Structure of the code. Where does what live? How do you navigate this thing?
4. **Tech Stack & Why** - Technologies used and WHY we chose them. Not just "we used SwiftUI" but "we used SwiftUI because..."
5. **The Journey** - A running log of:
   - Bugs we encountered and how we squashed them (be specific!)
   - "Aha!" moments and lessons learned
   - Potential pitfalls and how to avoid them
   - New technologies/patterns discovered
6. **Engineer's Wisdom** - Best practices demonstrated in this project. How do good engineers think? What patterns emerged? What would a senior engineer do differently?
7. **If I Were Starting Over...** - Retrospective insights. What would we do differently knowing what we know now?

#### Writing Style Guidelines:



- Use analogies liberally (e.g., "The ViewModel is like a translator between...")
- Include "war stories" about bugs
- Write like you're explaining to a smart friend, not writing a textbook
- Use humor where appropriate
- Make technical concepts stick with memorable comparisons
- Include the "why" behind every decision, not just the "what"

#### Update Triggers:



Update Journal.md whenever:

- Fixing a non-trivial bug
- Making an architectural decision
- Learning something new
- Encountering a gotcha or pitfall
- Completing a significant feature

## Xcode/Swift Conventions



- Follow modern SwiftUI patterns
- Prefer Swift Concurrency (async/await) over completion handlers
- Use dependency injection for testability