# pictor-serve

**Status:** Stable — **Version:** 0.2.2 — **Tests:** 161 passing

Standalone OpenAI-compatible inference server for Pictor.

Binary crate providing an HTTP server with `/v1/chat/completions` endpoint,
configurable host/port, model path, sampling parameters, and structured logging.
Uses pure `std::env` argument parsing — no clap dependency. Delegates the
engine and HTTP stack to [`pictor-runtime`](../pictor-runtime).

Part of the [Pictor](https://github.com/vbasky/pictor) project.

## Usage

```sh
# Install
cargo install pictor-serve

# Start server
pictor-serve --model path/to/Bonsai-8B.gguf --host 0.0.0.0 --port 8080

# With options
pictor-serve \
  --model models/Bonsai-8B.gguf \
  --max-tokens 512 \
  --temperature 0.7 \
  --log-level info
```

## Options

| Flag | Default | Description |
|------|---------|-------------|
| `--model <PATH>` | required | Path to GGUF model file |
| `--host <HOST>` | `0.0.0.0` | Bind address |
| `--port <PORT>` | `8080` | Bind port |
| `--tokenizer <PATH>` | auto | Optional tokenizer path |
| `--max-tokens <N>` | `256` | Default max tokens |
| `--temperature <F>` | `0.7` | Sampling temperature |
| `--seed <N>` | `42` | RNG seed |
| `--log-level <LEVEL>` | `info` | error/warn/info/debug/trace |
| `--auth-token <TOKEN>` | optional | Bearer auth token for request authentication |

## License

Apache-2.0 — derived from oxibonsai (COOLJAPAN OU). See [LICENSE](../../LICENSE) and [NOTICE](../../NOTICE).
