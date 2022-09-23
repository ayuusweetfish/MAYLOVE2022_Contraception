local draw = require 'draw_utils'
local button = require 'button'
local spermAnim = require 'sperm_anim'
local misc = require 'misc_utils'

return function ()
  local s = {}
  local W, H = W, H
  local font = _G['font_Kuaile']

  local text1 = love.graphics.newText(font[40], '卵子从卵巢出发，停留在输卵管中')
  local text2 = love.graphics.newText(font[40], '一颗精子与卵子结合，形成受精卵')
  local text3 = love.graphics.newText(font[40], '需要在 72 小时内使用紧急避孕药')
  local text4 = love.graphics.newText(font[40], '因子宫内壁并没有增厚，受精卵无法着床而被排出')
  local text5 = love.graphics.newText(font[40], '＊紧急避孕药绝对不是常规的避孕方式！')

  local textHour = love.graphics.newText(font[40], '时')
  local textMinute = love.graphics.newText(font[40], '分')
  local textHourNum, textMinuteNum
  local textHourFrozen, textMinuteFrozen

  local T = 0
  local timingStart = 4080
  local timingSpd = 1.5 -- 6 hours per second

  local updateTimingTexts = function ()
    local minutes = (T - timingStart) * timingSpd
    local hours
    if minutes >= 2880 then
      minutes = 4320 - 1440 * math.exp(-1/1440 * (minutes - 2880))
    end
    hours, minutes = math.floor(minutes / 60), minutes % 60
    if hours ~= textHourFrozen then
      textHourNum = love.graphics.newText(font[60], string.format('%02d', hours))
      textHourFrozen = hours
    end
    if minutes ~= textMinuteFrozen then
      textMinuteNum = love.graphics.newText(font[60], string.format('%02d', minutes))
      textMinuteFrozen = minutes
    end
  end

  local pillShow = timingStart + 20 * 60 / timingSpd
  local sincePillPress = -1
  local buttonPill
  buttonPill = button(
    draw.get('icon_emergency'),
    function ()
      buttonPill.enabled = false
      sincePillPress = 0
      print('!')
    end
  )
  buttonPill.enabled = false
  buttonPill.x = W * 0.78
  buttonPill.y = H * 0.66

  local spermGenX = W * 0.5
  local spermGenY = H * 0.9
  local spermIntroH = H * 0.06
  local spermGenXSD = W * 0.005
  local sperms = {}
  local spermGenCounter = 1440
  local fertSperm

  local spermDestrY = H * 0.32
  local spermDestrH = H * 0.08

  local eggX = W * 0.63
  local eggY = H * 0.242
  local eggMovePts = {
    0.630, 0.242, --
    0.575, 0.174,
    0.504, 0.208,
    0.515, 0.287, --
    0.500, 0.270,
    0.487, 0.314,
    0.478, 0.267, --
  }
  local eggMoveCurves = {}
  for i = 1, #eggMovePts - 7, 6 do
    eggMoveCurves[#eggMoveCurves + 1] = love.math.newBezierCurve(
      W * eggMovePts[i + 0], H * eggMovePts[i + 1],
      W * eggMovePts[i + 2], H * eggMovePts[i + 3],
      W * eggMovePts[i + 4], H * eggMovePts[i + 5],
      W * eggMovePts[i + 6], H * eggMovePts[i + 7]
    )
  end

  local buttonBack = misc.buttonBack()

  s.press = function (x, y)
    if buttonBack.press(x, y) then return true end
    if buttonPill.press(x, y) then return true end
  end

  s.hover = function (x, y)
    if buttonBack.move(x, y) then return true end
    if buttonPill.move(x, y) then return true end
  end

  s.move = function (x, y)
    if buttonBack.move(x, y) then return true end
    if buttonPill.move(x, y) then return true end
  end

  s.release = function (x, y)
    if buttonBack.release(x, y) then return true end
    if buttonPill.release(x, y) then return true end
  end

  s.update = function ()
    buttonBack.update()
    buttonPill.update()

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
      if first then s.fert = true; fertSperm = s end
      sperms[#sperms + 1] = s
    end

    if sincePillPress >= 0 then
      sincePillPress = sincePillPress + 1
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

    local eggMoveAlpha = 1

    if T >= 240 then
      local eggR = 11 + 0.5 * math.sin(T * 0.01)
      if T < 960 then
        local x = (T - 240) / 720
        eggR = eggR * (1 - math.cos(15 * x) * math.exp(-5 * x) * (1 - x))
        love.graphics.setColor(0.1, 0.1, 0.1, (1 - x) * (1 - x))
        love.graphics.circle('line', eggX, eggY, 10 + 120 * (1 - math.exp(-5 * x)))
      end
      -- Movement
      if sincePillPress >= 240 then
        local tx, ty
        if sincePillPress < 960 then
          local t = (sincePillPress - 240) / 720
          tx, ty = eggMoveCurves[1]:evaluate((1 - math.cos(t * math.pi)) / 2)
        else
          local t1 = (sincePillPress - 960) / 600
          local t = math.min(1, t1)
          local z = t * t
          tx, ty = eggMoveCurves[2]:evaluate((1 - math.cos(t * math.pi)) / 2 * (1 - z) + z)
          eggMoveAlpha = math.max(0, math.min(1, 1 - (t1 - 0.75) / 0.25))
          eggMoveAlpha = (1 - math.cos(eggMoveAlpha * math.pi)) / 2
        end
        fertSperm.x = fertSperm.x + (tx - eggX)
        fertSperm.y = fertSperm.y + (ty - eggY)
        eggX, eggY = tx, ty
      end
      love.graphics.setColor(0.3, 0.3, 0.3, eggMoveAlpha)
      love.graphics.circle('fill', eggX, eggY, (eggR + 2) * (0.5 + 0.5 * eggMoveAlpha))
      love.graphics.setColor(0.9, 0.9, 0.88, eggMoveAlpha)
      love.graphics.circle('fill', eggX, eggY, eggR * (0.5 + 0.5 * eggMoveAlpha))
    end

    -- for i = 1, #eggMoveCurves do
    --   love.graphics.setColor(0, 0, 0)
    --   love.graphics.line(eggMoveCurves[i]:render())
    -- end

    if sincePillPress >= 0 then
      fertSperm.drawDot(eggMoveAlpha)
    else
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
    end

    if T >= timingStart then
      local alpha = ramps(T, timingStart, 99999, 60)
      if sincePillPress >= 240 then
        alpha = alpha * math.max(0, 1 - (sincePillPress - 240) / 60)
      end
      if alpha > 0 then
        draw.shadow(0.3, 0.3, 0.3, alpha, textHour, W * 0.2, H * 0.43)
        draw.shadow(0.3, 0.3, 0.3, alpha, textMinute, W * 0.36, H * 0.43)
        updateTimingTexts()
        draw.shadow(0.3, 0.3, 0.3, alpha, textHourNum, W * 0.12, H * 0.426)
        draw.shadow(0.3, 0.3, 0.3, alpha, textMinuteNum, W * 0.28, H * 0.426)
      end
    end

    if T >= pillShow then
      local alpha = ramps(T, pillShow, 99999, 60)
      if sincePillPress == -1 then
        buttonPill.enabled = true
      else
        alpha = alpha * math.max(0, 1 - sincePillPress / 60)
      end
      if alpha > 0 then
        love.graphics.setColor(1, 1, 1, alpha)
        buttonPill.draw()
      end
    end

    if sincePillPress >= 1560 then
      local alpha = ramps(sincePillPress, 1560, 99999, 60)
      draw.shadow(0.3, 0.3, 0.3, alpha, text4, W * 0.5, H * 0.77)
      if sincePillPress >= 2520 then
        local alpha = ramps(sincePillPress, 2520, 99999, 60)
        draw.shadow(0.8, 0.3, 0.3, alpha, text5, W * 0.5, H * 0.85)
      end
    elseif T >= 600 and T < 1440 then
      local alpha = ramps(T, 600, 1440, 60)
      draw.shadow(0.3, 0.3, 0.3, alpha, text1, W * 0.5, H * 0.8)
    elseif T >= 2760 and T < 3600 then
      local alpha = ramps(T, 2760, 3600, 60)
      draw.shadow(0.3, 0.3, 0.3, alpha, text2, W * 0.5, H * 0.8)
    elseif T >= 4560 then
      local alpha = ramps(T, 4560, 99999, 60)
      if sincePillPress >= 240 then
        alpha = alpha * math.max(0, 1 - (sincePillPress - 240) / 60)
      end
      draw.shadow(0.3, 0.3, 0.3, alpha, text3, W * 0.5, H * 0.8)
    end

    love.graphics.setColor(0.3, 0.3, 0.3)
    buttonBack.draw()
  end

  s.destroy = function ()
  end

  return s
end
