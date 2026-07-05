# Contributing to pictor

Thank you for helping improve pictor. Before you open a PR, read the
attribution section below — this project carries upstream license obligations
that differ from sibling repos like [viser](https://github.com/vbasky/viser) and
[revelo](https://github.com/vbasky/revelo).

---

## Attribution & license (read first)

### Lineage

pictor is derived from **oxibonsai**, originally authored and distributed by
**COOLJAPAN OU** under the Apache License 2.0. pictor renames and continues
that codebase; it is not a clean-room rewrite.

| Document | Purpose |
| --- | --- |
| [LICENSE](../LICENSE) | Apache License 2.0 text + copyright holders |
| [NOTICE](../NOTICE) | Required upstream attribution (Apache §4(d)) |

### Copyright holders

- **COOLJAPAN OU** — original oxibonsai work (2024–2026)
- **Vikram Bhaskaran** — pictor modifications and continuation (2026)

### Contributor obligations

By submitting a pull request, you agree that:

1. **Your contribution is licensed under Apache-2.0**, compatible with the
   existing codebase.
2. **You do not remove** COOLJAPAN OU copyright notices, the LICENSE file, or
   the NOTICE file.
3. **You do not relicense** inherited oxibonsai code to BSD, MIT, or other
   terms without written permission from COOLJAPAN OU.
4. **Modified files** should make the change intent clear — a good commit message
   is sufficient for most edits; large rewrites may warrant a brief file-header
   note if attribution boundaries shift.

### What you may *not* assume

- pictor is **not** wholly owned by the pictor maintainers. COOLJAPAN OU retains
  copyright in the original work.
- Matching viser/revelo's BSD-2-Clause license in pictor would **violate**
  upstream Apache obligations unless COOLJAPAN OU grants a relicensing exception
  or the code is replaced with an independent implementation.

### Shipping binaries or crates

Distributions (crates.io tarballs, Docker images, git clones) must include:

- `LICENSE` (Apache 2.0)
- `NOTICE` (upstream attribution)
- Any existing copyright headers in source files you redistribute

---

## Architecture

```text
pictor/
├── crates/
│   ├── pictor-core/        GGUF parser, quant block types, model config
│   ├── pictor-kernels/     1-bit / ternary dequant, GEMV, GEMM (CPU + GPU)
│   ├── pictor-model/       Qwen3 transformer, KV cache, attention
│   ├── pictor-runtime/     Inference engine, sampling, speculative decoding
│   ├── pictor-tokenizer/   Pure Rust BPE / Unigram / WordPiece tokenizer
│   ├── pictor-rag/         Retrieval-augmented generation
│   ├── pictor-eval/        Model evaluation harness
│   ├── pictor-serve/       OpenAI-compatible HTTP server
│   ├── pictor-image/       FLUX.2 text-to-image pipeline
│   └── pictor/             Facade crate re-exporting the stack
├── docs/
├── ROADMAP.md
├── LICENSE
└── NOTICE
```

Per-crate status and history: `crates/*/TODO.md`. Workspace priorities:
[ROADMAP.md](../ROADMAP.md).

---

## Development setup

```bash
# Clone and build (CPU)
cargo build --workspace

# Apple Silicon GPU
cargo build --workspace --release --features metal

# NVIDIA GPU
cargo build --workspace --release --features native-cuda

# Run workspace tests
cargo test --workspace

# Faster test runner (if installed)
cargo nextest run --workspace
```

MSRV is declared in the workspace `Cargo.toml` (currently 1.86).

---

## Coding standards

- **Parity first.** Kernel and pipeline changes must preserve or improve oracle
  gates (image stages: cos ≥ 0.999; LLM: cross-tier correctness tests).
- **Pure Rust default.** No new FFI unless there is an extraordinary justification
  and it is feature-gated.
- **CPU fallback.** GPU paths must not remove the CPU reference path.
- **Focused PRs.** One logical change per PR; avoid drive-by refactors.
- **Tests.** New behaviour needs tests; bug fixes need a regression test when
  practical.

---

## High-leverage open work

See [ROADMAP.md](../ROADMAP.md) for the full priority list. Good first targets
for contributors with hardware access:

| Priority | Item |
| --- | --- |
| P0 | CUDA Q1 batched-prefill cap-of-8 correctness fix |
| P0 | CUDA batched TQ2 prefill + parity tests |
| P1 | VAE tiling for >512px image decode |
| P1 | Unified `pictor` CLI (image + chat + serve) |

---

## Pull request checklist

- [ ] `cargo test` (or `cargo nextest run`) passes for affected crates
- [ ] No LICENSE / NOTICE / copyright-header removals
- [ ] Commit messages explain *why*, not just *what*
- [ ] GPU kernel changes note hardware used for validation (or `// TODO(CI-GPU)`)

---

## Questions

Open a GitHub issue for design questions before large refactors. For roadmap
alignment, check [ROADMAP.md](../ROADMAP.md) first.