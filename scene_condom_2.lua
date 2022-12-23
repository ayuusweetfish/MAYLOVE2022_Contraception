local draw = require 'draw_utils'
local button = require 'button'
local spermAnim = require 'sperm_anim'
local knob = require 'knob'
local misc = require 'misc_utils'

return function ()
  local s = {}
  local W, H = W, H
  local font = _G['font_AaGSKA']

  local textTitle = love.graphics.newText(font[60], '将套套旋转到正确的方向')
  local textSuccessHint = love.graphics.newText(font[40], '精子被隔绝在外，实现避孕')

  local condomX = W * 0.41
  local condomY = H * 0.52
  local condomAngle = 0.5 + love.math.random() * 0.6
  if love.math.random(2) == 1 then condomAngle = -condomAngle end
  local knobCondom = knob(condomX, condomY, condomAngle)

  local buttonConfirmX = W * 0.7
  local buttonConfirmY = H * 0.52
  local sinceWrong = 360
  local sinceCorrect = -1

  local buttonConfirm
  buttonConfirm = button(
    draw.enclose(love.graphics.newText(font[48], '确认'), W * 0.18, H * 0.12),
    function ()
      local normalizedAngle = ((condomAngle % (math.pi * 2)) + 0.25) % (math.pi * 2) - 0.25
      if math.abs(normalizedAngle) <= 0.25 then
        sinceCorrect = 0
        condomAngle = normalizedAngle
        buttonConfirm.enabled = false
      else
        sinceWrong = 0
      end
    end
  )
  buttonConfirm.x = buttonConfirmX
  buttonConfirm.y = buttonConfirmY

  local condomMoveToX = W * 0.5
  local condomMoveToY = H * 0.6
  local spermGenX = W * 0.5
  local spermGenY = H * 0.9
  local spermIntroH = H * 0.06
  local spermGenXSD = W * 0.015
  local spermTurnaroundY = H * 0.63
  local spermDestrY = H * 0.98
  local sperms = {}
  local spermGenCounter = -1

  local buttonBack = misc.buttonBack()

  s.press = function (x, y)
    if buttonBack.press(x, y) then return true end
    if buttonConfirm.press(x, y) then return true end
    if knobCondom.press(x, y) then return true end
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
    if buttonBack.move(x, y) then return true end
    if buttonConfirm.move(x, y) then return true end
    if knobCondom.move(x, y) then
      condomAngle = knobCondom.angle
      return true
    end
  end

  s.release = function (x, y)
    if buttonBack.release(x, y) then return true end
    if buttonConfirm.release(x, y) then return true end
    if knobCondom.release(x, y) then return true end
  end

  s.update = function ()
    buttonBack.update()
    buttonConfirm.update()
    if sinceWrong < 360 then sinceWrong = sinceWrong + 1 end
    if sinceCorrect >= 0 and sinceCorrect < 120 then
      condomX = condomX + (condomMoveToX - condomX) * 0.03
      condomY = condomY + (condomMoveToY - condomY) * 0.03
      condomAngle = condomAngle * 0.97
    elseif sinceCorrect >= 120 then
      spermGenCounter = spermGenCounter - 1
      for i = 1, #sperms do
        local s = sperms[i]
        s.update()
        if s.y < spermTurnaroundY then
          local rate = (s.vy < 0 and 0.003 or 0.002)
          s.vx = s.vx + (love.math.random() - 0.5) * s.vy * 0.06
          s.vy = s.vy - (s.y - spermTurnaroundY) * rate
        end
      end
      local i = 1
      while i <= #sperms do
        if sperms[i].y >= spermDestrY then
          sperms[i] = sperms[#sperms]
          sperms[#sperms] = nil
        else
          i = i + 1
        end
      end
      if spermGenCounter <= 0 then
        spermGenCounter = love.math.random(50, 60)
        local x = spermGenX + spermGenXSD *
          math.max(-2, math.min(2, love.math.randomNormal()))
        local y = spermGenY
        local vx = 0
        local vy = -(0.5 + love.math.randomNormal() * 0.05)
        sperms[#sperms + 1] = spermAnim(x, y, vx, vy)
      end
    end
    if sinceCorrect >= 0 and sinceCorrect < 960 then
      sinceCorrect = sinceCorrect + 1
    end
  end

  s.draw = function ()
    love.graphics.clear(1, 1, 0.99)

    local rotateControlsAlpha = 1
    local uterusAlpha = 0
    if sinceCorrect >= 0 then
      rotateControlsAlpha = math.max(0, 1 - sinceCorrect / 60)
      rotateControlsAlpha = rotateControlsAlpha * rotateControlsAlpha
      uterusAlpha = math.min(1, sinceCorrect / 120)
      uterusAlpha = 1 - (1 - uterusAlpha) * (1 - uterusAlpha)
    end

    if uterusAlpha > 0 then
      love.graphics.setColor(1, 1, 1, uterusAlpha)
      draw.img('reprod', W * 0.5, H * 0.4, W * 0.5)
    end

    love.graphics.setColor(1, 1, 1)
    draw.img('condom_open', condomX, condomY,
      W * 0.12, nil, 0.5, 0.5, condomAngle)

    love.graphics.setColor(1, 1, 1, rotateControlsAlpha)
    draw.shadow(0.3, 0.3, 0.3, rotateControlsAlpha, textTitle, W * 0.5, H * 0.19)

    local px, py = condomX, 0.65 * H
    local pw, ph = 0.08 * W, 0.3 * H
    love.graphics.setColor(0.8, 0.8, 0.8, rotateControlsAlpha)
    love.graphics.rectangle('fill', px - pw / 2, py, pw, ph, pw / 2)

    love.graphics.setColor(0, 0, 0, rotateControlsAlpha)
    buttonConfirm.draw()

    if sinceWrong < 360 then
      local w, alpha
      if sinceWrong < 60 then
        local x = sinceWrong / 60
        x = 1 - math.exp(-x * 5) * (1 - x)
        w = 120 * x
        alpha = x
      elseif sinceWrong < 300 then
        w = 120
        alpha = 1
      else
        local x = (sinceWrong - 300) / 60
        local x1 = 1 + math.exp(-(1 - x) * 0.5) * x
        w = 120 + 20 * (x1 - 1)
        alpha = 1 - math.sin(x * math.pi / 2)
      end
      love.graphics.setColor(1, 1, 1, alpha * rotateControlsAlpha)
      draw.img('cross', buttonConfirmX, buttonConfirmY, w)
    end

    if sinceCorrect >= 0 then
      local fnAlpha = function (x, y)
        return math.max(0, math.min(1, (spermGenY - y) / spermIntroH))
      end
      for i = 1, #sperms do
        local s = sperms[i]
        s.draw(fnAlpha)
      end
    end

    if sinceCorrect >= 720 then
      local alpha = math.min(1, (sinceCorrect - 720) / 240)
      alpha = 1 - (1 - alpha) * (1 - alpha)
      draw.shadow(0.3, 0.3, 0.3, alpha, textSuccessHint, W * 0.5, H * 0.8)
    end

    love.graphics.setColor(0.3, 0.3, 0.3)
    buttonBack.draw()
  end

  s.destroy = function ()
  end

  return s
end
