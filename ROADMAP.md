# pictor roadmap

*pictor* is Latin for *painter*. The name is deliberate: generative AI is not one
model type — it is **creation across modalities**. pictor starts with pixels and
prose because those are the hardest to get *right* at sub-byte precision, but the
wider bet is larger:

> **A sovereign, oracle-validated inference substrate for the generative age** —
> one auditable Rust artifact that runs wherever intelligence must be created,
> constrained, and served: laptop, browser, edge appliance, private cloud, or
> multi-GPU datacenter.

Today pictor is already two production pipelines sharing one engine:

- **Text-to-image** — FLUX.2-Klein DiT (TQ2 ternary GGUF) + VAE + Qwen3 text
  encoder, parity-gated at cosine ≥ 0.999 on every stage.
- **LLM inference** — Qwen3 Bonsai family (Q1 / TQ2 GGUF) with a full runtime:
  sampling, speculative decoding, grammar constraints, tool calling, RAG, and an
  OpenAI-compatible server.

The long-term bet: **generative models should not require a Python reference
runtime and a production runtime you hope match.** pictor inverts that — parity is
the product, speed is earned. No opaque C++ shim in the default build. Every stage
must beat a golden reference before it ships.

Priorities below are ordered by impact. Checkboxes track status. Nothing here is
a commitment to a date.

---

## Vision

### The wider picture

Most of the industry treats generative AI as a zoo of frameworks: PyTorch for
research, C++/CUDA for speed, Python for glue, separate servers for chat vs
diffusion vs embeddings. pictor treats it as **one systems problem**:

| Layer | pictor's answer |
| --- | --- |
| **Artifact** | GGUF + embedded model cards — weights, metadata, and provenance in one file |
| **Math** | Oracle-gated numerics — reference tier is law; SIMD and GPU must prove equivalence |
| **Compute** | Shared kernel fabric — 1-bit, ternary, K-quant, FP8 dequant/GEMV/GEMM/attention |
| **Execution** | Hardware-aware dispatch — CPU (always), Metal, CUDA Graphs, future WebGPU |
| **Serving** | Agent-native runtime — grammar, tools, RAG, batching, OpenAI-compatible API |
| **Deployment** | Same binary story from WASM tab to multi-GPU host — no “cloud edition” fork |

**Where this goes beyond image + chat**

pictor is not “an image crate and an LLM crate in a monorepo.” The shared spine —
`pictor-core` → `pictor-kernels` → model loaders → runtime — is deliberately
modality-agnostic. New generative families should plug into existing quant
formats, kernel tiers, GPU graph capture, and parity harnesses instead of
forking another stack.

```text
  Today                          Tomorrow (same engine)
  ─────                          ──────────────────────
  text ──▶ image                 speech ──▶ transcript ──▶ summary
  text ──▶ tokens                image  ──▶ caption ──▶ edit loop
  docs ──▶ RAG answers           video  ──▶ keyframes ──▶ diffusion refine
                                 agents ──▶ tools + vision + retrieval in one session
```

**Sovereign inference** means operators can audit what runs: no mandatory cloud
API, no undeclared FFI, reproducible RNG and logits when oracles demand it.
**Extreme quantization** means frontier models fit on hardware people actually
own — 1-bit and ternary are the primary formats, not demo modes.

Sibling projects [viser](https://github.com/vbasky/viser) (video intelligence) and
[revelo](https://github.com/vbasky/revelo) (perception metrics) explore adjacent
media stacks under BSD-2-Clause. pictor is the **generative inference** complement:
create, constrain, and serve — with the same parity discipline.

### What we are building toward

pictor aims to be the **reference Pure Rust inference stack for frontier
quantization** — 1-bit, ternary, K-quant, and FP8 — spanning every generative
architecture that can be expressed as quantized tensor programs on CPU, Apple
Silicon, NVIDIA, and (eventually) WebGPU/WASM.

```text
                         ┌─────────────────────────────────────┐
                         │           pictor (facade)           │
                         └─────────────────────────────────────┘
                ┌────────────────┬────────────────┬────────────────┐
                ▼                ▼                ▼                ▼
          pictor-image    pictor-runtime    pictor-serve      pictor-rag
                │                │                │                │
                └────────┬───────┴────────┬───────┴────────────────┘
                         ▼                ▼
                   pictor-model     pictor-tokenizer
                         │                │
                         └────────┬───────┘
                                  ▼
                    pictor-kernels ◄──► pictor-core (GGUF / quant / config)
                                  │
                    CPU · NEON · AVX2/512 · Metal · CUDA (NVRTC + graphs)
```

### Principles (non-negotiable)

1. **Parity before speed.** A faster kernel that fails the oracle is a regression,
   not a win. Image stages gate at cos ≥ 0.999; LLM paths maintain tier-crossing
   correctness tests (reference vs AVX2 vs AVX-512 vs NEON vs GPU).
2. **Pure Rust by default.** Zero FFI in the default build. External crates are
   Rust all the way down — mmap, DEFLATE, ONNX proto, GPU dispatch.
3. **Extreme quantization is the product.** 1-bit and ternary are not demos; they
   are the primary weight formats. The stack exists to make sub-byte models
   practical on real hardware.
4. **CPU fallback always.** GPU paths default-on where parity-proven (DiT, VAE on
   Metal/CUDA), but every stage must remain runnable on a laptop with no GPU —
   for debugging, CI, and WASM targets.
5. **One engine, many modalities.** Kernels, GGUF I/O, and GPU graph execution
   are shared infrastructure. Image and language inference are two faces of the
   same paintbrush.

### North-star outcomes

| Horizon | Outcome |
| --- | --- |
| **Now** | Dual pipelines (image + LLM) with 4 000+ tests, parity gates enforced, Metal/CUDA/CPU tiers — the foundation everything else builds on. |
| **Near** | Sub-minute 512×512 image on consumer Apple Silicon and NVIDIA; production LLM serving (continuous batching, prefix cache, speculative decode); unified `pictor` CLI; crates.io release train. |
| **Mid** | 1024²+ diffusion with VAE tiling; **multimodal sessions** (shared Qwen3 encoder across image + chat in one loaded process); Python bindings; WASM CPU inference package; GGUF conversion tooling. |
| **Far** | WebGPU portable backend; audio/video generative stages on the shared kernel fabric; multi-GPU tensor-parallel image + LLM; on-device LoRA merge and personalization. |
| **Horizon** | **Generative inference OS** — one operator-facing runtime where agents compose text, image, retrieval, and structured tools under oracle monitors; community checkpoint ecosystem for sub-byte formats; edge-to-cloud deploy without stack forks. |

---

## Status snapshot

**Shipped and stable**

| Layer | Coverage |
| --- | --- |
| **pictor-core** | GGUF v1–v3, streaming parser, writer, model card; Q1_0_g128, TQ2_0_g128, K-quants (Q2–Q8_K), Q4_0/Q8_0, FP8 blocks; 207+ tests |
| **pictor-kernels** | Scalar + AVX2/512 + NEON tiers; 1-bit / ternary / FP8 GEMV/GEMM; Metal fused full-forward; CUDA NVRTC + CUDA Graphs; 675+ tests |
| **pictor-model** | Qwen3 transformer (1.7B/4B/8B), paged KV, flash attention, MoE, LoRA, FP8 KV, weight merge, ONNX→GGUF; 673+ tests |
| **pictor-runtime** | Engine, speculative decoding, beam search, grammar (BNF/GBNF/regex/JSON Schema), tool calling, continuous batching, prefix/semantic cache, Prometheus; 796+ tests |
| **pictor-tokenizer** | BPE / Unigram / WordPiece, HF `tokenizer.json`, streaming decode, trainer; 268+ tests |
| **pictor-rag** | Chunking, TF-IDF embedder, vector store, pipeline; 871+ tests |
| **pictor-serve** | Standalone OpenAI-compatible server, layered config, bearer auth; 260+ tests |
| **pictor-eval** | Perplexity, BLEU, ROUGE evaluators |
| **pictor-image** | Full FLUX.2-Klein pipeline; Metal ~52–62 s / CUDA ~31.7 s @ 512²; 59 DiT + 11 VAE parity taps |

**Not yet covered** — see tiers below.

---

## P0 — correctness & trust (do first)

These items protect the core promise: *correct output, always*.

- [ ] **CUDA Q1 batched-prefill cap-of-8 fix.** Three NVRTC kernels silently
      zero columns beyond 8 in batched prefill — mechanical fix written, **not
      yet validated on CUDA hardware**. Mirrors the proven Metal fix. Severity:
      critical (wrong logits, not slow logits).
- [ ] **CUDA batched TQ2 prefill.** Metal path shipped; CUDA still returns
      `Err` at the forward guard. Needs `cuda_gemm_tq2_g128_v7` + parity test
      mirroring `metal_prefill_ternary_parity_tests`.
- [ ] **CUDA batched TQ2 prefill-verify.** Speculative-decode verification
      entry point on CUDA; depends on batched TQ2 prefill above.
- [x] **Image parity harnesses.** `te_parity`, `dit_parity` (59 taps),
      `vae_parity` (11 taps), safetensors weight identity — all cos ≥ 0.999.
- [x] **Cross-tier kernel correctness.** Reference vs SIMD vs GPU parity tests
      across 1-bit, ternary, and FP8 paths.
- [x] **Threefry RNG reproducibility.** MLX-exact seed → byte-identical latents
      in the image pipeline.

---

## P1 — highest-impact capability

Features that unlock real daily use and close the biggest capability gaps.

### Image generation

- [ ] **VAE tiling.** Decode images larger than 512×512 without blowing
      activation memory — required for 1024² and beyond.
- [ ] **TE GPU weight cache.** Amortize the 4-bit MLX text-encoder load across
      multi-prompt sessions (~2.1 GB per cold start today).
- [ ] **VAE full GPU residency on CUDA.** Keep VAE weights resident on discrete
      GPU (~4 s additional win per image on A4000-class hardware).
- [ ] **High-resolution defaults.** 768² / 1024² presets once tiling lands;
      document memory envelopes per backend.
- [ ] **1-bit DiT variant.** Blocked on upstream PrismML checkpoint — kernel
      path ready via existing Q1 stack.

### LLM serving & throughput

- [ ] **Unified `pictor` CLI.** Single binary: `pictor image`, `pictor chat`,
      `pictor serve`, `pictor convert` — matching the ergonomics of viser/revelo.
- [ ] **Production serving guide.** Operator docs: `PICTOR_*` env reference,
      GPU toggles, memory budgets, `/admin/workload-stats` interpretation.
- [ ] **crates.io release train.** Version-aligned workspace publish
      (core → kernels → model → runtime → facade) with MSRV-locked CI matrix.

### Kernel performance

- [ ] **INT8 dot-product tier (AVX-VNNI / NEON UDOT).** FP32 FMA ternary
      expansion is correct but leaves SIMD dot-product hardware on the table;
      requires INT8-quantized activations path.
- [ ] **CI GPU runners.** Mandatory CUDA validation gate before merging NVRTC
      kernel changes — adopt `// TODO(CI-GPU)` discipline repo-wide.

---

## P2 — completeness & ecosystem

Breadth that makes pictor a platform, not a collection of crates.

### Distribution & bindings

- [ ] **Python bindings (PyO3).** `pip install pictor` for notebook workflows
      and HuggingFace ecosystem interop without abandoning the Rust core.
- [ ] **WASM package.** Browser-runnable tokenizer + CPU inference path;
      npm publish integration (deferred from facade crate TODO).
- [ ] **GGUF conversion tooling.** First-class `pictor convert` for safetensors →
      GGUF (ternary, Q1, K-quant) with embedded model cards.

### RAG & retrieval

- [ ] **Approximate nearest-neighbour index.** Flat cosine store is correct but
      O(n) — HNSW or similar for 100k+ chunk corpora.
- [ ] **Embedding model integration.** Pluggable embedders beyond TF-IDF
      (still Pure Rust policy — no mandatory cloud API).
- [ ] **Hybrid retrieval.** BM25 + dense fusion, metadata filters in production
      RAG server paths.

### Model coverage

- [ ] **Additional diffusion architectures.** FLUX.2-Klein is the reference;
      generalize weight loaders and RoPE/attention blocks for the next ternary
      DiT checkpoints as they ship.
- [ ] **Speculative draft models for image.** Draft DiT / fewer-step distillation
      for sub-10 s generation on Apple Silicon.
- [ ] **Multi-GPU image pipeline.** Tensor-parallel DiT for 1024²+ on multi-GPU
      hosts (model crate already has TP utilities for LLM).

### Observability

- [ ] **Image pipeline metrics.** Prometheus counters for stage latency (TE, DiT,
      VAE), GPU path taken, parity cosine snapshots — mirror runtime's
      `pictor_*` metrics surface.
- [ ] **Faithfulness probes for image.** Per-stage cosine drift alarms in
      production (detect silent numeric regression before users do).

---

## P3 — quality of life

Polish that rewards contributors and operators.

- [x] **CHANGELOG + release script.** viser/revelo-style `scripts/release.sh` and
      GitHub release workflow; RELEASING.md operator guide still TODO.
- [ ] **`justfile` recipes.** `just check`, `just test-gpu`, `just bench-kernels`,
      `just parity-image` — one-command workflows.
- [ ] **deny.toml + rust-toolchain.toml.** Supply-chain and MSRV pinning in CI.
- [x] **CONTRIBUTING.md** — attribution, license obligations, PR checklist
      (`docs/CONTRIBUTING.md`).
- [ ] **docs/ layout expansion.** `IMAGEN.md`, `CLI.md`, `HACKING.md` — sibling
      to revelo/viser doc sets.
- [ ] **Root README badges.** crates.io, docs.rs, CI workflow badge once publish
      train is live.

---

## Research horizon

Exploratory work — valuable, not yet scheduled. Ordered from “extends today’s
engine” to “new modalities.”

### Platform & portability

- **WebGPU backend.** Portable GPU path for WASM and cross-platform inference
  without NVRTC/Metal lock-in.
- **WASM-first agent runtime.** Tokenizer + CPU inference + constrained decoding
  in the browser tab — sovereign assistants without a round trip.
- **Deterministic replay.** Capture seeds, kernel tier, and model card hash for
  audit-grade reproduction of generative outputs in regulated environments.

### Multimodal & creative loops

- **Multimodal unification.** Share Qwen3 text-encoder weights across
  `pictor-image` and `pictor-runtime` in a single loaded session.
- **Image ↔ language loops.** Generate → caption → edit → regenerate with shared
  KV and TE caches; one session, multiple modalities.
- **Vision-conditioned generation.** Image prompts and mask-guided diffusion on
  the existing DiT/VAE spine (inpainting, style transfer) with parity taps per
  stage.

### New generative families (shared kernels)

- **Audio.** Quantized autoregressive and diffusion audio on the same GEMV/GEMM
  fabric; parity vs reference waveform or mel features.
- **Video.** Temporal attention and VAE stacks as additional `pictor-*` pipelines
  — composable with viser-style analysis upstream.
- **Embeddings & rerankers.** Dense retrieval models in GGUF for RAG without a
  separate embedding server.

### Efficiency & quality

- **FP8 end-to-end image.** FP8 activations in DiT/VAE where parity gates allow,
  building on the FP8 kernel tier already in pictor-kernels.
- **Distilled schedulers.** Learned step reduction (4-step → 1–2 step) with
  parity-bounded quality loss.
- **On-device fine-tuning.** LoRA merge infrastructure exists in pictor-model;
  explore consumer-GPU LoRA apply for personalization.
- **Speculative multimodal drafts.** Draft DiT / fewer-step distillation and
  draft LLM heads sharing the same verification machinery.

---

## Attribution

pictor is a **derivative work** of [oxibonsai](https://github.com/cool-japan/oxibonsai),
originally written and distributed by **COOLJAPAN OU** under the
[Apache License 2.0](LICENSE). The oxibonsai codebase provided the foundational
architecture — `pictor-core`, `pictor-kernels`, `pictor-model`, `pictor-runtime`,
and the surrounding crate graph — that pictor continues under new naming and
independent maintenance.

| Party | Role | Copyright |
| --- | --- | --- |
| COOLJAPAN OU | Original oxibonsai authors | 2024–2026 |
| Vikram Bhaskaran | pictor modifications & continuation | 2026 |

**License:** Apache-2.0 for the combined work. See [LICENSE](LICENSE) and
[NOTICE](NOTICE). Redistribution must retain upstream attribution and include a
copy of the Apache license.

**What this means for contributors**

- Do **not** relicense inherited code to BSD, MIT, or another termset without
  written permission from COOLJAPAN OU.
- New files and substantial rewrites you author are contributed under Apache-2.0
  and must not remove existing copyright or NOTICE entries.
- When modifying files that originated in oxibonsai, keep a clear change history
  (commit messages are fine; file-level notes where rewrites are large).

Full contributor obligations: [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md).

---

## How to read this document

| Symbol | Meaning |
| --- | --- |
| `[x]` | Shipped and covered by tests |
| `[ ]` | Planned or in progress |
| `[~]` | Partially done — see notes |

Per-crate implementation history lives in `crates/*/TODO.md`. This roadmap is the
workspace-level view: vision, priorities, and what comes next.

If you are deciding where to contribute: **P0 CUDA correctness** and **P1 VAE
tiling** are the highest-leverage open items today. Everything else builds on the
parity foundation already in place.