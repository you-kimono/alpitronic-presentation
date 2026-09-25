# Presentation

Quarto + reveal.js slides.

Live: https://you-kimono.github.io/alpitronic-presentation/ (PDF: [`index.pdf`](index.pdf))

## Prerequisites

Quarto CLI is installed at `~/.local/share/quarto-1.10.18`, symlinked to `~/.local/bin/quarto`
(already on `PATH` via `~/.profile`).

```bash
quarto --version
```

## Authoring

- `index.qmd` — the slides
- `palette.scss` — this deck's color palette (drop it to use a base theme's own)
- `custom.scss` — typography, layout and helper classes (no colors of its own)
- `_quarto.yml` — project + reveal.js options
- `images/` — figures

## Commands

```bash
quarto preview index.qmd    # live reload in the browser
quarto render               # build to _output/
```

Rendered output lands in `_output/` (git-ignored).

## Slide syntax cheatsheet

| Goal | Syntax |
| --- | --- |
| New slide | `## Heading` |
| Slide with no title | `---` on its own line |
| Reveal bullets one by one | `::: {.incremental}` block |
| Two columns | `:::: {.columns}` + `::: {.column width="50%"}` |
| Speaker notes | `::: {.notes}` block |
| Shrink a slide's text | `## Heading {.smaller}` |
| Background image | `## Heading {background-image="images/x.png"}` |

## Keys during the talk

`S` speaker view · `F` fullscreen · `O` slide overview · `B` chalkboard · `M` menu

## Theme

Set once in `_quarto.yml` as a layered list — base theme first, layers after:

```yaml
theme: [default, palette.scss, custom.scss]
```

| Layer | Holds |
| --- | --- |
| base (`default`, `dark`, `league`, ...) | reveal.js's own palette and type |
| `palette.scss` | this deck's light palette (bg, text, link, heading) |
| `custom.scss` | typography, layout, `.box` / `.bdr` / `.badge` — no colors of its own |

Built-in bases: `beige blood dark dracula default league moon night serif simple
sky solarized white`.

To switch the whole deck to a dark base, change the base name **and drop
`palette.scss`** — otherwise the light palette overrides it:

```yaml
theme: [dark, custom.scss]
```

Layer order matters and is not what you would guess: Quarto emits the *last*
layer's `scss:defaults` *first*, so a later layer wins even when the earlier one
declares `!default`. That is why yielding to the base theme means removing a
layer, not marking its variables `!default`.

`custom.scss` derives its colors from the active theme (`mix($body-color,
$body-bg, ...)`, `rgba($link-color, ...)`), so `.muted`, `.box` and `.bdr`
labels stay legible on either base. `.badge` sets its own background *and* text
color, so it needs no per-theme variant.

Do not put `format: revealjs: theme:` in a `.qmd` front matter — it layers on
top of the project setting instead of replacing it, which is confusing to debug.

### Restyling a single slide

reveal.js has no per-slide theme. For a one-off accent slide, set a background
and let reveal do the rest — it adds `has-dark-background` to the section and
the theme flips text, headings, links and code to light:

```markdown
## Why this matters {background-color="#12303f"}
```

Also available: `background-gradient=`, `background-image=`,
`background-opacity=`.

For anything beyond the background, add a class and style it in `custom.scss`:

```markdown
## Verdict {.accent .smaller}
```

```scss
.reveal section.accent { background: #12303f; color: #eef3f6; }
.reveal section.accent h2 { color: #7fd3f7; }
```

Note the `.reveal section.accent` prefix: a class on a `##` heading lands on the
`<section>` itself and must out-specify the theme's own `section` rules, unlike
`.bdr`, which is a div inside the slide.

## Arrows and symbols

`arrows.lua` (wired in via `_quarto.yml`) rewrites ASCII shorthand as real
glyphs in prose, so you can keep typing ASCII:

| Type | Get | | Type | Get |
| --- | :-: | --- | --- | :-: |
| `->` `<-` | → ← | | `<=` `>=` | ≤ ≥ |
| `-->` `<--` | ⟶ ⟵ | | `!=` `~=` | ≠ ≈ |
| `<->` `<=>` | ↔ ⇔ | | `+/-` | ± |
| `=>` `<==` | ⇒ ⇐ | | | |

Note `<=` gives ≤, not a left double arrow — boundary test cases need the
comparison far more often. Write `<==` for ⇐.

Code spans and code blocks are skipped, so `` `a -> b` ``, C++ listings and
Mermaid's `-->` edges are unaffected. To opt out in running prose, write
`[->]{.literal}`. A backslash escape does **not** work: pandoc resolves escapes
at parse time, so the filter still sees a plain `->`.

The last slides of `index.qmd` are a character-reference appendix (marked
`visibility="uncounted"` so they do not affect slide numbers). Delete that
block before presenting.

## Fonts

The reveal.js theme font, Source Sans Pro, has no glyph for ↔ ⟶ ⟵ ⇒ ⇐ ⇔
Ω Δ ✗ ⚠ ⚡. `custom.scss` appends a `$symbol-fallback` stack (DejaVu Sans on
Debian, Segoe UI Symbol / Apple Symbols / Noto Sans Symbols2 elsewhere) so
those render instead of tofu boxes. The "Rendering check" appendix slide shows
every glyph at once — open it on any machine you plan to present from.

## Behaviour Decision Records

Three worked BDR examples sit at the end of the content, before the character
appendix. Each is one slide built from a pandoc definition list inside a
`::: {.bdr}` div; `custom.scss` lays that out as a label/value grid.

Verdicts use a badge span: `[BUG]{.badge .bug}`, `[INTENDED]{.badge .req}`,
`[PROVISIONAL]{.badge .prov}`.

To add a fourth, copy an existing slide — keep the field order (ID, observed
behavior, FW version, sources consulted, decision, rationale, who decided,
linked IDs) and do **not** add `{.smaller}` to the heading; `.bdr dl` already
sets the size, and the two compound.

## Publishing

```bash
quarto publish gh-pages     # render and push _output/ to the gh-pages branch
```
