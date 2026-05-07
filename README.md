# AsgardBench

A benchmark for evaluating **Vision-Language Models (VLMs)** on embodied household tasks in a 3D simulated environment.

📄 **Paper:** [AsgardBench — Evaluating Visually Grounded Interactive Planning Under Minimal Feedback](https://arxiv.org/abs/2603.15888)

---

## What is AsgardBench?

AsgardBench tests how well a VLM can act as an autonomous agent inside a 3D home environment ([AI2-THOR](https://ai2thor.allenai.org/)). At each step, the model receives:

- A **task description** (e.g., "Make coffee in the mug")
- An **egocentric image** (first-person view of the current scene)
- A list of **available objects** in the room
- A **history** of previous actions and their outcomes

The model must choose the next action (e.g., `PICKUP Mug`, `TOGGLE_ON CoffeeMachine`) until the task is complete or the step limit is reached.

**Key facts:**
- 🏠 **108 task instances** across 12 task types (Make coffee, Cook egg, Set table, Clean mirror, …)
- 👁️ Egocentric RGB images at 1024×1024
- 🎯 Automatic success evaluation — no human annotation needed
- 🔌 Works with any **OpenAI-compatible API** (OpenAI, OpenRouter, Azure, vLLM, …)

---

## Supported Actions

| Action | Description |
|--------|-------------|
| `FIND <object>` | Navigate to and face the object |
| `PICKUP <object>` | Pick up the object |
| `PUT <object>` | Place the held object |
| `OPEN <object>` | Open a container (fridge, cabinet, …) |
| `CLOSE <object>` | Close a container |
| `TOGGLE_ON <object>` | Switch on an appliance |
| `TOGGLE_OFF <object>` | Switch off an appliance |
| `CLEAN <object>` | Clean the object (with a cloth/spray) |
| `SLICE <object>` | Slice the object |
| `DRINK <object>` | Drink from the object |
| `EMPTY <object>` | Empty the contents |
| `SPRAY <object>` | Spray the object |

---

## Installation

### Prerequisites

| Requirement | Notes |
|-------------|-------|
| **Linux or WSL2** | AI2-THOR only runs on Linux/macOS. Windows users: see [Windows Setup](#windows-setup-wsl2) |
| **Python 3.10+** | Managed automatically by `uv` |
| **uv** | Fast Python package manager |
| **API key** | Any OpenAI-compatible endpoint (OpenAI, OpenRouter, Azure, …) |
| **xvfb** | Required for headless Linux rendering (no GPU needed) |

### Install uv

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc   # or restart the terminal
```

### Clone and Install

```bash
git clone https://github.com/racoco083/AsgardBench.git
cd AsgardBench
uv sync
```

### Install xvfb (headless display — no GPU required)

```bash
sudo apt-get install -y xvfb
```

---

## Windows Setup (WSL2)

AI2-THOR requires Linux. On Windows, use WSL2 (Windows Subsystem for Linux).

### Step 1 — Install WSL2 + Ubuntu

Open **PowerShell as Administrator** and run:

```powershell
wsl --install
```

Restart your PC, then complete the Ubuntu username/password setup.

### Step 2 — Install dependencies in Ubuntu

```bash
sudo apt-get update
sudo apt-get install -y xvfb libgl1-mesa-dri libglib2.0-0
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc
```

### Step 3 — Set up the project

The Windows filesystem is accessible from WSL2 at `/mnt/c/...`. To avoid permission issues with the virtual environment, create it on the Linux filesystem:

```bash
cd /mnt/c/Users/<your-name>/AsgardBench

# Create the venv on the Linux filesystem (not on /mnt/c/)
UV_PROJECT_ENVIRONMENT=~/.venvs/asgardbench uv sync
```

### Step 4 — Run

```bash
UV_PROJECT_ENVIRONMENT=~/.venvs/asgardbench \
  xvfb-run -a uv run python -m AsgardBench.Model.model_tester \
  --test magt_benchmark_sanity \
  --model <your-model>
```

---

## Configuration

### 1. Create the `.env` file

```bash
cp .env.example .env
```

Edit `.env` with your API credentials:

```bash
OPENAI_API_KEY=your-api-key
OPENAI_BASE_URL=https://api.openai.com/v1   # change for other providers
OPENAI_CACHE_CONTROL=automatic              # use "explicit" for Anthropic/Google
```

### 2. Provider Examples

| Provider | `OPENAI_BASE_URL` | Notes |
|----------|--------------------|-------|
| **OpenAI** | `https://api.openai.com/v1` | Default |
| **OpenRouter** | `https://openrouter.ai/api/v1` | Access 100+ models |
| **Azure OpenAI** | `https://<resource>.openai.azure.com/` | Also set `OPENAI_API_VERSION` |
| **vLLM (local)** | `http://localhost:8000/v1` | For self-hosted models |

**OpenRouter example** (runs any model without a local GPU):

```bash
OPENAI_API_KEY=sk-or-v1-...
OPENAI_BASE_URL=https://openrouter.ai/api/v1
```

Then run with any model available on OpenRouter:

```bash
xvfb-run -a uv run python -m AsgardBench.Model.model_tester \
    --test magt_benchmark_sanity \
    --model qwen/qwen3.5-9b
```

---

## Running the Benchmark

### Sanity Check (2 tasks — ~5 minutes)

Run this first to verify your setup is working:

```bash
# Linux / WSL2 (headless)
xvfb-run -a uv run python -m AsgardBench.Model.model_tester \
    --test magt_benchmark_sanity \
    --model gpt-4o

# macOS (with display)
uv run python -m AsgardBench.Model.model_tester \
    --test magt_benchmark_sanity \
    --model gpt-4o
```

### Full Benchmark (108 tasks)

```bash
xvfb-run -a uv run python -m AsgardBench.Model.model_tester \
    --test magt_benchmark \
    --model gpt-4o
```

The benchmark automatically **resumes** if interrupted — already-completed tasks are skipped.

### All CLI Options

```
--test               Test set name (magt_benchmark | magt_benchmark_sanity)  [required]
--model              Model identifier, e.g. "gpt-4o" or "qwen/qwen3.5-9b"   [required]
--rep                Repetition number for multiple runs (default: 1)
--temperature        Sampling temperature (default: 0.0)
--max_completion_tokens  Max tokens in model response (default: 8192)
--text_only          Send no images — text-only mode
--feedback_type      Action feedback level: none | simple | detailed
--previous_image     Include previous step's image: none | color | grayscale
--use_memory         Enable agent memory (default: True)
```

Run `uv run python -m AsgardBench.Model.model_tester --help` for the full list.

---

## Results

### Output Directory Structure

Results are written to `Test/` after each task completes:

```
Test/
└── magt_benchmark/
    └── gpt-4o--T0_Fs_H60_...--rep1/
        ├── test_results.json        ← per-task success/failure summary
        ├── config.json              ← run configuration snapshot
        └── Plans/
            └── coffee__FloorPlan13/
                ├── plan.json        ← full execution trace with model responses
                ├── 0_FIND Mug.png   ← egocentric image at each step
                ├── 1_PICKUP Mug.png
                └── ...
```

### Reading `test_results.json`

```json
{
  "results": [
    {
      "name": "coffee__FloorPlan13_V1",
      "success": true,
      "fail_type": null,
      "num_steps": 12
    },
    {
      "name": "turn_on_tv__FloorPlan202_V1",
      "success": false,
      "fail_type": "max_steps",
      "num_steps": 50
    }
  ]
}
```

### Generating an Aggregated Report

After one or more runs, generate an Excel report with success rates and failure breakdowns:

```bash
uv run python -m AsgardBench.Model.generate_reports --tests magt_benchmark
```

Output: `Test/results.xlsx`

### Browsing Step-by-Step Executions

Launch a visual viewer to inspect each task's execution trace (images + model responses):

```bash
uv run streamlit run AsgardBench/plan_viewer.py
```

---

## Docker

For fully containerized execution (handles xvfb automatically):

### Build

```bash
docker build -t asgardbench .
```

### Run

```bash
# Sanity check
docker run --rm \
    -e OPENAI_API_KEY=sk-... \
    -e OPENAI_BASE_URL=https://openrouter.ai/api/v1 \
    asgardbench \
    --test magt_benchmark_sanity --model qwen/qwen3.5-9b

# Full benchmark — save results to host
docker run --rm \
    -v $(pwd)/Test:/app/Test \
    -e OPENAI_API_KEY=sk-... \
    -e OPENAI_BASE_URL=https://openrouter.ai/api/v1 \
    asgardbench \
    --test magt_benchmark --model qwen/qwen3.5-9b
```

---

## Benchmark Data Format

Each task in `Generated/magt_benchmark*/` has a `plan.json`:

```jsonc
{
  "name": "coffee__FloorPlan13_V1",
  "task_description": "Make coffee in the mug",
  "scene": "FloorPlan13",           // AI2-THOR scene
  "step_count": 25,                  // reference number of steps
  "initial_pose": {                  // agent starting position
    "position": {"x": 0.5, "y": 0.9, "z": -1.2},
    "rotation": 90,
    "horizon": 30
  },
  "goal": {                          // success conditions (checked automatically)
    "goal_type": "ObjectStateGoal",
    "conditions": [...]
  },
  "setup_actions": [...],            // scene initialization actions
  "object_setup": {...}              // object placements and states
}
```

---

## Citation

```bibtex
@misc{tupini2026asgardbench,
  title={AsgardBench - Evaluating Visually Grounded Interactive Planning Under Minimal Feedback}, 
  author={Andrea Tupini and Lars Liden and Reuben Tan and Yu Wang and Jianfeng Gao},
  year={2026},
  eprint={2603.15888},
  archivePrefix={arXiv},
  primaryClass={cs.AI},
  url={https://arxiv.org/abs/2603.15888}
}
```
