local draw = require 'draw_utils'
local button = require 'button'

return function ()
  local s = {}
  local W, H = W, H
  local font = _G['font_AaGSKA']

  local rowY = function (i) return H * (0.59 + 0.2 * (i - 2)) end

  local textTitle = love.graphics.newText(font[60], '选择一个未过期的套套')

  local buttons = {}
  local texts = {}
  local sinceWrong = {}

  local answer = love.math.random(3)
  local now = os.time()
  for i = 1, 3 do
    sinceWrong[i] = -1

    buttons[i] = button(draw.get('icon_condom'), function ()
      if i == answer then
        replaceScene(sceneCondom2())
      elseif sinceWrong[i] == -1 then
        sinceWrong[i] = 0
      end
    end)
    buttons[i].x = W * 0.3
    buttons[i].y = rowY(i)
    buttons[i].s = 0.6

    local time
    if i == answer then
      time = now + 86400 + love.math.random(86400 * 4)
    else
      time = now - 86400 * 5 - love.math.random(86400 * 120)
    end
    local timestr = os.date('%Y.%m.%d', time)
    texts[i] = love.graphics.newText(font[40], '有效期至：' .. timestr)
  end

  s.press = function (x, y)
    for i = 1, #buttons do if buttons[i].press(x, y) then return true end end
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
    for i = 1, #buttons do if buttons[i].move(x, y) then return true end end
  end

  s.release = function (x, y)
    for i = 1, #buttons do if buttons[i].release(x, y) then return true end end
  end

  s.update = function ()
    for i = 1, #buttons do buttons[i].update() end
    for i = 1, 3 do
      if sinceWrong[i] >= 0 and sinceWrong[i] < 120 then
        sinceWrong[i] = sinceWrong[i] + 1
      end
    end
  end

  s.draw = function ()
    love.graphics.clear(1, 1, 0.99)
    love.graphics.setColor(1, 1, 1)
    for i = 1, #buttons do buttons[i].draw() end

    for i = 1, 3 do
      if sinceWrong[i] >= 0 then
        local x = sinceWrong[i] / 120
        x = 1 - math.exp(-x * 5) * (1 - x)
        local alpha = x
        love.graphics.setColor(1, 1, 1, alpha)
        draw.img('cross', W * 0.3, rowY(i), x * 120)
      end
    end

    draw.shadow(0.3, 0.3, 0.3, 1, textTitle, W * 0.5, H * 0.19)
    for i = 1, 3 do
      draw.shadow(0.5, 0.5, 0.5, 1, texts[i], W * 0.6, rowY(i))
    end
  end

  s.destroy = function ()
  end

  return s
end
