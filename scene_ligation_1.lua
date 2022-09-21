local draw = require 'draw_utils'
local button = require 'button'
local misc = require 'misc_utils'

return function ()
  local s = {}
  local W, H = W, H
  local font = _G['font_AaGSKA']

  local rowY = function (i) return H * (0.59 + 0.2 * (i - 2)) end

  local textTitle = love.graphics.newText(font[60], '指出正确的结扎位置')

  local diagramCenX, diagramCenY = W * 0.5, H * 0.55
  local diagramW = W * 0.3
  local diagramH = diagramW * (178 / 155)

  local sinceWrong = -1
  local wrongX, wrongY
  local sinceLastWrongFade = -1
  local lastWrongX, lastWrongY
  local sinceCorrect = -1
  local correctX, correctY

  local correct = function (x, y)
    x = x - diagramCenX
    y = y - diagramCenY
    local sx1, sy1 = -39, 10
    local sx2, sy2 = -57, -30
    local distToSeg = function (ax, ay, px, py, qx, qy)
      local l2 = (px - qx) * (px - qx) + (py - qy) * (py - qy)
      local t = ((ax - px) * (qx - px) + (ay - py) * (qy - py)) / l2
      t = math.max(0, math.min(1, t))
      local bx, by = px + (qx - px) * t, py + (qy - py) * t
      return math.sqrt((ax - bx) * (ax - bx) + (ay - by) * (ay - by))
    end
    return distToSeg(x, y, sx1, sy1, sx2, sy2) <= 15
      or distToSeg(x, y, -sx1, sy1, -sx2, sy2) <= 15
  end

  local buttonBack = misc.buttonBack()

  s.press = function (x, y)
    if buttonBack.press(x, y) then return true end
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
    if buttonBack.move(x, y) then return true end
  end

  s.release = function (x, y)
    if buttonBack.release(x, y) then return true end

    if sinceCorrect == -1 then
      if x >= diagramCenX - diagramW / 2 and x <= diagramCenX + diagramW / 2 and
         y >= diagramCenY - diagramH / 2 and y <= diagramCenY + diagramH / 2
      then
        if sinceWrong ~= -1 then
          sinceLastWrongFade = math.max(0, 120 - sinceWrong) * 0.4
          lastWrongX, lastWrongY = wrongX, wrongY
        end
        if correct(x, y) then
          sinceWrong = -1
          sinceCorrect = 0
          correctX, correctY = x, y
        else
          sinceWrong = 0
          wrongX, wrongY = x, y
        end
      end
    end
  end

  s.update = function ()
    buttonBack.update()
    if sinceWrong >= 0 then sinceWrong = sinceWrong + 1 end
    if sinceLastWrongFade >= 0 then
      sinceLastWrongFade = sinceLastWrongFade + 1
      if sinceLastWrongFade == 48 then sinceLastWrongFade = -1 end
    end
    if sinceCorrect >= 0 then
      sinceCorrect = sinceCorrect + 1
      if sinceCorrect == 480 then replaceScene(sceneLigation2()) end
    end
  end

  s.draw = function ()
    love.graphics.clear(1, 1, 0.99)
    love.graphics.setColor(1, 1, 1)

    draw.img('male_reprod', diagramCenX, diagramCenY, diagramW)

    if sinceWrong >= 0 then
      local x = sinceWrong / 120
      x = 1 - math.exp(-x * 5) * (1 - x)
      love.graphics.setColor(1, 1, 1, x)
      draw.img('cross', wrongX, wrongY, x * 60)
    end
    if sinceLastWrongFade >= 0 then
      local x = 1 - sinceLastWrongFade / 48
      x = 1 - math.exp(-x * 5) * (1 - x)
      love.graphics.setColor(1, 1, 1, x)
      draw.img('cross', lastWrongX, lastWrongY, x * 60)
    end
    if sinceCorrect >= 0 then
      local x = sinceCorrect / 120
      x = 1 - math.exp(-x * 5) * (1 - x)
      love.graphics.setColor(0.6, 0.8, 0.5, 0.5 * x)
      love.graphics.circle('fill', correctX, correctY, x * 30)
      love.graphics.circle('fill', diagramCenX * 2 - correctX, correctY, x * 30)
      love.graphics.setColor(1, 1, 1, x)
      draw.img('tick', correctX, correctY, x * 60, nil, 0.4, 0.65)
      draw.img('tick', diagramCenX * 2 - correctX, correctY, x * 60, nil, 0.4, 0.65)
    end

    draw.shadow(0.3, 0.3, 0.3, 1, textTitle, W * 0.5, H * 0.19)

    love.graphics.setColor(0.3, 0.3, 0.3)
    buttonBack.draw()

  --[[
    local step = 3
    local rx = math.floor((diagramW / 2) / step) * step
    local ry = math.floor((diagramH / 2) / step) * step
    for x = diagramCenX - rx, diagramCenX + rx, step do
      for y = diagramCenY - ry, diagramCenY + ry, step do
        if x == diagramCenX and y == diagramCenY then
          love.graphics.setColor(1.0, 0.4, 0.4, 0.9)
        elseif correct(x, y) then
          love.graphics.setColor(0.4, 0.8, 0.4, 0.9)
        else
          love.graphics.setColor(0.4, 0.4, 0.4, 0.9)
        end
        love.graphics.circle('fill', x, y, step * 0.3)
      end
    end
  ]]
  end

  s.destroy = function ()
  end

  return s
end
