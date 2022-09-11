return function (x, y, vx, vy)
  vx = vx or 0
  vy = vy or 0

  local s = {
    x = x,
    y = y,
    vx = vx,
    vy = vy,
    hist = {},
  }

  local N_HIST = 60
  local T = 0

  for i = 1, N_HIST do s.hist[i] = {x, y, 0, 0} end

  s.update = function ()
    T = T + 1
    local histPtr = T % N_HIST + 1
    s.hist[histPtr] = {s.x, s.y, s.vx, s.vy}
    s.x = s.x + s.vx
    s.y = s.y + s.vy
  end

  s.draw = function (fnAlpha)
    local histPtr = T % N_HIST + 1
    local x1, y1 = s.x, s.y
    for i = N_HIST - 1, 0, -1 do
      local x, y, vx, vy = unpack(s.hist[(i + histPtr) % N_HIST + 1])
      local x2 = x + vy * math.sin(i * 0.12 + T * 0.1) * (1 - i / N_HIST) * 6
      local y2 = y - vx * math.sin(i * 0.12 + T * 0.1) * (1 - i / N_HIST) * 6
      local a2 = fnAlpha and fnAlpha(x2, y2) or 1
      love.graphics.setColor(0.1, 0.1, 0.1, (i / N_HIST) * a2)
      love.graphics.line(x1, y1, x2, y2)
      x1, y1 = x2, y2
    end
    love.graphics.setColor(0.1, 0.1, 0.1, fnAlpha and fnAlpha(s.x, s.y) or 1)
    love.graphics.circle('fill', s.x, s.y, 3)
  end

  return s
end
