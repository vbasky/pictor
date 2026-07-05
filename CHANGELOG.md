# Changelog

## [0.1.0] - 2026-07-06

Initial public release of pictor — a Pure Rust generative inference stack derived
from [oxibonsai](https://github.com/cool-japan/oxibonsai) (COOLJAPAN OU,
Apache-2.0), continued under new naming and independent maintenance.

### Added

- **Workspace** — ten crates: `pictor-core`, `pictor-kernels`, `pictor-model`,
  `pictor-runtime`, `pictor-tokenizer`, `pictor-rag`, `pictor-eval`,
  `pictor-serve`, `pictor-image`, and facade `pictor`.
- **Extreme quantization** — Q1_0_g128 (1-bit), TQ2_0_g128 (ternary), K-quants,
  Q4/Q8, and FP8 blocks in GGUF with streaming parser, writer, and model cards.
- **Kernel fabric** — scalar + AVX2/AVX-512 + NEON tiers; Metal fused
  full-forward; CUDA NVRTC + CUDA Graphs; 675+ kernel tests.
- **LLM stack** — Qwen3 transformer, paged KV, flash attention, speculative
  decoding, grammar constraints (BNF/GBNF/JSON Schema/regex), tool calling,
  continuous batching, prefix cache, RAG hooks, OpenAI-compatible server.
- **Image pipeline** — FLUX.2-Klein text-to-image: Qwen3 text encoder, TQ2 DiT
  GGUF, VAE decode; parity harnesses at cosine ≥ 0.999 per stage.
- **Documentation** — README, ROADMAP (expanded generative-inference vision),
  CONTRIBUTING, NOTICE, banner assets under `docs/`.
- **Release tooling** — `scripts/release.sh`, CI and release GitHub workflows.

### Performance (reference hardware, 512×512, 4 steps)

- Apple Silicon (M3-class, Metal): ≈ 52–62 s
- NVIDIA A4000-class (CUDA): ≈ 31.7 s
- CPU (Rayon + NEON): ≈ 10–15 min

### Attribution

Copyright © 2024–2026 COOLJAPAN OU (original oxibonsai). Modifications © 2026
Vikram Bhaskaran. Licensed under Apache-2.0 — see [LICENSE](LICENSE) and
[NOTICE](NOTICE).