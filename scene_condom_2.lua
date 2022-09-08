local draw = require 'draw_utils'
local button = require 'button'

return function ()
  local s = {}
  local W, H = W, H
  local font = _G['font_AaGSKA']

  local textTitle = love.graphics.newText(font[60], '将套套旋转到正确的方向')

  local condomX = W * 0.41
  local condomY = H * 0.52
  local condomAngle = 0.5 + love.math.random() * 0.6
  if love.math.random(2) == 1 then condomAngle = -condomAngle end

  local buttonConfirmX = W * 0.7
  local buttonConfirmY = H * 0.52
  local sinceWrong = 360

  local buttonConfirm = button(
    draw.enclose(love.graphics.newText(font[48], '确认'), W * 0.18, H * 0.12),
    function ()
      if math.abs(condomAngle) <= 0.25 then
        print('Correct!')
      else
        sinceWrong = 0
      end
    end
  )
  buttonConfirm.x = buttonConfirmX
  buttonConfirm.y = buttonConfirmY

  local holdStartCondomX, holdStartCondomY, holdStartAngle

  s.press = function (x, y)
    if buttonConfirm.press(x, y) then return true end
    if (x - condomX)^2 + (y - condomY)^2 < 50^2 then
      holdStartCondomX, holdStartCondomY = x, y + 50
    else
      holdStartCondomX, holdStartCondomY = condomX, condomY
    end
    holdStartAngle = condomAngle - math.atan2(y - holdStartCondomY, x - holdStartCondomX)
    return true
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
    if buttonConfirm.move(x, y) then return true end
    condomAngle = holdStartAngle + math.atan2(y - holdStartCondomY, x - holdStartCondomX)
    return true
  end

  s.release = function (x, y)
    if buttonConfirm.release(x, y) then return true end
    return true
  end

  s.update = function ()
    buttonConfirm.update()
    if sinceWrong < 360 then sinceWrong = sinceWrong + 1 end
  end

  s.draw = function ()
    love.graphics.clear(1, 1, 0.99)

    draw.shadow(0.3, 0.3, 0.3, textTitle, W * 0.5, H * 0.19)

    love.graphics.setColor(1, 1, 1)
    draw.img('condom_open', condomX, condomY,
      W * 0.12, nil, 0.5, 0.5, condomAngle)

    love.graphics.setColor(0, 0, 0)
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
      love.graphics.setColor(1, 1, 1, alpha)
      draw.img('cross', buttonConfirmX, buttonConfirmY, w)
    end
  end

  s.destroy = function ()
  end

  return s
end
