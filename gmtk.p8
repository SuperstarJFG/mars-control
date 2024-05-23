pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--gmtk
--by superstarjfg

--Game
function _init()
  scroll=0
  starteddrill=false
  upgrade=-1
  text={"mars","control"}
  starttxt="press x to start"
  storm={}
  textbox={}
  shock={}
  stormspeed=2
  stormintensity=10
  drilling=false
  drilltimer=0
  px=56
  py=-112
  dx=0
  dy=0
  mapx=48
  mapy=0
  camx=0
  camy=0
  camspd=8
  poke(0x5f2e,1)
  poke(0x5f5c,-1)
  
  --new_shock(_x,_y,_mx,_my,_1,_2,_3,_4,_5,_6,_rx,_ry,_rmx,_rmy)
  new_shock(40,88,64,0,true,false,true,false,true,false,96,105,48,0)
  new_shock(80,88,64,0,true,false,false,false,false,true,96,105,48,0)
  new_shock(96,88,64,0,false,true,false,false,true,false,96,105,48,0)
  new_shock(112,88,64,0,false,false,true,true,false,false,96,105,48,0)
  
  new_shock(32,16,96,16,false,true,true,true,true,true,72,25,80,16)
  new_shock(48,16,96,16,true,false,true,false,true,true,72,25,80,16)
  new_shock(64,16,96,16,true,true,false,true,false,true,72,25,80,16)
  new_shock(80,16,96,16,true,true,true,true,true,false,72,25,80,16)
  
  new_shock(32,72,32,0,true,true,true,true,true,true,96,105,48,0)
  new_shock(48,72,32,0,true,true,true,true,true,true,96,105,48,0)
  new_shock(64,72,32,0,true,true,true,true,true,true,96,105,48,0)
  
  move_left=false
  move_right=false
  tp=false
  jump=false
  drill=false
  key=false
  fly=false
  ending=false
  
  debug=false
  if debug==true then
    move_left=true
    move_right=true
    tp=true
    jump=true
    drill=true
    key=false
    fly=true
  end
end

function _update60()
  --dtb_update()
  for t in all(textbox) do
    t:update()
  end
  for s in all(shock) do
    s:update()
  end
  if upgrade<1 then
    sfx(upgrade+2)
    for i=1,stormintensity do
      new_storm()
    end
    for s in all(storm) do
      s:update()
    end
    else

  end
  if(upgrade==-1 and btnp(❎)) then
    stormspeed=1.5 
    stormintensity=15
    upgrade=0
    say(5,"storm intensity increasing.\nlocating shelter.\ncavern detected underground.\nrecommending: activate [drill].\ninput: hold [down_arrow].")
    input=3
  end
  if(drilling and upgrade<1) drilltimer+=1
  if(drilltimer>130) _init() upgrade=1 sfx(1,-2) sfx(2,-2) sfx(5)
  if upgrade>0 and upgrade<5 then upgrade+=1/60 end
  if upgrade>3 and upgrade<3.1 then 
    input=1 
    move_right=true 
    say(4,"internal damage sustained.\ndamaged systems: ▒▒▒▒▒▒▒▒\nfunctional system: [move_right].\ninput: hold [right_arrow].")
  end
    
  if move_left and btn(0) then dx-=.1 end
  if move_right and btn(1) then dx+=.1 end  
  if jump and btnp(2) and hit(px+1,py+16,14,3)==1 then dy=-2 end
  if fly==true then jump=false end
  if fly and btn(2) then dy=-1 end
  if (drill or upgrade==0) and btn(3) then drilling=true else drilling=false end
  if tp and btnp(❎) then px=96 py=105 dx=0 dy=0 mapx=48 mapy=0 sfx(9) end
  if dx>1 then dx=1 end

  if hit(px+dx,py,15,15)==1 then
    dx=0
  end
  if hit(px,py+dy,15,15)==1 then
    dy=0
  end
  
  px+=dx
  py+=dy
  dx*=.9
  dy+=.1
  
  if dx>0 then left=false end
  if dx<0 then left=true end
  
  -- corners
  if not drilling and hit(px,py,1,1)==1 then py+=1 end
  if not drilling and hit(px+14,py,1,1)==1 then py+=1 end
  if hit(px,py+14,1,1)==1 then py-=1 end
  if hit(px+14,py+14,1,1)==1 then py-=1 end
  
  -- map
  if px<0 then 
    mapx-=16 
    px+=112
    camx=128
  end
  if px>112 then
    mapx+=16
    px-=112
    camx=-128
  end
  if py<0 and upgrade>3 then 
    mapy-=16 
    py+=112
    camy=128
  end
  if py>112 then
    mapy+=16
    py-=112
    camy=-128
  end
  
  -- cam
  if camx<0 then
    camx+=camspd
  end
  if camx>0 then
    camx-=camspd
  end
  if camy<0 then
    camy+=camspd
  end
  if camy>0 then
    camy-=camspd
  end

  camera(camx,camy)
  
  -- repair stations
  if move_left==false and mapx==96 and mapy==16 and px>7 and py<33 then
    input=0
    say(5,"repair station activated.\nsystem functional: [move_left].\ninput: hold [left_arrow].")
    move_left=true
    sfx(7)
  end
  if tp==false and mapx==96 and mapy==16 and px>103 and py<33 then
    input=❎
    say(5,"upgrade station activated.\nupgrade: [instant_transit].\ninput: press [x].")
    tp=true
    sfx(7)
  end
  if jump==false and mapx==64 and mapy==16 and px<89 and py<25 then
    input=2
    say(5,"upgrade station activated.\nupgrade: [vertical_propulsion].\ninput: press [up_arrow].")
    jump=true
    sfx(7)
  end
  if drill==false and mapx==32 and mapy==0 and px<89 and py<105 then
    input=3
    say(5,"repair station activated.\nsystem functional: [drill].\ninput: hold [down_arrow].")
    drill=true
    sfx(7)
  end
  if key==false and mapx==96 and mapy==16 and px>16 and py>41 then
    input=❎
    say(5,"control station activated.\nelectrical systems offline")
    key=true
    sfx(4)
  end
  if fly==false and mapx==32 and mapy==0 and px<9 and py<89 then
    input=2
    say(5,"enhancement station activated.\nenhanced: [vertical_propulsion].\ninput: hold [up_arrow].")
    fly=true
    sfx(7)
  end
  
  -- dirt
  if px>25 and px<47 and py>24 and py<60 and drilling==true then
    py+=2.2
  end
  
  -- ending
  if fly and mapy==-16 then 
    ending=true 
    say(5,"data report:\nsubstantial intel gathered.\norigin: likely nonhuman.\nuse: advancing mars colony 427.\nthe end")
  end
  if ending then px=128 py=128 fly=false mapx=0 end
  
  -- drill sfx
  if drilling and drillsound then sfx(6) end
  if drilling then drillsound=false else sfx(6,-2) drillsound=true end
  
  -- move sfx
  if abs(dx)>.3 and hit(px+1,py+16,14,3)==1 and movesound then sfx(8) end
  if abs(dx)>.3 and hit(px+1,py+16,14,3)==1 then movesound=false else sfx(8,-2) movesound=true end
end

function _draw()
  pal(3,5+128,1)
  -- intro draw
  if upgrade<1 then
    intro_draw()
  end
  
  -- title draw
  if upgrade==-1 then
    for i=1,#text do
      title(text[i],9,5,64-(#text[i]*2),20+7*i)
    end
    print(starttxt,64-(#starttxt*2),70+time()%2,7)
  end
  
  -- normal draw
  if(upgrade<1) return
  cls()
  pal(2,3+128,1)
  pal(8,1+128,1)
  pal(10,2+128,1)
  pal(12,13+128,1)
  pal(14,3,1)
  
  map(mapx-16,mapy-16,-128,-128,48,48)
  
  draw_fire()
  
  -- player
  if time()%1>.5 then 
    spr(6,px,py,2,2,left)
    if(drilling) spr(8,px,py,2,2,left)
  else
    if abs(dx)>.1 then
      spr(38,px,py,2,2,left)
      if(drilling) spr(40,px,py,2,2,left)
    else
      spr(6,px,py,2,2,left)
      if(drilling) spr(40,px,py,2,2,left)
    end
  end

  for s in all(shock) do
    s:draw()
  end
  camera()
  for t in all(textbox) do
    t:draw()
  end
  if (btnp(4)) print("yo",30,30,7)
end


--functions
function hit(x,y,w,h)
  collide=0
  
  for i=x,x+w do
    if fget(mget(i/8+mapx,y/8+mapy))==1 or fget(mget(i/8+mapx,(y+h)/8+mapy))==1 then collide=1 end
    if fget(mget(i/8+mapx,y/8+mapy))==2 or fget(mget(i/8+mapx,(y+h)/8+mapy))==2 then collide=2 end
    if fget(mget(i/8+mapx,y/8+mapy))==3 or fget(mget(i/8+mapx,(y+h)/8+mapy))==3 then collide=3 end
  end
  
  return collide
end

function new_shock(_x,_y,_mx,_my,_1,_2,_3,_4,_5,_6,_rx,_ry,_rmx,_rmy)
  add(shock, {
  x=_x,
  y=_y,
  mx=_mx,
  my=_my,
  on1=_1,
  on2=_2,
  on3=_3,
  on4=_4,
  on5=_5,
  on6=_6,
  rx=_rx,
  ry=_ry,
  rmx=_rmx,
  rmy=_rmy,
  enabled=false,
  update=function(self)
    self.enabled=false
    if ceil(time()%6)==1 and self.on1 then self.enabled=true end
    if ceil(time()%6)==2 and self.on2 then self.enabled=true end
    if ceil(time()%6)==3 and self.on3 then self.enabled=true end   
    if ceil(time()%6)==4 and self.on4 then self.enabled=true end
    if ceil(time()%6)==5 and self.on5 then self.enabled=true end
    if ceil(time()%6)==6 and self.on6 then self.enabled=true end
    if mapx==self.mx and mapy==self.my then 
    else 
      self.enabled=false 
    end
    if time()%1<.5 then self.enabled=false end
    if debug==false and self.enabled and self.x+8>px and self.x+8<px+16 and not key then 
      px=self.rx
      py=self.ry 
      mapx=self.rmx
      mapy=self.rmy
      dx=0
      dy=0
    end
  end,
  draw=function(self)
  local flip1=0
  local flip2=0
  local white=0
    if self.enabled and not key then 
      if flr(rnd(2))==1 then flip1=true else flip1=false end
      if flr(rnd(2))==1 then flip2=true else flip2=false end
      if flr(rnd(2))==1 then pal(11,7) end
      spr(20,_x,_y,2,3,flip1,flip2)
      pal(11,11)
      if stat(16)==-1 then sfx(3) end
    end
  end
 })
end

function intro_draw()
  pal(14,14+128,1)
  pal(12,15+128,1)
  cls(12)
  circfill(30,30,5,10)
  -- bg
  if(drilling==true) starteddrill=true 
  if starteddrill==false then scroll+=.5 end
  if(scroll==128) scroll=0
  for i=0,1 do
    spr(80,0+128*i-scroll,96,16,3,1)
  end
  -- bot
  if time()%1>.5 then 
    spr(6,56,103+.1*drilltimer,2,2)
    if(drilling) spr(8,56,103+.1*drilltimer,2,2)
  else
    spr(38,56,103+.1*drilltimer,2,2)
    if(drilling) spr(40,56,103+.1*drilltimer,2,2)
  end
  -- fg
  for i=0,1 do
    spr(80,0+128*i-scroll,104,16,4)
  end
  
  for s in all(storm) do
    s:draw()
  end
  for t in all(textbox) do
    t:draw()
  end
end

function draw_fire()
  if flr(rnd(2))==1 then flipfire=true else flipfire=false end
  if dy<0 and not fly then 
    spr(70+flr(rnd(2)),px+4,py+14,1,1,flipfire)
  end
  if fly and btn(2) then 
    spr(72+flr(rnd(2)),px+4,py+14,1,1,flipfire) 
  end
end
  
function new_storm()
  add(storm, {
  x=130,
  y=rnd(148)-10,
  dx=-rnd(1)-stormspeed,
  dy=sin(time()),
  update=function(self)
    self.x+=self.dx
    self.y+=self.dy
    if(self.x<0 or self.y>148 or self.y<-20) del(storm,self)
  end,
  draw=function(self)
    pset(self.x,self.y,14)
  end
 })
end

function title(t1,c1,s1,x1,y1)
 --line 1 shadow
 print(t1,x1-1,y1-1,s1)
 print(t1,x1-1,y1,s1)
 print(t1,x1-1,y1+1,s1)
 print(t1,x1,y1-1,s1)
 print(t1,x1,y1,s1)
 print(t1,x1,y1+1,s1)
 print(t1,x1+1,y1-1,s1)
 print(t1,x1+1,y1,s1)
 print(t1,x1+1,y1+1,s1)
 --line 1 text
 print(t1,x1,y1,c1)
end

function say(_lines,_txt)
  add(textbox, {
  lines=_lines,
  txt=_txt,
  i=1,
  sound=true,
  frame1=true,
  update=function(self)
    if self.frame1==true then 
      for t in all(textbox) do
        if t.frame1==false then del(textbox,t) end
      end
    end
    self.frame1=false
    if self.sound then sfx(0) end
    self.sound=false
    if self.i<#self.txt then
      self.i+=1
      dx=0
      dy=0
    else
      if(btnp(input) and not ending) del(textbox,self)
      sfx(0,-2)
    end
  end,
  draw=function(self)
    rect(0,0,127,6*self.lines,0)
    rectfill(1,1,126,6*self.lines-1,0)
    print(sub(self.txt,1,self.i),1,1,11)
  end
 })
end

__gfx__
00000000000000000000000000000000dccccccccccccccd0000000000000000dddddddddddddddd0ddc0dd08888888800000000000000aaaaa0000000000000
000000000000000000000000000000000dccccccccccccd00000000000000000d77777777777777ddccc0dc0811188880aaaaa00000000aaaacccccc00000000
0000000000000000000000000000000000dddccccccddd000000000000ddddddd76666666666666ddccc0cc0811111880aaaaa000cccccccaacddccc0adccaaa
0000000000022222000000222222200000000dddddd000000000000000d7777dd76666666666666dcccc0cc0881118880aaaaa000ccdddcc00cddddd0addcaaa
0000000000028888000000288888200000000055530000000000000000d7666dddd5355355355dddaa000cc088888888000000000cddddcc0000aaaa00aaaaaa
000000000002bbb800000028bbb8200000000055530000000000000000d7666d33d3553553553d33dcc000008111181100aacccc000000000ccccccc0ccccaa0
000000000002888800000028888820000000000530000000dd00000000dddddd330d53553553d033ddc0aaaa811118110aaacccc0ccccccc0ccdddcc0dcccaa0
0000000000028b8b00000028b8bb20000000000530000000d7d0000000003300550d35535535d0550000aaaa888888880aaaccdd0cdddddd0cdddddd00000000
000004400002888800000028888820000000000bb0000000d77ddddddddddddd5500d535535d0055ddaacdd0888888880aaaaa000088880808800000cccccaa0
04404444000222220000002222222000000000b000000000d77777777777777d5500d355355d0055cdaacccd8811881800dccdd00081188888888800ddcccca0
4444444400022e2e0000002e2e2e200000000b0000000000d76666666666666d55000d5355d00055cc00cccd8888818800cccdd00881888881111880dccccca0
454444540002e2e200000022e2e220000000b00000000000d76666666666666d00000d3555d000000000cccc888888880accccc0888881118811188800000000
444446440002eeee0000002eeeee200000000b0000000000d73566635666356d000000d53d000000aa000000811188810aaaa00088118118888888880ccccc00
444444440002eeee0000002eeeee2000000000b000000000d5763d5763d5763d000000d35d000000aa0cccdd811188880accccdd08888888118111800ddccc00
446445440222222202222222222222200000000bb000000003665036650366500000000dd0000000aa0ccccd8118818800ccdcdd08111888118111880ddcccaa
444444442bbbbbbb2bbbbbbbbbbbbbb2000000000b00000000530005300053000000000dd0000000aa0cccdd88888888aacccccd8881118888888888000000aa
444444440000000000000000000000000000000000b000000000000000000000ddddddddddddddddaa00000088888888aa0000008888888888888888dcccccaa
4454454400000000000000000000000000000000000b00000000000000ddddddd77777777777777daa0ccccd88881118aacccdd00888888881118880ddcdcc00
444444460000000000000000000000000000000000b000000000000000d7777dd76666666666666daa0cccdd8888111800cccdd08811118881118880ddcccca0
454644440000000000000088888880000000000000b000000000000000d7666dd76666666666666daa0000008118888800ccccc08811118888888880000aaaa0
44444644000000000000008000008000000000000b0000000000000000d7666ddd53553553553ddd0000cccc888888880000000088888888881888800ccccca0
44444444000000000000008909998000000000000b0000000000000000dddddd33d5535535535d330cc0cccd811111880acccccd81181118888188000ddccc00
4444444000000000000000800000800000000000b0000000000000000000330033d5355355355d330cdacccd811118880accccdd08881118818880000ddccd00
0444000000000000000000809909800000000000b0000000dd00000000005500550d55355355d0550ddacdd0888888880aaccccc000888888888000000aaaaa0
000000000000000000000080000080000000000b00000000d7d0000000005500550d53553553d055dcc0aaaa8888888800000000ddddddc0ddddddc0ddccaaa0
000000000000000000000088888880000000000b00000000d77ddddddddddddd5500d553553d0055ddc0aaaa11811118000ccdd0ccdddcc0ccccccc0ccccaaa0
00000000000000000000008181818000000000b000000000d77777777777777d5500d535535d0055aa000000118111180aacccd0ccccccc000000000ccccaa00
000000000000000000000088181880000000000b00000000d76666666666666d00000d5535d00000aa000ccc888888880aacccc0aaaa0000ccddddc000000000
0000000000000000000000811111800000000000b0000000d75366653666536d00000d5355d00000cccc0ccc881111880aaaaa00dddddc00ccdddcc000aaaaa0
00000000000000000000008111118000000000000b000000d37656376563765d000000d55d000000dccc0ccc88111118aaaaaaaacccddcaaccccccc000aaaaa0
0000000000000000088888888888888000000000b0000000d5663d5663d5663d000000d53d000000dccc0dcc88811118aaaaaaaaccccccaaaa00000000aaaaa0
000000000000000082222222222222280000000b0000000000350003500035000000000dd00000000ddc0ddc88888888aaaaaaaa00000aaaaa00000000000000
000000000000000000000000000000000000000530000000a44444a0a44444a02eeeee202eeeee20000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000005300000004497944aa497944aeeb7bee22eb7bee2000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000055530000004977794a4977794aeb777be2eb777be2000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000055530000004977794a4977774aeb777be2eb7777e2000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000dddddd00000497794a0a497794aeb77be202eb77be2000000000000000000000000000000000000000000000000
0000000000000000000000000000000000dddccccccddd00a49794a0a44794a02eb7be202ee7be20000000000000000000000000000000000000000000000000
000000000000000000000000000000000dccccccccccccd00a494a000aa44a0002ebe200022ee200000000000000000000000000000000000000000000000000
00000000000000000000000000000000dccccccccccccccd00a4a000000a4000002e20000002e000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000044444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000004444eeeeeeeee44400000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000444444eeee44eeeeeeeeee44444000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000444eeeeeeeeeeee44eeeeeeeeeeeee444000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000004444eeeeeeeeeeeeeeeee444eeeeeeeeeeeee444400000000000000000000000000000000000000000000000000000000000000000000000000
0000000000444eeeeeeeeeeeeeeeeeeeeeeee444eeeeeeeeeeeeee44444444400000000000000000000000000000000000004444000000000000000000000000
0000000444eeeeeeeeeeeeeeeeeeeeeeeeeeeeee444eeeeeeeeeeeeeeeeeeee4444400000000000000000000000000000444eeee334000000000000000000000
0000044eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4444eeeeeeeeeeeeeeeeeeeee44444444440000000000000004444eeeee33dd3444440000000000000000
00044eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee444444444444444eeeeeeee3ddddd3eeee4444400000000000
044eeeeeeeeeeeeeeeeeeeee4444ee33eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee444eeeeeeeeeeeeeeeeee3d5dddd34eeeeeeee44444400000
4eeeeeeeeeeeeeeeeeeeee44eeeee3dd33eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee444eeeeeeeeeeeeeeeeeeeee35d555d34eeeeeeeeeeeeee44444
eeeeeeeeeeeeeeeeee4444eeeeee3ddddd3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4444eeeeeeeeeeeeeeeeeeeeeeee355dd5534eeeeeeeeeeeeeeeeeee
eeeeee444444444444eeeeeeeeee3dddd553eeeeee44444eeeeeeeeeeeeeeeeeeee44444eeeeeeeeeeeeeeeeeeeeeeeeeeee435555544eeeeeeeeeee4444eeee
444444eeeeeeeeeeeeeeeeeeeeee3d5d5d534eeee4eeeee44444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee444eeeeeee444444444eeeeee44444eeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeee35d5d5544e444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee444eee444eeeee4444444eee4444eeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeee45555544eeeeeeeeeeeeeeeeeee44444eeeeeeeeeeeeeeeeeeeeee44444eeeeeeeee444eeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeee4444444eeeeeeeeeeeeeeeeee44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeee44444eeeeeeeeeeeeeeeee44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
__label__
vvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvv
uvuvvvvvvuvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvu
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuuvvvvvvvvuvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvuuvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvv
vuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvu
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvuvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvuvv
vvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvuvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvuvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvuvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvuvv
vvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvuuvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvuvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvuvvvvvvvvvvvvvvvvaaaaavvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvaaaaaaavvvvvvvvvvvvvvvvvvvvv55555555555555555vvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvaaaauaaaavvvvvvvvvvvvvvvvvvvv59995999599955995vvvvuvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvuvvvuvvvvu
vvuvvvvvvvvvvvvvvvvvvvvvvaaaaaaaaaaavvvvvvvvvvvvvvvvvvv59995959595959555vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvuvvaaaaaaaaauavvvuvvvvvvvvvvvvvvv59595999599559995vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvuvvvvvvauaaaaaaaaavvuvvvvvvvvuvvvvvvv59595959595955595vuvvvvuuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvaaaaaaaaaaavvvvvvvvvvvvvvvvvvv59595959595959955vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
uvvvvvvvvvvvvvvvvvvvvvvuvaaaauaaaaaavvvvvvvvvvvvvvvvvvv5555555555555555vvvvvvvvuvvvvvvvvvvuvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvuvvvvuvvvvvvvaaaaaaaaavvvvvvvvvvvvvvv55555555555555555555555555vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvuvvvvvvuuaauaaaavvvvvvvvvvvvvvv559955995995599959995599595vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvv
vvuvvvvvvvvvuvvvvvvvvvvvvvvvaaaaavvvvuvvvvvvvvvvv595559595959559559595959595vvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvuvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv595v59595959559559955959595vvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv59555959595955955959595959555vvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv55995995595955955959599559995vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvuvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv5555555555555555555555555555vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvuvvvvvvvvvvvvvvvvuvuuvvvvvvvvvvvvvvvvvvvvuvvuvvvvvvvvvvvvvvvvuvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvuvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvuvvvvvvvvvv
vvvvvvvvvuuuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvuvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvuvvvvvvuvvvvvvuvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvv
vvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvuvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvuvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvuvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvuvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvuvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvu
vvuvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvu
vvvvvuvvvvvvvvvvvvuuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvuvvvvvvvv
vvvvuvvvuvvvvvvvvvvvvvuvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvuvvvvuvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvuvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvv
vvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvv
vvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvv777v777v777vv77vv77vvvvv7v7vvvvv777vv77vvvvvv77v777v777v777v777vvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvv
vvuvvvvvvvvvvvvvvvvvvvvvvvuvvvvv7v7v7v7v7vvv7vvv7vvvvvvv7v7vvvvvv7vv7v7vvvvv7vuvv7vv7v7v7v7vv7vvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv777v77vv77vv777v777vvvvvv7uuvvvvv7vv7v7vvvvv777vv7vv777v77vvv7vvvvvvvvvvvuvvvvvvvvvuvvvvvvvvvvvu
vvvvvvuvvvvvvvvvuvvvvvvvuvvvvvvv7vvv7v7v7vvvvv7vvv7vvvvv7v7vvvvvv7vv7v7vvvvvvv7vv7vv7v7v7v7vv7vuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvuvvuvvvvvvvvvv7vvv7v7v777v77vv77vvvvvv7v7vvvvvv7vv77vvvvvv77vvv7vv7v7v7v7vv7vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvuvvvvvvvvvvvvvuvvvvvuvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuuvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvuvvuvvvvvvvvvvvuvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvuvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvu
vvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvuvvvvvvuvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvv
vvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvuvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvuvvvuvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvuvvvuvvvvvvvvvvvvvvvvuuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvuvvvvvvvuvvvuvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvuvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvv
vvvvvvuvvvvvvvvvvvvuvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvv
vvvvuvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvuuvvvvvvvvuvvvvvvvuvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvu
vvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvuvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvv
vvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvuvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv444444444vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvuvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvv444uuuuuuuuu4444vuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvv44444uuuuuuuuuu44uuuu444444vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvv444uuuuuuuuuuuuu44uuuuuuuuuuuu444vuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvuvvvvvvvv4444uuuuuuuuuuuuu444uuuuuuuuuuuuuuuuu4444vvvvvvvvvvddddddvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvuvvvvvvvvvvvvuvvvvvv
vvvvvv444444444uuuuuuuuuuuuuu444uuuuuuuuuuuuuuuuuuuuuuuu444vvvvvvvd7777dvvvvvvvvvvvvvvvvvvvvvu444vvvvvvuvvvvvvvuvvvvvvvuvvvvvvvv
v44444uuuuuuuuuuuuuuuuuuuu444uuuuuuuuuuuuuuuuuuuuuuuuuuuuuu444vvvvd7666dvvvvvuvvvvvvvvuvvv4lluuuu444vvvvvvvvvvvvvvuvuvvvvvvvvvvv
4uuuuuuuuuuuuuuuuuuuuu4444uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu4uvvd7666dvvvvvvvvvvvvv44444lddlluuuuu4444vvuvvvvvvvvvvvv444444444
uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuudduuuuuu44ddddddvvvvvvvv44444uuuuldddddluuu44444444444444444444uuuuuuuuu
uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuulluu4444uuuuuuuuuuud7duuuuuuu44llvvvu444444uuuuuuuu4ldddd54444uuuuuuuuuu44uuuu444uuuuuuuuuu
uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuullddluuuuu44uuuuuuuuud77ddduddddddddd44uuuuuuuuuuuuuu4444444uuuu44uuuuuuuuuu44444uu4u4uuuuuuu
uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuldddddluuuuuu4444uuuuud77777777777777duuuuuuuuuuuuuu444uuuuuuuuuuuu44uuuuuuuuuuuuu444uu4444uuu
44uuuuuuuuuuuuuuuuuuuu44444uuuuuul55ddddluuuuuuuuuu44444d76666666666666du4444uuuuu4444uuuuuuuuuuuuuuuuu444uuuuuuuuuuuuu4444uu444
4444uuuuuuuuuuuuu44444uuuuu4uuuu4l5d5d5dl4444uuuuuuuuuuud766666666uu666duuuuu44444uuuuuuuuuuuuuuuuuuuuuuuu444uuuuuuuuuuuuuu44444
uuuu44444uuuuuuuuuuuuuuuuuuu444u4455d5444uuuull4uuuuuuuud7l5666l5666l56duuuu444uuuuuuuuuuuuuuuuuuuuuuuuuuuuuu444uuuuuuuuuuuuuuuu
uuuuuuuuu4444444444uuuuuuuuuuuuuu44444uuuuullddl44444uuud576ld576ld576lduu44uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu4444uuuuuuuuuuuu
uuuuuuuuuuuuuuuuuuu444444444444444uuuuuuuuldddddluuuu44444665ul665ul665u44uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu
uuuuuuuuuuuuuuuuuuuu444uuuuuuuuuuuuuuuuuuld5ddddl4uuuuuuuu444444luuu5l44uuuuuuuuuuuuuuuuuuuuu4444uulluuuuuuuuuuuuuuuuuuuuuuuuuuu
uuuuuuuuuuuuuuuuu444uuuuuuuuuuuuuuuuuuuuul5d555dl4uuuuuuuuuuuuuu444444uuuuuuuuuuuuuuuuuuuuu44uuuuulddlluuuuuuuuuuuuuuuuuuuuuuuuu
uuuuuuuuuuuuu4444uuuuuuuuuuuuuuuuuuuuuuuul55dd55l4uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu4444uuuuuuldddddluuuuuuuuuuuuuuuuuuuuuuuu
uuuuuuuu44444uuuuuuuuuuuuuuuuuuuuuuuuuuuu4l5555544uuuuuuuuuuu4444uuuuuuuuuu444444444444uuuuuuuuuuldddd55luuuuuu44444uuuuuuuuuuuu
uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu444uuuuuuu444444444uuuuuu44444uuuuuuuu44u444uuuuuuuuuuuuuuuuuuuuuuld5d5d5l4uuuu4uuuuuu4444uuuuuuu
uuuuuuuuuuuuuuuuuuuuuuuuuuuu444uuu444uuuuu4444444uuu4444uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuul5d5d5544u44uuuuuuuuuuuuuuuuuuu
4uuuuuuuuuuuuuuuuuuuuuu44444uuuuuuuuu444uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu4u5555u4uuuuuuuuuuuuuuuuuuu4444
uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu444444uuuuuuuuuuuuuuuuuuu44uuuu
uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu44444uuuuuuuuuuuuuuuuu44uuuuuu
uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu

__gff__
0000000000000000000001000101010101000000000000000000010001000001010000000000000000000100010000010000000000000000000001000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0d0e2a000000003a0d0e0d0e0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c1c1b2e00000000002d2e00002d1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0c2a2b00000000000000000000002f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c2a1b2b000000000000000000001d1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c3b2b2e000000000000000000002b2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c2b2e00000000000000000000001b1f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c000000000000000000000000002d3a0d0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000c0d0e0d0e0d0e0d0e0f00000000001c0000000000000000000000000000001d1b1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000c2a00000405040504052f0f000000002c0000000000000000000000000000002d2b2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001c0000000000000000003a0e0f0000001c000000000000000000000000000000002d3a0d0e0d0e0d0e0d0e0d0e0d0e0d0d0e0d0e0d0e0d0e0d0e0d0e0d0e0d0f0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000002c00000000000000000000003a0f00002c0000000000000000000000000000000000000000040500000004050405040500000000002d2e000000000000002d1f0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001c2223000000000000000000003a0f0c1c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002f0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000002c323300444544454445000000003a0e2a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001d1f0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000003c3d3e3d3e3d3e3d3e1a002223002d2e000000000000000000000000010300000000000000000000000000000000000000000000000000000000000000002d2f0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000003c1c0032330000000000000000000000000000001113001d1e0000000044450000004445444544450000000000000000000000000000001f0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000003c3d3e3d3e3d3e3e3d3e3d3e3d3e3d3e3d3e3d3e3d3e3d3d3e3d3e3d3e3d3e3d3e3d3e3d3e3d3e3e3d3e3d3e3d1a00000000000000002f0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0d0e0d0e0d0e0e0d0e0d0e0d2a00000000000000003a0e0d0e0d0e0d0e0d0e0d0e0d0e0d0e0f00000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c2b2b2e000000000000000000000000000000000000002d1b2e0004050405040504051d2b2e2f00000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c2b2e00000000000000000000000000000000000000000000000000000000000000002d2e001f00000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c002223000000000000000000000000020300000000000000000000000000000000000000002f00000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c1e3233000000000000000000000000121300000000000022230000000000000000000022231f00000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003c3d3e3d3e3d3e3d3e1a10101010100a3d3e3d1a1e00000032330044454445444544450032332f00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003c1c20202020202f3f003c3c3d3e3d3d3e3d3e3d3e3d3e3d3e3d3e3d3e3d3f00000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c00000000001f0f0000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c00000000003a0d0e0d0e0d0e0d0e0d0e0d0e0d0e0d0e0d0e0d0e0d0f0000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c001d1e0000000000000000000000000000000000000000002d0b2b1f0000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c1d2b1b0000000000000000000000002223000000000000000000002f0000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c0b3b2b1e0000000000000000000000323300000000000000001d0a3f0000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003c3d3e3d3e3d3e3d3e3d3e3d3e3d3d3e3d3e3d3e3d3e3d3e3d3e3d3f000000000000000000000000000000000000
__sfx__
0005000224325007050070500705007050a7050b705007050b7050c705007050c7050d7050d7050d7050070500705007050070500705007050070500705007050070500705007050070500705007050070500705
001500200a6100c6100c6100b6100961006610056100561007610096100a6100c6100e6100f6101061010610106100f6100e6100d6100b6100a6100a6100a6100b6100b6100c6100d6100d6100d6100d61009610
001500200a6200c6200c6200b6200962006620056200562007620096200a6200c6200e6200f6201062010620106200f6200e6200d6200b6200a6200a6200a6200b6200b6200c6200d6200d6200d6200d62009620
0002000026624376371263431627196341564730614276372363435627066243e6340e6441b6240a627366341d6443062415614246273e6241f634286343b6140f6141b627346243d62430614096173861737617
010300002377321774207731e7741d7731b77419773177741677315774147731377412773117740f7730e7740d7730c7740b7730a774097730877407773067740577304774037730277401773007740077300774
000500001e5521d5521d5521c5521c5521b5521b5521955219552175521655215552145521355211552105520e5520d5520c5520b5520a5520955208552075520555205552035520255201552003730037300373
001001020717107173001530015300153001530015300153001530015300153001530015300153001530015300153001530015300153001530015300153001530015300153001530015300153001530015300153
00100000070740a0740c074050740f074110741307416074180740f0040f004110041d0041d004005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504
001800020076305763007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703
000500000f4500a45005450004500f4500c4500040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
__music__
02 03404344
00 04424344

