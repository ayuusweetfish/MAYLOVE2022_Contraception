local draw = require 'draw_utils'
local button = require 'button'

return function ()
  local s = {}
  local W, H = W, H
  local font = _G['font_AaGSKA']

  local t1 = love.graphics.newText(font[80], '我从哪里来')
  local t2 = love.graphics.newText(font[48], '选择一种避孕方式')

  local options = {
    {'condom', _G['sceneCondom1']},
    {'short_acting', _G['sceneShort1']},
    {'emergency', _G['sceneEmerg1']},
    {'ligation', _G['']},
  }

  local buttons = {}
  for i = 1, #options do
    local name, scene = unpack(options[i])
    local button_img = draw.get('icon_' .. name)
    buttons[i] = button(button_img, function ()
      replaceScene(scene())
    end)
    buttons[i].x = W * (0.5 + 0.22 * (i - 2.5))
    buttons[i].y = H * 0.7
    buttons[i].s = 0.8
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
  end

  s.draw = function ()
    love.graphics.clear(1, 1, 0.99)
    love.graphics.setColor(1, 1, 1, 0.2)
    draw.img('intro_bg', W / 2, H / 2, H * 0.8)
    draw.shadow(0.3, 0.3, 0.3, 1, t1, W / 2, H * 0.25)
    draw.shadow(0.5, 0.5, 0.5, 1, t2, W / 2, H * 0.44)

    love.graphics.setColor(1, 1, 1)
    for i = 1, #buttons do buttons[i].draw() end
  end

  s.destroy = function ()
  end

  return s
end
