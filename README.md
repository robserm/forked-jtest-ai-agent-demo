# jtest-static-analysis and jtest-unit-testing Skills Demo (Windows, Linux, macOS)

This tutorial shows how to integrate the `jtest-static-analysis` and `jtest-unit-testing` skills into a coding agent, then use them to fix static analysis violations and generate unit tests in an example project.

Skill sources are located in repository: https://github.com/parasoft/jtest-ai-agent-skills

For the purpose of this tutorial we demonstrate integration with GitHub Copilot CLI agent, but the skill can be used with any coding agent that supports `SKILL.md` skills and has access to Jtest MCP tools.

## Step 1: Confirm prerequisites

Parasoft Jtest 2026.1 is installed and licensed.

Clone the repository containing the Jtest skills and agents:

```bash
git clone https://github.com/parasoft/jtest-ai-agent-skills
```

Clone the repository containing the Jtest example project:

```bash
git clone https://github.com/parasoft/jtest-ai-agent-demo
```

## Step 2: Install skills and MCP tools into your coding agent

Run the one-step install script from the `scripts` directory of the cloned `jtest-ai-agent-skills` repository. It copies all AI skills and agents, and configures the Jtest MCP server in your agent's configuration.

Supported agent identifiers: `copilot-cli`, `codex-cli`

**Windows** (Command Prompt or PowerShell):
```bat
cd "jtest-ai-agent-skills\scripts"
install.bat --jtest.home "C:\Parasoft\jtest" copilot-cli
```

**Linux/macOS**:
```bash
cd "jtest-ai-agent-skills/scripts"
chmod +x install.sh
./install.sh --jtest.home /opt/parasoft/jtest copilot-cli
```

The `--jtest.home` argument can be omitted if the `JTEST_HOME` environment variable is already set.

Replace `copilot-cli` with the identifier for your agent:

```bat
install.bat --jtest.home "C:\Parasoft\jtest" codex-cli
```

> **Note:** The script installs skills and agents definitions to the agent's user-level skills directory and writes the Jtest
> MCP server entry to the agent's MCP configuration file. For GitHub Copilot, project-local
> installation is also supported — place the  `jtest-static-analysis` and `jtest-unit-testing` directories under `.github/skills/`
> and the contents of the `agents` directory under `.github/agents/` in your repository.

> **Tip:** If Python 3 is not found on Windows, the script cannot automatically update an existing
> MCP configuration file and will print the JSON fragment to add manually. See
> `[JTEST_HOME]/integration/mcp/MCP_SETUP.md` for manual setup instructions.

## Step 3: Set environment variables for the demo project

The skills are non-interactive and expect certain environment variables to be present.

PowerShell (Windows):
```powershell
$env:JTEST_HOME = "<YOUR_JTEST_INSTALLATION_DIRECTORY>"
$env:ANALYZED_PROJECT_PATH = "$env:<CLONED_PROJECTS_DIRECTORY>\jtest-ai-agent-demo"
$env:JTEST_COMMIT_FIXES = "false"
# Optional settings:
# $env:JTEST_SETTINGS = "C:\path\to\jtestcli.properties"
# $env:JTEST_FIX_ATTEMPTS = "3"
# $env:JTEST_UTA_NO_OF_MAX_FIXES = "50"
```

Command Prompt (Windows `cmd`):
```bat
set "JTEST_HOME=<YOUR_JTEST_INSTALLATION_DIRECTORY>"
set "ANALYZED_PROJECT_PATH=<CLONED_PROJECTS_DIRECTORY>\jtest-ai-agent-demo"
set "JTEST_COMMIT_FIXES=false"
rem Optional settings:
rem set "JTEST_SETTINGS=C:\path\to\jtestcli.properties"
rem set "JTEST_FIX_ATTEMPTS=3"
rem set "JTEST_UTA_NO_OF_MAX_FIXES=50"
```

Bash/Zsh (Linux/macOS):
```bash
export JTEST_HOME="<YOUR_JTEST_INSTALLATION_DIRECTORY>"
export ANALYZED_PROJECT_PATH="<CLONED_PROJECTS_DIRECTORY>/jtest-ai-agent-demo"
export JTEST_COMMIT_FIXES="false"
# Optional settings:
# export JTEST_SETTINGS="/path/to/jtestcli.properties"
# export JTEST_FIX_ATTEMPTS="3"
# export JTEST_UTA_NO_OF_MAX_FIXES="50"
```

Note:
The default configurations settings are:
- JTEST_STATIC_CONFIGURATION="builtin://Recommended Rules" for Jtest Static Analysis Skill 
- JTEST_UTA_CONFIGURATION="builtin://Create Unit Tests" for Jtest Unit Testing Skill

Change those settings if you need to use different configurations.

## Step 4: Open the demo project in your agent

Open or navigate to the demo project directory in your agent:

- **Windows:** `%JTEST_HOME%\examples\demo`
- **Linux/macOS:** `$JTEST_HOME/examples/demo`

## Step 5: Ask the agent to fix violations

Start the coding agent. 

Tips for first run:
- Keep `JTEST_COMMIT_FIXES=false` until you verify the results.
- Do not fix all the violations at once for the project, prioritizing by severity and confidence, but limit to a few fixes so you can inspect the results before potentially making more changes.

Send this prompt:

```text
Use jtest-static-analysis to fix violations in priority order, but fix at most 5 violations in this run. Do not suppress violations. After each fix, run tests and re-run Jtest verification against the baseline report as required by the skill.
```

## Step 6: Ask the agent to generate unit tests

After static-analysis fixes are applied, run the unit-testing skill to improve coverage around changed code.

Send this prompt:

```text
Use jtest-unit-testing to create unit tests for the project. Keep only passing tests in the final result.
```

Or:

```text
Use jtest-unit-testing to create unit tests for locally modified files. Keep only passing tests in the final result.
```

## Step 7: Validate the results

Manually verify the result and inspect git diff (project must be under git source control for this):

```
git status --short
git diff
```

## Step 8: Optional automatic commit mode

If you want the skill to commit each successful fix:

PowerShell (Windows):
```powershell
$env:JTEST_COMMIT_FIXES = "true"
```

Command Prompt (Windows `cmd`):
```bat
set "JTEST_COMMIT_FIXES=true"
```

Bash/Zsh (Linux/macOS):
```bash
export JTEST_COMMIT_FIXES="true"
```

Then rerun Steps 5-6.

## Step 9: Common failures and quick fixes

- `JTEST_HOME` not set or invalid: set `JTEST_HOME` and verify `jtestcli` exists there.
- `ANALYZED_PROJECT_PATH` invalid: point to `jtest-ai-agent-demo`.
- Build/tests fail: fix compilation or test failures first.
- Missing `JTEST_SETTINGS` file: correct the path or unset the variable.
- No violations found: this is a valid success state.
- No tests created: the code is either not well-testable or already well-tested.

## References

- Jtest skills used in this tutorial:
    - [`Jtest AI Integration`](https://github.com/parasoft/jtest-ai-agent-skills)
- Jtest MCP tools setup:
    - `[JTEST_HOME]/integration/mcp/README.md`
- Copilot skills docs:
    - https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-skills
- Codex CLI skills docs:
    - https://developers.openai.com/codex/skills
