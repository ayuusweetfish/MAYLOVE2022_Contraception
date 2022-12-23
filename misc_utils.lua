local draw = require 'draw_utils'
local button = require 'button'

local buttonBack = function ()
  local font = _G['font_AaGSKA']
  local b = button(
    draw.enclose(love.graphics.newText(font[40], '返回'), 120, 60),
    function () replaceScene(sceneIntro()) end
  )
  b.x = 80
  b.y = 50
  return b
end

return {
  buttonBack = buttonBack,
}
