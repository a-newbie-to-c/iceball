--[[
    This file is part of Ice Lua Components.

    Ice Lua Components is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Ice Lua Components is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Ice Lua Components.  If not, see <http://www.gnu.org/licenses/>.
]]

print("pkg/base/main_client.lua starting")
print(...)

dofile("pkg/base/common.lua")

-- define keys
BTSK_FORWARD = SDLK_w
BTSK_BACK    = SDLK_s
BTSK_LEFT    = SDLK_a
BTSK_RIGHT   = SDLK_d
BTSK_JUMP    = SDLK_SPACE
BTSK_CROUCH  = SDLK_LCTRL
BTSK_SNEAK   = SDLK_v
BTSK_RELOAD  = SDLK_r

BTSK_TOOL1 = SDLK_1
BTSK_TOOL2 = SDLK_2
BTSK_TOOL3 = SDLK_3
BTSK_TOOL4 = SDLK_4
BTSK_TOOL5 = SDLK_5

BTSK_COLORLEFT  = SDLK_LEFT
BTSK_COLORRIGHT = SDLK_RIGHT
BTSK_COLORUP    = SDLK_UP
BTSK_COLORDOWN  = SDLK_DOWN

BTSK_QUIT = SDLK_ESCAPE

BTSK_DEBUG = SDLK_F1
BTSK_MAP = SDLK_m

players = {max = 32, current = 1}

-- set stuff
rotpos = 0.0
debug_enabled = false
mouse_released = false
large_map = false
sensitivity = 1.0/1000.0
mouse_skip = 3

-- load images
img_crosshair = client.img_load("pkg/base/gfx/crosshair.tga")

-- load/make models
mdl_test = client.model_load_pmf("pkg/base/pmf/test.pmf")
mdl_test_bone = client.model_bone_find(mdl_test, "test")
mdl_spade, mdl_spade_bone = client.model_load_pmf("pkg/base/pmf/spade.pmf"), 0
mdl_block, mdl_block_bone = client.model_load_pmf("pkg/base/pmf/block.pmf"), 0
-- TODO: load all weapons
mdl_rifle, mdl_rifle_bone = client.model_load_pmf("pkg/base/pmf/rifle.pmf"), 0
mdl_nade, mdl_nade_bone = client.model_load_pmf("pkg/base/pmf/nade.pmf"), 0

-- quick hack to stitch a player model together
if false then
	local head,body,arm,leg
	head = client.model_load_pmf("pkg/base/pmf/src/playerhead.pmf")
	body = client.model_load_pmf("pkg/base/pmf/src/playerbody.pmf")
	arm = client.model_load_pmf("pkg/base/pmf/src/playerarm.pmf")
	leg = client.model_load_pmf("pkg/base/pmf/src/playerleg.pmf")
	
	local mname, mdata, mbone
	local mbase = client.model_new(6)
	mname, mdata = client.model_bone_get(head, 0)
	mbase, mbone = client.model_bone_new(mbase)
	client.model_bone_set(mbase, mbone, "head", mdata)
	mname, mdata = client.model_bone_get(body, 0)
	mbase, mbone = client.model_bone_new(mbase)
	client.model_bone_set(mbase, mbone, "body", mdata)
	mname, mdata = client.model_bone_get(arm, 0)
	mbase, mbone = client.model_bone_new(mbase)
	client.model_bone_set(mbase, mbone, "arm", mdata)
	mname, mdata = client.model_bone_get(leg, 0)
	mbase, mbone = client.model_bone_new(mbase)
	client.model_bone_set(mbase, mbone, "leg", mdata)
	
	client.model_save_pmf(mbase, "clsave/player.pmf")
end

mdl_player = client.model_load_pmf("pkg/base/pmf/player.pmf")
mdl_player_head = client.model_bone_find(mdl_player, "head")
mdl_player_body = client.model_bone_find(mdl_player, "body")
mdl_player_arm = client.model_bone_find(mdl_player, "arm")
mdl_player_leg = client.model_bone_find(mdl_player, "leg")

local _
_, mdl_block_data = client.model_bone_get(mdl_block, mdl_block_bone)


mdl_bbox = client.model_new(1)
mdl_bbox_bone_data1 = {
	{radius=10, x = -100, y = -70, z = -100, r = 255, g = 85, b = 85},
	{radius=10, x =  100, y = -70, z = -100, r = 255, g = 85, b = 85},
	{radius=10, x = -100, y = -70, z =  100, r = 255, g = 85, b = 85},
	{radius=10, x =  100, y = -70, z =  100, r = 255, g = 85, b = 85},
	{radius=10, x = -100, y = 600, z = -100, r = 255, g = 85, b = 85},
	{radius=10, x =  100, y = 600, z = -100, r = 255, g = 85, b = 85},
	{radius=10, x = -100, y = 600, z =  100, r = 255, g = 85, b = 85},
	{radius=10, x =  100, y = 600, z =  100, r = 255, g = 85, b = 85},
}
mdl_bbox_bone_data2 = {
	{radius=10, x = -100, y = -70, z = -100, r = 255, g = 85, b = 85},
	{radius=10, x =  100, y = -70, z = -100, r = 255, g = 85, b = 85},
	{radius=10, x = -100, y = -70, z =  100, r = 255, g = 85, b = 85},
	{radius=10, x =  100, y = -70, z =  100, r = 255, g = 85, b = 85},
	{radius=10, x = -100, y = 410, z = -100, r = 255, g = 85, b = 85},
	{radius=10, x =  100, y = 410, z = -100, r = 255, g = 85, b = 85},
	{radius=10, x = -100, y = 410, z =  100, r = 255, g = 85, b = 85},
	{radius=10, x =  100, y = 410, z =  100, r = 255, g = 85, b = 85},
}
mdl_bbox, mdl_bbox_bone1 = client.model_bone_new(mdl_bbox)
mdl_bbox, mdl_bbox_bone2 = client.model_bone_new(mdl_bbox)
client.model_bone_set(mdl_bbox, mdl_bbox_bone1, "bbox_stand", mdl_bbox_bone_data1)
client.model_bone_set(mdl_bbox, mdl_bbox_bone2, "bbox_crouch", mdl_bbox_bone_data2)


-- set hooks
function h_tick_camfly(sec_current, sec_delta)
	rotpos = rotpos + sec_delta*120.0
	
	local i
	for i=1,players.max do
		local plr = players[i]
		if plr then
			plr.tick(sec_current, sec_delta)
		end
	end
	players[players.current].camera_firstperson()
	-- wait a bit
	return 0.005
end

function h_tick_init(sec_current, sec_delta)
	local i
	--[[local squads = {[0]={},[1]={}}
	for i=1,4 do
		squads[0][i] = name_generate()
		squads[1][i] = name_generate()
	end]]
	
	for i=1,players.max do
		players[i] = new_player({
			name = name_generate(),
			--[[squad = squads[math.fmod(i-1,2)][
				math.fmod(math.floor((i-1)/2),4)+1],]]
			squad = nil,
			team = math.fmod(i-1,2), -- 0 == blue, 1 == green
			weapon = WPN_RIFLE,
		})
	end
	players.current = math.floor(math.random()*32)+1
	
	mouse_released = false
	client.mouse_lock_set(true)
	client.mouse_visible_set(false)
	
	client.hook_tick = h_tick_camfly
	return client.hook_tick(sec_current, sec_delta)
end

client.hook_tick = h_tick_init

function client.hook_key(key, state)
	if not players[players.current] then return end
	local plr = players[players.current]
	
	if key == SDLK_F5 then
		mouse_released = true
		client.mouse_lock_set(false)
		client.mouse_visible_set(true)
	elseif key == BTSK_QUIT then
		-- TODO: clean up
		client.hook_tick = nil
	elseif key == BTSK_FORWARD then
		plr.ev_forward = state
	elseif key == BTSK_BACK then
		plr.ev_back = state
	elseif key == BTSK_LEFT then
		plr.ev_left = state
	elseif key == BTSK_RIGHT then
		plr.ev_right = state
	elseif key == BTSK_CROUCH then
		plr.ev_crouch = state
	elseif key == BTSK_JUMP then
		plr.ev_jump = state
	elseif key == BTSK_SNEAK then
		plr.ev_sneak = state
	elseif key == BTSK_TOOL1 then
		plr.tool = TOOL_SPADE
	elseif key == BTSK_TOOL2 then
		plr.tool = TOOL_BLOCK
	elseif key == BTSK_TOOL3 then
		plr.tool = TOOL_GUN
	elseif key == BTSK_TOOL4 then
		plr.tool = TOOL_NADE
	elseif key == BTSK_TOOL5 then
		-- TODO
	elseif state then
		if key == BTSK_DEBUG then
			debug_enabled = not debug_enabled
		elseif key == BTSK_MAP then
			large_map = not large_map
		elseif key == BTSK_COLORLEFT then
			plr.blk_color_x = plr.blk_color_x - 1
			if plr.blk_color_x < 0 then
				plr.blk_color_x = 7
			end
			plr.blk_color = cpalette[plr.blk_color_x+plr.blk_color_y*8+1]
		elseif key == BTSK_COLORRIGHT then
			plr.blk_color_x = plr.blk_color_x + 1
			if plr.blk_color_x > 7 then
				plr.blk_color_x = 0
			end
			plr.blk_color = cpalette[plr.blk_color_x+plr.blk_color_y*8+1]
		elseif key == BTSK_COLORUP then
			plr.blk_color_y = plr.blk_color_y - 1
			if plr.blk_color_y < 0 then
				plr.blk_color_y = 7
			end
			plr.blk_color = cpalette[plr.blk_color_x+plr.blk_color_y*8+1]
		elseif key == BTSK_COLORDOWN then
			plr.blk_color_y = plr.blk_color_y + 1
			if plr.blk_color_y > 7 then
				plr.blk_color_y = 0
			end
			plr.blk_color = cpalette[plr.blk_color_x+plr.blk_color_y*8+1]
		end
	end
end

function client.hook_mouse_button(button, state)
	if mouse_released then
		mouse_released = false
		client.mouse_lock_set(true)
		client.mouse_visible_set(false)
		return
	end
	
	local plr = players[players.current]
	
	local xlen, ylen, zlen
	xlen, ylen, zlen = common.map_get_dims()
	
	if state then
		if button == 1 then
			-- LMB
			if plr.tool == TOOL_BLOCK and plr.blx1 then
				if plr.blx1 >= 0 and plr.blx1 < xlen and plr.blz1 >= 0 and plr.blz1 < zlen then
				if plr.bly2 <= ylen-2 then
				map_block_set(
					plr.blx1, plr.bly1, plr.blz1,
					1,
					plr.blk_color[1],
					plr.blk_color[2],
					plr.blk_color[3])
				end
				end
			elseif plr.tool == TOOL_SPADE and plr.blx2 then
				if plr.blx1 >= 0 and plr.blx1 < xlen and plr.blz1 >= 0 and plr.blz1 < zlen then
				if plr.bly2 <= ylen-3 then
					map_block_break(plr.blx2, plr.bly2, plr.blz2)
				end
				end
			end
		elseif button == 3 then
			-- RMB
			if plr.tool == TOOL_BLOCK and plr.blx3 then
				local ct,cr,cg,cb
				ct,cr,cg,cb = map_block_pick(plr.blx3, plr.bly3, plr.blz3)
				plr.blk_color = {cr,cg,cb}
			elseif plr.tool == TOOL_SPADE and plr.blx2 then
				if plr.blx1 >= 0 and plr.blx1 < xlen and plr.blz1 >= 0 and plr.blz1 < zlen then
				if plr.bly2-1 <= ylen-3 then
					map_block_break(plr.blx2, plr.bly2-1, plr.blz2)
				end
				if plr.bly2 <= ylen-3 then
					map_block_break(plr.blx2, plr.bly2, plr.blz2)
				end
				if plr.bly2+1 <= ylen-3 then
					map_block_break(plr.blx2, plr.bly2+1, plr.blz2)
				end
				end
			elseif plr.tool == TOOL_GUN then
				plr.zooming = not plr.zooming
			end
		elseif button == 2 then
			-- middleclick
		end
	end
end

function client.hook_mouse_motion(x, y, dx, dy)
	if not players[players.current] then return end
	if mouse_released then return end
	if mouse_skip > 0 then
		mouse_skip = mouse_skip - 1
		return
	end
	
	local plr = players[players.current]
	
	plr.angy = plr.angy - dx*math.pi*sensitivity/plr.zoom
	plr.angx = plr.angx + dy*math.pi*sensitivity/plr.zoom
end

function client.hook_render()
	players[players.current].show_hud()
end

-- load map
map_fname = ...
map_fname = map_fname or MAP_DEFAULT
map_loaded = common.map_load(map_fname, "auto")
common.map_set(map_loaded)

print(client.map_fog_get())
--client.map_fog_set(24,0,32,60)
client.map_fog_set(192,238,255,60)
print(client.map_fog_get())

-- create map overview
-- TODO: update image when map gets mutilated
do
	local xlen, ylen, zlen
	xlen, ylen, zlen = common.map_get_dims()
	img_overview = common.img_new(xlen, zlen)
	img_overview_grid = common.img_new(xlen, zlen)
	img_overview_icons = common.img_new(xlen, zlen)
	local x,z
	
	for z=0,zlen-1 do
	for x=0,xlen-1 do
		local l = common.map_pillar_get(x,z)
		local r,g,b
		r = l[5]
		g = l[6]
		b = l[7]
		local c = 0xFF000000+256*(256*b+g)+r
		common.img_pixel_set(img_overview, x, z, c)
	end
	end
	for z=63,zlen-1,64 do
	for x=0,xlen-1 do
		common.img_pixel_set(img_overview_grid, x, z, 0xFFFFFFFF)
	end
	end
	for z=0,zlen-1 do
	for x=63,xlen-1,64 do
		common.img_pixel_set(img_overview_grid, x, z, 0xFFFFFFFF)
	end
	end
end

print("pkg/base/main_client.lua loaded.")

--dofile("pkg/base/plug_snow.lua")
dofile("pkg/base/plug_pmfedit.lua")
