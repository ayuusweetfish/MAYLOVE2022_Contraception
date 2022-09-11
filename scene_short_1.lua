local draw = require 'draw_utils'
local button = require 'button'
local knob = require 'knob'

return function ()
  local s = {}
  local W, H = W, H
  local font = _G['font_AaGSKA']

  local rowY = function (i) return H * (0.59 + 0.2 * (i - 2)) end

  local textTitle = love.graphics.newText(font[60], '设定每日服药的时间')

  local alarmCenX = W * 0.5
  local alarmCenY = H * 0.5 + 39.5

  local alarmSetTime = love.math.random() * math.pi
  local knobAlarm = knob(alarmCenX, alarmCenY, alarmSetTime)

  local alarmCurTime = alarmSetTime
  local dayProgress = 0
  local dayProgressTarget = 0

  local buttonConfirm = button(
    draw.enclose(love.graphics.newText(font[48], '确认'), W * 0.18, H * 0.12),
    function ()
      alarmCurTime = alarmSetTime
      dayProgressTarget = 1
    end
  )
  buttonConfirm.x = W * 0.8
  buttonConfirm.y = H * 0.75

  s.press = function (x, y)
    if buttonConfirm.press(x, y) then return true end
    if knobAlarm.press(x, y) then return true end
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
    if buttonConfirm.move(x, y) then return true end
    if knobAlarm.move(x, y) then
      alarmCurTime = knobAlarm.angle
      return true
    end
  end

  s.release = function (x, y)
    if buttonConfirm.release(x, y) then return true end
    if knobAlarm.release(x, y) then return true end
  end

  s.update = function ()
    buttonConfirm.update()
    if dayProgressTarget > 0 then
      dayProgress = math.min(dayProgressTarget, dayProgress + 1 / 360)
      local x = (1 - (1 - dayProgress) * (1 - dayProgress) * (1 - dayProgress)) * math.sin(dayProgress * math.pi / 2)
      alarmCurTime = alarmSetTime + x * (4 * math.pi)
      if dayProgress == dayProgressTarget then
        dayProgressTarget = 0
      end
    end
  end

  s.draw = function ()
    love.graphics.clear(1, 1, 0.99)

    love.graphics.setColor(1, 1, 1)
    draw.img('alarm_clock', W * 0.5, H * 0.5, W * 0.24)
    love.graphics.setColor(1, 1, 1,
      (math.cos(dayProgress * math.pi * 2) + 1) / 2)
    draw.img('alarm_clock_hand_m', alarmCenX, alarmCenY, nil, nil, 0.5, 1, alarmCurTime * 12)
    love.graphics.setColor(1, 1, 1)
    draw.img('alarm_clock_hand_h', alarmCenX, alarmCenY, nil, nil, 0.5, 1, alarmCurTime)

    love.graphics.setColor(0, 0, 0)
    buttonConfirm.draw()

    draw.shadow(0.3, 0.3, 0.3, 1, textTitle, W * 0.5, H * 0.19)
  end

  s.destroy = function ()
  end

  return s
end
