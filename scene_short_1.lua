local draw = require 'draw_utils'
local button = require 'button'
local knob = require 'knob'
local misc = require 'misc_utils'

return function ()
  local s = {}
  local W, H = W, H
  local font = _G['font_AaGSKA']

  local rowY = function (i) return H * (0.59 + 0.2 * (i - 2)) end

  local textTitle = love.graphics.newText(font[60], '设定每日服药的时间')
  local textInitialHint = love.graphics.newText(font[40], '定时每日服药 1 次，持续 21 天')
  local textMiss = love.graphics.newText(font[40],
    '漏服后应尽快在 12 小时内补服，\n否则需重新开始服药周期')
  local textStopHint1 = love.graphics.newText(font[40], '完成 21 天周期后停药 7 天')
  local textStopHint2 = love.graphics.newText(font[40], '停药期间发生出血是正常现象')

  local alarmCenX = W * 0.5
  local alarmCenY = H * 0.5 + 39.5

  local alarmSetTime = love.math.random() * math.pi
  local knobAlarm = knob(alarmCenX, alarmCenY, alarmSetTime)

  local alarmCurTime = alarmSetTime
  local dayProgress = 0
  local dayProgressStart = 0
  local dayProgressTarget = 0
  local dayProgressSpd = 0
  local untilConfirmVisible = -1
  local sinceConfirmInitial = -1

  local dayNum = 0
  local calendarText
  local nextDay = function ()
    dayNum = dayNum + 1
    calendarText = love.graphics.newText(font[120], tonumber(dayNum))
  end
  local dayMissed = love.math.random(10, 15)
  local missAmount = 0.08 + love.math.random() * 0.03

  local buttonConfirm
  buttonConfirm = button(
    draw.enclose(love.graphics.newText(font[48], '确认'), W * 0.18, H * 0.12),
    function ()
      alarmSetTime = alarmCurTime
      dayProgressStart = 0
      dayProgressTarget = 1
      dayProgressSpd = 1 / 360
      sinceConfirmInitial = 0
      buttonConfirm.enabled = false
      knobAlarm.enabled = false
      nextDay()
    end
  )
  buttonConfirm.enabled = false
  buttonConfirm.x = W * 0.8
  buttonConfirm.y = H * 0.75

  local untilPills = -1
  local sincePills = -1

  local buttonPills
  local pressToContinue = false

  local takePill = function ()
    if dayNum == 27 then
      replaceScene(sceneShort2())
      return
    end
    sincePills = 0
    dayProgress = 0
    dayProgressStart = 0
    dayProgressTarget = 1
    if dayNum + 1 == dayMissed then
      dayProgressTarget = 1 + missAmount
    elseif dayNum == dayMissed then
      dayProgress = missAmount
      dayProgressStart = missAmount
    end
    dayProgressSpd = ((dayNum < 3
      or dayNum == dayMissed - 1
      or dayNum == dayMissed) and 1 / 360 or 1 / 180)
    buttonPills.enabled = false
    pressToContinue = false
    untilPills = -1
  end

  buttonPills = button(draw.get('pills'), takePill)
  buttonPills.enabled = false
  buttonPills.x = W * 0.834
  buttonPills.y = H * 0.8

  local buttonBack = misc.buttonBack()

  s.press = function (x, y)
    if buttonBack.press(x, y) then return true end
    if buttonConfirm.press(x, y) then return true end
    if buttonPills.press(x, y) then return true end
    if knobAlarm.press(x, y) then return true end
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
    if buttonBack.move(x, y) then return true end
    if buttonConfirm.move(x, y) then return true end
    if buttonPills.move(x, y) then return true end
    if knobAlarm.move(x, y) then
      alarmCurTime = knobAlarm.angle
      return true
    end
  end

  s.release = function (x, y)
    if buttonBack.release(x, y) then return true end
    if buttonConfirm.release(x, y) then return true end
    if buttonPills.release(x, y) then return true end
    if knobAlarm.release(x, y) then
      if untilConfirmVisible == -1 then
        untilConfirmVisible = 120
      end
      return true
    end
    if pressToContinue then
      takePill()
      return true
    end
  end

  s.update = function ()
    buttonBack.update()
    buttonConfirm.update()
    buttonPills.update()
    if dayProgressTarget > 0 then
      dayProgress = math.min(dayProgressTarget, dayProgress + dayProgressSpd)
      local x = (dayProgress - dayProgressStart) / (dayProgressTarget - dayProgressStart)
      local y = (1 - (1 - x) * (1 - x) * (1 - x)) * math.sin(x * math.pi / 2)
      alarmCurTime = alarmSetTime +
        (dayProgressStart + y * (dayProgressTarget - dayProgressStart)) * (4 * math.pi)
      if dayProgress == dayProgressTarget then
        dayProgressTarget = 0
        untilPills = (dayNum == dayMissed and 540 or 60)
      end
    end
    if untilConfirmVisible > 0 then
      untilConfirmVisible = untilConfirmVisible - 1
      if untilConfirmVisible == 0 then
        buttonConfirm.enabled = true
      end
    end
    if sinceConfirmInitial >= 0 and sinceConfirmInitial < 240 then
      sinceConfirmInitial = sinceConfirmInitial + 1
    end
    if untilPills > 0 then
      untilPills = untilPills - 1
      if untilPills == 0 then
        if dayNum <= 21 then
          buttonPills.enabled = true
        else
          pressToContinue = true
        end
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

    local confirmAlpha = 1
    local titleAlpha = 1
    if untilConfirmVisible == -1 then
      confirmAlpha = 0
    elseif untilConfirmVisible > 0 then
      confirmAlpha = math.min(1, 1 - untilConfirmVisible / 120)
      confirmAlpha = confirmAlpha * confirmAlpha
    elseif sinceConfirmInitial >= 0 then
      confirmAlpha = math.max(0, 1 - sinceConfirmInitial / 120)
      confirmAlpha = confirmAlpha * confirmAlpha
      titleAlpha = confirmAlpha
    end
    love.graphics.setColor(0, 0, 0, confirmAlpha)
    buttonConfirm.draw()
    draw.shadow(0.3, 0.3, 0.3, titleAlpha, textTitle, W * 0.5, H * 0.19)

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
    if dayNum <= 21 then
      if untilPills >= 0 then
        pillsAlpha = math.max(0, 1 - (untilPills / 60)^2)
      elseif sincePills >= 0 then
        pillsAlpha = math.max(0, 1 - (sincePills / 60)^2)
      end
      if pillsAlpha > 0 then
        love.graphics.setColor(1, 1, 1, pillsAlpha)
        buttonPills.draw()
      end
      if dayNum == dayMissed and (untilPills >= 0 or sincePills >= 0) then
        local textMissAlpha
        if untilPills >= 0 then
          textMissAlpha = 1 - (math.max(0, untilPills - 480) / 60)^2
        else
          textMissAlpha = 1 - (math.min(1, sincePills / 60))^2
        end
        draw.shadow(0.3, 0.3, 0.3, textMissAlpha, textMiss, W * 0.336, H * 0.8)
      end
      if dayNum == 1 and (untilPills >= 0 or sincePills < 60) then
        draw.shadow(0.3, 0.3, 0.3, pillsAlpha, textInitialHint, W * 0.31, H * 0.822)
      end
    end

    if dayNum >= 22 then
      local hint1Alpha = 0
      local hint2Alpha = 0
      if dayNum == 22 then
        if untilPills >= 0 then
          hint1Alpha = math.max(0, 1 - (untilPills / 60)^2)
        elseif sincePills >= 0 and sincePills < 60 then
          hint1Alpha = 1
        end
      elseif dayNum == 23 and sincePills < 60 then
        hint1Alpha = math.max(0, 1 - (sincePills / 60)^2)
      elseif dayNum <= 24 then
        hint1Alpha = 1
      end
      if dayNum == 24 then
        if sincePills >= 60 then
          hint1Alpha = math.max(0, 1 - (sincePills / 60)^2)
          hint2Alpha = math.min(1, ((sincePills - 60) / 60)^2)
        else
          hint1Alpha = 0
          hint2Alpha = 1
        end
      elseif dayNum >= 25 then
        hint2Alpha = 1
      end
      if hint1Alpha > 0 then
        draw.shadow(0.3, 0.3, 0.3, hint1Alpha, textStopHint1, W * 0.336, H * 0.788)
      end
      if hint2Alpha > 0 then
        draw.shadow(0.3, 0.3, 0.3, hint2Alpha, textStopHint2, W * 0.336, H * 0.788)
      end
    end

    love.graphics.setColor(0.3, 0.3, 0.3)
    buttonBack.draw()
  end

  s.destroy = function ()
  end

  return s
end
