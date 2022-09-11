local draw = require 'draw_utils'
local button = require 'button'
local spermAnim = require 'sperm_anim'
local misc = require 'misc_utils'

return function ()
  local s = {}
  local W, H = W, H
  local font = _G['font_AaGSKA']

  local text1 = love.graphics.newText(font[40], '卵子从卵巢出发，停留在输卵管中')
  local text2 = love.graphics.newText(font[40], '一颗精子与卵子结合，形成受精卵')

  local T = 0

  local spermGenX = W * 0.5
  local spermGenY = H * 0.9
  local spermIntroH = H * 0.06
  local spermGenXSD = W * 0.005
  local sperms = {}
  local spermGenCounter = 1440

  local spermDestrY = H * 0.32
  local spermDestrH = H * 0.08

  local eggX = W * 0.63
  local eggY = H * 0.242

  local buttonBack = misc.buttonBack()

  s.press = function (x, y)
    if buttonBack.press(x, y) then return true end
  end

  s.hover = function (x, y)
    if buttonBack.move(x, y) then return true end
  end

  s.move = function (x, y)
    if buttonBack.move(x, y) then return true end
  end

  s.release = function (x, y)
    if buttonBack.release(x, y) then return true end
  end

  s.update = function ()
    buttonBack.update()

    T = T + 1

    for i = 1, #sperms do
      local s = sperms[i]
      s.update()
      if s.fert then
        if not s.turned and s.y < spermDestrY then
          s.turned = true
        end
        if s.turned then
          local dx = eggX - s.x
          local dy = eggY - s.y
          local d = math.sqrt(dx * dx + dy * dy)
          local vx = s.vx + dx / d * 0.0055
          local vy = s.vy + dy / d * 0.0055
          local vmax = math.min(0.5, (dx * dx + dy * dy) / 1600)
          local scale = math.min(1, vmax / math.sqrt(vx * vx + vy * vy))
          s.vx = vx * scale
          s.vy = vy * scale
        end
      end
    end

    local i = 1
    while i <= #sperms do
      if not sperms[i].fert and sperms[i].y < spermDestrY - spermDestrH then
        sperms[i] = sperms[#sperms]
        sperms[#sperms] = nil
      else
        i = i + 1
      end
    end

    spermGenCounter = spermGenCounter - 1
    if spermGenCounter == 0 and T <= 2760 then
      local first = (#sperms == 0)
      spermGenCounter = love.math.random(50, 60)
      local x = spermGenX + spermGenXSD *
        math.max(-2, math.min(2, love.math.randomNormal()))
      local y = spermGenY
      local vx = 0
      local vy = -(0.5 + love.math.randomNormal() * 0.05)
      local s = spermAnim(x, y, vx, vy)
      if first then s.fert = true end
      sperms[#sperms + 1] = s
    end
  end

  local ramps = function (x, a, b, w)
    if x <= a or x >= b then return 0
    elseif x >= a + w and x <= b - w then return 1
    elseif x < a + w then -- a < x < a + w
      return ((x - a) / w)^2
    else -- b - w < x < b
      return ((b - x) / w)^2
    end
  end

  s.draw = function ()
    love.graphics.clear(1, 1, 0.99)

    love.graphics.setColor(1, 1, 1)
    draw.img('reprod', W * 0.5, H * 0.4, W * 0.5)

    if T >= 240 then
      local eggR = 11 + 0.5 * math.sin(T * 0.01)
      if T < 960 then
        local x = (T - 240) / 720
        eggR = eggR * (1 - math.cos(15 * x) * math.exp(-5 * x) * (1 - x))
        love.graphics.setColor(0.1, 0.1, 0.1, (1 - x) * (1 - x))
        love.graphics.circle('line', eggX, eggY, 10 + 120 * (1 - math.exp(-5 * x)))
      end
      love.graphics.setColor(0.3, 0.3, 0.3)
      love.graphics.circle('fill', eggX, eggY, eggR + 2)
      love.graphics.setColor(0.9, 0.9, 0.88)
      love.graphics.circle('fill', eggX, eggY, eggR)
    end

    for i = 1, #sperms do
      local s = sperms[i]
      local baseAlpha = 1
      if not s.fert then
        baseAlpha = math.max(0, math.min(1, (s.y - spermDestrY) / spermDestrH))
      end
      s.draw(function (x, y)
        return math.max(0, math.min(1, (spermGenY - y) / spermIntroH)) * baseAlpha
      end)
    end

    if T >= 600 and T < 1440 then
      local alpha = ramps(T, 600, 1440, 60)
      draw.shadow(0.3, 0.3, 0.3, alpha, text1, W * 0.5, H * 0.8)
    elseif T >= 2760 and T < 3600 then
      local alpha = ramps(T, 2760, 3600, 60)
      draw.shadow(0.3, 0.3, 0.3, alpha, text2, W * 0.5, H * 0.8)
    end

    love.graphics.setColor(0.3, 0.3, 0.3)
    buttonBack.draw()
  end

  s.destroy = function ()
  end

  return s
end
