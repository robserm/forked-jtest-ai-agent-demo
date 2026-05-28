# jtest-static-analysis and jtest-unit-testing Skills Demo (Windows, Linux, macOS)

This tutorial shows how to integrate the `jtest-static-analysis` and `jtest-unit-testing` skills into a coding agent, then use them to fix static analysis violations and generate unit tests in an example project.

Skill sources are located in repository: [parasoft/jtest-ai-agent-skills](https://github.com/parasoft/jtest-ai-agent-skills)

For the purpose of this tutorial we demonstrate integration with GitHub Copilot CLI agent, but the skill can be used with any coding agent that supports `SKILL.md` skills and has access to Jtest MCP tools.

---

## Overview

This repository is an example java project that demonstrates how the Parasoft Jtest AI agent skills can be used to automatically fix static analysis violations inside a GitHub CI/CD pipeline.

The key idea is that when a pull request is created, the pipeline runs Jtest, detects violations, and then invokes an AI coding agent (GitGub Copilot, or others) equipped with Jtest skills and MCP tools to automatically fix the violations, commit the fixes to a new branch, and open a new pull request.

The Jtest AI Agent skills used in this project are taken from the [parasoft/jtest-ai-agent-skills](https://github.com/parasoft/jtest-ai-agent-skills) repository.


## Prerequisites

The following prerequisites apply to both the GitHub Actions and local workstation workflows.

* Install and license Parasoft Jtest  
Parasoft Jtest 2026.1 or later must be installed and licensed on the machine (or runner) where analysis will execute. Note the installation directory — it is required for the `JTEST_HOME` setting.

* Install and configure GitHub Copilot CLI  
The GitHub Copilot CLI agent must be installed and authenticated. Refer to the [GitHub Copilot CLI documentation](https://docs.github.com/en/copilot/how-tos/copilot-cli) for installation steps.
When selecting a model, choose one capable of multi-step reasoning and tool use.

* Integrating Jtest AI Solutions with GitHub Copilot CLI  
Clone repository [parasoft/jtest-ai-agent-skills](https://github.com/parasoft/jtest-ai-agent-skills) and perform according [parasoft/jtest-ai-agent-skills#integrating-jtest-ai-solutions-with-your-coding-agent](https://github.com/parasoft/jtest-ai-agent-skills#integrating-jtest-ai-solutions-with-your-coding-agent)
using `install.sh` script to configure jtest MCP and add the skills to your agent's skill set.


## GitHub Action workflow

### 1. Preparation
1. Fork or copy this repository.
2. Set up and connect a GitHub self-hosted runner: **Settings > Actions > Runners**. See also [Prerequisites](#prerequisites) above.
3. Enable the following option in your repository: **Settings > Actions > General > Allow GitHub Actions to create and approve pull requests**.
4. Clone the repository to your local machine.
5. Configure JTEST_HOME and other settings in `.github/workflows/jtest-analyzer.config` or via environment variables as described in [parasoft/jtest-ai-agent-skills#configuration-reference](https://github.com/parasoft/jtest-ai-agent-skills#configuration-reference)

### 2. Introducing a Code Change
1. Create a `feature` branch in the local repository.
2. Introduce a change to the source code.
3. Push the branch to the remote GitHub repository.
4. Open a pull request on GitHub to merge your `feature` branch into your default branch (`master` or `main`).

### 3. CI/CD Pipeline Execution
Opening a pull request triggers the workflow defined in [.github/workflows/jtest-ai-agent-workflow.yml](.github/workflows/jtest-ai-agent-workflow.yml):

1. The project is built.
2. Jtest runs static analysis by running [jtest-analyze.sh](https://github.com/parasoft/jtest-ai-agent-skills/blob/master/skills/jtest-static-analysis/scripts/jtest-analyze/jtest-analyze.sh) and archives the reports as build artifacts.
3. If violations are found, the AI Autofix step is triggered:
  - A new `autofix/pr-<number>/<timestamp>` branch is created.
  - The AI agent processes violations rule by rule.
  - Each fix is verified by running [build-verify.sh](https://github.com/parasoft/jtest-ai-agent-skills/blob/master/skills/jtest-static-analysis/scripts/build-verify/build-verify.sh).
  - Verified fixes are committed to the `autofix` branch (one commit per rule).
  - The `autofix` branch is pushed to the remote repository.
  - A pull request from `autofix` into your `feature` branch is opened, and a comment with links is posted on the original PR.

### 4. Reviewing the Autofix Pull Request
1. Review the changes proposed in the `autofix` branch.
2. Merge the `autofix` branch into your `feature` branch.
3. Verify that the pipeline passes on the updated `feature` branch.
4. Merge the `feature` branch into your default branch (`master` or `main`).


## Local workstation workflow

### 1. Preparation  
1. Clone the repository to your local machine.
2. Configure JTEST_HOME and other settings in `.github/workflows/jtest-analyzer.config` or via environment variables as described in [parasoft/jtest-ai-agent-skills#configuration-reference](https://github.com/parasoft/jtest-ai-agent-skills#configuration-reference)  
a) You may omit `ANALYZED_PROJECT_PATH` since it is set automatically in `.github/workflow/jtest-ai-agent-run.sh` script   
b) Ensure that `JTEST_COMMIT_FIXES` is set to `false`  

### 2. Manually execute the workflow
1. Run script `.github/workflow/jtest-ai-agent-run.sh`

### 3. Review changes
1. Review the changes applied on project code.
   
