# AsgardBench runner - OpenRouter (qwen/qwen3.5-9b)
$env:Path = "C:\Users\uytr0\.local\bin;$env:Path"

$args_str = $args -join ' '
if (-not $args_str) {
    # Default: sanity check (2 tasks)
    uv run python -m AsgardBench.Model.model_tester `
        --test magt_benchmark_sanity `
        --model qwen/qwen3.5-9b
} else {
    Invoke-Expression "uv run python -m AsgardBench.Model.model_tester $args_str"
}
