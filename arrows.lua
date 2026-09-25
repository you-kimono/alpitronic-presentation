-- Render ASCII shorthand as real Unicode glyphs in prose.
--
-- Str elements never occur inside `code` spans or code blocks, so code
-- listings and Mermaid diagrams keep their literal ASCII.
--
-- Caveat: pandoc's `smart` extension rewrites `--` as an en dash and `---`
-- as an em dash *before* filters run, so `-->` reaches this filter as `–>`
-- and `<--` as `<–`. Both forms are matched below.
--
-- Note on `<=`: it maps to the comparison operator, not a leftward double
-- arrow, because in a test-design deck "I <= I_max" is far more likely than
-- an implication. Write `<==` if you want the arrow.
--
-- To opt out in prose, wrap the text in a span: [->]{.literal}
-- (A backslash escape does NOT work: pandoc resolves escapes at parse time,
-- so the filter still sees a plain `->`.)

local subs = {
  -- three characters or more, matched first
  { "<=>",         "\u{21D4}" },  -- ⇔
  { "<==",         "\u{21D0}" },  -- ⇐
  { "==>",         "\u{21D2}" },  -- ⇒
  { "<->",         "\u{2194}" },  -- ↔
  { "+/-",         "\u{00B1}" },  -- ±
  -- post-smart-punctuation long arrows (`-->`, `<--`, `--->`)
  { "\u{2013}>",   "\u{27F6}" },  -- ⟶
  { "\u{2014}>",   "\u{27F6}" },
  { "<\u{2013}",   "\u{27F5}" },  -- ⟵
  { "<\u{2014}",   "\u{27F5}" },
  -- two characters
  { "->",          "\u{2192}" },  -- →
  { "<-",          "\u{2190}" },  -- ←
  { "=>",          "\u{21D2}" },  -- ⇒
  { "<=",          "\u{2264}" },  -- ≤
  { ">=",          "\u{2265}" },  -- ≥
  { "!=",          "\u{2260}" },  -- ≠
  { "~=",          "\u{2248}" },  -- ≈
}

local function escape_html(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- Pass 1: freeze [.literal] spans into raw HTML so pass 2 cannot see them.
local function protect(el)
  if el.classes:includes("literal") then
    return pandoc.RawInline("html", escape_html(pandoc.utils.stringify(el)))
  end
end

-- Pass 2: rewrite the shorthand.
local function convert(el)
  local t = el.text
  for _, pair in ipairs(subs) do
    -- escape pattern metacharacters in the literal key
    t = t:gsub(pair[1]:gsub("%p", "%%%0"), pair[2])
  end
  if t == el.text then return nil end
  return pandoc.Str(t)
end

return {
  { Span = protect },
  { Str = convert },
}
