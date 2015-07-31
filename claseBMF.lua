
local claseBMF = {}
claseBMF.__index = claseBMF

-- claseBMF.newBMF()                                                        --
-- Crea un objeto fuente bitmap como una imagen de la que se seleccionarán  --
-- zonas para cada carácter.	                                              --
-- fichbmp:	nombre del archivo que contiene la fuente.										  --
-- cw:			anchura de cada carácter.																	      --
-- ch:			altura de cada carácter.														            --
-- mapa:		cadena que representa la lista ordenada de caracteres dibujados --
--          en el bitmap.			                                              --

function claseBMF.newBMF(fichbmp, cw, ch, mapa)
  local BMF = {}
  local fil, col
  
  setmetatable(BMF, claseBMF)
  
  BMF.mapa = mapa
  BMF.bitmap = LG.newImage(fichbmp)
  BMF.cw = cw
  BMF.ch = ch
  BMF.bitmapw = BMF.bitmap:getWidth()   -- anchura del bitmap de la fuente
  BMF.bitmaph = BMF.bitmap:getHeight()  -- altura del bitmap de la fuente 
  BMF.nx = BMF.bitmapw / cw             -- nº de caracteres por fila      
  BMF.ny = BMF.bitmaph / ch             -- nº de filas                    
  BMF.quads = {}                        -- quads con todos los recortes   
  
  for fil = 0, BMF.ny - 1 do
    for col = 0, BMF.nx - 1 do
      BMF.quads[fil * BMF.nx + col] =
        LG.newQuad(col * cw, fil * ch, cw, ch, BMF.bitmapw, BMF.bitmaph)
    end
  end
  
  return BMF
end
  
-- claseBMF.escribir()                                                    --
-- Escribe un texto en la pantalla con la fuente bitmap.                  --
-- x, y:		posición en pantalla                                          --
-- cad:		  cadena de texto a dibujar                                     --
-- tam:		  tamaño relativo al original del texto                         --
-- alfa:		transparencia 0-255 (0 transparente)                          --

function claseBMF.escribir(self, x, y, cad, tam, alfa)
  local i, c, pos
  
  if (tam == nil) then tam = 1.0; end
  if (alfa == nil) then alfa = 255; end
  for i = 1, string.len(cad) do
    c = string.sub(cad, i, i)
    if (c == "(") then c = "%("; end    -- carácter especial para string.find()
    pos = string.find(self.mapa, c)
    if (pos) then pos = pos - 1 else pos = 0; end
    LG.setColor(255, 255, 255, alfa)
    LG.draw(self.bitmap, self.quads[pos], x, y, 0, tam, tam)
    LG.setColor(255, 255, 255, 255)
    x = x + self.cw * tam
  end
end

return claseBMF
