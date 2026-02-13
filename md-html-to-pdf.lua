-- html-centered-gallery-blocks.lua
-- Replaces pattern:
-- RawBlock(<p align="center">), Plain/Para(with RawInline <img ...>), RawBlock(</p>)
-- with a centered Para of Pandoc Images.

local function get_attr(tag, name)
  local v = tag:match(name .. "%s*=%s*\"(.-)\"")
  if v then return v end
  v = tag:match(name .. "%s*=%s*'(.-)'")
  if v then return v end
  v = tag:match(name .. "%s*=%s*([^%s>]+)")
  return v
end

local function parse_size(v)
  if not v then return nil end
  v = v:gsub("^%s+", ""):gsub("%s+$", "")
  if v:match("^%d+$") then return v .. "px" end
  return v
end

local function image_from_img_tag(imgtag)
  local src = get_attr(imgtag, "src")
  if not src then return nil end
  local alt = get_attr(imgtag, "alt") or ""
  local width = parse_size(get_attr(imgtag, "width"))
  local height = parse_size(get_attr(imgtag, "height"))
  
  local attr = pandoc.Attr("", {}, {})
  if width then attr.attributes["width"] = width end
  if height then attr.attributes["height"] = height end
  attr.attributes["height"] = "160px"
  return pandoc.Image({ pandoc.Str(alt) }, src, alt, attr)
end

local function is_center_open(block)
  return block
    and block.t == "RawBlock"
    and block.format == "html"
    and block.text:match("<%s*p%s+[^>]*align%s*=%s*['\"]center['\"][^>]*>")
end

local function is_p_close(block)
  return block
    and block.t == "RawBlock"
    and block.format == "html"
    and block.text:match("<%s*/%s*p%s*>")
end

local function collect_imgs_from_block(block)
  local imgs = {}
  if not block or (block.t ~= "Plain" and block.t ~= "Para") then
    return imgs
  end
  for _, inline in ipairs(block.content) do
    if inline.t == "RawInline" and inline.format == "html" and inline.text:match("<%s*img%s") then
      local img = image_from_img_tag(inline.text)
      if img then table.insert(imgs, img) end
    end
  end
  return imgs
end

function Blocks(blocks)
  local out = pandoc.List()
  local i = 1

  while i <= #blocks do
    if is_center_open(blocks[i]) then
      local j = i + 1
      local all_imgs = {}

      -- collect from following Plain/Para blocks until </p>
      while j <= #blocks and not is_p_close(blocks[j]) do
        local imgs = collect_imgs_from_block(blocks[j])
        for _, img in ipairs(imgs) do table.insert(all_imgs, img) end
        j = j + 1
      end

      if j <= #blocks and is_p_close(blocks[j]) and #all_imgs > 0 then
        -- build centered gallery block
        local inlines = {}
        for k, img in ipairs(all_imgs) do
          if k > 1 then
            table.insert(inlines, pandoc.RawInline("latex", "\\hspace{0.75em}"))
          end
          table.insert(inlines, img)
        end

        out:insert(pandoc.Div(
          { pandoc.Para(inlines) },
          pandoc.Attr("", {}, { ["style"] = "text-align: center;" })
        ))

        i = j + 1 -- skip past </p>
      else
        -- pattern didn't match well; keep original block
        out:insert(blocks[i])
        i = i + 1
      end
    else
      out:insert(blocks[i])
      i = i + 1
    end
  end

  return out
end
