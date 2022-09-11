local draw = require 'draw_utils'
local button = require 'button'
local spermAnim = require 'sperm_anim'

return function ()
  local s = {}
  local W, H = W, H
  local font = _G['font_AaGSKA']

  local textHint = love.graphics.newText(font[40],
    '受激素影响卵子不排出，无法形成受精卵而怀孕'
  )
  local T = 0

  local spermGenX = W * 0.5
  local spermGenY = H * 0.9
  local spermIntroH = H * 0.06
  local spermGenXSD = W * 0.005
  local sperms = {}
  local spermGenCounter = 1

  local spermTurnawayY = H * 0.34

  s.press = function (x, y)
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
  end

  s.release = function (x, y)
  end

  s.update = function ()
    T = T + 1

    for i = 1, #sperms do
      local s = sperms[i]
      s.update()
      if s.y < spermTurnawayY and not s.turned then
        s.turned = 0
      end
      if s.turned then
        s.turned = s.turned + 1
        if s.turned <= 20 then
          s.vx = s.vx + (love.math.random() - 0.5) * 0.06
          s.vy = s.vy + (love.math.random() - 0.5) * 0.06
          -- local v = math.sqrt(s.vx * s.vx + s.vy * s.vy)
          s.vx = s.vx * 0.97
          s.vy = s.vy * 0.97
        end
      end
    end

    spermGenCounter = spermGenCounter - 1
    if spermGenCounter == 0 then
      spermGenCounter = love.math.random(50, 60)
      local x = spermGenX + spermGenXSD *
        math.max(-2, math.min(2, love.math.randomNormal()))
      local y = spermGenY
      local vx = 0
      local vy = -(0.5 + love.math.randomNormal() * 0.05)
      sperms[#sperms + 1] = spermAnim(x, y, vx, vy)
    end
  end

  s.draw = function ()
    love.graphics.clear(1, 1, 0.99)

    love.graphics.setColor(1, 1, 1)
    draw.img('reprod', W * 0.5, H * 0.4, W * 0.5)

    for i = 1, #sperms do
      local s = sperms[i]
      local baseAlpha = s.turned and (1 - math.max(0, (s.turned - 60) / 120)) or 1
      s.draw(function (x, y)
        return math.max(0, math.min(1, (spermGenY - y) / spermIntroH)) * baseAlpha
      end)
    end

    if T >= 720 then
      local alpha = math.min(1, (T - 720) / 240)
      alpha = 1 - (1 - alpha) * (1 - alpha)
      draw.shadow(0.3, 0.3, 0.3, alpha, textHint, W * 0.5, H * 0.8)
    end
  end

  s.destroy = function ()
  end

  return s
end
