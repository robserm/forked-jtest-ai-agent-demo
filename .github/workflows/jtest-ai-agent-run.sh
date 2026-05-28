#!/bin/bash

set -euo pipefail

# This script should run AI Agent for jtest Static Analysis with AI Autofix and/or JUnit test generation for uncovered code.
# It is intended to be executed by 'jtest-ai-agent-workflow.yml' but can also be run manually.


# == jtest skill settings ==

# Automatically configure the path to the analyzed project
SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
export ANALYZED_PROJECT_PATH="$(dirname $(dirname $(dirname "${SCRIPT_DIR}")))"

# Configure the path to Jtest installation directory.
# You may also configure this path in jtest-skill.config at project root (for more details see jtest-skill.config.template at jtest-ai-demo-skills repository).
#export JTEST_HOME="<JTEST INSTALLATION PATH>"


# == Prompts ==

# example prompts for usage of different jtest skills. For more details look at jtest-ai-demo-skills repository.
PROMPT="Use jtest-static-analysis to fix violations in priority order. Fix at most 5 violations in this run. Do not suppress violations. After each fix, verify the build and re-run Jtest analysis to confirm the violation is gone."
#PROMPT="Use jtest-unit-testing to automatically generate JUnit tests and increase code coverage for an existing project."


# == Copilot ==

# Execute the prompt with Copilot
copilot --allow-all --no-ask-user -s -p "${PROMPT}"


# == Codex ==

# Execute the prompt with Codex
# codex exec -s danger-full-access --config allow_login_shell=false "${PROMPT}"
