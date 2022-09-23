W = 1080
H = 720

local isMobile = (love.system.getOS() == 'Android' or love.system.getOS() == 'iOS')
local isWeb = (love.system.getOS() == 'Web')

local globalScale
love.window.setMode(
  isWeb and (W / 3 * 2) or W,
  isWeb and (H / 3 * 2) or H,
  { fullscreen = not isWeb, highdpi = true }
)
love.window.setTitle('Contraception')
local wDev, hDev = love.graphics.getDimensions()
globalScale = math.min(wDev / W, hDev / H)
local Wx = wDev / globalScale
local Hx = hDev / globalScale
local offsX = (Wx - W) / 2
local offsY = (Hx - H) / 2

-- Load font
local font = {}
for _, size in ipairs({28, 40, 48, 60, 80, 120}) do
  font[size] = love.graphics.newFont('res/1574853606_subset.ttf', size)
end
_G['font_AaGSKA'] = font
love.graphics.setFont(font[40])

local sceneIntro = require 'scene_intro'
_G['sceneIntro'] = sceneIntro
local sceneCondom1 = require 'scene_condom_1'
_G['sceneCondom1'] = sceneCondom1
local sceneCondom2 = require 'scene_condom_2'
_G['sceneCondom2'] = sceneCondom2
local sceneShort1 = require 'scene_short_1'
_G['sceneShort1'] = sceneShort1
local sceneShort2 = require 'scene_short_2'
_G['sceneShort2'] = sceneShort2
local sceneEmerg1 = require 'scene_emerg_1'
_G['sceneEmerg1'] = sceneEmerg1
local sceneLigation1 = require 'scene_ligation_1'
_G['sceneLigation1'] = sceneLigation1
local sceneLigation2 = require 'scene_ligation_2'
_G['sceneLigation2'] = sceneLigation2

local curScene = sceneIntro()
local lastScene = nil
local transitionTimer = 0
local currentTransition = nil
local transitions = {}

_G['replaceScene'] = function (newScene, transitionName)
  lastScene = curScene
  curScene = newScene
  transitionTimer = 0
  currentTransition = transitions[transitionName or 'fadeWhite']
end

local mouseScene = nil
function love.mousepressed(x, y, button, istouch, presses)
  if button ~= 1 then return end
  if lastScene ~= nil then return end
  mouseScene = curScene
  curScene.press((x - offsX) / globalScale, (y - offsY) / globalScale)
end
function love.mousemoved(x, y, button, istouch)
  curScene.hover((x - offsX) / globalScale, (y - offsY) / globalScale)
  if mouseScene ~= curScene then return end
  curScene.move((x - offsX) / globalScale, (y - offsY) / globalScale)
end
function love.mousereleased(x, y, button, istouch, presses)
  if button ~= 1 then return end
  if mouseScene ~= curScene then return end
  curScene.release((x - offsX) / globalScale, (y - offsY) / globalScale)
  mouseScene = nil
end

local T = 0
local timeStep = 1 / 240

function love.update(dt)
  T = T + dt
  local count = 0
  while T > timeStep and count < 4 do
    T = T - timeStep
    count = count + 1
    if lastScene ~= nil then
      lastScene:update()
      -- At most 4 ticks per update for transitions
      if count <= 4 then
        transitionTimer = transitionTimer + 1
      end
    else
      curScene:update()
    end
  end
end

transitions['fadeWhite'] = {
  dur = 120,
  draw = function (x)
    local opacity = 0
    if x < 0.5 then
      lastScene:draw()
      opacity = x * 2
    else
      curScene:draw()
      opacity = 2 - x * 2
    end
    love.graphics.setColor(0.95, 0.95, 0.95, opacity)
    love.graphics.rectangle('fill', -offsX, -offsY, Wx, Hx)
  end
}

function love.draw()
  love.graphics.scale(globalScale)
  love.graphics.setColor(1, 1, 1)
  love.graphics.push()
  love.graphics.translate(offsX, offsY)
  if lastScene ~= nil then
    local x = transitionTimer / currentTransition.dur
    currentTransition.draw(x)
    if x >= 1 then
      if lastScene.destroy then lastScene.destroy() end
      lastScene = nil
    end
  else
    curScene.draw()
  end
  love.graphics.pop()
end

function love.keypressed(key)
  if key == 'lshift' then
    if not isMobile and not isWeb then
      love.window.setFullscreen(not love.window.getFullscreen())
    end
  end
end
