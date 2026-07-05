# pictor-rag

[![Version](https://img.shields.io/badge/version-0.2.2-blue)](https://crates.io/crates/pictor-rag)
[![Status](https://img.shields.io/badge/status-stable-brightgreen)](https://github.com/vbasky/pictor)
[![Tests](https://img.shields.io/badge/tests-871_passing-brightgreen)](https://github.com/vbasky/pictor)

Pure Rust Retrieval-Augmented Generation (RAG) pipeline for Pictor.

Self-contained RAG stack: document chunking (character, sentence, paragraph,
semantic, hierarchical, sliding window, markdown), pure Rust embedders
(identity, TF-IDF), in-memory vector store with cosine similarity, top-k
retrieval, and end-to-end prompt-building pipeline.

Part of the [Pictor](https://github.com/vbasky/pictor) project.

## Status

**Stable** — version 0.2.2, 871 tests passing (`cargo nextest run -p pictor-rag`). Uplifted from Alpha in 0.1.2.

## Features

- `RagPipeline` — end-to-end index + query pipeline
- `VectorStore` — in-memory L2-normalized cosine similarity search
- `Retriever` — document indexing and top-k chunk retrieval
- `Embedder` trait — pluggable embedding backends
- `IdentityEmbedder` — hash-based embedder for testing
- `TfIdfEmbedder` — bag-of-words TF-IDF embedding
- Chunking strategies: character window, sentence, paragraph, recursive,
  sliding window, markdown, semantic (cosine boundary), hierarchical
- `ChunkerRegistry` — dynamic dispatch for pluggable chunking backends
- Zero external API calls — fully self-contained

## Usage

```toml
[dependencies]
pictor-rag = "0.2.2"
```

```rust
use pictor_rag::RagPipeline;

let mut pipeline = RagPipeline::default();
pipeline.index_document("Rust is a systems programming language.")?;
let prompt = pipeline.build_prompt("What is Rust?")?;
```

## License

Apache-2.0 — derived from oxibonsai (COOLJAPAN OU). See [LICENSE](../../LICENSE) and [NOTICE](../../NOTICE).
