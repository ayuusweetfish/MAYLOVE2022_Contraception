local draw = require 'draw_utils'
local button = require 'button'
local misc = require 'misc_utils'

return function ()
  local s = {}
  local W, H = W, H
  local font = _G['font_Kuaile']

  local rowY = function (i) return H * (0.59 + 0.2 * (i - 2)) end

  local textSuccessHint = love.graphics.newText(font[40], '精子不从精囊中排出，被身体吸收，实现避孕')

  local buttonBack = misc.buttonBack()

  s.press = function (x, y)
    if buttonBack.press(x, y) then return true end
  end

  s.hover = function (x, y)
  end

  s.move = function (x, y)
    if buttonBack.move(x, y) then return true end
  end

  s.release = function (x, y)
    if buttonBack.release(x, y) then return true end

    if sinceCorrect == -1 then
      if x >= diagramCenX - diagramW / 2 and x <= diagramCenX + diagramW / 2 and
         y >= diagramCenY - diagramH / 2 and y <= diagramCenY + diagramH / 2
      then
        if sinceWrong ~= -1 then
          sinceLastWrongFade = math.max(0, 120 - sinceWrong) * 0.4
          lastWrongX, lastWrongY = wrongX, wrongY
        end
        if correct(x, y) then
          sinceWrong = -1
          sinceCorrect = 0
          correctX, correctY = x, y
        else
          sinceWrong = 0
          wrongX, wrongY = x, y
        end
      end
    end
  end

  s.update = function ()
    buttonBack.update()
  end

  s.draw = function ()
    love.graphics.clear(1, 1, 0.99)
    love.graphics.setColor(1, 1, 1)

    draw.img('male_ligation', W * 0.5, H * 0.44, W * 0.3)
    draw.shadow(0.3, 0.3, 0.3, 1, textSuccessHint, W * 0.5, H * 0.72)

    love.graphics.setColor(0.3, 0.3, 0.3)
    buttonBack.draw()
  end

  s.destroy = function ()
  end

  return s
end
