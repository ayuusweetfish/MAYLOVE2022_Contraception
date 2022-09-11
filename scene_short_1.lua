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
  local sinceConfirmInitial = -1

  local dayNum = 0
  local calendarText
  local nextDay = function ()
    dayNum = dayNum + 1
    calendarText = love.graphics.newText(font[120], tonumber(dayNum))
  end

  local buttonConfirm
  buttonConfirm = button(
    draw.enclose(love.graphics.newText(font[48], '确认'), W * 0.18, H * 0.12),
    function ()
      alarmCurTime = alarmSetTime
      dayProgressTarget = 1
      sinceConfirmInitial = 0
      buttonConfirm.enabled = false
      knobAlarm.enabled = false
      nextDay()
    end
  )
  buttonConfirm.x = W * 0.8
  buttonConfirm.y = H * 0.75

  local untilPills = -1
  local sincePills = -1

  local buttonPills
  buttonPills = button(
    draw.get('pills'),
    function ()
      sincePills = 0
      dayProgress = 0
      dayProgressTarget = 1
      untilPills = -1
    end
  )
  buttonPills.enabled = false
  buttonPills.x = W * 0.834
  buttonPills.y = H * 0.8

  s.press = function (x, y)
    if buttonConfirm.press(x, y) then return true end
    if buttonPills.press(x, y) then return true end
    if knobAlarm.press(x, y) then return true end
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
    if buttonConfirm.move(x, y) then return true end
    if buttonPills.move(x, y) then return true end
    if knobAlarm.move(x, y) then
      alarmCurTime = knobAlarm.angle
      return true
    end
  end

  s.release = function (x, y)
    if buttonConfirm.release(x, y) then return true end
    if buttonPills.release(x, y) then return true end
    if knobAlarm.release(x, y) then return true end
  end

  s.update = function ()
    buttonConfirm.update()
    buttonPills.update()
    if dayProgressTarget > 0 then
      dayProgress = math.min(dayProgressTarget, dayProgress + 1 / 360)
      local x = (1 - (1 - dayProgress) * (1 - dayProgress) * (1 - dayProgress))
        * math.sin(dayProgress * math.pi / 2)
      alarmCurTime = alarmSetTime + x * (4 * math.pi)
      if dayProgress == dayProgressTarget then
        dayProgressTarget = 0
        untilPills = 60
      end
    end
    if sinceConfirmInitial >= 0 and sinceConfirmInitial < 240 then
      sinceConfirmInitial = sinceConfirmInitial + 1
    end
    if untilPills > 0 then
      untilPills = untilPills - 1
      if untilPills == 0 then
        buttonPills.enabled = true
      end
    end
    if sincePills >= 0 and sincePills < 120 then
      sincePills = sincePills + 1
      if sincePills == 60 then
        nextDay()
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

    local confirmAlpha = math.max(0, 1 - sinceConfirmInitial / 120)
    confirmAlpha = confirmAlpha * confirmAlpha
    love.graphics.setColor(0, 0, 0, confirmAlpha)
    buttonConfirm.draw()
    draw.shadow(0.3, 0.3, 0.3, confirmAlpha, textTitle, W * 0.5, H * 0.19)

    local calendarAlpha = math.max(0, (sinceConfirmInitial - 120) / 120)
    local calendarTextAlpha = 1
    if sincePills >= 0 then
      if sincePills < 60 then
        calendarTextAlpha = 1 - (sincePills / 60)^2
      else
        calendarTextAlpha = ((sincePills - 60) / 60)^2
      end
    end
    if calendarAlpha > 0 then
      calendarAlpha = 1 - (1 - calendarAlpha) * (1 - calendarAlpha)
      love.graphics.setColor(1, 1, 1, calendarAlpha)
      draw.img('calendar', W * 0.217, H * 0.3, W * 0.2)
      draw.shadow(0.93, 0.5, 0.66, calendarAlpha * calendarTextAlpha,
        calendarText, W * 0.208, H * 0.313)
    end

    local pillsAlpha = 0
    if untilPills >= 0 then
      pillsAlpha = 1 - (untilPills / 60)^2
    elseif sincePills >= 0 then
      pillsAlpha = math.max(0, 1 - (sincePills / 60)^2)
    end
    if pillsAlpha > 0 then
      love.graphics.setColor(1, 1, 1, pillsAlpha)
      buttonPills.draw()
    end
  end

  s.destroy = function ()
  end

  return s
end
