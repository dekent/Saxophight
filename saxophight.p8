pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
--saxophight!    help max the sax
--perform the solo of his carreer

--game screen
screen=0 --0:title,1:play,2:lose

--title screen
title_direction=0
title_max_x=52
title_sprite=8
top_score_blues=0
top_score_bebop=0
title_transition=false
title_counter=0
show_instructions=false

--gameover screen
gameover_transition=true
gameover_counter=0
set_gameover=false

--player
p = {}
p.max_dx = 2
p.x_col_l_bound = {6,0} --lower bound for h collision
p.x_col_u_bound = {15,9} --upper bound for h collision
p.player = true
p.sax = 0

spawn = {}
spawn.x = {72,231}
spawn.y = {48,119}
blues_beat = 12 --frames per beat (75 bpm)
bebop_beat = 9 --frames per beat (150 bpm)
g = .15 --gravity acceleration (pixels/frame^2)
max_dy = 7 --terminal vel, prevents going through 8x8 tile
camera_delay = 4

--music stuff
blues_chords = {1,1,1,1,4,4,1,1,5,4,1,5,1,1,1,1,4,4,1,1,5,4,1,1}
blues_bass_pos = {1,1,1,2,1,1,1,0,1,2,1,2,1,0,1,2,0,0,0,2,0,2,0,2,0,0,0,2,0,2,0,1,2,2,2,1,0,0,0,2,0,0,0,1,2,1,2,1,0,1,0,2,0,2,0,2,0,1,0,1,0,2,0,1,2,1,2,1,2,1,2,1,2,0,2,1,2,1,2,0,1,2,1,0,2,0,2,1,2,1,2,1,2,1,2,1}
bebop_chords = {1,2,1,5,4,4,1,5,2,5,1,2,1,2,1,5,4,4,1,5,2,5,1,1}
bebop_bass_pos = {1,2,1,0,2,0,2,1,2,0,1,2,1,0,1,0,2,0,1,2,0,2,1,0,1,0,2,0,1,0,2,1,0,1,2,1,2,1,0,2,0,1,2,1,0,1,0,2,1,2,1,0,1,2,1,0,1,2,0,2,0,1,0,1,2,0,1,2,0,2,1,0,1,0,1,2,0,2,1,2,0,1,2,1,2,1,0,2,1,2,1,0,2,1,2,1}

--unlockables
sax_colors = {true,false,false,false,false}
msg_thresholds = {50,100,200,300,450,600,800,1000,1250,1500,1800,2100}

--messages
bass_msgs = {
 "keep it up, max!",
 "feel the groove",
 "woo!",
 "that's it!",
 "keep that flow, max!",
 "feel the swing",
 "blow that horn"
}
drum_msgs = {
 "hot licks, max!",
 "feel the rhythm",
 "keep it movin'",
 "you're killin' it!",
 "solid",
 "break it down, max!",
 "right on!"
}
bar_msgs = {
 "groovin'",
 "dig it!",
 "drink's on me, max!",
 "oh yeah",
 "that's what i'm talkin' about",
 "mhmm",
 "sounds good, max",
 "get down!",
 "jammin'",
 "don't stop!"
}
drink_msgs = {
 "that cat can blow!",
 "yeah!",
 "swingin'",
 "i'm feelin' it",
 "whoa!",
 "he can wail",
 "swanky!"
}
hat_msgs = {
 "hat's off to you",
 "nice!",
 "toe tappin'!",
 "how's he still going?",
 "ornithological!",
 "he's got some chops",
 "wild"
}
bass_hit_msgs = {
 "oof...",
 "ouch!",
 "stay in key, max!",
 "watch those accidentals!",
 "keep at it!",
 "1 2 3 4"
}
drum_hit_msgs = {
 "get back in the swing!",
 "hmm...",
 "relax, max!",
 "err...",
 "bounce back, max!",
 "stay focused"
}
gameover_msgs = {
 "let's take it from the top!",
 "take five",
 "don't blow your top",
 "back to the head",
 "we'll be here all week",
 "don't split just yet!",
 "how 'bout another round?",
 "shine that sax"
}

function _init()
 --read high score data, set unlocks
 cartdata("saxophight")
 top_score_blues = dget(0)
 top_score_bebop = dget(1)
 if top_score_blues >= 500 then
 	sax_colors[2] = true
 end
 if top_score_blues >= 1000 then
  sax_colors[4] = true
 end
 if top_score_bebop >= 500 then
  sax_colors[3] = true
 end
 if top_score_bebop >= 1000 then
  sax_colors[5] = true
 end
 
 music(7)
end

--reset the game for another round
--game_mode=0:blues
--game_mode=1:bebop
function reset(game_mode)
 --reset a lot of state
 notes = {}
 shatter = {}
 tpt_spawns = {}
 trumpets = {}
 accidentals = {}
 counter = 0
 camera_follow = {}
 note_counter = 1
 chord_counter = 1
 triplet_flag = false
 arm_in = true
 head_nod = false
 play_snare = false
 play_hihat = false
 snare_counter = 0
 kick_counter = 0
 hihat_counter = 0
 new_unlock = false
 msgs = {}
 for i=1,5 do
  msgs[i] = {}
  msgs[i].text = ""
  msgs[i].counter = 0
 end
 gameover_msg_set = false
 
 --hud
 game_points = 0
 health = 40
 breath = 40
 
 --player initialization
 p.x = 120
 p.y = 112
 p.dx = 0
 p.dy = 0
 p.ddx = 0
 p.dir = 1
 p.state = 0 --0:stand,1:run,2:jump
 p.frame = 0 --animation frame
 p.sprite = 0 --animation offset
 p.jump_reset = false --flag for jump key release
 p.x_col = {0,9} --horizontal collision box
 p.y_col = {0,30} --vertical collision box
 
 for i=1,camera_delay do
  c={}
  c.x = p.x-60
  c.y = p.y-96
  camera_follow[i] = c
 end
 
 --blues- vs bebop-specific
 if (game_mode == 0) then
  beat = blues_beat
  prev_note = 12
  music(0,0)
 else
  beat = bebop_beat
  prev_note = 22
  music(3,0)
 end
end

function h_physics(obj)
 --friction
 if (on_ground(obj)) then
 	if (obj.ddx == 0)	obj.dx *= .9
	end
	
	--update
	obj.dx += obj.ddx
	obj.dx = mid(-obj.max_dx,obj.dx,obj.max_dx)
	obj.x += obj.dx
end

function v_physics(obj)
	--check for not on ground
	if (not on_ground(obj)) then
		obj.state = 2
		obj.jump_reset = false
		obj.dy = mid(-max_dy, obj.dy+g, max_dy)
	else
		--player case: start jump
		if (obj.player and obj.start_jump) then
		 obj.dy = -2
		 obj.state = 2
		 obj.start_jump = false
		end
	end	
	obj.y += obj.dy
end

function v_collision(obj)
 --iteration 1 ceiling, 2 floor
 for i=2,1,-1 do
		in_collision = false
		for j=obj.x_col[1],obj.x_col[2] do
		 v_edge = obj.y+7-obj.y_col[i]
  	if (is_solid(obj.x+j, v_edge)) in_collision=true break
 	end
 	if (in_collision) then
	  obj.dy = 0
   obj.y = flr(v_edge/8)*8+9*i-17+obj.y_col[i]
   return true
	 end
	end
	return false
end

function h_collision(obj)
 --iteration 1 left, 2 right
 for i=1,2 do
		in_collision = false
		for j=obj.y_col[1],obj.y_col[2] do
		 h_edge = obj.x+obj.x_col[i]
  	if (is_solid(h_edge, obj.y+7-j)) in_collision=true break
 	end
 	if (in_collision) then
	  obj.dx = 0
   obj.x = flr(h_edge/8)*8-9*i+17-obj.x_col[i]
   return true
	 end
	end
	return false
end

function check_object_collisions()
 --projectile collision
 for tpt in all(trumpets) do
  for note in all(notes) do
   if (obj_collision(tpt, note)) then
    if (tpt.sprite < 136) then
     game_points += 10
     check_msg_thresholds(10)
	    tpt.sprite += 8
     tpt.frame = 0
	    tpt.dx = 0
	    tpt.dy = -1
 	   play_hihat = true
    end
  	 destroy_note(note)
   end
  end
 end
 
 --collision with player
 for tpt in all(trumpets) do
  if (obj_collision(tpt,p)) then
   if (tpt.sprite<136) then
    hit_player()
    tpt.sprite += 8
    tpt.frame = 0
    push = tpt.dx
    tpt.dx = p.dx
    p.dx += push/2
    tpt.dy = -1
   end
  end
 end
 for accidental in all(accidentals) do
  if (obj_collision(accidental,p)) then
   hit_player()
   p.dx += accidental.dir*accidental.dx/2
   shatter_effect = {}
   shatter_effect.x = accidental.x+avg(accidental.x_col[1],accidental.x_col[2]-4)
   shatter_effect.y = accidental.y+avg(accidental.y_col[1],accidental.y_col[2]-4)
   shatter_effect.sprite=188
   add(shatter, shatter_effect)
   del(accidentals, accidental)
   if rnd(1) < .5 then
    if rnd(1) < .5 then
     msgs[1].text = rnd_msg(bass_hit_msgs)
     msgs[1].counter = 240
     msgs[2].counter = 0
    else
     msgs[2].text = rnd_msg(drum_hit_msgs)
     msgs[2].counter = 240
     msgs[1].counter = 0
    end
   end
  end
 end
end

function hit_player()
 play_snare = true
 health -= 2.5
 if (health<0) then
 	health=0
 	set_gameover = true
 	
 end
end

function obj_collision(obj1, obj2)
	y1 = obj1.y
	y2 = obj2.y
	if (obj1==p) y1+=7
	if (obj2==p) y2+=7
	c1 = obj1.x+obj1.x_col[1]
	c2 = obj1.x+obj1.x_col[2]
	c3 = obj2.x+obj2.x_col[1]
	c4 = obj2.x+obj2.x_col[2]
	c5 = y1-obj1.y_col[1]
	c6 = y1-obj1.y_col[2]
	c7 = y2-obj2.y_col[1]
	c8 = y2-obj2.y_col[2]
 return (c1<c4 and c2>c3 and c7>c6 and c8<c5)
end

function on_ground(obj)
 for i=obj.x_col[1],obj.x_col[2] do
 	if (is_solid(obj.x+i, obj.y-obj.y_col[1]+8)) return true
 end
 return false
end

function against_wall(obj,dir)
	for j=obj.y_col[1],obj.y_col[2] do
		if (is_solid(obj.x+obj.x_col[.5*dir+1.5]+dir,obj.y+7-j)) return true
	end
	return false
end

function is_solid(x,y)
 return fget(mget(x/8, y/8)) == 1
end

function turn(dir)
 if (p.dir == -dir) p.x += dir*8
 p.dir = dir
 i = .5*dir+1.5
 p.x_col = {p.x_col_l_bound[i],p.x_col_u_bound[i]}
end

function run_p(dir)
 turn(dir)
	p.ddx = p.dir*.2
	if (p.state==0) p.state=1 p.frame=0
end

function air_drift(dir)
	turn(dir)
	p.ddx = p.dir*.1
end

function blow()
 if (breath <= 0) breath=0 return
 breath -= 0.25
 if (breath<0) breath=0
 
 if (counter == 0) blow_note(0) prev_note=-1
 
 if (counter == flr(1/3*beat)) then
  if (rnd(1) > .8) then
   blow_note(1)
   triplet_flag = true
  else
   triplet_flag = false
  end
 end
 
 if (counter == flr(2/3*beat) and (triplet_flag or rnd(1) > .5)) then
  blow_note(2)
  triplet_flag = false
 end
end

--length:
 --0 for full
 --1 for middle triplet
 --2 for eighth
function blow_note(length)
 --determine note
 if (prev_note==-1) then
  if (length==1 or length==2) then
   note_sfx = select_note(1)
  else
   note_sfx = select_note(3)
  end
 else
  if length==0 then
   note_sfx = select_note(4)
  elseif length==1 then
   note_sfx = select_note(2)
  else
   if triplet_flag then
    note_sfx = select_note(2)
   else
    note_sfx = select_note(5)
   end
  end
 end

 --save note
 prev_note = note_sfx
 
 --play note
 if (length==2) length=1
	sfx(note_sfx,3,length)
	
	--set visual orientation
	orientation=0
	if beat == blues_beat then
		if (note_sfx > 11) orientation=1
	else
	 if (note_sfx > 30) orientation=1
	end

 --phyiscal note
 if (btn(2)) then
	 create_note(.75,-3.5,orientation)
	else
	 if (btn(3)) then
	  if on_ground(p) then
		  create_note(2.25,-2,orientation)
		 else
		 create_note(2.25,0,orientation)
		 end
	 else
	  create_note(1.25,-2.85,orientation)
	 end
	end
end

--option 1: random
--option 2: prev_note
--option 3: chord
--option 4: chord+prev_note
--option 5: chord(light)+prev_note
function select_note(option)
 if beat == blues_beat then
  dist_size = 13
  sfx_offset = 5
 else
  dist_size = 17
  sfx_offset = 21
 end
 
 if (option==1) return flr(rnd(dist_size)) + sfx_offset + 1

	last_note = prev_note-sfx_offset
	 
 pdist={}
 for i=1,dist_size do
  pdist[i]=0.0
 end

 if (option==2 or option==4 or option==5) then
	 --add prev_note chance
	 pdist[last_note] += 1
	 if (last_note+1<=dist_size) pdist[last_note+1] += 1
	 if (last_note+2<=dist_size) pdist[last_note+2] += 0.5
	 if (last_note+3<=dist_size) pdist[last_note+3] += 0.25
	 if (last_note-1>0) pdist[last_note-1] += 1
	 if (last_note-2>0) pdist[last_note-2] += 0.5
	 if (last_note-3>0) pdist[last_note-3] += 0.25	
	 
	 if (last_note+5<=dist_size) then
	  for i=last_note+5,dist_size do
	   pdist[i] -= 0.5
	  end
	 end
	 if (last_note-5>1) then
	  for i=last_note-5,1 do
	   pdist[i] -= 0.5
	  end
	 end
 end

 if (option==3 or option==4) then
  if beat == blues_beat then
	  pdist = add_chord(pdist,blues_chords[chord_counter],1.0)
	 else
	  pdist = add_chord(pdist,bebop_chords[chord_counter],1.0)
	 end
 end

 if (option==5) then
  if beat == blues_beat then
	  pdist = add_chord(pdist,blues_chords[chord_counter],0.5)
	 else
	  pdist = add_chord(pdist,bebop_chords[chord_counter],0.5)
	 end
 end

 pdist_sum = 0
 for i=1,dist_size do
  if (pdist[i] < 0) pdist[i]=0
  pdist_sum += pdist[i]
 end
 for i=1,dist_size do
  pdist[i] /= pdist_sum
 end

 --select from distribution
 randnote = rnd(1)
 sum = 0
 for i=1,dist_size do
  sum += pdist[i]
  if (sum >= randnote) then
   return i+sfx_offset
  end
 end
 
 return 1+sfx_offset
end

function add_chord(dist,chord,value)
 if beat == blues_beat then
  --blues chords
  if chord==1 then
   dist[1] += value
   dist[2] += value
   dist[5] += value
   dist[7] += value
   dist[8] += value
   dist[11] += value
   dist[13] += value
  elseif chord==4 then
   dist[1] += value
   dist[3] += value
   dist[7] += value
   dist[9] += value
   dist[13] += value 
  elseif chord==5 then
   dist[5] += value
   dist[6] += value
   dist[11] += value
   dist[12] += value
  end
 else
  --bebop chords
  if chord==1 then
   dist[1] += value
   dist[3] += value
   dist[5] += value
   dist[8] += value
   dist[9] += value
   dist[11] += value
   dist[13] += value
   dist[16] += value
  elseif chord==2 then
   dist[2] += value
   dist[4] += value
   dist[7] += value
   dist[10] += value 
   dist[12] += value
   dist[15] += value
  elseif chord==4 then
   dist[1] += value
   dist[4] += value
   dist[7] += value
   dist[9] += value
   dist[12] += value 
   dist[15] += value
   dist[17] += value
  elseif chord==5 then
   dist[2] += value
   dist[5] += value
   dist[8] += value
   dist[10] += value
   dist[13] += value
   dist[16] += value
  end
 end
 return dist
end

function move_note(note)
	h_physics(note)
	if(h_collision(note) and screen==1) destroy_note(note)
	v_physics(note)
	if(v_collision(note) and screen==1) destroy_note(note)
end

function move_trumpet(tpt)
 h_physics(tpt)
 h_collision(tpt)
 v_physics(tpt)
 if (v_collision(tpt) and tpt.sprite < 136 and on_ground(tpt)) then
  tpt.sprite += 8
  tpt.frame = 0
 end
end

function move_accidental(accidental)
 if accidental.dx~=0 then
  accidental.x += accidental.dir*accidental.dx
  accidental.y = accidental.base_y + accidental.amp*sin(accidental.x*accidental.scale)
 end 
 
 if accidental.x>304 or accidental.x<0 then
  del(accidentals, accidental)
 end
end

function standard_physics(obj)
 h_physics(obj)
 h_collision(obj)
 v_physics(obj)
 v_collision(obj)
end

function destroy_note(note)
 shatter_effect = {}
 shatter_effect.x = note.x+avg(note.x_col[1],note.x_col[2]-4)
 shatter_effect.y = note.y+avg(note.y_col[1],note.y_col[2]-4)
 shatter_effect.sprite=188
 add(shatter, shatter_effect)
 del(notes, note)
end

function avg(a,b)
 return (a+b)/2
end

--orientation=0 for low notes
--orientation=1 for high notes
function create_note(dx,dy,orientation)
 n = flr(rnd(6))
 x_col = {0,3}
 y_col = {0,7}
 if (n == 1 or n == 4) x_col[2] = 7
 if (n == 2) x_col[2] = 5
 if (n == 5) x_col[2] = 4
 x = p.x
 if (p.dir == 1) x+=12
 y = p.y-16

 if (orientation == 1) n+=6
 
 note = create_object(176+n,x,y,p.dir*dx,dy,x_col,y_col)
 add(notes,note)
end

function spawn_enemies()
 if (#tpt_spawns+#trumpets <= max(sqrt(min(game_points,500)/3),3) and rnd(1) > .75) then
  tpt_spawn = create_trumpet_spawn()
  add(tpt_spawns, tpt_spawn)
 end
 if beat == bebop_beat then
  if #accidentals < 1 and rnd(1) > .95 then
   create_accidental()
  end
 end 
end

function generate_spawn_point()
 point = {}
 point.x = generate_spawn_coord(spawn.x)
 point.y = generate_spawn_coord(spawn.y)
 return point
end

function generate_spawn_coord(bounds)
 return rnd(bounds[2]-bounds[1])+bounds[1]
end

function create_trumpet_spawn()
 point = generate_spawn_point()
 while (close_to_player(point)) do
  point = generate_spawn_point()
 end
 dx = rnd(1.5)+1
 if (point.x > p.x) dx*=-1
 --if (rnd(1) < .5) dx*=-1
 dy = rnd(3)-3
 return create_object(144,point.x,point.y,dx,dy,{1,6},{1,6})
end

function create_trumpet(tpt_spawn)
 n = flr(rnd(8))
 del(tpt_spawns, tpt_spawn)
 return create_object(128+n,tpt_spawn.x,tpt_spawn.y,tpt_spawn.dx,tpt_spawn.dy,{1,6},{1,6})
end

function close_to_player(spawn)
 dx = p.x+7.5-spawn.x
 dy = p.y-7.5-spawn.y
 dst = sqrt(dx*dx+dy*dy)
 return dst < 32
end

function create_accidental()
 spr_offset = flr(rnd(3))
 x_col = {0,4}
 y_col = {0,7}
 if spr_offset==0 then
  x_col[2] = 5
 end
 --y:112-128
 spr_y = 112 + flr(rnd(17))
 spr_dx = 1 + rnd(.4)
 accidental = create_object(160+spr_offset,0,spr_y,spr_dx,0,x_col,y_col)
 if rnd(1) > 0.5 then
  accidental.x = 304
  accidental.dir = -1
 end
 accidental.base_y = accidental.y
 accidental.scale = rnd(.01) + 0.005
 accidental.amp = flr(rnd(5)) + 6
 add(accidentals, accidental)
end

function create_object(sprite,x,y,dx,dy,x_col,y_col)
 object = {}
	object.sprite=sprite
	object.x=x
	object.y=y
	object.dx=dx
	object.dy=dy
	object.x_col=x_col
	object.y_col=y_col
	
	--default values for simple objects
	object.ddx=0
	object.max_dx=7
	object.player=false
	object.dir=1
	object.frame=0
	
	return object
end

function update_animations()
 p.frame += 1
 p.frame %= 32
 
 if (p.state == 2 and on_ground(p)) p.state=0
 if (p.state == 0) p.sprite=0
 if (p.state == 1) then
  if (p.frame < 32) p.sprite=0
  if (p.frame < 24) p.sprite=4
  if (p.frame < 16) p.sprite=0
  if (p.frame < 8) p.sprite=2 
  if (against_wall(p,p.dir)) p.sprite=0 p.state=0
 end
 if (p.state == 2) p.sprite=6
 
 foreach(trumpets,update_tpt_animation)
end

function update_tpt_animation(tpt)
 --fallen trumpet
 if tpt.sprite >= 136 then
 	tpt.frame += 1
 	if tpt.frame > 120 then
 	 del(trumpets, tpt)
 	 game_points+=1
 	 check_msg_thresholds(1)
 	end
  return
 end
  
 --active trumpet
 tpt.frame = (tpt.frame+1)%20
 tpt.sprite = 128+flr(tpt.frame/2.5)
end

function update_effects()
 foreach(shatter,update_shatter)
 foreach(tpt_spawns,update_tpt_spawn)
end

function update_shatter(s)
 s.sprite += 1
 if (s.sprite > 191) del(shatter,s)
end

function update_tpt_spawn(tpt_spawn)
 tpt_spawn.frame += 1
 if (tpt_spawn.frame > 15) then
  tpt = create_trumpet(tpt_spawn)
  add(trumpets, tpt)
  del(tpt_spawns, tpt_spawn)
 else
  tpt_spawn.sprite = 144+tpt_spawn.frame
 end
end

function update_music()
	counter += 1
	if (counter >= beat) then
		note_counter += 1
		if (note_counter > 4) then
			chord_counter += 1
			if beat == blues_beat then
				if (chord_counter == 9) music(1,0)
				if (chord_counter == 17) music(2,0)
				if (chord_counter > #blues_chords) then
			  chord_counter = 1
			  music(0,0)
			 end
			else
			 if (chord_counter == 9) music(4,0)
			 if (chord_counter == 17) music(5,0)
			 if (chord_counter > #bebop_chords) then
			  chord_counter = 1
			  music(3,0)
			 end
			end
			note_counter = 1
		end
		counter = 0
	end
end

function update_drums()
 if counter == 0 and breath<14 then
  sfx(20,1)
  kick_counter = 4
 end
 if counter == 0 or counter == flr(2/3*beat) then
  if play_snare then
   sfx(19,2)
   snare_counter = 4
   play_snare = false
  elseif play_hihat then
   sfx(21,2)
   hihat_counter = 4
   play_hihat = false
  end
 end
end

function freeze_objects()
 for tpt in all(trumpets) do
  if (tpt.sprite < 136) then
	  tpt.sprite += 8
   tpt.frame = 0
  end
  tpt.dx = 0
	 tpt.dy = 0
	 tpt.ddx = 0
 end
 for note in all(notes) do
	  note.dx = 0
	  note.dy = 0
	  note.ddx = 0
 end
 for accidental in all(accidentals) do
  accidental.dx = 0
  accidental.dy = 0
  accidental.ddx = 0
 end
end

function update_msgs()
 for i=1,5 do
  msgs[i].counter = max(msgs[i].counter - 1, 0)
 end
end

function check_msg_thresholds(change)
 for i=1,#msg_thresholds do
  if game_points>=msg_thresholds[i] and game_points-change<msg_thresholds[i] then
   create_msgs()
   return
  end
 end
end

function create_msgs()
 msg_chance = .333
 if game_points>=500 then
  msg_chance = .5
 elseif game_points>=1000 then
  msg_chance = .667
 end
 
 --musicians
 if rnd(1) < msg_chance then
  if rnd(1) < .5 then
	  msgs[1].text = rnd_msg(bass_msgs)
 	 msgs[1].counter = 240
 	 msgs[2].counter = 0
 	else
 	 msgs[2].text = rnd_msg(drum_msgs)
 	 msgs[2].counter = 240
 	 msgs[1].counter = 0
 	end
 end
 
 --bartender
 if rnd(1) < msg_chance then
  msgs[3].text = rnd_msg(bar_msgs)
  msgs[3].counter = 240
 end
 
 --listeners
 if rnd(1) < msg_chance then
  if rnd(1) < .5 then
	  msgs[4].text = rnd_msg(drink_msgs)
 	 msgs[4].counter = 240
 	 msgs[5].counter = 0
 	else
 	 msgs[5].text = rnd_msg(hat_msgs)
 	 msgs[5].counter = 240
 	 msgs[4].counter = 0
 	end
 end
end

function rnd_msg(msg_list)
 return msg_list[flr(rnd(#msg_list))+1]
end

function _update()
 if screen == 0 then
  if not title_transition then	 
  title_counter = (title_counter+1)%120 
	  if not show_instructions then
	  
	   if btnp(1) then
	    title_direction = 1
     title_max_x = 60
     title_sprite = 0
    end
   
    if btnp(0) then
     title_max_x = 52
     title_direction = 0
     title_sprite = 8
    end
   
    if btnp(2) then
     p.sax = (p.sax + 1) % 5
     while not sax_colors[p.sax+1] do
      p.sax = (p.sax + 1) % 5
     end
    elseif btnp(3) then
     p.sax = (p.sax - 1) % 5
     while not sax_colors[p.sax+1] do
      p.sax = (p.sax - 1) % 5
     end
    end
   
    if btnp(4) then
     music(-1)
     title_transition = true
     sfx(19,3)
    elseif btnp(5) then
     show_instructions = true
     instruction_page = 1
    end
   else
    if btnp(4) or btnp(5) then
     instruction_page += 1
     if instruction_page > 2 then
      show_instructions = false
     end
    end
   end
  else
   --walk off screen
   if (title_max_x <= 28 and (title_max_x-4)%12 == 0) or (title_max_x >=96 and (title_max_x+3)%9 == 0) then
    sfx(21,1)
   end
   title_max_x += title_direction*2-1
   
   --title_max_x += 1
   if title_max_x <= -68 or title_max_x >= 168 then
    screen = 1
    reset(title_direction)
    if title_direction == 0 then
     title_max_x = 52
     title_sprite = 8
    else
     title_max_x = 60
     title_sprite = 0
    end
    title_transition = false
    title_counter = 0
   else
   --set sprite
    if title_direction == 0 then
     if title_max_x > 40 or (title_max_x <= 4 and title_max_x > -8) then
      title_sprite = 10
     elseif (title_max_x <= 28 and title_max_x > 16) or title_max_x <= -20 then
      title_sprite = 12
     else
      title_sprite = 8
     end
    else
     if title_max_x < 69 or (title_max_x >= 96 and title_max_x < 105) or title_max_x >= 132 then
      title_sprite = 2
     elseif (title_max_x >= 78 and title_max_x < 87) or (title_max_x >= 114 and title_max_x < 123) then
      title_sprite = 4
     else
      title_sprite = 0
     end
    end
   end
  end
 end

 if screen == 1 then  
  --update the state of the world
  foreach(notes, move_note)
  foreach(trumpets, move_trumpet)
  foreach(accidentals, move_accidental)
    
  --player actions
	 --horizontal movement
	 p_on_ground = on_ground(p)
	 if (p_on_ground) then
	 	if (btn(0) and not against_wall(p,-1)) run_p(-1)
	 	if (btn(1) and not against_wall(p,1)) run_p(1)
	 	if (not btn(0) and not btn(1)) then
	 		p.ddx=0
	 	 p.state=0
	 	 p.frame=0
	 	end
	 else
	  if (btn(0)) air_drift(-1)
	 	if (btn(1)) air_drift(1)
	 	if (not btn(0) and not btn(1)) p.ddx=0
	 end
	
 	--jump
 	if (on_ground(p)) then
	  if (p.jump_reset) then
		 	if (btn(4) and p.jump_reset) then
			 	p.start_jump=true
			 	p.jump_reset = false
			 end
		 else
			 if (not btn(4)) p.jump_reset = true
		 end
	 end
	
	 --blow
	 if (btn(5)) then
	 	blow()
	 else
	 	breath = min(breath+1,40)	 	
	 end

  --update player position
	 standard_physics(p)
	
	 check_object_collisions()
  update_effects()
	
	 --create new enemies
	 spawn_enemies()
	
	 --final state updates
	 update_drums()
	 update_animations()
	 update_music()
	 update_msgs()
	 
	 --gameover check
	 if set_gameover then
	  music(-1,0)
	  music(6)
   screen=2
   freeze_objects()
   set_gameover = false
	 end
 end
 
 if screen == 2 then
  if gameover_transition then
   foreach(notes, move_note)
   foreach(trumpets, move_trumpet)
   gameover_counter += 1
   if gameover_counter > 244 then
    gameover_transition = false
   end
  else
   --wait for input
   if btnp(4) or btnp(5) then
    if beat == blues_beat then
     if game_points > top_score_blues then
      top_score_blues = game_points
      dset(0,top_score_blues)
     end
    else
     if game_points > top_score_bebop then
      top_score_bebop = game_points
      dset(1,top_score_bebop)
     end
    end
    screen = 0
    gameover_counter = 0
    gameover_transition = true
    music(7)
   end
  end
 end
end

function update_camera()
 newc = {}
 --center camera at the middle of the hitbox
	newc.x = p.x-64-4*p.dir+8
	newc.y = p.y-96
	
	camera_follow[camera_delay+1] = newc
	for i=1,camera_delay do
		camera_follow[i] = camera_follow[i+1]
	end
	
	camera(camera_follow[1].x,camera_follow[1].y)
end

function update_background()
 --sign flicker
 if mget(5,7) == 77 then
  if rnd(1) < 0.05 then
   mset(5,7,109)
   mset(6,7,110)
   mset(7,7,111)
   mset(5,8,125)
   mset(6,8,126)
   mset(7,8,127)
  end
 else
  if rnd(1) < 0.1 then
   mset(5,7,77)
   mset(6,7,78)
   mset(7,7,79)
   mset(5,8,93)
   mset(6,8,94)
   mset(7,8,95)
  end
 end
 
 --background characters
 if chord_counter%2 == 0 then
  if (note_counter == 3 and not arm_in) arm_in = true
 else
  if (note_counter == 3 and arm_in) arm_in = false
 end
 
 if chord_counter%2 == 0 then
  if (not head_nod) head_nod = true
 else
  if (head_nod) head_nod = false 
 end
end

function draw_background_chars()
 --bass player
 spr(192,88,80)
 bass_frame=(chord_counter-1)*4+note_counter
 bass_sprite=193
 if beat == blues_beat then
  if blues_bass_pos[bass_frame] == 0 then
   bass_sprite=194
  end
  if blues_bass_pos[bass_frame] == 2 then
   bass_sprite=241
  end
 else
  if bebop_bass_pos[bass_frame] == 0 then
   bass_sprite=194
  end
  if bebop_bass_pos[bass_frame] == 2 then
   bass_sprite=241
  end
 end
 spr(bass_sprite,96,80)
 if bass_frame%2 == 1 then
	 spr(208,88,88)
	else
	 spr(240,88,88)
	end
	spr(209,96,88)
	spr(224,88,96)
	spr(225,96,96)
	
	--drummer
	spr(200,116,80)
	if snare_counter > 0 then
	 spr(248,116,88)
	 snare_counter -= 1
	else
	 spr(216,116,88)
	end
	if kick_counter > 0 then
	 spr(245,108,96,2,1)
	 kick_counter -= 1
	else
	 spr(231,108,96,2,1)
	end
	if hihat_counter > 0 then
	 spr(201,108,80)
	 spr(247,108,88)
	 hihat_counter -= 1
	else
	 spr(199,108,80)
	 spr(215,108,88)
	end

	--hat tipper
	if head_nod then
		spr(195,192,80,2,2)
	else
	 spr(210,192,80)
	 spr(244,200,80)
	 spr(242,192,88,2,1)
	end
	
	--drink nurser
 if arm_in then
  spr(197,184,80,1,2)
 else
  spr(198,184,80,1,2)
 end

 --bartender
 tender_left_x = 144
 tender_right_x = 152
 tender_flipped = false
 if p.x>=148 then
		tender_flipped = true
		tender_left_x = 152
		tender_right_x = 144
 end
 spr(217,144,80,2,1,tender_flipped)
 spr(233,tender_left_x,88,1,1,tender_flipped)
 if note_counter%2==0 then
  spr(234,tender_right_x,88,1,1,tender_flipped)
 elseif note_counter==1 then
  spr(235,tender_right_x,88,1,1,tender_flipped)
 else
  spr(251,tender_right_x,88,1,1,tender_flipped)
 end
 spr(249,144,96,2,1)
 spr(203,136,88,1,2)
 spr(203,160,88,1,2,true)
 
 --legs
	if bass_frame%2==1 then
 	spr(226,192,96)
 	spr(230,184,96,1,1)
 else
  spr(227,192,96)
  spr(229,184,96,1,1)
 end
	spr(228,200,96)
 
end

function draw_notes()
 foreach(notes, draw_spr)
end

function draw_effects()
 foreach(shatter, draw_spr)
 foreach(tpt_spawns, draw_spr)
end

function draw_enemies()
 foreach(trumpets, draw_spr)
 foreach(accidentals, draw_spr)
end

function draw_spr(s)
 spr(s.sprite, s.x, s.y)
end

function draw_hud()
 camera()
 color(6)
 rect(2,2,44,8)
 rect(83,2,125,8)
 
 --meters
 
 color(2)
 rect(3,3,3+health,7)
 if (health >= 1) then
  color(8)
  rectfill(3,3,3+health-1,6)
 end
 
 color(1)
 rect(124-breath,3,124,7)
 if (breath >= 1) then
 	color(12)
 	rectfill(124-breath+1,3,124,6)
 end

 --score 
 print_centered_n(game_points,65,4,3)
 print_centered_n(game_points,64,3,11)
 
end

function print_centered(text,tx,ty,tcol,numspecial)
 if tcol == nil then
 	tcol = 6
 end
 if numspecial == nil then
  numspecial = 0
 end
 print(text, tx-#text*2-numspecial*3/2, ty, tcol)
end

--print centered for numbers
function print_centered_n(number,tx,ty,tcol)
 temp_number = number
 ndigits = 1
 while (temp_number > 9) do
  temp_number = flr(temp_number/10)
  ndigits += 1
 end
 print(number, tx-ndigits*2, ty, tcol)
end

function set_sax_color()
 if p.sax == 1 then
		pal(9,13)
		pal(10,7)
	elseif p.sax == 2 then
	 pal(9,4)
	 pal(10,9)
	elseif p.sax == 3 then
	 pal(9,2)
	 pal(10,0)
	elseif p.sax == 4 then
	 pal(10,7)
	 pal(9,15)
	end
end

function reset_sax_color()
 pal(9,9)
 pal(10,10)
end

function instruction(page)
 rectfill(11,11,119,119,0)
 rectfill(10,10,118,118,1)
 rect(12,12,116,116,6)
 if page == 1 then
  palt(11,true)
  palt(0,false)
  spr(0,18,18,2,2)
  palt(11,false)
  palt(0,true)
  print("guide max the sax",42,20,6)
  print("through his solo",42,28,6)
  
  spr(137,18,42)
  spr(134,26,42)
  print("avoid trumpets",42,44,6)
  
  spr(180,18,58)
  spr(187,26,58)
  print("protect max by",42,60,6)
  print("playing notes",42,68,6)
  
  spr(160,18,84)
  spr(161,26,84)
  print("beware of extra",42,86,6)
  print("bebop accidentals",42,94,6)
  
  print("1/2",100,106,6)
 else
  print("title screen",18,18,6)
  print("‹‘",22,26,6)
  print("select genre",42,26,6)
  print("”ƒ",22,34,6)
  print("select saxophone",42,34,6)
  print("playing a solo",18,50,6)
  print("‹‘",22,58,6)
  print("move",42,58,6)
  print("Ž/z",22,66,6)
  print("jump",42,66,6)
  print("—/x",22,74,6)
  print("blow",42,74,6)
  print("”ƒ",22,82,6)
  print("angle notes",42,82,6)
  print("2/2",100,106,6)
  
  palt(11,true)
  palt(0,true)
  spr(192,18,90,2,3)
  spr(199,34,90,2,3)
  palt(0,true)
  palt(11,false)
 end
end

function draw_comments()
 for i=1,5 do
  if msgs[i].counter > 0 then
   msg_y = 72
   if i==1 then
    msg_x = 93
    msg_color = 8
   elseif i==2 then
    msg_x = 116
    msg_color = 9
   elseif i==3 then
    msg_x = 153
    msg_color = 6
    for i=1,5 do
     if i~=3 and msgs[i].counter > 0 then
      msg_y = 64
     end
    end
   elseif i==4 then
    msg_x = 188
    msg_color = 14
   else
    msg_x = 199
    msg_color = 15
   end
   print_centered(msgs[i].text, msg_x, msg_y, msg_color)
  end
 end
end

function _draw()

 cls()

 if screen == 0 then
  --render title screen text
  print_centered("saxophight",65,2,4)
  print_centered("saxophight",64,1,10)
  print_centered("help max the sax make his",64,8)
  print_centered("way in the cutthroat world of",64,14)
  print_centered("underground jazz",64,20)
  
  blues_color1 = 5
  blues_color2 = 6
  bebop_color1 = 5
  bebop_color2 = 6
  
  if title_direction == 0 then
   blues_color1 = 1
   blues_color2 = 12
  else
   bebop_color1 = 2
   bebop_color2 = 8
  end
  
  print_centered("blues",33,39,blues_color1)
  print_centered("blues",32,38,blues_color2)
  print_centered_n(top_score_blues,33,46,blues_color1)
  print_centered_n(top_score_blues,32,45,blues_color2)
  
  print_centered("bebop",97,39,bebop_color1)  
  print_centered("bebop",96,38,bebop_color2)
  print_centered_n(top_score_bebop,97,46,bebop_color1)
  print_centered_n(top_score_bebop,96,45,bebop_color2)
		
		--render title screen scene
		for i=0,16 do
			spr(64,i*8,88,1,2)
			spr(97,i*8,104)
		end
		
		--render saxophone selection
		sax_msg = "saxophone: "
		if p.sax == 1 then
		 sax_msg = sax_msg.."silver"
		elseif p.sax == 2 then
		 sax_msg = sax_msg.."bronze"
		elseif p.sax == 3 then
		 sax_msg = sax_msg.."black lacquer"
		elseif p.sax == 4 then
		 sax_msg = sax_msg.."grafton"
		else
		 sax_msg = sax_msg.."classic"
		end
			
		print_centered(sax_msg,63,112,6)

		--render instructions
		if not title_transition then
		 if title_counter >= 30 and title_counter < 60 then
		  print_centered("press Ž/z to start",63,120,6,1)
		 elseif title_counter >= 90 then
		 	print_centered("press —/x for instructions",63,120,6,1)
		 end
		end
		
		--render title screen max
		palt(0,false)
		palt(11,true)
		set_sax_color()
		if title_direction == 0 then
		 spr(title_sprite,title_max_x,72,2,4)
		else
		 spr(title_sprite,title_max_x,72,2,4)
		end
		pal(9,9)
		pal(10,10)
		palt(0,true)
		
		--render ready text
		if title_max_x <= -20 and title_max_x > -32 then
		print_centered("one           ",64,64,6)
		elseif title_max_x <= -32 and title_max_x > -44 then
		 print_centered("one more      ",64,64,6)
		elseif title_max_x <= -44 and title_max_x > -56 then
		 print_centered("one more time ",64,64,6) 
		elseif title_max_x <= -56 then
 		print_centered("one more time!",64,64,6)
		end
		if title_max_x >= 132 and title_max_x < 141 then
		print_centered("one           ",64,64,6)
		elseif title_max_x >= 141 and title_max_x < 150 then
		 print_centered("one more      ",64,64,6)
		elseif title_max_x >= 150 and title_max_x < 159 then
		 print_centered("one more once ",64,64,6)
		elseif title_max_x >= 159 then
		 print_centered("one more once!",64,64,6)
		end

  --render instruction page
		if show_instructions then
   instruction(instruction_page)
  end
 elseif screen == 1 then
  --render background
  update_camera()
  update_background()
	 map(0,0,0,0,48,32)
  
  --render background characters
  palt(0,false)
  palt(11,true)
  draw_background_chars()
  draw_comments()
	 
	 --render max the sax
	 sprite = p.sprite
	 set_sax_color()
	 if (p.dir == -1) sprite+=8
	 for shift=0,48,16 do
	 	spr(48-shift+sprite, p.x, p.y-shift/2)
	 	spr(49-shift+sprite, p.x+8, p.y-shift/2)
	 end
	 reset_sax_color()
	 
	 palt(0,true)
	 
	 --render the brass enemies
	 draw_enemies()
	 
	 --render music notes
	 draw_notes()
	 
	 --render effects
	 draw_effects()
  
  --render hud
  draw_hud()
 elseif screen == 2 then
  if gameover_counter < 154 then
   --render (mostly) frozen scene
   update_camera()
	  map(0,0,0,0,48,32)

   palt(0,false)
   palt(11,true)
   draw_background_chars()
	  sprite = p.sprite
	  if (p.dir == -1) sprite+=8
	  for shift=0,48,16 do
	  	spr(48-shift+sprite, p.x, p.y-shift/2)
	  	spr(49-shift+sprite, p.x+8, p.y-shift/2)
	  end
 	 palt(0,true)
	  draw_enemies()
	  draw_notes()
   draw_hud()
  
   --render transition effects
   if gameover_counter > 90 then
    rectfill(0,0,128,(gameover_counter-90)*2,0)
   end
  else
   --render phrase and final score
   print_centered("final score",64,48,5)
   print_centered("final score",63,47,6)
   if gameover_counter > 184 then
    print_centered_n(game_points,64,56,3)
    print_centered_n(game_points,63,55,11)
   end
   if gameover_counter > 214 then
    if beat == blues_beat then
     if game_points > top_score_blues then
      print_centered("top performance!",64,64,4)
      print_centered("top performance!",63,63,10)
     end
     if not sax_colors[2] then
      if game_points >= 500 then
       sax_colors[2] = true
       new_unlock = true
      end
     end
     if not sax_colors[4] then
      if game_points >= 1000 then
       sax_colors[4] = true
       new_unlock = true
      end
     end
    else
     if game_points > top_score_bebop then
      print_centered("top performance!",64,64,4)
      print_centered("top performance!",63,63,10)
     end
     if not sax_colors[3] then
      if game_points >= 500 then
       sax_colors[3] = true
       new_unlock = true
      end
     end
     if not sax_colors[5] then
      if game_points >= 1000 then
       sax_colors[5] = true
       new_unlock = true
      end
     end
    end
    if new_unlock then
     print_centered("new sax unlocked!",64,72,4)
     print_centered("new sax unlocked!",63,71,10)
    end
   end
   if gameover_counter > 244 then
    if beat == blues_beat then
     replay_text_color1 = 1
     replay_text_color2 = 12
    else
     replay_text_color1 = 2
     replay_text_color2 = 8
    end
    if not gameover_msg_set then
	    gameover_msg = rnd_msg(gameover_msgs)
	    gameover_msg_set = true
	   end
    print_centered(gameover_msg,64,80,replay_text_color1)
    print_centered(gameover_msg,63,79,replay_text_color2)
   end
  end
 end
end
__gfx__
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb555bbbbb
bbbbb555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb54444bbbbbbbbbbbbbbb555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb44445bbbb
bbbb54444bbbbbbbbbbbb555bbbbbbbbbbbbb555bbbbbbbbbbbb54444bbbbbbbbbbbbbb44445bbbbbbbbbbbb555bbbbbbbbbbbbb555bbbbbbbbbbbb44445bbbb
bbbb44444bbbbbbbbbbb54444bbbbbbbbbbb54444bbbbbbbbbbb44444aabbbbbbbbbbbb44444bbbbbbbbbbb44445bbbbbbbbbbb44445bbbbbbbbbaa44444bbbb
bbbb77744aabbbbbbbbb44444bbbbbbbbbbb44444bbbbbbbbbb11774bbb9abbbbbbbbaa447711bbbbbbbbbb44444bbbbbbbbbbb44444bbbbbbba9bbb47711bbb
bbb111577bb9abbbbbbb77744aabbbbbbbbb77744aabbbbbbb1111577bbb9bbbbbba9bb7751111bbbbbbbaa447711bbbbbbbbaa44777bbbbbbb9bbb7751111bb
bb1111517bbb9bbbbbb111577bb9abbbbbb111577bb9abbbbb1611517bbb9abbbbb9bbb7151161bbbbba9bb7751111bbbbba9bb775111bbbbba9bbb7151161bb
b61611511bbb9abbbb1111517bbb9bbbbb1111517bbb9bbbb61611511bbbaabbbba9bbb15116116bbbb9bbb7151161bbbbb9bbb7151111bbbba44bb55111616b
b61161151bbbaabbb61611511bbbaabbb6161151bbb9abbbb61161151bb9abbbbba44bb51161116bbbba9bbb5111616bbba44bb55116116bbbb415111116016b
b61116115bb9abbbb61161151bb9abbbb6116115bbbaabbbb61116115bb9abbbbbb415111610116bbbba44bb1116016bbbb415111161116bbbba15611160116b
1611016111b9abbbb61116115bb9abbbb6106111bb9abbbb1611016111544bbbbbba156661061161bbbb41511160116bbbba15666611116bbbbba01666061161
1611601666514bbb1611016611b14bbb161106111b9abbbb1611601666514bbbbbbba90000161161bbbba15666061161bbbba90000061161bbbba90000161161
1611610000514bbb1611600166514bbb161160666514bbbb1611610000abbbbbbbbba90561161161bbbbba0000161161bbbba90561161161bbbbba9561161161
1611611659abbbbb16116110009bbbbb161161000514bbbb6111611699abaabbbbbbba9561161161bbbbba9561161161bbbbba9561161161bbaaba9561161116
1611611599abaabb1611611699abaabb161161159abbbbbb6116111599aa11abbbaaba9551161161bbbbbba561161161bbaaba9561161161ba11aa9551161116
1611611599aa11ab16111615999a11ab611161199abaabbb11161115099aa1abba11aa9051161161bbbaaba561161161ba11a99551161161ba1aa99055116111
b0116100099aa1abb1611615099aa1ab61161159aaa11abb11611000bb99aabbba1aa99b0016110bbba11aa951116116ba1aa99051611610bbaa99bb00011611
b1000011bb99aabbb00116100b99aabbb01610009aaa1abbb0000111bbbbbbbbbbaa99bb1100001bbba1aaa90001610bbbaa99000161100bbbbbbbbb11100000
b1111111bbbbbbbbb11000011bbbbbbbb1000111099aabbbb1111111bbbbbbbbbbbbbbbb1111111bbbbaa9901110001bbbbbbbb11000011bbbbbbbbb0111111b
b1111111bbbbbbbbb11111111bbbbbbbb1111111bbbbbbbbb1111110bbbbbbbbbbbbbbbb1111111bbbbbbbbb1111111bbbbbbbb11111111bbbbbbbbb1011111b
bb111101bbbbbbbbb111101111bbbbbbbb111110bbbbbbbbbb111111bbbbbbbbbbbbbbbb101111bbbbbbbbbb011111bbbbbbbb111101111bbbbbbbb1101111bb
bb111101bbbbbbbbb1111b0111bbbbbbbbb11111bbbbbbbbbbb011111bbbbbbbbbbbbbbb101111bbbbbbbbbb11111bbbbbbbbb1110b1111bbbbbbb11101111bb
bb111101bbbbbbbbb1111bb111bbbbbbbbb011111bbbbbbbbbbb001111bbbbbbbbbbbbbb101111bbbbbbbbb111110bbbbbbbbb111bb1111bbbbbb111101111bb
bb111011bbbbbbbbb111bbbb111bbbbbbbb100111bbbbbbbbbbb111111bbbbbbbbbbbbbb110111bbbbbbbbb111001bbbbbbbb111bbbb111bbbbbb111110111bb
bb111011bbbbbbbbb111bbbb111bbbbbbb1110111bbbbbbb551111111bbbbbbbbbbbbbbb110111bbbbbbbbb1110111bbbbbbb111bbbb111bbbbbbb111101115b
bb111011bbbbbbbb111bbbbb111bbbbbbb111bb111bbbbbb55111100bbbbbbbbbbbbbbbb110111bbbbbbbb111bb111bbbbbbb111bbbbb111bbbbbbbbb101115b
bb111011bbbbbbbb111bbbbb111bbbbbb111bbb111bbbbbb5dbbb011bbbbbbbbbbbbbbbb110111bbbbbbbb111bbb111bbbbbb111bbbbb111bbbbbbbbbbb1115b
bb111071bbbbbbbb111bbbbb171bbbbbb111bbb111bbbbbb5bbbb171bbbbbbbbbbbbbbbb170111bbbbbbbb111bbb111bbbbbb171bbbbb111bbbbbbbbbbb1115b
bb171055dbbbbbbb571bbbbbb55dbbbbb555bbb175d5bbbbbbbbb555dbbbbbbbbbbbbbbd550171bbbbbb5d571bbb555bbbbbd55bbbbbb175bbbbbbbbbbb171bb
bb555d0555bbbbbb555bbbbbb5555bbbb5555bb5555bbbbbbbbbb55555bbbbbbbbbbbb5550d555bbbbbbb5555bb5555bbbb5555bbbbbb555bbbbbbbbbbd555bb
bb55555bbbbbbbbbb555bbbbbbbbbbbbbbbbbbb55bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb55555bbbbbbbbb55bbbbbbbbbbbbbbbbbbb555bbbbbbbbbb55555bb
00000000000000005555555555555555555555550500000000000500000000000000005500000000000500000000000000050000000000000000000000000000
000000000000000000000000000000005aaaaaa50500000000000500000000000000550055000000555550000000000000005000000000000000000000000000
000000000000000015511551155115515aaaaaa50500000000000500000000000055000005000000000005005555555500000500000000000000000011110000
000000000000000015551555155515555aaaaaa50500000000000500000000005500000005000000000000500000000000000500000000000000111112211000
000000000000005511551155115511555aaaaaa5050000000000050000000055000000000500000000000005000000000000005000000000111112212a921000
000000000000550000000000000000005aaaaaa505000000000005000000550000000000050000000000000000000000000000500000111112212a92a9921000
004000400055000055555555555555555aaaaaa50500000000000500005500000000000005000000000000000000000000000050001112212a92a99222921000
000400045500000055544445000000005aaaaaa5050000000000050055000000000000000500000000000000000000000000000501122a92a992229222921000
400040004005000052544445000500005aaaaaa50000000000000000000500000000000055555555000000550000000500055555012a99229292a992a9921000
040004000400500052544445000050005aaaaaa50000000000000000000500000000055500000000000055000000005055550000112299229992992299211000
004040400040050052544445000005005aaaaaa5000000000000000000050000000005000000000055550000000005000000000012a2992a9292921292110000
040404040404005052544445000000505aaaaaa50000000000000000000500000000050000000000000500000000050000000000129999292292922292211000
404440444044400552544445000000055aaaaaa55555555555555555000500000000050000000000000500000000500000000000112992292292999299921000
440444044404440052544445000000005aaaaaa50000000000000500000500000000050000000000000500000000500000000000011221121121222122211000
444044404440444052544445004000405aaaaaa50000000000000500000500000000050000000000000500000000500000000000001111111111111111110000
04440444044404445254444500040004555555550000000000000500000500000000050000000000000500000005000000000000000000000000000000000000
52544445404440445254444500005000000050000000000000000500000000500000000000000000000000000000000000050000000000000000000000000000
52544445440444045254444500005020222050000000000000000500000000050000000055555555000000000000000000050000000000000000000000000000
55544445220222022554444500005002222050000000000000000500000000005000000000000000000000005555555500050000000000000000000000000000
05555555000000000055555500005000000050000000000000000500000000000500000000000000000000000000000000050000000000000000000001100000
55555555555555555555555500005000000050000000000000000500000000000050000000000000000000000000000000050000000000000000011019910000
00000000000000000000000000005000000050000000000000000500000000000005000000000000500000000000000000050000000000000110199199910000
00000000000000000000000000005000000050000000000000000500000000000000500000000000050000000055555500050000000001101991999111910000
00000000000000000000000000005000000050005555555555555500000000000000050000000000005000005500000055550000000119919991119111910000
55550000555555550000050000000000000000000500000000000055000000000000005000000005000500000000000055555555001999119191992199210000
00050000555555550000050022220020222002220500000000005500000000000000000500000005000500000000000000000005001199119991921192100000
55550000555555555000050022022002222022025500000000550000000000000000000000000005000500005555555500000000019199192191910191000000
55550000555555550500050000000000000000000500000055000000000000000000000000000005000500000000000000000000019992191191911191100000
55555555555555550050050000000000000000000050000000000000555555555555555500000005000500000000000000000000001921191191999199910000
55550005555555550005050020022220022222020005000000000000000000000000000000000005000500000000000000000000000110010010111011100000
55555555555555550000550000222020002220200000500000000000000000000000000000000005000500005000000000000000000000000000000000000000
55555555555555550000050000000000000000000000050000000000000000000000000000000005555555550550000000000000000000000000000000000000
0000000000000a900009900009a00000000000000000000000006000000000000000000000000000000000000000000000000000000000000000600000006000
0000000000000a1900a11a00911a0000000000000000a06000aaa0000600000000000000000000000000000000000000000000000000000000aaa00000aaa000
009000a90000aaaa000aa000a1aa90000aa09aa0000aaa0000a9a90000a90000009000a900900aa0009000a90aa09aa000009aa00aa09aa000a9a90000a9a900
6aaaaa19000a9a00000a90000aa90a00911909a00090a9000090a0000aaaa0006aaaaa196aaaa1196aaaaa19911909a09a0909a0911909a00090a0000090a000
0a9090a9009a0900000a0900000aaaa0911aaaa60aa9a0000009a00000a09a000a9090a90a9091190a9090a9911aaaa691aaaaa6911aaaa60009a0000009a000
0aa9000000aaa000009a9a0000009a000aa00900a1aa0000000aa0000009aaaa0aa900000aa90aa00aa900000aa009009a0009000aa00900000aa00000a11a00
00000000060a0000000aaa000000006000000000911a000000a11a0000000a1900000000000000000000000000000000000000000000000000a11a0000a11a00
000000000000000000060000000000000000000009a000000009900000000a900000000000000000000000000000000000000000000000000009900000099000
000000000000000a0000000000000000000000a00007000000000000000000000000000000000000000000000000000000000000a007700a0a0aa0a00a0000a0
0000000000000000000000a0000000000000000000000a0000070000000a00000000a000000a000000000000000aa0000a0770a0007aa700a0a00a0aa000000a
00000000000000000000000070000a000700000000000700000aaa000007aa0000a7a00a00a7a0a0000aa00000a77a00007aa70007a00a700a0000a000000000
000aa000000aa000000aa000000aa000000a7000007aa00000a7700000a770000a77a00000a77a0000a77a000a7aa7a007a00a707a0000a7a000000a00000000
000aa000000aa000000aa000000aa0000007a000000a700000a77a0000a77a00007a7a0000a77a0000a77a000a7aa7a007a00a707a0000a7a000000a00000000
000000000000000000000000000a0000000007000a700a0000a0aa0000a0aa0000a0a000000aa000000aa00000a77a00007aa70007a00a700a0000a000000000
000000000000000000a0000000000070a000000000000000000000000a000000000000000000000000000000000aa0000a0770a0007aa700a0a00a0aa000000a
0000000000a0000000000007000000000000000000000000a0000000000000000000000000000000000000000000000000000000a007700a0a0aa0a00a0000a0
01818000180000001800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01818800180000001818800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01888000180000001881800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18818000181800001801800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01818800188180001808800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01888000180180001881800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18818000181800000001800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01818000188000000001800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00170000001777770017000017000000177777001700000001770000017701770177000001770000017701770177000000000000000000007000001700170000
00170000001777770017700017000000177777001777000001770000017701770177000001770000017701770177000000000000170001700017000000000000
00170000001700170017170001700000017001700171700017000000170017001700000017000000170017001700000001701700001700000000000000000000
00170000001700170017170001700000017001700171700017000000170017001700000017000000170017001717000000177000000017000000017000000017
00170000001700170017000000170000001700170017000017000000170017001717000001700000017001700171700000177000017000001700000070000000
00170000001700170017000000170000001700170017000017000000170017001717000001700000017001700171700001701700000170000000000000000000
17700000177017701770000017700000177017701770000017000000177777001770000000170000001777770017000000000000170001700001700000000000
17700000177017701770000017700000177017701770000017000000177777001700000000170000001777770017000000000000000000007000001700017000
bbbbbbbbb2bbbbbbb2bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000
bbbbbbbbbb2bbbbbbb2bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb55bbbbbbbb00000000
bbbbbbbbbb2bbbbbbb2bbbbbbbbbb555bbbbbbbbbb28bbbbbb28bbbbbbbbbbd0ddbbbbbbbbbbbbd0bbbbbbbbbbbbbbbbbbb28bbbbbbbb5550bbbbbbb00000000
bbb88bbbb2bbbbbbb2bbbbbbbbbbb55055bbbbbbb2822bbbb2822bbbbbbbbbddddbbbbbbbbbbbbddbbbbbbbbbbbbbbbbbb2822bbbbbb500055bbbbbb00000000
bb8444bbb2bbbbbbb4bbbbbbbbbf50055bbbbbbbb2111bbbb2111bbbbbbbbb1111dbbbbbbbbbbb11bbbbbbbbbbbbbbbbbb2111bbbbbb55555bbbbbbb00000000
bb8444bbb4bbbbbbb24bbbbbbbf50555fbbbbbbbb11ee1bbb11ee1bbbbbbbdddddbbbbbbbbbbbdddbbbbbbbbbbbbbbbbbb11ee1bbbbbbffffbbbbbbb00000000
bb8448bbb24bbbbb42bbbbbbbbf00ffffbbbbbbb12eee2bb12eee2bbbbbbbb9999bbbbbbbbbbbb99bbbbbbbb44444444b14eee4bbbbbbbff7bbbbbbb00000000
b88ddbbb24bbbbbb2bbbbbbbbb6600ff7bbbbbbbb22ebbbbb22e660bbbbfbbb997bbbbbbbbbbbbb9bbbbbbbb00000000bb44ebbbbbbb66776dbbbbbb00000000
bbdddd442bbbbbbbbbbbbbbbbbb666776dbbbbbbb88e8bbbbb88e40bbbbbfbdccddbbbbbbbbbbbbbbbbbbbbbb4444044bbbbbbbbbbb66d26d6bbbbbb00000000
bbd4dd0929bbbbbbbbbbbb55bbbb6d26d6bbbbbbb8888ebbb8ee440bbbbbbfd77dddbbbbbbbbbbbbbbbbbbbbb4444544bbbbbbbbbb666d66d66bbbbb00000000
bbd4dd99299bbbbbbbbbb555bbbbbd66d66bbbbbb8e88ee0b8888eebbbbbbd9971ddbbbbbbbbbbbb66bbbbbbb4444544bbbbbbbbbb66bd66d66bbbbb00000000
bbb44092999dbbbbbbbbb000bbbbbd66d66bbbbbbbee0e66bb8800ebbbabbdddddddbbbbbbbbbbb2226bbbbbb4444544bbbbbbbbbbb66d66d6fbbbbb00000000
bbdd4444999dbbbbbbb05555bbbbbd66d6fbbbbbb88eeee4b8888ebbaaaaadd1dddbbbbbbbbbbbb2226bbbbbb4444544bbbbbbbbbbbbfd655fbbbbbb00000000
bbdddd0699dbbbbbbbbbbfffbbbbb5555fbbbbbbb8888e44b8888bbb99999bdd19fffbb0bbbbbbb6622bbbbbbbbbbbbbbbbbbbbbbbbbb5555fbbbbbb00000000
bbdddd96929bbbbbbbbbbbffbbbbb5555fbbbbbbb8888b00b8888bbbbb9bbb1dd9d55550bbbbbbbb227bbbbbbbbbbbbbbbbbbbbbbbbbb555f5bbbbbb00000000
bbddd599629bbbbbbbbb6677bbbbb555f5bbbbbbb8eeebbbb8eeebbbbb5bbb1111577750bbbbbbbd77ddbbbbbbbbbbbbbbbbbbbbbbbbb55555bbbbbb00000000
bbddd999692dbbbbbbbb055bbbb05550550bbbbbbeebdbbbbeebdbbbb050b11666500050bbbbbb7d7dd77bbb7dd77bbbbbbbbbbbbbbb555055bbbbbb00000000
bbdd5999299dbbbbbbb0555bbb0555bb550bbbbbbdbbbdbbbdbbdbbbbb5b116000600050bbbbbb7dddd777bbddd77bbbbbbbbbbbbbb555bb55bbbbbb00000000
bb45b999299dbbbbbbb055bbbb055bbb550bbbbbbdbbbdbbbdbbbdbbbb5b1666000655bbbbbbbb7ddddd77bbddd77bbbbbbbbbbbbbb55bbb55bbbbbb00000000
bb4bbb9929dbbbbbbb0555bbbbb55bbb550bbbbbbdbbbdbbbdbbbdbbbb5b667760006bbbbbbbb77dddd777bbdd777bbbbbbbbbbbbbb55bbb55bbbbbb00000000
bb4bbbb92dbbbbbbbb055bbbbbb55bbb55bbbbbbbdbbb8bbbdbbbdbbbb54677776006bbbbbbbb77dd2777bbb2777bbbbbbbbbbbbbbb55bbb55bbbbbb00000000
bb4bbbbb2bbbbbbbbbb55bbbbb445bbb55bbbbbbb88bbb8bb88bb88bb55567777600655bbbbbbb200227bbbb227bbbbbbbbbbbbbbb445bbb55bbbbbb00000000
bbbbbbbbbbbbbbbbbb444bbbbbb44bbb55bbbbbbbbbbbbbbbbbbbbbbbbbbb6776006bb5b444444444444444444444444bbbbbbbbbbb44bbb55bbbbbb00000000
bbbbbbbbbbbbbbbbbbbbbbb4bbbbbbb444bbbbbbbbbbbbbbbbbbbbbbbbbbbb66666bbbbb000000000000000000000000bbbbbbbbbbbbbbb444bbbbbb00000000
bbdddd44b2bbbbbbbbb66d26d6bbbbbbbbbbbbbbb050b11666500050bbbbbbdccddbbbbb44440444444044447dd77bbbbbbbbbbbbbbbbbbbbbbbbbbb00000000
bbd4dd09bb2bbbbbbb660d66d66bbbbbbbbbbbbbbb5b116600600050bbbbbbd77dddbbbb4444544444454444ddd777bbbbbbbbbbbbbbbbbbbbbbbbbb00000000
bb4ddd99bb2bbbbbbb660d66d66bbbbb0bbbbbbbbb5b1677600655bbbbbbbddd71ddbbbb4444544444454444dddd77bbbbbbbbbbbbbbbbbbbbbbbbbb00000000
bb4dd092b2bbbbbbbbb66d66d6fbbbbb55bbbbbbbb5b677776006bbbbbafff99ddddbbbb4444544444454444dddd77bbbbbbbbbbbbbbbbbbbbbbbbbb00000000
bbd44446b2bbbbbbbbbbfd655fbbbbbb5bbbbbbbbb54677776006bbbaaaaad1ddddbbbbb4444544444454444dd2777bbbbbbbbbbbbbbbbbbbbbbbbbb00000000
bbdddd06b2bbbbbbbbbbb5555fbbbbbbfbbbbbbbb55567777600655b99999bd11d1bbbb0bbbbbbbbbbbbbbbb00227bbbbbbbbbbbbbbbbbbbbbbbbbbb00000000
bbdddd96b4bbbbbbbbbbb555f5bbbbbb7bbbbbbbbbbbb6776006bb5bbb9bbb1dd9d55550bbbbbbbbbbbbbbbb44444444bbbbbbbbbbbbbbbbbbbbbbbb00000000
bbddd599244bbbbbbbbbb55555bbbbbb6dbbbbbbbbbbbb66666bbbbbbb5bbb11d9fff750bbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbbbbbb00000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000001000000000000000000000000000101010000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
7344736400006373447374447473447364637473447374447473447374640000637374447473440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7354736400006373547374547473547364637473547374547473547374640000637374547473540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7374736400006373747374737473747364637473747374737473747374640000637374737473740000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7374736400006373747374737473747364637473747374737473747374640000637374737473740000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434343434343424343434343434343434343434343434343434343434243434343434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000004748520000000000000000000000000000000000000041765200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5555555556480000524b6b7b4b6b7b4b6b7b4b6b7b4b6b7b4b6b7b5a00005200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000464d4e4f525b004c5b004c5b004c5b004c5b004c5b004c5700005200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000465d5e5f525700795700795700795700795700795700795700005200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7000000046586949525700795700795700795700795700795700795700005200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7170000046460045525700795700795700795700795700795700795700005200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7171706566460045525700795700795700795700795700795700795700005200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7171717067720045525c597c5c597c5c597c5c597c5c597c5c597c4a6a005200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
71717171706768455240404040404040404040404040404040404040536a5200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000006775525050505050505050505050505050505050505050515200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7777777777777778606161616161616161616161616161616161616161616200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
013000000717507175071750817507175071750717506175071750a17507175081750717505175071750b1750c1750c1750c1750b1750c1750a1750c17506175071750717507175061750717505175071750d175
013000000e1750e1750e1750d1750c1750c1750c175061750717507175071750d1750e1750c1750e17508175071750a175071750617507175021750717506175071750a17507175081750717505175071750b175
013000000c175071750c1750b1750c1750a1750c17506175071750a17507175061750717505175071750d1750e175111750e1750d1750c175101750c175061750717502175071750617507175051750717506175
01240000051750c1750917508175071750a175051750417505175091750c1750d1750c1750a175101750b1750a1750e17511175151751617515175111751017511175101750c1750d1750e1750c175091750a175
01240000071750a1750e1750b1750c1750a175071750417505175091750c1750817507175111750e17506175051750c1750917506175071750a175051750417505175091750c1750b1750c175101750717509175
012400000a1750e17511175151751617515175111751017511175091750c1750d1750e175091750517506175071750a1750e1750d1750c1750a175071750617505175111750c1750917505175001750517504175
011000001325013250132001320213202132021320013200132041320413204132011320613206132060000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001625016250162000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001825018250182000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001925019250192000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001a2501a2501a2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001d2501d2501d2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001f2501f2501f2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002225022250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002425024250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000025250252502b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002625026250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002925029250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002b2502b250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000029670296502964029630296302962029620296102961029610296102b6002d6052d6002f6051c60530605006051c6051c6051c6051c60500605006050060500605006050060500605006050060500605
001800000907334600346000100032600326003260032600306003060030600306002f6002f600236002360023600006000060000600006000060000600006000060000600006000060000600006000060000600
000100003c2503b2323c2223b2223c2123b2123260032600306003060030600306002f6002f600346003460034600346000060000600006000060000600006000060000600006000060000600006000060000600
010c000011250112503c200132003c2003b200392003b2003c200302003c200302003c20000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
010c00001325013250372023a202372023a202372023a202002003a20000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
010c00001525015250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001625016250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001825018250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001925019250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001a2501a250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001c2501c250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001d2501d250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001f2501f250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00002125021250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00002225022250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00002425024250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00002525025250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00002625026250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00002827028250002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
010c00002925029250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011300001820018200182051b2001b2001b2051d2001d2001825218242182451b2501b2401b2451d2521d2421d2451e2501e2401e2451f2521f2421f24500200002001a2501a2501a2501a2411a2421a2321a225
01130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c6750c6750c60220250202502025020241202422023220225
011300000c1000c1050c1050a1000a1050a10507100071050c1700c1750c1050a1700a1750a105071700717507100061700617506100051700517505100001000010002170021510214102131021210211102115
011000000217002175000000000000000021700517005175021700217500000000000000000000000000000002170021750000000000000000217005170051750217002175000000000000000000000000000000
0110000005170051750000000000000000517007170071750517005175000000c1700917008170071700717502170021750000000000000000217005170051750217002175000000000000000000000000000000
011000000917009175000000000009170091750000000000091700917500000000000917009175000000000008170081750000000000081700817500000000000717007175000000000007170071750000000000
011000000000000000000000000000000000000000000000000000000000000000000907300000000000000000000000000000000000000000000000000000000000000000000000000009073000000000000000
011000000907300000000000000009073000000000000000090730000000000000000907300000000000000009073000000000000000090730000000000000000907300000000000000009073000000000000000
011000000c6030000000000000000c6550000000000000000060300000000000000009073000000c65500000000000000000000000000c6550000000000000000000000000000000000009073000000c65500000
011000000907300000000000000009073000000c6550000009073000000000000000090730000000000000000907300000000000000009073000000c655000000907309003000000000009073000000000000000
011000001a2501a2501a2501a2501a2501a2501a2501a2501a2411a2421a2421a2421a2321a2321a2321a2351d2501d2501d2501d2501d2411d2421d2321d2351f2501f2501f2501f2501f2411f2421f2321f235
0110000021252212451d2501d24520252202451f2501f24521252212451d2501d24520252202451f2501f24520252202451f2501f2451d2501d2451a2521a2451c2501c2451d2521d2451c2501d2501825218245
011000001a2501a25500000000000000000000000000000000000000000000000000000000000000000000001a2501a25500000000000000031200000000000000000000000000000000212501f2521f25100000
011000002125021255000000000000000000000000000000000000000000000000002125020250212522124126250262550000000000000000000000000000000000000000000000000000000000000000000000
011000002425224245242502424500000000000000000000212502124521250212450000000000000000000020252202452025020245000000000000000000001a2501a245182521824500000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
04 00404344
04 01424344
04 02424344
04 03424344
04 04424344
04 05424344
04 27282944
00 2a2d4344
00 2b2d4344
00 2c2e4344
00 2a2f4344
00 2b2f4344
00 2c304344
01 2a2f3144
00 2b2f3144
00 2c303244
00 2a2f3344
00 2b2f3444
02 2c303544
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344

