//! # Pictor
//!
//! **Pure Rust 1-bit LLM inference engine for PrismML Bonsai models.**
//!
//! Pictor is a high-performance inference engine designed for 1-bit quantized
//! large language models in GGUF format. It provides a complete pipeline from model
//! loading through token generation, with optional RAG, tokenization, evaluation,
//! and HTTP serving capabilities.
//!
//! ## Quick Start
//!
//! ```rust,no_run
//! use pictor::core::GgufStreamParser;
//!
//! // Parse a GGUF model file via the streaming parser
//! let _parser = GgufStreamParser::new();
//! ```
//!
//! ## Crate Organization
//!
//! | Crate | Description |
//! |-------|-------------|
//! | [`pictor-core`](https://crates.io/crates/pictor-core) | GGUF loader, tensor types, quantization, configuration |
//! | [`pictor-kernels`](https://crates.io/crates/pictor-kernels) | Optimized compute kernels (SIMD, matmul, softmax) |
//! | [`pictor-model`](https://crates.io/crates/pictor-model) | Transformer model definitions, KV cache, attention |
//! | [`pictor-runtime`](https://crates.io/crates/pictor-runtime) | Inference engine, sampling, speculative decoding |
//! | [`pictor-tokenizer`](https://crates.io/crates/pictor-tokenizer) | HuggingFace tokenizer integration |
//! | [`pictor-rag`](https://crates.io/crates/pictor-rag) | Retrieval-augmented generation pipeline |
//! | [`pictor-eval`](https://crates.io/crates/pictor-eval) | Model evaluation and benchmarking |
//! | [`pictor-serve`](https://crates.io/crates/pictor-serve) | OpenAI-compatible HTTP server |
//!
//! ## Feature Flags
//!
//! | Feature | Description |
//! |---------|-------------|
//! | `server` | HTTP server support via `pictor-serve` |
//! | `rag` | Retrieval-augmented generation |
//! | `native-tokenizer` | HuggingFace tokenizer support |
//! | `eval` | Model evaluation framework |
//! | `full` | Enable all optional features |
//! | `simd-avx2` | AVX2 SIMD kernels (x86_64) |
//! | `simd-avx512` | AVX-512 SIMD kernels (x86_64) |
//! | `simd-neon` | NEON SIMD kernels (AArch64) |
//! | `wasm` | WebAssembly target support |
//!
//! ## License
//!
//! Apache-2.0 — derived from oxibonsai (COOLJAPAN OU). See LICENSE and NOTICE.

/// Core GGUF loading, tensor types, quantization, and configuration.
pub use pictor_core as core;

/// Optimized compute kernels (SIMD matmul, softmax, RMS norm, RoPE).
pub use pictor_kernels as kernels;

/// Transformer model definitions, KV cache, paged attention.
pub use pictor_model as model;

/// Inference engine, sampling strategies, speculative decoding.
pub use pictor_runtime as runtime;

/// Retrieval-augmented generation pipeline.
#[cfg(feature = "rag")]
pub use pictor_rag as rag;

/// HuggingFace tokenizer integration.
#[cfg(feature = "native-tokenizer")]
pub use pictor_tokenizer as tokenizer;

/// Model evaluation and benchmarking framework.
#[cfg(feature = "eval")]
pub use pictor_eval as eval;

/// OpenAI-compatible HTTP server.
#[cfg(feature = "server")]
pub use pictor_serve as serve;
