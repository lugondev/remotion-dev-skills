SKILL_DIR := skills/remotion
SKILL_FILE := $(SKILL_DIR)/SKILL.md
SKILL_PATH := $(shell pwd)/$(SKILL_FILE)

.PHONY: help list opencode claude copilot cursor all

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  list      Show current setup status for each agent"
	@echo "  opencode  (Re)install remotion skill for opencode (project-local)"
	@echo "  claude    (Re)install remotion skill for Claude Code (CLAUDE.md)"
	@echo "  copilot   (Re)install remotion skill for GitHub Copilot"
	@echo "  cursor    (Re)install remotion skill for Cursor/Codex"
	@echo "  all       (Re)install remotion skill for all agents"

list:
	@echo "=== Remotion Skill Setup Status ==="
	@printf "opencode: "
	@if [ -f .opencode/opencode.json ]; then python3 -c "import json; c=json.load(open('.opencode/opencode.json')); p=c.get('skills',{}).get('remotion',{}).get('path',''); print('INSTALLED ('+p+')' if p else 'MISSING')"; else echo "MISSING"; fi
	@printf "claude:   "
	@if grep -q "remotion" CLAUDE.md 2>/dev/null; then echo "INSTALLED (CLAUDE.md)"; else echo "MISSING"; fi
	@printf "copilot:  "
	@if [ -f .github/copilot-instructions.md ] && grep -q "remotion" .github/copilot-instructions.md 2>/dev/null; then echo "INSTALLED (.github/copilot-instructions.md)"; else echo "MISSING"; fi
	@printf "cursor:   "
	@if [ -f .cursor/rules/remotion.mdc ]; then echo "INSTALLED (.cursor/rules/remotion.mdc)"; else echo "MISSING"; fi

opencode:
	@echo "Installing remotion skill for opencode..."
	@mkdir -p .opencode
	python3 -c "import json; cfg=json.load(open('.opencode/opencode.json')) if __import__('os').path.exists('.opencode/opencode.json') else {}; cfg.setdefault('skills',{}); cfg['skills']['remotion']={'description':'Create, edit, and render videos with Remotion','path':'$(SKILL_PATH)'}; json.dump(cfg, open('.opencode/opencode.json','w'), indent=2)"
	@echo "opencode config written to .opencode/opencode.json"

claude:
	@echo "Installing remotion skill for Claude Code..."
	@echo '# Remotion Skills' > CLAUDE.md
	@echo '' >> CLAUDE.md
	@echo 'This project provides AI agent skills for Remotion video creation.' >> CLAUDE.md
	@echo '' >> CLAUDE.md
	@echo '## Remotion Skill' >> CLAUDE.md
	@echo '' >> CLAUDE.md
	@echo 'Load the Remotion skill at $(SKILL_PATH) when working with video compositions.' >> CLAUDE.md
	@echo 'Skills provide specialized instructions and workflows for specific tasks.' >> CLAUDE.md
	@echo 'Use the skill tool to load a skill when a task matches its description.' >> CLAUDE.md
	@echo 'CLAUDE.md updated'

copilot:
	@echo "Installing remotion skill for GitHub Copilot..."
	@mkdir -p .github
	@echo '# Copilot Instructions' > .github/copilot-instructions.md
	@echo '' >> .github/copilot-instructions.md
	@echo '## Remotion' >> .github/copilot-instructions.md
	@echo '' >> .github/copilot-instructions.md
	@echo 'This project uses Remotion for video creation. Reference the skill documentation at $(SKILL_PATH) for best practices, code patterns, and API usage.' >> .github/copilot-instructions.md
	@echo '.github/copilot-instructions.md updated'

cursor:
	@echo "Installing remotion skill for Cursor/Codex..."
	@mkdir -p .cursor/rules
	@{ \
		echo '---'; \
		echo 'description: Remotion video creation best practices'; \
		echo 'globs: "**/*.{ts,tsx}"'; \
		echo '---'; \
		echo ''; \
		echo 'This project uses Remotion for video creation.'; \
		echo ''; \
		echo 'Reference the full skill documentation at:'; \
		echo '$(SKILL_PATH)'; \
		echo ''; \
		echo 'For video layout guidance, see:'; \
		echo '$(shell pwd)/$(SKILL_DIR)/rules/video-layout.md'; \
	} > .cursor/rules/remotion.mdc
	@echo 'Cursor rule written to .cursor/rules/remotion.mdc'

all: opencode claude copilot cursor
	@echo ""
	@echo "=== All agents configured ==="
	@$(MAKE) list
