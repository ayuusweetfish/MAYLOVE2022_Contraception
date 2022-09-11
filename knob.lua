return function (cx, cy, a)
  local o = { angle = a }

  local holdStartX, holdStartY, holdStartAngle

  o.press = function (x, y)
    if (x - cx)^2 + (y - cy)^2 < 50^2 then
      holdStartX, holdStartY = x, y + 50
    else
      holdStartX, holdStartY = cx, cy
    end
    holdStartAngle = o.angle - math.atan2(y - holdStartY, x - holdStartX)
    return true
  end

  o.move = function (x, y)
    o.angle = holdStartAngle + math.atan2(y - holdStartY, x - holdStartX)
    return true
  end

  o.release = function (x, y)
    return true
  end

  return o
end
