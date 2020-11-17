pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- solene is missing
-- mobo
c_title_text="solene is missing!"
c_defeat_text="defeat!you didn't\nsave solene!"
c_victory_text="victory!you saved\nsolene!"
c_intro_text_1="oh no!"
c_intro_text_2="my dear solene is missing!\nand it's my birthday..."
c_intro_text_3="she has been kidnapped\nby the evil morgan!"
c_intro_text_4="she must be rescued!"
c_solene_text_1="oh thank you for saving me!"
c_solene_text_2="here,a kiss!\nhappy birthday ludovic!"
c_solene_text_3="let's go through the door\nbehind me!"
c_morgan_text_1="get rid of all those\ndisgusting green blobs"
c_morgan_text_2="and i will give you this key\nto release her."
c_morgan_text_3="take the sword..."
c_morgan_text_4="a deal is a deal..."
c_morgan_text_5="take this key!"
c_player_x=5
c_player_y=3
c_player_speed=0.125

function _init()
	state=2
end

function _update()
	if (state==0) update_game()
	if (state==1) update_gameover()
	if (state==2) update_gamestart()
end

function _draw()
	if (state==0) draw_game()
	if (state==1) draw_gameover()
	if (state==2) draw_gamestart()
end
-->8
-- game start
function update_gamestart()
	if (btn(🅾️)) init_game()
end

function draw_gamestart()
	camera()
	cls(13)
	rectfill(31,83,105,119,14)
	rectfill(28,80,102,116,2)
	spr(6,128/2-4,64)
	print(c_title_text,31,86,6)
	print("C or 🅾️ to start",34,106,6)
end
-->8
-- game over
function update_gameover()
	if (btn(🅾️)) then
		reload(0x2000, 0x2000, 0x1000)
		init_game()
	end
	if music_start then
		music_start=false
		music(-1)
	end
end

function draw_gameover()
	camera()
	cls(13)
	rectfill(31,43,105,79,14)
	rectfill(28,40,102,76,2)
	if p!=nil and p.life==0 then
 		print(c_defeat_text,34,46,6)
 	else
		print(c_victory_text,34,46,6)
 end
	print("C/🅾️ to retry",34,66,6)
end
-->8
-- game
function init_game()
	state=0
	music_start=false
	init_camera()
	create_player(c_player_x,c_player_y)
	create_monsters()
	init_msg()
	create_msg("ludovic",c_intro_text_1,
		c_intro_text_2, c_intro_text_3,c_intro_text_4)
end

function update_game()
	if not music_start then
		music(0)
		music_start=true
	end
	if not messages[1] then
		move_player()
		move_monsters()
	end
	update_camera()
	update_msg()
end

function draw_game()
	cls()
	palt(0,false)
	palt(7,true)
	draw_map()
	draw_player()
	draw_monsters()
	draw_ui()
	draw_msg()
end
-->8
--map
function draw_map()
	map()
end

function check_flag(flag,x,y)
	local sprite=mget(x,y)
	return fget(sprite,flag)
end

function init_camera()
	camx,camy=0,0
end

function update_camera()
	local sectionx=flr(p.x/16)*16
	local sectiony=flr(p.y/16)*16
	local destx=sectionx*8
	local desty=sectiony*8
	local diffx=destx-camx
	local diffy=desty-camy
	diffx/=4
	diffy/=4
	camx+=diffx
	camy+=diffy
	camera(camx,camy)
end


function other_update_camera()
 local camx=mid(0,
 	(p.x-7.5)*8+p.ox,(31-15)*8)
 local camy=mid(0,
 	(p.y-7.5)*8+p.oy,(31-15)*8)
	camera(camx,camy)
end

function next_tile(x,y)
	sprite=mget(x,y)
	mset(x,y,sprite+1)
end

function pick_up_key(x,y)
	next_tile(x,y)
	p.keys+=1
	sfx(0)
end

function pick_up_sword(x,y)
	next_tile(x,y)
	p.sword+=1
	sfx(0)
end

function open_door(x,y)
	next_tile(x,y)
	p.keys-=1
	sfx(1)
end
-->8
--player
function create_player(x,y)
	 p={
	 	x=x,y=y,
	 	ox=0,oy=0,
	 	start_ox=0,start_oy=0,
	 	anim_t=0,
	 	sprite=7,
	 	keys=0,
	 	flip=false,
	 	life=3,
	 	inv_t=0,
	 	sword=0,
	 	attack_t=0,
	 	attack_d=1
	 }
end

function move_player()
 p.attack=false
	local newx=p.x
	local newy=p.y
	local newox,newoy=0,0
	if p.anim_t==0 then
		if (btn(➡️)) then
			newx+=1
			newox=-8
			p.flip=false
			p.attack_d=1
		elseif (btn(⬅️)) then
			newx-=1
			newox=8
			p.flip=true
			p.attack_d=2
		elseif (btn(⬇️)) then
			newy+=1
			newoy=-8
			p.attack_d=3
		elseif (btn(⬆️)) then
			newy-=1
			newoy=8
			p.attack_d=4
		elseif (btnp(❎)) then
			if p.sword>0 then
				if p.attack_d==1 then
					attack_player(p.x+1,p.y)
				elseif p.attack_d==2 then
					attack_player(p.x-1,p.y)
				elseif p.attack_d==3 then
					attack_player(p.x,p.y+1)
				elseif p.attack_d==4 then
					attack_player(p.x,p.y-1)
				end
			end
		end
	end
	--invulnerabilty frame
	if p.inv_t>0 then
		p.inv_t-=1
	end
	--attack frame
	if p.attack_t>0 then
		p.attack_t-=1
	end

	interact(newx,newy)

	if not check_flag(0,newx,newy)
		and (p.x!=newx or p.y!=newy) then
		p.x=mid(0,newx,127)
		p.y=mid(0,newy,63)
		p.start_ox=newox
		p.start_oy=newoy
		p.anim_t=1
	end

	--animation
	p.anim_t=max(p.anim_t-c_player_speed,0)
	p.ox=p.start_ox*p.anim_t
	p.oy=p.start_oy*p.anim_t
	if p.anim_t>0.5 then
		p.sprite=23
		if p.inv_t>0 then
			p.sprite=24
		end
		if p.attack_t>0 then
			p.sprite=25
		end
	else
		p.sprite=7
		if p.inv_t>0 then
			p.sprite=8
		end
		if p.attack_t>0 then
			p.sprite=9
		end
	end

	if p.life<=0 then
		state=1
	end
end

function interact(x,y)
	if check_flag(1,x,y) then
		pick_up_key(x,y)
	elseif check_flag(3,x,y) then
		pick_up_sword(x,y)
	elseif check_flag(2,x,y) then
	 if p.keys>0 then
		 open_door(x,y)
		end
	elseif x==9 and y==14 then
		create_msg("a sign","⌂+웃=➡️")
	elseif x==27 and y==5 then
		create_msg("solene",c_solene_text_1,
			c_solene_text_2,c_solene_text_3)
		mset(27,1,59)
		sfx(1)
	elseif not check_flag(0,x,y) and x==27 and y==1 then
		state=1
	elseif x==2 and y==29 then
		if #monsters>0 then
			create_msg("morgan",c_morgan_text_1,
				c_morgan_text_2, c_morgan_text_3)
		else
			create_msg("morgan",c_morgan_text_4,
				c_morgan_text_5)
				mset(3,28,59)
				sfx(1)
		end
	end
end

function attack_player(x,y)
		p.attack_t=1*8
		sfx(2)
		for m in all(monsters) do
			if x==m.x and y==m.y then
				m.life-=1
				sfx(3)
			end
		end
end

function draw_player()
	spr(p.sprite,
	p.x*8+p.ox,p.y*8+p.oy,1,1,p.flip)

	if p.attack_t>0 then
		if p.attack_d==1 then
			spr(36,p.x*8+1*8,p.y*8)
		elseif p.attack_d==2 then
			spr(36,p.x*8-1*8,p.y*8)
		elseif p.attack_d==3 then
			spr(36,p.x*8,p.y*8+1*8)
		elseif p.attack_d==4 then
			spr(36,p.x*8,p.y*8-1*8)
		end
	end

end
-->8
--ui
function draw_ui()
 camera()
 spr(32,2,1)
	spr(48,2,8)
	spr(49,2,14)
	spr(33,127-16,1)
	print_outline("x"..p.life,10,1)
	print_outline("x"..p.keys,10,8)
	print_outline("x"..p.sword,10,15)
	print_outline("x"..#monsters,127-7,2)
end

function print_outline(text,x,y)
		print(text,x-1,y,0)
		print(text,x+1,y,0)
		print(text,x,y-1,0)
		print(text,x,y+1,0)
		print(text,x,y,10)
end
-->8
--messages
function init_msg()
 msg_title=""
	messages={}
end

function create_msg(name,...)
	msg_title=name
	messages={...}
end

function update_msg()
	if (btnp(❎)) then
		if messages[1] then
			sfx(4)
			deli(messages,1)
		end
	end
end

function draw_msg()
	if messages[1] then
		local y=100
		rectfill(6,y,6+#msg_title*4,
			y+8,1)
		print(msg_title,7,y+1,6)
		rectfill(2,y+9,125,y+21,1)
		print(messages[1],3,y+10,6)
	end
end
-->8
--monsters
function create_monsters()
	 monsters={}
	 local positions={
			{x=11,y=10},
			{x=8,y=12},
			{x=1,y=17},
			{x=6,y=20},
			{x=27,y=23},
			{x=20,y=22},
			{x=21,y=12},
			{x=7,y=24},
			{x=6,y=30},
	 }
	 for p in all(positions) do
		 m={
		 	x=p.x,y=p.y,
		 	ox=0,oy=0,
		 	start_ox=0,start_oy=0,
		 	anim_t=0,
		 	sprite=39,
		 	flip=false,
		 	dirx=1,
		 	life=1
		 }
		 add(monsters,m)
		end
end

function move_monsters()
	for m in all(monsters) do
		local newx=m.x
		local newy=m.y
		local newox,newoy=0,0
		if m.anim_t==0 then
			if m.dirx==1 then
				newx+=1
				newox=-8
				m.flip=false
			elseif m.dirx==-1 then
				newx-=1
				newox=8
				m.flip=true
			end
		end

		interact_monster(newx,newy)

		--wall collision
		if check_flag(0,x,y) then
			m.dirx=-m.dirx
		end

		if not check_flag(0,newx,newy)
			and (m.x!=newx or m.y!=newy) then
			m.x=mid(0,newx,127)
			m.y=mid(0,newy,63)
			m.start_ox=newox
			m.start_oy=newoy
			m.anim_t=1
		end

		--animation
		m.anim_t=max(m.anim_t-0.125,0)
		m.ox=m.start_ox*m.anim_t
		m.oy=m.start_oy*m.anim_t
		if m.anim_t>0.5 then
			m.sprite=39
		else
			m.sprite=55
		end
		-- death
		if m.life<=0 then
			del(monsters,m)
		end
	end
end

function interact_monster(newx,newy)
	if p.inv_t==0 and p.attack_t==0 and newx==p.x and newy==p.y then
		p.inv_t=3*8
		p.life-=1
		sfx(2)
	end
end

function draw_monsters()
	for m in all(monsters) do
		spr(m.sprite, m.x*8+m.ox,
			m.y*8+m.oy,1,1,m.flip)
	end
end
__gfx__
00000000555555555555558555888855888888886666666699a9a9dd799999977888888779999997dddddddddddddddd76222222222222222222226700000000
000000005555555558555868582222858888888866666666aaffffdd79ffff9778eeee8779ffff97ddddddddddddddddd62ddd2ddd2ddd2ddd2dd26d00000000
0000000055555555868555858222222888888888eeeeeeee99fcfcdd79f4f47778e8e87779f4f476dddddaddddddddddd6266626662666266626626d00000000
000000005555555558555555222882228888888888888888aaffffdd9fffff778eeeee779fffff60daaaadaddddddddd22000000000000000000002200000000
00000000555555555555585522222222888888888888888899ff8edd7bfffb7778eee8777bfffa071a111a1111111111d60dd0ddd0ddd0ddd0ddd06d00000000
0000000055555555555586858288882888888888888888886deeed6df7bbb7f7e78887e7f7bbb9971111111111111111d6022022202220222022206d00000000
000000005555555555555855522222258888888888888888ddeeeddd773337777788877777333777d222222dd222222dd6000000000000000000006d00000000
000000005555555555555555555115558888888888888888ddeeeddd7747477777e7e77777474777dddddddddddddddd2200ddd0ddd0ddd0ddd0d02200000000
000000000000000055555655555555550000000066666666511111557999999778888887799999970000000000000000d6002220222022202220206d00000000
0000000000000000555568654444444400000000655555565166665579ffff9778eeee8779ffff970000000000000000d6000000000000000000006d00000000
000000000000000055555655400404040000000066666666516c6c5579f4f47778e8e87779f4f4760000000000000000d60dd0ddd0ddd0ddd0ddd06d00000000
000000000000000055555555404404440000000065555556566666559fffff778eeeee779fffff60000000000000000022022022202220222022202200000000
000000000000000055655555444444440000000066666666546664557bfffb7778eee8777bfffa070000000000000000d6000000000000000000006d00000000
00000000000000005686555555511555000000006555555665444565f7bbb7f7e78887e7f7bbb9970000000000000000d600ddd0ddd0ddd0ddd0d06d00000000
000000000000000055655555555115550000000066666666550205557733377777888777773337770000000000000000d6002220222022202220206d00000000
0000000000000000555555555522225500000000655555565545455577747777777e777777747777000000000000000022000000000000000000002200000000
70070077700000075555500055555000779999770000000000000000777777770000000000000000dddddddd00000000d60dddddddddddddddddd06d00000000
08808807033333305005065050050000797777970000000000000000773333770000000000000000dddddddd00000000d60dddddddddddddddddd06d00000000
0888880703b83b800a90655000000000977aa7790000000000000000733333370000000000000000dddddddd00000000d60dddddddddddddddddd06d00000000
0888880703bb3bb0099655050000000597a77a79000000000000000033b83b830000000000000000dddddddd00000000220dddddddddddddddddd02200000000
7088807703333330506950555000005597a77a79000000000000000033bb3bb30000000000000000dddddddd00000000d60dddddddddddddddddd06d00000000
77080777033888300a55a90500000005977aa77900000000000000003333333300000000000000000000000000000000d60dddddddddddddddddd06d00000000
777077777033330709909905000000057977779700000000000000007338883700000000000000006626662600000000d60dddddddddddddddddd06d00000000
77777777770000770005005500050055779999770000000000000000773333770000000000000000dd2ddd2d00000000220dddddddddddddddddd02200000000
777777777777700000000000000000000000000000000000000000007733337700000000000000002244442222422222d60dddddddddddddddddd06d00000000
70a0000770070650000000000000000000000000000000000000000073333337000000000000000005444450054dddddd60dddddddddddddddddd06d00000000
0a7aaaa00a906550000000000000000000000000000000000000000033bb3bb3000000000000000045444454454dddddd60dddddddddddddddddd06d00000000
70a000a009965507000000000000000000000000000000000000000033b83b83000000000000000045444454454ddddd220dddddddddddddddddd02200000000
7777770770695077000000000000000000000000000000000000000033333333000000000000000045004454450dddddd60dddddddddddddddddd06d00000000
777777770a55a907000000000000000000000000000000000000000073388837000000000000000045404454450dddddd6000000000000000000006d00000000
7777777709909907000000000000000000000000000000000000000077333377000000000000000045444454454dddddd6266626662666266626626d00000000
7777777700070077000000000000000000000000000000000000000077777777000000000000000045444454454ddddd762ddd2ddd2ddd2ddd2dd26700000000
__gff__
0000000101010100000003010101010000000001000001000000010101010100000008000000000000000001010001000000000000000000000005000101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0303030303030303030303030303030303030303030304040c0d0d0d0d0d0e03131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
030303030c0d0e01020103030303030301010201050504041c1d1d3a1d1d1e03131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
030303031c1d1e01010103030303030301010101040404042c2d2d2d2d2d2e03131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
030303032c2d2e01120103030303030301020105040403032c2d2d2d2d2d2e03131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
030303033c2a3e01010103030303030301010104040403032c2d2d2d2d2d2e03131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
030201011c3b1e01010201010101010101120504040303032c2d2d062d2d2e03131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
0301010101010101010101050505050505050404040303032c2d2d2d2d2d2e03131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
0301120505050505150505040404040404040404030303032c2d2d2d2d2d2e03131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
0505050404040404150404040404040404040403030303032c2d2d2d2d2d2e03131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
0404040404040401010101010101030303030303030303032c2d2d2d2d2d2e03131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
0404040401010101010101010201030303030303030303033c3d3d2a3d3d3e03131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
0301010101010201010101010101030303030303030303031c1d1d3a1d1d1e03131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
0303030301120101010102010101030303030303010101010101010101010103131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
0303030301010102010101010112030301010101010101010101010101010203131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
0303030301010101011301010101010101010102010101010101010101010103131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
0301010301010101010101010101010101010101010101010101020101010103131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
0301010301010101010101010101010101010101010101010101010101010103131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
0301120301011201010112010101010112010101010101120101010101010103131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
0301010102010101010101010101010101010101010101010101010101010103131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
0301010101010101020101030303030303030301010101010101010112030303131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
0301010112010101010103030303030303030303010101010201010101030303131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
0303030303030303030303030303030303030303010201010101010101030303131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
0303030303030303030303030303030303030101010101010101030303030303131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
0303030303030303030303030303030303030201010101010101030101010103131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
030c0d0d0d0e0101010103030301010101010101010101120103030101020103131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
031c1d1d1d1e0122010203030301010101010101010101010103030101010303131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
032c2d0a2d2e0101010101010101020101010101010101010101010103030303131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
033c3d2a3d3e0101010101010101010101010112010101010101010103030303131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
031c1d3a1d1e0101020101010101010101010101010101010101010303030303131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
0301160101010101010101010101010102010101010101010101010303030303131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
0301010112010101011201030101010101010101010101010101030303030303131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
0303030303030303030303030303030303030303030303030303030303030303131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313
__sfx__
000300001e51021530245402855030550375503f550055000750008500095000b5000e5000f50010500125001450016500195001b5001d5001f5002350024500285002b5002d50030500135001d5003a5003e500
00010000256502265022650206501f6501c6501a64018630146300962000620006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
00010000247502c75030750307502e7502b750257500c750067500070001700017000170001700017000170000700007000070000700007000070000700007000070000700007000070000700007000070000700
00020000116500d650096500565003650016500065000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000100002c0502c0502d0502d0502c0502b0502b05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800000e02010020110201302011020100200e0200c0201002011020100200e0200e020110200e0200e0200e02010020110201302011020100200e0200c0201002011020100200e0200e020110200e0200e020
011800002602000000000000000028020000000000000000240200000026020000000000000000000000000028020000002902000000280200000026020000002402000000000000000000000000000000000000
__music__
00 0a424344
02 0a0b4344

