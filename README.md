# Zirconium (.zr)

Zirconium is an experimental, pre-alpha programming language implemented in Zig.  
Current focus: building a minimal end‑to‑end pipeline (tokenizer ➜ parser ➜ AST + debug output) for very small function-based programs.

> Status: Early prototype. There is no executor / interpreter / VM / type checker yet. The tool currently parses a subset of function declarations and simple return statements from `.zr` source files and prints an AST-ish debug representation.

---

## Current Capabilities (What Actually Works)

Implemented so far (see `src/`):

| Layer | Features |
|-------|----------|
| Tokenizer (`tokenizer.zig`) | Identifiers (`[A-Za-z][A-Za-z0-9]*`), unsigned integer literals (fits in `u8`), single-char symbols: `(` `)` `{` `}` `;`, EOF sentinel. Whitespace is skipped. Unknown characters become `Unknown` tokens. |
| Tokens (`tokens.zig`) | Tagged union with basic formatting for debug printing. |
| Parser (`parser.zig`) | Parses a sequence of function declarations of the form: `func <name>() <return_type> { <statements> }`. Statements: return statements with optional integer expression, integer expression statements, empty statements (`;`). |
| AST (`ast.zig`) | Nodes: `ProgNode`, `FuncNode`, `BlockNode`, `StmtNode` (Expression, Return, Empty), `ExprNode` (currently just integer literal). |
| CLI (`src/main.zig`) | `zig build run -- path/to/file.zr` tokenizes + parses file, prints a debug representation of the AST (formatting still rough). |
| Tests | A few basic parser tests via `zig build test`. |

---

## 🔬 Example

`main.zr` (included):

```zr
func main() int {
    return 10;
}

func foo() int {
    return 20;
}
```

Run:

```bash
zig build run -- main.zr
```

Example (approximate) debug output (formatting WIP):

```
Found function: main
Found return type: int
Found function: foo
Found return type: int
Program (
    ...
)
```

(The AST formatting currently uses `{s}` in places where a custom formatter is needed; this will improve.)

---

## Roadmap (Short / Medium Term)

Short-term (parsing core):

- [ ] Fix AST formatting (replace `{s}` misuse; implement proper slice iteration)
- [ ] Add function parameter list parsing (even if ignored)
- [ ] Add simple expression grammar (binary: `+ - * /`)
- [ ] Introduce variable declarations (`let` / `var` or `int`, `char` etc.)
- [ ] Better error reporting with source spans
- [ ] Strengthen tokenizer tests

Long-term:

- [ ] Symbol table + name resolution
- [ ] Basic type system scaffold (int, bool, unit)
- [ ] Return type checking
- [ ] Introduce an interpreter (tree-walk) for experimentation
- [ ] Source location tracking (line/col on tokens and AST nodes)
- [ ] Replace manual slice ownership with arenas / bump allocator

## Development

Clone & build:

```bash
git clone https://github.com/impascoe/Zirconium.git
cd Zirconium
zig build            # builds the executable
zig build run -- file.zr
zig build test       # runs unit tests
```

Recommended Zig: `>= 0.14.0` (see `build.zig.zon`).

---

## Testing

Current tests are parser-focused:

```bash
zig build test
```

Planned additions:
- Tokenizer tests
- Negative parse tests (expected failures)
- Execution tests (post-interpreter)

---

## Known Technical Issues

| Item | Notes |
|------|-------|
| Formatting `{s}` misuse | Some custom `format` impls hand invalid types to `{s}` (will fix to proper iteration). |
| Error surface | Panics / broad `error.UnexpectedToken`; need structured diagnostics. |
| Memory mgmt | Per-identifier allocation; migrate to arenas. |
| Return type capture | Unvalidated; treat as raw identifier. |
| Integer width | `u8` for literals—very restrictive (for prototyping). |
| Debug noise | Tokenizer prints every char; feature gate with a `--debug-lex` flag later. |

---

## FAQ

| Question | Answer |
|----------|--------|
| Can I run real programs? | Not yet, only AST parsing & debug printing. |
| Is the syntax stable? | No. This is still very much work in progress. |
| Why use Zig to implement it? | Performance, explicit memory control, good tooling. |
| Why "Zirconium"? | Elemental motif; sounds sturdy but still being refined. |

---
