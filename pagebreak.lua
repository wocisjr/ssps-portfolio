-- pagebreak.lua
-- Convert HTML comments like <!-- pagebreak --> into LaTeX page breaks.

local function normalize(s)
  if not s then return "" end
  -- collapse whitespace incl. newlines
  s = s:gsub("%s+", " ")
  s = s:gsub("^%s+", ""):gsub("%s+$", "")
  return s
end

local function is_pagebreak_comment(s)
  s = normalize(s)
  return s == "<!-- pagebreak -->"
      or s == "<!-- newpage -->"
      or s == "<!-- clearpage -->"
end

local function pagebreak_block()
  -- use clearpage if you want floats flushed:
  -- return pandoc.RawBlock("latex", "\\clearpage")
  return pandoc.RawBlock("latex", "\\newpage")
end

function RawBlock(el)
  if el.format == "html" and is_pagebreak_comment(el.text) then
    return pagebreak_block()
  end
  return nil
end

function RawInline(el)
  if el.format == "html" and is_pagebreak_comment(el.text) then
    -- Inline replacement: insert a raw LaTeX inline break.
    -- In LaTeX, \newpage works fine inline too.
    return pandoc.RawInline("latex", "\\newpage")
  end
  return nil
end
