# pictor

Pure Rust 1-bit LLM inference engine for PrismML Bonsai models — umbrella crate.

**Status:** Stable (thin re-export facade) · **Version:** 0.1.0 · **Updated:** 2026-05-30

Re-exports all Pictor subcrates for convenience. Add this single dependency
to get access to the entire Pictor ecosystem:

```toml
[dependencies]
pictor = "0.1.0"

# Enable optional subsystems:
pictor = { version = "0.1.0", features = ["full"] }
```

## Subcrates

| Crate | Description |
|-------|-------------|
| `pictor-core` | GGUF loader, tensor types, configuration |
| `pictor-kernels` | 1-bit compute kernels (dequant, GEMV, GEMM, SIMD) |
| `pictor-model` | Qwen3 transformer family (1.7B/4B/8B), KV cache, attention |
| `pictor-runtime` | Inference engine, sampling, OpenAI-compatible server |
| `pictor-tokenizer` | Pure Rust BPE tokenizer (optional) |
| `pictor-rag` | Retrieval-augmented generation pipeline (optional) |
| `pictor-eval` | Model evaluation framework (optional) |
| `pictor-serve` | Standalone OpenAI-compatible server (optional) |

## Feature Flags

| Flag | Description |
|------|-------------|
| `server` | HTTP server (axum) |
| `rag` | RAG pipeline |
| `native-tokenizer` | Pure Rust BPE tokenizer |
| `eval` | Evaluation harness |
| `simd-avx2` | AVX2+FMA SIMD kernels |
| `simd-avx512` | AVX-512 SIMD kernels |
| `simd-neon` | NEON SIMD kernels |
| `wasm` | WASM-safe build |
| `full` | All optional features |

## License

Apache-2.0 — derived from oxibonsai (COOLJAPAN OU). See [LICENSE](../../LICENSE) and [NOTICE](../../NOTICE).
