-- LOVE 0.9.2 ----------------------------------------------------------------
-- Sandbox Golf                                                             --
------------------------------------------------------------------------------

-- GLOBALES ------------------------------------------------------------------

  love = _G.love
  LW = love.window
  LG = love.graphics
  LI = love.image
  LK = love.keyboard
  LT = love.timer
  LA = love.audio
  LE = love.event
  LM = love.mouse
  rnd = love.math.random

-- Prototipos:
  frame_presentacion, iniciar_juego, iniciar_hoyo = nil
  colocar_elementos, colocar_green, colocar_marcador = nil
  frame_inicio_lanzamiento, frame_lanzando, frame_trayectoria = nil
  frame_bola_dentro, frame_fin_hoyo, frame_game_over, aplauso = nil
  
-- Sprites:
	IMG_fondo, IMG_fondo_presentacion, IMG_fondo_green = nil
	IMG_1jug, IMG_2jug, IMG_1jug_s, IMG_2jug_s, IMG_start = nil
	IMG_nube1, IMG_nube2, IMG_nube3 = nil
	IMG_hierba, IMG_agua, IMG_arena, IMG_arbol, IMG_green = nil
	IMG_bola, IMG_bolaG, IMG_puntero1, IMG_puntero2 = nil
	IMG_flag1este, IMG_flag2este, IMG_flag1oeste, IMG_flag2oeste = nil
  
-- Sonidos:
	SND_pio1, SND_pio2, SND_grillo, SND_rana = nil
	SND_pio1_id, SND_pio2_id, SND_grillo_id, SND_rana_id = nil
	SND_click, SND_teeoff, SND_bote, SND_putt, SND_bola_en_hoyo = nil
	SND_boo, SND_aplauso, SND_ovacion = nil
  
-- Fuentes:
  fuente_p, fuente_g = nil
  claseBMF = require("claseBMF")
  BMF = claseBMF.newBMF("lib/fnt_bitmap.png", 32, 32,
                      "+-4:AGMSY(.5ÑBHNTZ)06ÑCIOU  17 DJPV  28 EKQW ,39?FLRX ")
  BMF2 = claseBMF.newBMF("lib/fnt_bitmap2x.png", 64, 64,
                      "+-4:AGMSY(.5ÑBHNTZ)06ÑCIOU  17 DJPV  28 EKQW ,39?FLRX ")
                      
-- Botones:
  claseBoton = require("claseBoton")
  botonAmenos = claseBoton.newBoton(1037, 180, 40, 40,
                {100, 100, 100, 255}, {0, 0, 200, 255}, {0, 100, 200, 255},
                "-", {255, 255, 255, 255})
  botonA45 = claseBoton.newBoton(1087, 180, 40, 40,
                {100, 100, 100, 255}, {0, 0, 200, 255}, {0, 100, 200, 255},
                "45", {255, 255, 255, 255})
  botonAmas = claseBoton.newBoton(1137, 180, 40, 40,
                {100, 100, 100, 255}, {0, 0, 200, 255}, {0, 100, 200, 255},
                "+", {255, 255, 255, 255})
  botonPmenos = claseBoton.newBoton(1037, 420, 40, 40,
                {100, 100, 100, 255}, {0, 0, 200, 255}, {0, 100, 200, 255},
                "-", {255, 255, 255, 255})
  botonP99 = claseBoton.newBoton(1087, 420, 40, 40,
                {100, 100, 100, 255}, {0, 0, 200, 255}, {0, 100, 200, 255},
                "99", {255, 255, 255, 255})
  botonPmas = claseBoton.newBoton(1137, 420, 40, 40,
                {100, 100, 100, 255}, {0, 0, 200, 255}, {0, 100, 200, 255},
                "+", {255, 255, 255, 255})
  botonLanzar = claseBoton.newBoton(1038, 480, 140, 130,
                {100, 100, 100, 255}, {200, 0, 0, 255}, {255, 50, 50, 255},
                "SHOOT!", {255, 255, 255, 255})
  botonSalir = claseBoton.newBoton(1038, 625, 140, 130,
                {100, 100, 100, 255}, {200, 100, 0, 255}, {255, 150, 0, 255},
                "EXIT", {255, 255, 255, 255})

-- Gamestates:
  GS = 0
  GS_PRESENTACION, GS_INICIO_LANZAMIENTO, GS_LANZANDO, GS_TRAYECTORIA,
  GS_BOLA_DENTRO, GS_FIN_HOYO, GS_GAME_OVER = 0, 1, 2, 3, 4, 5, 6
  
-- Otros globales:
  WINX = 1195                     -- tamaño X de ventana        
  WINY = 768                      -- tamaño X de ventana        
	PANTX = 1024						        -- tamaño X de zona de juego  
	PANTY = 768						          -- idem Y											
	TAMTXT = 8		                  -- tamaño de texto					  
	FRAMES = 0									    -- contador de frames				  
	SUELO = 600						          -- posición del suelo         
	MAXWIND = 20						        -- velocidad máxima del viento
	
	hoyo, distancia, par, njug, jugact, viento, angulo, fuerza = nil
	bolax, bolay, velx, vely, fviento = nil
	flag_arena, flag_perdida, flag_green = nil
	score = {}								    -- puntuaciones de los 2 jugadores                
	scorep = {}                   -- puntuaciones sobre/bajo par de los 2 jugadores 
	stroke = {}                   -- nº de lanzamiento actual de los 2 jugadores    
	bolaxini = {}                 -- posición de partida de bola para cada jugador  
	flag_finhoyo = {}             -- flag de hoyo finalizado para los 2 jugadores   
	
	-- Datos de los 18 hoyos (pantalla 32x24 bloques gráficos):                   
	-- 0:green, 1:arena1, 2:arena2, 3:agua, 4:árboles, 5:distancia, 6:par         
	-- mapas = {{25,12,0,17,8,210,4}, {10,5,15,0,0,90,3},  {15,8,0,0,19,123,3},   
	--       {16,20,0,10,25,140,3}, {25,17,21,0,0,210,4},  {20,10,0,0,17,165,4},  
	--       {17,12,0,25,0,143,3},  {19,5,23,0,9,160,3},   {11,0,0,15,8,95,3},    
	--       {22,12,0,16,0,182,4},  {27,10,22,0,16,225,4}, {18,22,0,13,0,148,3},  
	--       {12,16,0,20,8,100,3},  {23,10,0,17,14,190,4}, {28,6,24,10,18,229,5}, 
	--       {16,10,0,0,20,140,3},  {21,13,17,0,10,172,4}, {28,10,14,18,21,234,5}}
  -- Almacenados en tabla mapas.                                                
  
  mapas = {}
  
  FPS = 50.0
  frameT = 1.0 / FPS
  frameNXT = LT.getTime()

-- FIN GLOBALES --------------------------------------------------------------


------------------------------------------------------------------------------
-- love.load()                                                              --
------------------------------------------------------------------------------

function love.load()

  LW.setMode(WINX, WINY, {fullscreen=false, fullscreentype="desktop", centered=true})
  LM.setCursor(LM.newCursor("lib/bmp_mousepointer.png", 0, 0))
  
  -- Cargar imágenes
  IMG_fondo_presentacion = LG.newImage("lib/bmp_bg-1195x768.png")
	IMG_fondo = LG.newImage("lib/bmp_bg-1024x768.png")
  IMG_fondo_green = LG.newImage("lib/bmp_bg-1024x768-green.png")
	IMG_1jug = LG.newImage("lib/bmp_gamepad1.png")
  IMG_2jug = LG.newImage("lib/bmp_gamepad2.png")
	IMG_1jug_s = LG.newImage("lib/bmp_gamepad1s.png")
  IMG_2jug_s = LG.newImage("lib/bmp_gamepad2s.png")
  IMG_start = LG.newImage("lib/bmp_buttonstart.png")
  IMG_nube1 = LG.newImage("lib/bmp_cloud1.png")
  IMG_nube2 = LG.newImage("lib/bmp_cloud2.png")
  IMG_nube3 = LG.newImage("lib/bmp_cloud3.png")
	IMG_hierba = LG.newImage("lib/bmp_grassmid.png")
  IMG_agua = LG.newImage("lib/bmp_liquidwatertop_mid.png")
  IMG_arena = LG.newImage("lib/bmp_sandmid.png")
  IMG_arbol = LG.newImage("lib/bmp_pinesapling.png")
  IMG_green = LG.newImage("lib/bmp_green.png")
	IMG_bola = LG.newImage("lib/bmp_ballgrey.png")
  IMG_bolaG = LG.newImage("lib/bmp_grey_tickwhite.png")
  IMG_puntero1 = LG.newImage("lib/bmp_red_sliderup.png")
  IMG_puntero2 = LG.newImage("lib/bmp_blue_sliderup.png")
	IMG_flag1este = LG.newImage("lib/bmp_flag1este.png")
	IMG_flag2este = LG.newImage("lib/bmp_flag2este.png")
	IMG_flag1oeste = LG.newImage("lib/bmp_flag1oeste.png")
	IMG_flag2oeste = LG.newImage("lib/bmp_flag2oeste.png")

  -- Cargar sonidos
  SND_pio1 = LA.newSource("lib/snd_amb_bird_1.mp3", "static")
	SND_pio2 = LA.newSource("lib/snd_amb_bird_2.mp3", "static")
	SND_grillo = LA.newSource("lib/snd_amb_cricket_1.mp3", "static")
	SND_rana = LA.newSource("lib/snd_amb_frog_1.mp3", "static")
	SND_click = LA.newSource("lib/snd_click.mp3", "static")
	SND_teeoff = LA.newSource("lib/snd_teeoff.mp3", "static")
	SND_bote = LA.newSource("lib/snd_bote.mp3", "static")
	SND_putt = LA.newSource("lib/snd_putt.mp3", "static")
	SND_bola_en_hoyo = LA.newSource("lib/snd_bola_en_hoyo.mp3", "static")
	SND_boo = LA.newSource("lib/snd_boo.mp3", "static")
	SND_aplauso = LA.newSource("lib/snd_aplauso.mp3", "static")
	SND_ovacion = LA.newSource("lib/snd_ovacion.mp3", "static")

  -- Mapas: 18 hoyos con 7 elementos en cada uno (0: green, 1: arena1, 2: arena2, 
  --        3: agua, 4: árboles, 5: distancia, 6: par)                            
  
  mapas = {{[0]=25,12,0,17,8,210,4}, {[0]=10,5,15,0,0,90,3},   {[0]=15,8,0,0,19,123,3},
           {[0]=16,20,0,10,25,140,3},{[0]=25,17,21,0,0,210,4}, {[0]=20,10,0,0,17,165,4},
           {[0]=17,12,0,25,0,143,3}, {[0]=19,5,23,0,9,160,3},  {[0]=11,0,0,15,8,95,3},
           {[0]=22,12,0,16,0,182,4}, {[0]=27,10,22,0,16,225,4},{[0]=18,22,0,13,0,148,3},
           {[0]=12,16,0,20,8,100,3}, {[0]=23,10,0,17,14,190,4},{[0]=28,6,24,10,18,229,5},
           {[0]=16,10,0,0,20,140,3}, {[0]=21,13,17,0,10,172,4},{[0]=28,10,14,18,21,234,5}}
           
  -- Fuente TTF
  fuente_p = LG.newFont("lib/fnt_kenpixel_blocks.ttf", 32)
  fuente_g = LG.newFont("lib/fnt_kenpixel_blocks.ttf", 96)
           
  -- Inicializar el juego
  njug = 1
  angulo, fuerza = 0, 0
  FRAMES = 0
  GS = GS_PRESENTACION
end

------------------------------------------------------------------------------
-- love.update()                                                            --
------------------------------------------------------------------------------

function love.update(dt)
  
  frameNXT = frameNXT + frameT
  
  if (LK.isDown("escape")) then LE.quit(); end
  
end

------------------------------------------------------------------------------
-- love.draw()                                                              --
------------------------------------------------------------------------------

function love.draw()
  local ahora
  
  if (GS ~= GS_PRESENTACION) and (GS ~= GS_GAME_OVER) then
    if (flag_green) then
      colocar_green()
    else
      colocar_elementos()
    end
    colocar_marcador()
  end
  
  -- ACTUALIZAR Y PINTAR FRAME SEGÚN ESTADO ----------------------------------
  if (GS == GS_PRESENTACION) then frame_presentacion(); end
  if (GS == GS_INICIO_LANZAMIENTO) then frame_inicio_lanzamiento(); end
  if (GS == GS_LANZANDO) then frame_lanzando(); end
  if (GS == GS_TRAYECTORIA) then frame_trayectoria(); end
  if (GS == GS_BOLA_DENTRO) then frame_bola_dentro(); end
  if (GS == GS_FIN_HOYO) then frame_fin_hoyo(); end
  if (GS == GS_GAME_OVER) then frame_game_over(); end
  
  -- Fin de frame
  ahora = LT.getTime()
  if (frameNXT < ahora) then
    frameNXT = ahora
  else
    LT.sleep(frameNXT - ahora)
  end
  FRAMES = FRAMES + 1
end

------------------------------------------------------------------------------
-- frame_presentacion()                                                     --
------------------------------------------------------------------------------

function frame_presentacion()
  local mx, my
  
  -- Comprobar botones
  mx = LM.getX()
  my = LM.getY()
  if (LM.isDown("l")) then
    if (mx >= WINX*0.05) and (mx <= WINX*0.05 + 100) and
       (my >= WINY*0.75) and (my <= WINY*0.75 + 100) then
      if (njug == 2) then LA.play(SND_click); end
      njug = 1
    end
    if (mx >= WINX*0.18) and (mx <= WINX*0.18 + 100) and
       (my >= WINY*0.75) and (my <= WINY*0.75 + 100) then
      if (njug == 1) then LA.play(SND_click); end
      njug = 2
    end
    if (mx >= WINX*0.31) and (mx <= WINX*0.31 + 100) and
       (my >= WINY*0.73) and (my <= WINY*0.73 + 100) then
      LA.stop()
      LA.play(SND_click)
      iniciar_juego()
    end
  end
  
  -- Sonidos de la naturaleza
  if (FRAMES % 20 == 0) and (rnd(0,2) == 0) then LA.play(SND_grillo); end
  if (FRAMES % 50 == 0) and (rnd(0,5) == 0) then LA.play(SND_rana); end
  if (FRAMES % 100 == 0) and (rnd(0,2) == 0) then LA.play(SND_pio1); end
  if (FRAMES % 200 == 0) and (rnd(0,2) == 0) then LA.play(SND_pio2); end

  -- Pintar frame
  LG.draw(IMG_fondo_presentacion)
  if (njug == 1) then
    LG.draw(IMG_1jug_s, WINX*0.05, WINY*0.75)
    LG.draw(IMG_2jug, WINX*0.18, WINY*0.75)
  else
    LG.draw(IMG_1jug, WINX*0.05, WINY*0.75)
    LG.draw(IMG_2jug_s, WINX*0.18, WINY*0.75)
  end
  LG.draw(IMG_start, WINX*0.31, WINY*0.73)
  LG.setColor(255, 255, 255, 220)
  LG.draw(IMG_nube1, (FRAMES/1 + 500) % WINX, 0)
  LG.draw(IMG_nube2, (FRAMES/2 + 200) % WINX, WINY*0.15)
  LG.draw(IMG_nube3, (FRAMES/4 + 100) % WINX, WINY*0.30)
  LG.setColor(255, 255, 255, 255)
end

------------------------------------------------------------------------------
-- iniciar_juego()                                                          --
------------------------------------------------------------------------------

function iniciar_juego()

  hoyo = 1
  score[1] = 0
  score[2] = 0
  scorep[1] = 0
  scorep[2] = 0
  iniciar_hoyo()
end

------------------------------------------------------------------------------
-- iniciar_hoyo()                                                           --
------------------------------------------------------------------------------

function iniciar_hoyo()

  distancia = mapas[hoyo][5]
	par = mapas[hoyo][6]
	bolax = 5
	bolay = SUELO-5
	bolaxini[1]  = 5
	bolaxini[2] = 5
	stroke[1] = 1
	stroke[2] = 1
	jugact = 1
	viento = rnd(-MAXWIND, MAXWIND)	  -- velocidad del viento entre -MAXWIND y MAXWIND
	fviento = viento / 20000.0	      -- fuerza del viento
	flag_arena = false
	flag_perdida = false
	flag_green = false
	flag_finhoyo[1] = false
	flag_finhoyo[2] = false
	FRAMES = 0
	GS = GS_INICIO_LANZAMIENTO
end

------------------------------------------------------------------------------
-- colocar_elementos()                                                      --
------------------------------------------------------------------------------

function colocar_elementos()
	local i, periodo, pos, txt
	
  LG.draw(IMG_fondo, 0, 0)         -- fondo
  for i = 0, 31 do
    LG.draw(IMG_hierba, i*32, SUELO)
  end
  pos = mapas[hoyo][1]              -- arena 1
  if (pos > 0) then
    LG.draw(IMG_arena, pos*32, SUELO)
    LG.draw(IMG_arena, pos*32 + 32, SUELO)
  end
  pos = mapas[hoyo][2]              -- arena 2
  if (pos > 0) then
    LG.draw(IMG_arena, pos*32, SUELO)
    LG.draw(IMG_arena, pos*32 + 32, SUELO)
  end
  pos = mapas[hoyo][3]              -- agua
  if (pos > 0) then
    LG.draw(IMG_agua, pos*32, SUELO)
    LG.draw(IMG_agua, pos*32 + 32, SUELO)
  end
  pos = mapas[hoyo][4]              -- árbol
  if (pos > 0) then
    LG.draw(IMG_arbol, pos*32, SUELO-64)
  end
  LG.draw(IMG_bola, bolax, bolay)   -- bola y puntero
  if (jugact == 1) then
    LG.draw(IMG_puntero1, bolax-10, SUELO+50)
    if (njug == 2) then LG.draw(IMG_puntero2, bolaxini[2]-10, SUELO+50); end
  else
    LG.draw(IMG_puntero2, bolax-10, SUELO+50)
    LG.draw(IMG_puntero1, bolaxini[1]-10, SUELO+50)
  end
  pos = mapas[hoyo][0]              -- green
  LG.draw(IMG_green, pos*32, SUELO)
  LG.draw(IMG_green, pos*32 + 32, SUELO)

  -- Banderín animado
  pos = distancia * 4
  periodo = math.abs(viento)        -- valores periodo: 0..MAXWIND
  periodo = MAXWIND+5 - periodo     -- a más viento, menos periodo (animación más rápida)
  if (FRAMES % periodo < periodo/2) then
    if (viento > 0) then
      LG.draw(IMG_flag1este, pos, SUELO-64)
    else
      LG.draw(IMG_flag1oeste, pos-26, SUELO-64)
    end
  else
    if (viento > 0) then
      LG.draw(IMG_flag2este, pos, SUELO-64)
    else
      LG.draw(IMG_flag2oeste, pos-26, SUELO-64)
    end
  end
  
  if (GS == GS_LANZANDO) then
    -- Interfaz para dar ángulo
    LG.setFont(fuente_p)
    LG.setColor(0, 255, 0, 255)
    if (FRAMES % 20 >= 10) and (angulo == 0) then LG.setColor(0, 160, 0, 255); end
    LG.print("ANGLE", 1050, 10)
    LG.setFont(fuente_g)
    txt = angulo; if (angulo < 10) then txt = "0"..angulo; end
    LG.print(txt, 1041, 40)
    botonAmenos:pintar()
    botonA45:pintar()
    botonAmas:pintar()

    -- Interfaz para dar fuerza
    LG.setFont(fuente_p)
    LG.setColor(255, 0, 0, 255)
    if (FRAMES % 20 >= 10) and (fuerza == 0) then LG.setColor(160, 0, 0, 255); end
    LG.print("POWER", 1050, 250)
    LG.setFont(fuente_g)
    txt = fuerza; if (fuerza < 10) then txt = "0"..fuerza; end
    LG.print(txt, 1041, 280)
    botonPmenos:pintar()
    botonP99:pintar()
    botonPmas:pintar()
    
    -- Botones para salir y lanzar
    botonSalir:pintar()
    if (angulo > 0) and (fuerza > 0) then botonLanzar:pintar(); end
  end
end

------------------------------------------------------------------------------
-- colocar_green()                                                          --
------------------------------------------------------------------------------

function colocar_green()
  local pos, greenx, greeny, greenxini1, greenxini2, greenpos, periodo, txt
  local ESCALA = 16
  
  -- Colocar fondo
  LG.draw(IMG_fondo_green)
  
  -- Colocar terreno
  for pos = 0, 31 do LG.draw(IMG_green, pos*32, SUELO); end
  
  -- Colocar bola y puntero
  greenpos = mapas[hoyo][0] * 32
  greenx = (bolax - greenpos) * ESCALA
  greeny = (bolay - SUELO) * ESCALA + SUELO + 64
  greenxini1 = (bolaxini[1] - greenpos) * ESCALA
  greenxini2 = (bolaxini[2] - greenpos) * ESCALA
  if (GS ~= GS_FIN_HOYO) and (GS ~= GS_BOLA_DENTRO) then
    LG.draw(IMG_bolaG, greenx, greeny)
  end
  if (jugact == 1) then
    LG.draw(IMG_puntero1, greenx-20, SUELO+50, 0.0, 2.0, 2.0)
    if (njug == 2) then
      LG.draw(IMG_puntero2, greenxini2-20, SUELO+50, 0.0, 2.0, 2.0)
    end
  else
    LG.draw(IMG_puntero2, greenx-20, SUELO+50, 0.0, 2.0, 2.0)
    LG.draw(IMG_puntero1, greenxini1-20, SUELO+50, 0.0, 2.0, 2.0)
  end
  
  -- Banderín animado
  pos = (distancia*4 - greenpos) * ESCALA
  periodo = math.abs(viento)        -- valores periodo: 0..MAXWIND
  periodo = MAXWIND+5 - periodo     -- a más viento, menos periodo (animación más rápida)
  if (FRAMES % periodo < periodo/2) then
    if (viento > 0) then
      LG.draw(IMG_flag1este, pos, SUELO-128, 0.0, 2.0, 2.0)
    else
      LG.draw(IMG_flag1oeste, pos-52, SUELO-128, 0.0, 2.0, 2.0)
    end
  else
    if (viento > 0) then
      LG.draw(IMG_flag2este, pos, SUELO-128, 0.0, 2.0, 2.0)
    else
      LG.draw(IMG_flag2oeste, pos-52, SUELO-128, 0.0, 2.0, 2.0)
    end
  end
  LG.setColor(0,0,0,255)
  LG.rectangle("fill", pos-8, SUELO+1, 25, 25)
  
  if (GS == GS_LANZANDO) then
    -- Interfaz para dar fuerza
    LG.setFont(fuente_p)
    LG.setColor(255, 0, 0, 255)
    if (FRAMES % 20 >= 10) and (fuerza == 0) then LG.setColor(160, 0, 0, 255); end
    LG.print("POWER", 1050, 250)
    LG.setFont(fuente_g)
    txt = fuerza; if (fuerza < 10) then txt = "0"..fuerza; end
    LG.print(txt, 1041, 280)
    botonPmenos:pintar()
    botonP99:pintar()
    botonPmas:pintar()
    
    -- Botones para salir y lanzar
    botonSalir:pintar()
    if (fuerza > 0) then botonLanzar:pintar(); end
  end

end

------------------------------------------------------------------------------
-- colocar_marcador()                                                       --
------------------------------------------------------------------------------

function colocar_marcador()
  local alfa, left, signo, texto
  
  -- Datos generales
  BMF:escribir(10, 10, "HOLE "..hoyo, 1.0, 255)
  BMF:escribir(10, 50, "DIST "..distancia, 1.0, 255)
  BMF:escribir(10, 90, "PAR  "..par, 1.0, 255)

  signo = ""
  if (viento >= 0) then signo = "+"; end
  BMF:escribir(10, 130, "WIND "..signo..viento, 1.0, 255)

  alfa = 0
  if (FRAMES % 40 >= 20) then alfa = 255; end
  if (flag_arena) then
    BMF:escribir(10, 170, "SAND", 1.0, alfa)
  end
  
  -- Datos jugador 1
  if (GS ~= GS_LANZANDO) or (jugact == 2) then alfa = 255; end
  if (jugact == 1) then
    left = math.floor(distancia - bolax/4)
  else
    left = math.floor(distancia - bolaxini[1]/4)
  end
  BMF:escribir(330, 10, "PLAYER ", 1.0, 255)
  BMF:escribir(544, 10, "1", 1.0, alfa)
  BMF:escribir(330, 50, "LEFT   "..left, 1.0, 255)
  BMF:escribir(330, 90, "STROKE ", 1.0, 255)
  BMF:escribir(544, 90, stroke[1], 1.0, alfa)
  
  -- Datos jugador 2
  alfa = 0
  if (FRAMES % 40 >= 20) then alfa = 255; end
  if (njug == 2) then
    if (GS ~= GS_LANZANDO) or (jugact == 1) then alfa = 255; end
    if (jugact == 2) then
      left = math.floor(distancia - bolax/4)
    else
      left = math.floor(distancia - bolaxini[2]/4)
    end
    BMF:escribir(690, 10, "PLAYER ", 1.0, 255)
    BMF:escribir(914, 10, "2", 1.0, alfa)
    BMF:escribir(690, 50, "LEFT   "..left, 1.0, 255)
    BMF:escribir(690, 90, "STROKE ", 1.0, 255)
    BMF:escribir(914, 90, stroke[2], 1.0, alfa)
  end
  
  -- Puntuaciones jugador 1 y 2
  signo = ""
  if (scorep[1] >= 0) then signo = "+"; end
  texto = "SCORE 1: "..score[1].." ("..signo..scorep[1]..")"
  BMF:escribir(330, 170, texto, 1.0, 255)
  if (njug == 2) then
    signo = ""
    if (scorep[2] >= 0) then signo = "+"; end
    texto = "SCORE 2: "..score[2].." ("..signo..scorep[2]..")"
    BMF:escribir(330, 210, texto, 1.0, 255)
  end
end

------------------------------------------------------------------------------
-- frame_inicio_lanzamiento()                                               --
------------------------------------------------------------------------------

function frame_inicio_lanzamiento()
  local alfa
  
  if (FRAMES <= 50) then
    alfa = FRAMES * 5 + 5
  elseif (FRAMES <= 100) then
    alfa = 255
  else
    alfa = 255 - (FRAMES-100) * 5
  end
  if (flag_perdida) then        -- la bola se perdió
    BMF2:escribir(280, 300, "LOST BALL", 1.0, alfa)
  elseif (bolax == 5) then      -- nuevo hoyo, la bola está al inicio
    BMF2:escribir(320, 300, "HOLE "..hoyo, 1.0, alfa)
  else
    BMF2:escribir(300, 300, "PLAYER "..jugact, 1.0, alfa)
  end
  if (alfa <= 0) then
    flag_perdida = false
    GS = GS_LANZANDO
  end
end

------------------------------------------------------------------------------
-- frame_lanzando()                                                         --
------------------------------------------------------------------------------

function frame_lanzando()
  local radianes, resp
  local botones_salida = {"No!", "OK", escapebutton = 1, enterbutton = 2}

  -- Pulsaciones de botones de ángulo y fuerza
  if (FRAMES % 4 == 0) then
    if (botonAmenos:click()) and (angulo > 0) then angulo = angulo - 1; end
    if (botonA45:click()) then angulo = 45; end
    if (botonAmas:click()) and (angulo < 90) then angulo = angulo + 1; end
    if (botonPmenos:click()) and (fuerza > 0) then fuerza = fuerza - 1; end
    if (botonP99:click()) then fuerza = 99; end
    if (botonPmas:click()) and (fuerza < 99) then fuerza = fuerza + 1; end
  end
  
  --Botón de disparo
  if (fuerza > 0) and (botonLanzar:click()) then
    if (flag_green) then angulo = 0; end  -- en green los tiros son rasos
    if (flag_arena) then
      fuerza = fuerza / 2
      angulo = angulo + rnd(-20, 20)
      if (angulo < 0)  then angulo = 0; end
      if (angulo > 90) then angulo = 90; end
    end
    radianes = ((90 - angulo) * math.pi) / 180.0  -- pasar ángulo a radianes
    velx = (fuerza * math.sin(radianes)) / 40.0
    if (bolax > distancia*4) then                 -- golpear siempre hacia el banderín
      velx = -velx
    end
    vely = -(fuerza * math.cos(radianes)) / 40.0
    if (flag_green) then
      LA.play(SND_putt)
    else
      LA.play(SND_teeoff)
    end
    FRAMES = 0
    GS = GS_TRAYECTORIA
  end
  
  -- Botón de salida
  if (botonSalir:click()) then
    resp = LW.showMessageBox("Warning", "Abort game?", botones_salida, "warning", true)
    if (resp == 2) then
      FRAMES = 0
      GS = GS_GAME_OVER
    end
  end
end

------------------------------------------------------------------------------
-- frame_trayectoria()                                                      --
------------------------------------------------------------------------------

function frame_trayectoria()
  local pos1, pos2, dist1, dist2, boladentro
  
  -- Comprobar si estamos en green o no
  pos1 = mapas[hoyo][0] * 32
  flag_green = false
  if (bolax > pos1) and (bolax <= pos1+64) and (bolay > SUELO-64) then
    flag_green = true
  end
  
  -- Actualizar bola
  bolax = bolax + velx
  bolay = bolay + vely
  if (angulo > 0) then    -- no es un tiro desde el green
    vely = vely + 0.015
    velx = velx - 0.001 + fviento
  else
    if (velx < 0) then velx = velx + 0.01; end
    if (velx > 0) then velx = velx - 0.01; end
  end
  
  -- Colisión con árbol?
  pos1 = mapas[hoyo][4] * 32 + 16
  if (pos1 > 16) and (bolax >= pos1) and (bolax <= pos1+32) and (bolay >= SUELO-64) then
    LA.play(SND_bote)
    LA.play(SND_boo)
    bolax = bolax - 5
    velx = -velx * 0.6
  end
  
  -- Colisión con suelo? (se ignora si es tiro desde el green, que es raso)
  if (bolay >= SUELO-5) and (angulo > 0) then
    LA.play(SND_bote)
    bolay = SUELO-5
    vely = -vely * 0.4
    velx = velx * 0.6
    pos1 = mapas[hoyo][1] * 32    -- arena?
    pos2 = mapas[hoyo][2] * 32
    if ((bolax >= pos1) and (bolax < pos1+64)) or
       ((bolax >= pos2) and (bolax < pos2+64)) then
      vely = vely * 0.4
      velx = velx * 0.6
    end
  end

  -- Bola fuera de límites o al agua?
  pos1 = mapas[hoyo][3] * 32
  if (bolax < 4) or (bolax > 1020) or 
    ((bolax >= pos1) and (bolax < pos1+64) and (bolay >= SUELO-5)) then
    flag_perdida = true
    stroke[jugact] = stroke[jugact] + 1
    angulo = 0
    fuerza = 0
    bolax = bolaxini[jugact]
    bolay = SUELO-5
    LA.play(SND_boo)
    flag_green = false    -- comprobar si estamos en green
    pos1 = mapas[hoyo][0] * 32
    if (bolax >= pos1) and (bolax <= pos1+64) and (bolay > SUELO+64) then
      flag_green = true
    end
    FRAMES = 0
    GS = GS_INICIO_LANZAMIENTO
  end

  -- Choque de bola con el agujero (provocará que entre)
  if (math.abs(bolax - distancia*4) <= 1) and (math.abs(velx) < 0.15) and (bolay > SUELO-15) then
    velx = 0.0
    bolay = SUELO-5
  end

  -- BOLA DETENIDA --
  if (math.abs(velx) < 0.05) and (bolay == SUELO-5) then
    pos1 = mapas[hoyo][1] * 32
    pos2 = mapas[hoyo][2] * 32
    flag_arena = false    -- comprobar si estamos en arena
    if (bolax >= pos1) and (bolax < pos1+64) or
      ((pos2 > 0) and (bolax >= pos2) and (bolax < pos2+64)) then
      flag_arena = true
      LA.play(SND_boo)
    elseif (math.abs(bolax - distancia*4) <= 1) then  -- bola en el hoyo!!!
      LA.play(SND_bola_en_hoyo)
      bolax = distancia*4
      flag_finhoyo[jugact] = true
      boladentro = true
      aplauso()
    else
      aplauso()
    end
    bolaxini[jugact] = bolax
    
    if (flag_finhoyo[jugact] == false) then
      stroke[jugact] = stroke[jugact] + 1
    end
    
    if (njug == 2) then     -- continúa el jugador que esté más lejos del hoyo
      dist1 = math.abs(bolaxini[1] - distancia*4)
      dist2 = math.abs(bolaxini[2] - distancia*4)
      if (dist1 > dist2) then
        jugact = 1
      else
        jugact = 2
      end
      bolax = bolaxini[jugact]
      pos1 = mapas[hoyo][0] * 32    -- comprobar si está en green el nuevo jugador
      flag_green = false
      if (bolax >= pos1) and (bolax <= pos1+64) then
        flag_green = true
      end
    end

    angulo = 0
    fuerza = 0
    FRAMES = 0
    if (flag_finhoyo[1]) and ((flag_finhoyo[2]) or (njug == 1)) then
      GS = GS_FIN_HOYO              -- ya la han metido los dos: final de hoyo
    elseif (boladentro) then
      GS = GS_BOLA_DENTRO
    else
      GS = GS_INICIO_LANZAMIENTO
    end
  end
end

------------------------------------------------------------------------------
-- frame_bola_dentro()                                                      --
------------------------------------------------------------------------------

function frame_bola_dentro()
  local alfa
  
  if (flag_green) then    -- pintar bola dentro del agujero
    LG.draw(IMG_bolaG, (bolaxini[3-jugact] - (mapas[hoyo][0] * 32)) * 16 -4,
                       (bolay - SUELO + 5) * 16 + SUELO + 8)
  end
  if (FRAMES <= 50) then
    alfa = FRAMES * 5 + 5
  elseif (FRAMES <= 100) then
    alfa = 255
  else
    alfa = 255 - (FRAMES*100) * 5
  end
  LG.setColor(255, 255, 255, alfa)
  BMF2:escribir(240, 300, "BALL IN")
  if (alfa <= 0) then
    FRAMES = 0
    GS = GS_INICIO_LANZAMIENTO
  end
end

------------------------------------------------------------------------------
-- frame_fin_hoyo()                                                         --
------------------------------------------------------------------------------

function frame_fin_hoyo()
  local alfa
  
  if (flag_green) then    -- pintar bola dentro del agujero
    LG.draw(IMG_bolaG, (bolaxini[3-jugact] - (mapas[hoyo][0] * 32)) * 16 -4,
                       (bolay - SUELO + 5) * 16 + SUELO + 8)
  end
  if (FRAMES <= 50) then
    alfa = FRAMES * 5 + 5
  elseif (FRAMES <= 100) then
    alfa = 255
  else
    alfa = 255 - (FRAMES*100) * 5
  end
  LG.setColor(255, 255, 255, alfa)
  BMF2:escribir(240, 300, "BALL IN")
  if (alfa <= 0) then
    score[1] = score[1] + stroke[1]
    score[2] = score[2] + stroke[2]
    scorep[1] = scorep[1] + stroke[1] - par
    scorep[2] = scorep[2] + stroke[2] - par
    hoyo = hoyo + 1
    if (hoyo > 2) then     -- GAME OVER
      FRAMES = 0
      GS = GS_GAME_OVER
    else
      iniciar_hoyo()
      FRAMES = 0
      GS = GS_INICIO_LANZAMIENTO
    end
  end
end

------------------------------------------------------------------------------
-- frame_game_over()                                                        --
------------------------------------------------------------------------------

function frame_game_over()
  local signo
  
  -- Fondo
  LG.draw(IMG_fondo_green, 0, 0)

  -- Botón de salida
  botonSalir:pintar()
  if (botonSalir:click()) then
    FRAMES = 0
    GS = GS_PRESENTACION
  end
  
  -- Mostrar resultado de la partida
  LG.setColor(255, 255, 255, 255)
  BMF2:escribir(200, 100, "GAME OVER")
  BMF2:escribir(20, 200, "SCORE1:")
  signo = ""
  if (scorep[1] >= 0) then signo = "+"; end
  BMF2:escribir(512, 200, score[1].."("..signo..scorep[1]..")")
  
  if (njug == 2) then
    BMF2:escribir(20, 300, "SCORE2:")
    signo = ""
    if (scorep[2] >= 0) then signo = "+"; end
    BMF2:escribir(512, 300, score[2].."("..signo..scorep[2]..")")
  end
end

------------------------------------------------------------------------------
-- aplauso()                                                                --
------------------------------------------------------------------------------

function aplauso()
  local tiros_restantes, media_tiro, ultimo_tiro, left
  
  -- Fin de hoyo bajo par --> ovación
  if (bolax == distancia*4) and (stroke[jugact] < par) then
    LA.play(SND_ovacion)
    return
  end
  
  -- Fin de hoyo en el par --> aplauso
  if (bolax == distancia*4) and (stroke[jugact] == par) then
    LA.play(SND_aplauso)
    return
  end
  
  -- Fin de hoyo en +2 o peor --> abucheo
  if (bolax == distancia*4) and (stroke[jugact] >= par+2) then
    LA.play(SND_boo)
    return
  end
  
  -- La bola queda muy cerca del hoyo lanzando desde lejos --> ovación
  ultimo_tiro = math.abs(bolax - bolaxini[jugact])
  if (math.abs(distancia*4 - bolax) < 10) and (ultimo_tiro > 50) then
    LA.play(SND_ovacion)
    return
  end
  
  -- Llevamos buena media para lograr el par --> aplauso
  tiros_restantes = par - stroke[jugact]
  media_tiro = math.floor(distancia / (par-1))
  left = math.floor(distancia - bolax/4)
  if ((tiros_restantes-1) * media_tiro > math.abs(left)) then
    LA.play(SND_aplauso)
  end
end
