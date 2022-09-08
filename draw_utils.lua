local imgs = {}

local files = love.filesystem.getDirectoryItems('res')
for i = 1, #files do
  local file = files[i]
  if file:sub(-4) == '.png' then
    local name = file:sub(1, #file - 4)
    local img = love.graphics.newImage('res/' .. file)
    imgs[name] = img
  end
end

local draw = function (drawable, x, y, w, h, ax, ay, r)
  ax = ax or 0.5
  ay = ay or 0.5
  r = r or 0
  local iw, ih = drawable:getDimensions()
  local sx = w and w / iw or 1
  local sy = h and h / ih or sx
  love.graphics.draw(drawable,
    x, y, r,
    sx, sy,
    ax * iw, ay * ih)
end

local img = function (name, x, y, w, h, ax, ay, r)
  draw(imgs[name], x, y, w, h, ax, ay, r)
end

local shadow = function (R, G, B, drawable, x, y, w, h, ax, ay, r)
  love.graphics.setColor(R, G, B)
  draw(drawable, x - 1, y - 1, w, h, ax, ay, r)
  love.graphics.setColor(R / 2, G / 2, B / 2)
  draw(drawable, x + 1, y + 1, w, h, ax, ay, r)
end

local draw_ = {
  get = function (name) return imgs[name] end,
  img = img,
  shadow = shadow,
}
setmetatable(draw_, { __call = function (self, ...) draw(...) end })
return draw_
