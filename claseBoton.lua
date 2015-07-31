
local claseBoton = {}
claseBoton.__index = claseBoton

-- claseBoton.newBoton()                                                    --
-- Crear un objeto Boton.                                                   --
-- x, y, w, h:    posición y dimensiones del botón                          --
-- color1:        color del borde exterior                                  --
-- color2:        color del interior                                        --
-- color3:        color del interior con el cursor encima                   --
-- texto:         texto del botón                                           --
-- colortexto:    color del texto                                           --

function claseBoton.newBoton(x, y, w, h, color1, color2, color3, texto, colortexto)
  local Boton = {}
  
  Boton.x, Boton.y, Boton.w, Boton.h = x, y, w, h
  Boton.c1, Boton.c2, Boton.c3 = color1, color2, color3
  Boton.texto, Boton.colortexto = texto, colortexto
  Boton.fnt = LG.newFont(24)
  
  setmetatable(Boton, claseBoton)
  
  return Boton
end

-- claseBoton.pintar()                                                    --
-- Pinta el botón en la pantalla con sus valores actuales                 --

function claseBoton.pintar(self)
  local mx = LM.getX()
  local my = LM.getY()
  local click = LM.isDown("l")
  local dentro
  local tx, ty
  
  if (mx >= self.x) and (mx <= self.x + self.w) and
     (my >= self.y) and (my <= self.y + self.h) then
    dentro = true
  else
    dentro = false
  end
  if (click and dentro) then
    LG.setColor(255,255,255,255)
  else
    LG.setColor(self.c1)
  end
  LG.rectangle("line", self.x, self.y, self.w, self.h)
  if (dentro) then
    LG.setColor(self.c3)
  else
    LG.setColor(self.c2)
  end
  LG.rectangle("fill", self.x, self.y, self.w, self.h)
  
  -- Colocar texto
  tx = self.x + self.w/2 - self.fnt:getWidth(self.texto)/2
  ty = self.y + self.h/2 - self.fnt:getHeight(self.texto)/2
  LG.setColor(self.colortexto)
  LG.setFont(self.fnt)
  LG.print(self.texto, tx, ty)
end

-- claseBoton.click()                                                     --
-- Devuelve true si se está pinchando en el botón.                        --

function claseBoton.click(self)
  local mx = LM.getX()
  local my = LM.getY()
  local click = LM.isDown("l")
  local dentro
  
  if (mx >= self.x) and (mx <= self.x + self.w) and
     (my >= self.y) and (my <= self.y + self.h) then
    dentro = true
  else
    dentro = false
  end
  if (click and dentro) then return true; end

  return false
end

return claseBoton
