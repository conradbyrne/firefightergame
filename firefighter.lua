--variables

function _init()
    player={
      sp=1,
      x=9 * 8,
      y=26 * 8,
      w=8,
      h=8,
      flp=false,
      dx=0,
      dy=0,
      max_dx=2,
      max_dy=3,
      acc=0.5,
      boost=5,
      anim=0,
      running=false,
      jumping=false,
      falling=false,
      landed=false,
      death_count=0,
      cats_caught=0,
      fires_extinguished=0
    }
  
    game_ended = false
    gravity=0.3
    friction=0.85

    --water blasts
    water_blasts = {}
    shoot_cooldown = 0
    water_width = 16
    water_height = 8
    water_speed = 3


    fires = {
        { x= 15 * 8, y= 26 * 8 + 4, active=true},
        { x = 74 * 8, y=26 * 8 + 4, active =true},
        { x=67 * 8, y = 20 * 8 + 4, active=true},
        { x=75 * 8, y=11 * 8 + 4, active=true},
        { x=85 * 8, y=5 * 8 + 4, active = true},
        { x=32 * 8, y=22 * 8 + 4, active=true},
        { x=6 * 8, y=14* 8 + 4, active=true},
        { x=15*8, y = 9*8 + 4, active=true},
        { x=29*8, y = 4*8 + 4, active = true},
        { x=39*8, y = 1*8 + 4, active = true},
        { x=36*8, y = 22*8 + 4, active = true},

        
    }
    fire_height = 11
    fire_width = 11

    cat_height = 8
    cat_width = 8
    catch_message_timer = 0

    cats = {
        { x= 46 * 8, y=13 * 8, caught=false},
        { x= 86 * 8, y=10 * 8, caught=false},
        { x = 34 * 8, y= 23 * 8, caught=false}
    }
  
    --simple camera
    cam_x=0
    cam_y=0
  
    --map limits
    map_start=0
    map_end=1024
  end
  
  -->8
  --update and draw
  
  function _update()
    player_update()
    water_update()
    fire_update()
    cat_update()
    player_animate()
    update_catch_message()
  
    --simple camera
    cam_x=player.x-64+(player.w/2)
    if cam_x<map_start then
       cam_x=map_start
    end
    if cam_x>map_end-128 then
       cam_x=map_end-128
    end
    cam_y=player.y-64+(player.h/2)
    if cam_y<map_start then
       cam_y=map_start
    end
    if cam_y>map_end-128 then
       cam_y=map_end-128
    end



    camera(cam_x,cam_y)
  end
  
  function _draw()
    cls()
    map(0,0)
    -- Draw the player hitbox (for testing)
    --rect(player.x, player.y, player.x + player.w, player.y + player.h, 8) -- 8 is the color of the rectangle
    spr(player.sp,player.x,player.y,1,1,player.flp)
    for blast in all(water_blasts) do
        spr(7, blast.x, blast.y - 3, 2, 2, blast.flp)
        -- Draw the water hitbox (for testing)
        --rect(blast.x, blast.y, blast.x + water_width, blast.y + water_height, 8) -- 8 is the color of the rectangle
    end
    for fire in all(fires) do
        if fire.active then
            spr(21, fire.x - 2, fire.y - 4, 2, 2)
            -- Draw the fire hitbox (for testing)
            --rect(fire.x, fire.y, fire.x + fire_width, fire.y + fire_height, 8) -- 8 is the color of the rectangle
        end
    end
    for cat in all(cats) do
        if not cat.caught then
            spr(9, cat.x, cat.y, 1, 1)
            -- Draw the cat hitbox (for testing)
            --rect(cat.x, cat.y, cat.x + cat_width, cat.y + cat_height, 8) -- 8 is the color of the rectangle
        end
    end

    draw_info()
    draw_catch_message()
    if player.cats_caught == 3 and player.fires_extinguished == 11 then
        if game_ended == false then
            sfx(7)
            game_ended = true
        end
        print("you win!", player.x - 30, player.y - 30, 3)  -- Display above the player
    end

  end

  function draw_info()
        -- Define text values
    local deaths_text = "deaths: " .. player.death_count
    local cats_text = "cats: " .. player.cats_caught .. "/" .. 3
    local fires_text = "fires: " .. player.fires_extinguished .. "/" .. 11
    
    local x_pos = player.x + 21
    local y_pos_deaths = player.y + -60
    if y_pos_deaths < 0 then
        y_pos_deaths = 0
    end
    local y_pos_cats = y_pos_deaths + 8
    local y_pos_fires = y_pos_cats + 8

    
    -- Set text color (white for example, color index 7)
    color(7)
    
    -- Print text on the screen
    print(deaths_text, x_pos, y_pos_deaths)
    print(cats_text, x_pos, y_pos_cats)
    print(fires_text, x_pos, y_pos_fires)

  end
  
  -->8
  --collisions
  
  function collide_map(obj,aim,flag)
   --obj = table needs x,y,w,h
   --aim = left,right,up,down
  
   local x=obj.x  local y=obj.y
   local w=obj.w  local h=obj.h
  
   local x1=0	 local y1=0
   local x2=0  local y2=0
  
   if aim=="left" then
     x1=x-1  y1=y
     x2=x    y2=y+h-1
  
   elseif aim=="right" then
     x1=x+w-1    y1=y
     x2=x+w  y2=y+h-1
  
   elseif aim=="up" then
     x1=x+2    y1=y-1
     x2=x+w-3  y2=y
  
   elseif aim=="down" then
     x1=x+2      y1=y+h
     x2=x+w-3    y2=y+h
   end
  
   --pixels to tiles
   x1/=8    y1/=8
   x2/=8    y2/=8
  
   if fget(mget(x1,y1), flag)
   or fget(mget(x1,y2), flag)
   or fget(mget(x2,y1), flag)
   or fget(mget(x2,y2), flag) then
     return true
   else
     return false
   end
  
  end
  
  -->8
  --player
  
  function player_update()
    --physics
    player.dy+=gravity
    player.dx*=friction
  
    --controls
    if btn(⬅️) then
      player.dx-=player.acc
      player.running=true
      player.flp=true
    end
    if btn(➡️) then
      player.dx+=player.acc
      player.running=true
      player.flp=false
    end
  
  
    --jump
    if btnp(2)
    and player.landed then
      player.dy-=player.boost
      player.landed=false
    end

    if not btn(⬅️) and not btn(➡️) and
    not player.jumping and
    not player.falling and
    player.landed then
        player.running=false
    end
  
    --check collision up and down
    if player.dy>0 then
      player.falling=true
      player.landed=false
      player.jumping=false
  
      player.dy=limit_speed(player.dy,player.max_dy)
  
      if collide_map(player,"down",0) then
        player.landed=true
        player.falling=false
        player.dy=0
        player.y-=((player.y+player.h+1)%8)-1
      end
    elseif player.dy<0 then
      player.jumping=true
      if collide_map(player,"up",1) then
        player.dy=0
      end
    end
  
    --check collision left and right
    if player.dx<0 then
  
      player.dx=limit_speed(player.dx,player.max_dx)
  
      if collide_map(player,"left",1) then
        player.dx=0
      end
    elseif player.dx>0 then
  
      player.dx=limit_speed(player.dx,player.max_dx)
  
      if collide_map(player,"right",1) then
        player.dx=0
      end
    end
  
    player.x+=player.dx
    player.y+=player.dy
  
    --limit player to map
    if player.x<map_start then
      player.x=map_start
    end
    if player.x>map_end-player.w then
      player.x=map_end-player.w
    end
  end

  function water_update()
    if shoot_cooldown > 0 then
        shoot_cooldown -= 1
    end
    -- Shoot water blast when button pressed and cooldown is ready
    if btn(🅾️)  and shoot_cooldown == 0 then 
        shoot_water_blast(player)
        sfx(5)
        shoot_cooldown = 15 -- time between shots (adjust as needed)
    end
    -- Update water blasts
    update_water_blasts() 
  end

  function shoot_water_blast(player)
    -- orientation
    if player.flp then
        x = player.x - water_width
        dx = -1 * water_speed
    else
        x = player.x + player.w
        dx = water_speed
    end

    local blast = {
        x = x,
        y = player.y - 1,
        life = 50,          -- how long the blast lasts (in frames)
        flp = player.flp,
        dx = dx
    }
    add(water_blasts, blast)
  end

  -- Update water blasts
function update_water_blasts()
    for blast in all(water_blasts) do
        -- Decrease life of blast
        blast.life -= 1
        blast.x += blast.dx
        -- Remove blast if life is over or it's off the screen
        if blast.life <= 0 or blast.x < map_start or blast.x > map_end then
            del(water_blasts, blast)
        end
    end
end

function fire_update()
    check_fire_water_collision()
    check_fire_player_collision()
end

function check_fire_water_collision()
    for fire in all(fires) do
        if fire.active then
            for blast in all(water_blasts) do
                if (blast.x < fire.x + fire_width and
                    blast.x + water_width > fire.x and
                    blast.y < fire.y + fire_height and
                    blast.y + water_height > fire.y) then
                    -- Extinguish fire
                    sfx(2)
                    fire.active = false
                    blast.life = 0
                    player.fires_extinguished += 1
                end
            end
        end
    end
end

function check_fire_player_collision()
    for fire in all(fires) do
        if fire.active then
            if (player.x < fire.x + fire_width and
            player.x + player.w > fire.x and
            player.y < fire.y + fire_height and
            player.y + player.h > fire.y) then
            -- reset
            reset_player()
            sfx(3)
        end  
        end
    end
end

function reset_player()
    player.x=9 * 8
    player.y=26 * 8
    player.flp=false
    player.dx=0
    player.dy=0
    player.acc=0.5
    player.anim=0
    player.running=false
    player.jumping=false
    player.falling=false
    player.landed=false
    player.death_count += 1
end

function cat_update()
    for cat in all(cats) do
        if not cat.caught then
            if (player.x < cat.x + cat_width and
            player.x + player.w > cat.x and
            player.y < cat.y + cat_height and
            player.y + player.h > cat.y) then
            -- catch cat
            sfx(6)
            cat.caught = true
            player.cats_caught += 1
            show_catch_message = true
            catch_message_timer = 60  -- Display for 1 second (60 frames)
        end  
        end
    end
end

-- Update the catch message display
function update_catch_message()
    if show_catch_message then
        catch_message_timer -= 1
        if catch_message_timer <= 0 then
            show_catch_message = false
        end
    end
end

-- Draw the catch message
function draw_catch_message()
    if show_catch_message then
        print("cat saved! ", player.x - 16, player.y - 16, 10)  -- Display above the player
    end
end
  
  function player_animate()
    if player.jumping then
      player.sp=5
    elseif player.falling then
      player.sp=6
    elseif player.running then
      if time()-player.anim>.1 then
        player.anim=time()
        player.sp+=1
        if player.sp>4 then
          player.sp=3
        end
      end
    else --player idle
      if time()-player.anim>.3 then
        player.anim=time()
        player.sp+=1
        if player.sp>2 then
          player.sp=1
        end
      end
    end
  end
  
  function limit_speed(num,maximum)
    return mid(-maximum,num,maximum)
  end