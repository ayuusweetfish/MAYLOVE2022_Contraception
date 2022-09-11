return function (cx, cy, a)
  local o = { angle = a, enabled = true }

  local holdStartX, holdStartY, holdStartAngle
  local held = false

  o.press = function (x, y)
    if not o.enabled then return false end
    if (x - cx)^2 + (y - cy)^2 < 50^2 then
      holdStartX, holdStartY = x, y + 50
    else
      holdStartX, holdStartY = cx, cy
    end
    holdStartAngle = o.angle - math.atan2(y - holdStartY, x - holdStartX)
    held = true
    return true
  end

  o.move = function (x, y)
    if not held then return false end
    o.angle = holdStartAngle + math.atan2(y - holdStartY, x - holdStartX)
    return true
  end

  o.release = function (x, y)
    if not held then return false end
    held = false
    return true
  end

  return o
end
