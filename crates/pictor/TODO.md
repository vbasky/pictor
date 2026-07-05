# pictor TODO

> v0.2.2 — 2026-06-06
> **STABLE** — umbrella facade crate, re-exports all pictor-* subcrates.

## Status

This is the top-level facade crate. It has no independent logic — it re-exports
`pictor-core`, `pictor-kernels`, `pictor-model`, `pictor-runtime`,
and optionally `pictor-rag`, `pictor-eval`, `pictor-tokenizer`, and
`pictor-serve` via feature flags.

All substantive work lives in the subcrates. See the workspace-level `TODO.md`
for the full phase history and `/crates/*/TODO.md` for per-crate status.

## Features

| Feature              | Status       | Notes                                  |
|----------------------|--------------|----------------------------------------|
| `default`            | Stable       | Core inference (no server)             |
| `server`             | Stable       | OpenAI-compatible HTTP server          |
| `rag`                | Stable       | Retrieval-augmented generation         |
| `native-tokenizer`   | Stable       | pictor-tokenizer integration        |
| `eval`               | Stable       | ARC/GSM8K evaluators                   |
| `full`               | Stable       | All of the above                       |
| `wasm`               | Stable       | WASM32 target (no GPU)                 |
| `simd-avx2/avx512`   | Stable       | x86_64 SIMD tiers                      |
| `simd-neon`          | Stable       | AArch64 NEON (default-on Apple/ARM)    |

## Deferred

- [ ] Python bindings (PyO3) — pending user request
- [ ] npm/WASM package auto-publish integration
