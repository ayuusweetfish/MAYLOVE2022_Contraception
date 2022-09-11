local draw = require 'draw_utils'
local button = require 'button'
local spermAnim = require 'sperm_anim'

return function ()
  local s = {}
  local W, H = W, H
  local font = _G['font_AaGSKA']

  s.press = function (x, y)
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
  end

  s.release = function (x, y)
  end

  s.update = function ()
  end

  s.draw = function ()
    love.graphics.clear(1, 1, 0.99)

    love.graphics.setColor(1, 1, 1)
    draw.img('reprod', W * 0.5, H * 0.4, W * 0.5)
  end

  s.destroy = function ()
  end

  return s
end
