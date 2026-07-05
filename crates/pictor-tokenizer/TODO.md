# pictor-tokenizer TODO

> Pure Rust BPE/Unigram/WordPiece tokenizer: encode, decode, training, serialization
> 14 src files + 7 integration test files, ~7,000 lines, 351+ tests (all passing)
> Version: 0.2.2 · Last updated: 2026-06-06

## Status: Stable — Phase 18: WordPiece tokenizer added

Full BPE/Unigram/WordPiece tokenizer with HuggingFace `tokenizer.json` support, chat templates for five model families, UTF-8-safe streaming decoder, training, encoding/decoding, batch operations, special token handling, and JSON serialization.

## Done

- [x] Alpha → Stable uplift for `pictor-tokenizer` — all source edits complete, 5 new test files added, clippy clean (-D warnings), doctests + bench compile green
- [x] `PictorTokenizer` struct — encode, decode, batch encode/decode
- [x] BPE algorithm — `BpeMerges` table, `bpe_encode`, GPT-2 style pre-tokenization
- [x] Byte fallback tokens (`<0xHH>`) for unknown bytes
- [x] Special token handling (BOS, EOS, PAD, custom tokens)
- [x] Char-level tokenizer (`char_level_stub`) for testing without trained vocab
- [x] `BpeTrainer` — learn merges from corpus with configurable vocab size
- [x] `TrainerConfig` — merge frequency thresholds, training statistics
- [x] `Vocabulary` — bidirectional token↔ID mapping
- [x] `ChatTemplateKind` — canned templates for ChatML, Llama-3, Mistral, Gemma, Qwen
- [x] `BatchEncoder` — padding (`PaddingStrategy`) and truncation (`TruncationSide`)
- [x] `from_json(vocab_json, merges_json, config)` tokenizer loader
- [x] `HfTokenizerJson` — full HuggingFace `tokenizer.json` parser (Qwen3/Llama-3/Mistral/Gemma), both merge shapes, ByteLevel detection, 256-entry bytes↔unicode map
- [x] `PictorTokenizer::from_json_file` / `from_hf_tokenizer_json` — load HF files directly
- [x] `StreamingDecoder` — UTF-8-safe streaming decode with strict/lossy finish
- [x] `TokenizerState::save` / `load` — base64 serialization format (FORMAT_MAGIC)
- [x] WASM-safe implementation (no filesystem dependency in core)
- [x] `#[non_exhaustive]` on public config + error enums for forward compatibility
- [x] No-unwrap compliance in production code (policy)
- [x] Comprehensive tests — 130+ in-module unit tests + 130+ integration tests spread across `hf_format_tests`, `chat_template_tests`, `streaming_tests`, `unicode_edge_tests`, `property_tests` (proptest), `serialization_tests`, `trainer_tests`

## Phase 17 — Unigram Tokenizer

- [x] **`UnigramVocab`** — Viterbi best-path segmentation over token lattice; `(token, log_prob)` entries; single-byte UNK fallback with `UNK_PENALTY`; `UnigramError::{EmptyVocab, UnkOutOfRange, DuplicateToken}` 
- [x] **HF format Unigram branch** — `HfModelType::Unigram`; parses `model.vocab` as `[[token, score]]`; `model.unk_id`; 6 integration tests in `tests/unigram_integration_tests.rs`; 4 tests in `hf_format_tests.rs`
- [x] **`PictorTokenizer::with_unigram`** — constructor + `is_unigram()` predicate; encode dispatches to Viterbi path

## Phase 18 — WordPiece Tokenizer

- [x] **`WordPieceVocab`** — greedy longest-match-first with `##`-prefixed continuation tokens; Unicode-safe char-boundary iteration (not byte offsets); `max_input_chars_per_word` limit (default 200); `with_max_input_chars()` builder; `WordPieceError::{EmptyVocab, UnkOutOfRange, DuplicateToken}`; `WORDPIECE_CONTINUATION_PREFIX` constant; 20 inline unit tests
- [x] **HF format WordPiece branch** — `HfModelType::WordPiece`; parses `model.vocab` as object (same shape as BPE); `wordpiece_max_chars: Option<usize>` field; `build_wordpiece_vocab_from_map` helper; 8 integration tests in `hf_format_tests.rs`
- [x] **`PictorTokenizer::with_wordpiece`** — constructor + `is_wordpiece()` predicate; encode dispatches WordPiece before BPE/Unigram; 15 integration tests in `tests/wordpiece_integration_tests.rs`
