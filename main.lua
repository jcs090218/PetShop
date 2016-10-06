-- ========================================================================
-- $File: main.lua $
-- $Date: 2016-09-23 12:42:00 $
-- $Revision: $
-- $Creator: Jen-Chieh Shen $
-- $Notice: See LICENSE.txt for modification and distribution information $
--                   Copyright (c) 2016 by Shen, Jen-Chieh $
-- ========================================================================


require ("JCSLOVELua_Framework/code/jcslove")

require ("stdafx")


local g_spritePath = "assets/sprites/"
local g_soundPath = "assets/sounds/"

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
-- User set variables!!
-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

-- Do the pets get block by two side of
-- the scene?
local g_blockPets = true
local g_spawnSound = "die"
local g_cameraSpeed = 200

local g_minCamX = -50
local g_maxCamX = 1000

local g_minCamY = -90
local g_maxCamY = 5

local g_backgroundFriction = 0.5
local g_midgroundFriction = 0.75
local g_gamegroundFriction = 1
local g_foregroundFriction = 1

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

local camera = nil

local scenemanager = nil
local collisionmanager = nil
local soundmanager = nil

-- store all the scene here.
local g_petScene = nil
local g_menuScene = nil

-- Interface for each scene
local g_menuSceneInterfaces = {}
local g_petSceneInterfaces = {}

-- pet in the pet scene
local g_pets = {}
local g_petsCount = 0
local g_clouds = {}
local g_cloudSpeed = -10
local g_trees = {}
local g_lights = {}

-- pet scene collider.
local g_colliders = {}

local g_actionOrder =
   {
      "stand0_",    -- this is the blink
      "stand1_",
      "move_",
      "jump_",
   }

local g_actionFrameCount =
   {
      3,
      4,
      3,
      1,
   }

------------------------------------------------
-- Intialize the game
------------------------------------------------
function love.load()

   jcslove.init()
   jcslove_window.SetScreenSize(1280, 720)
   jcslove_window.SetTitle("Pet Shop - JenChieh")

   -- Create Singleton Instance.
   camera = jcslove_camera:GetInstance()

   scenemanager = jcslove_scenemanager:GetInstance()
   collisionmanager = jcslove_collisionmanager:GetInstance()
   soundmanager = jcslove_soundmanager:GetInstance()

   -- Initialize Scenes
   InitMenuScene()
   InitPetScene()
   InitCollider()

   -- Always start wisth the menu scene
   scenemanager:SwitchScene(g_menuScene)

   -- TEMPORARY(jenchieh): enable the pet scene for now
   --scenemanager:SwitchScene(g_petScene)

   -- -----------------
   -- pause trigger
   if jcslove_debug.DEBUG then
      jcslove_window.MessageBox(
         "Pet Shop - JenChieh",
         "Pause",
         "warning")
   end

end

------------------------------------------------
-- Update Game Logic Algorithm
------------------------------------------------
-- @param dt: delta time
------------------------------------------------
function love.update(dt)

   scenemanager:update(dt)

   camera:update(dt)

   test(dt)

   -- STUDY(jenchieh): not sure is there a
   -- better way of doing this.
   jcslove_input.ResetInputBuffer()
end

------------------------------------------------
-- Render the Game
------------------------------------------------
function love.draw()
   love.graphics.setColor(255, 255, 255, 125)

   scenemanager:draw()

   camera:draw()
end

------------------------------------------------
-- Test function
------------------------------------------------
function test(dt)

   -- NOTE(jenchieh): Only Do the follow
   -- logic in menu scene.
   if scenemanager:GetCurrentScene() == g_menuScene then

      if jcslove_input.GetMouseButtonDown(1) then
         scenemanager:SwitchScene(g_petScene)
         soundmanager:SetBGMForNextScene(g_soundPath .. "MapleStory BGM- Ellin Forest", ".mp3")
      end

      camera:SetPositionXY(0, 0)

   end

   -- NOTE(jenchieh): Only Do the follow
   -- logic in pet scene.
   if scenemanager:GetCurrentScene() == g_petScene then

      if jcslove_input.GetMouseButtonDown(1) then
         CreateRandomPet(love.mouse.getX(), love.mouse.getY())
      end

      if jcslove_input.GetKeyDown('m') then
         scenemanager:SwitchScene(g_menuScene)
         soundmanager:SetBGMForNextScene(g_soundPath .. "login bgm", ".mp3")
      end

      -- update clouds

      -- Set the cloud back to the original position!
      for index = 1, #g_clouds do
         local cloud = g_clouds[index]

         if cloud.x <= -1000 then
            cloud.x = 2000
         end

      end

      -- TEMPORARY(jenchieh): camera test
      if jcslove_input.GetKey('a') then
         camera.velocity.x = -g_cameraSpeed
      elseif jcslove_input.GetKey('d') then
         camera.velocity.x = g_cameraSpeed
      else
         camera.velocity.x = 0
      end

      if jcslove_input.GetKey('s') then
         camera.velocity.y = g_cameraSpeed
      elseif jcslove_input.GetKey('w') then
         camera.velocity.y = -g_cameraSpeed
      else
         camera.velocity.y = 0
      end

      -- reset the camera position back 0, 0
      if jcslove_input.GetKeyDown('r') then
         camera:SetPositionXY(0, 0)
      end

      -- Camera movement
      CameraMovement()

      -- Interface trigger
      InterfaceTrigger()
   end



end


------------------------------------------------
-- Initialzie the Menu Scene
------------------------------------------------
function InitMenuScene()
   -- >>>>>>>>>>> Start Create Interface and Scene <<<<<<<<<-- Create the new scene
   g_menuScene = jcslove_scene:new()
   soundmanager:PlayBGM(g_soundPath .. "login bgm", ".mp3")

   g_menuSceneInterfaces[1] = jcslove_interface:new()
   g_menuSceneInterfaces[2] = jcslove_interface:new()
   g_menuSceneInterfaces[3] = jcslove_interface:new()
   g_menuSceneInterfaces[4] = jcslove_interface:new()

   local background = g_menuSceneInterfaces[1]
   local midground = g_menuSceneInterfaces[2]
   local gameground = g_menuSceneInterfaces[3]
   local foreground = g_menuSceneInterfaces[4]

   -- set friction for each interface
   background.friction = 1
   midground.friction = 1
   gameground.friction = 1
   foreground.friction = 1

   -- add interface to the scene
   g_menuScene:add(background)
   g_menuScene:add(midground)
   g_menuScene:add(gameground)
   g_menuScene:add(foreground)
   -- >>>>>>>>>>> End Create Interface and Scene <<<<<<<<<


   -- >>>>>>>>>>> Start Add Game Object into interface <<<<<<<<<
   local some = 60

   local back_0 = jcslove_util.CreateInterfaceSprite(
      background,
      g_spritePath .. "IDvampireEU_town - no name/back_0.png")
   back_0.x = 640
   back_0.y = 475 - some

   local back_1_1 = jcslove_util.CreateInterfaceSprite(
      background,
      g_spritePath .. "IDvampireEU_town - no name/back_1.png")
   back_1_1.x = 600
   back_1_1.y = 400 - some
   local back_1_2 = jcslove_util.CreateInterfaceSprite(
      background,
      g_spritePath .. "IDvampireEU_town - no name/back_1.png")
   back_1_2.x = 600 + 426
   back_1_2.y = 400 - some

   local back_2 = jcslove_util.CreateInterfaceSprite(
      background,
      g_spritePath .. "IDvampireEU_town - no name/back_2.png")
   back_2.x = 640
   back_2.y = 300 - some

   local ani_5 = jcslove_util.CreateInterfaceAnimation(
      midground,
      g_spritePath .. "ID11thFestival - no name/",
      "ani.5_",
      ".png",
      5)
   ani_5.x = 1000
   ani_5.y = 200 - some
   ani_5.animation.timePerFrame = 1

   local ani0 = jcslove_util.CreateInterfaceAnimation(
      midground,
      g_spritePath .. "IDvampireEU_town - no name/",
      "ani.0_",
      ".png",
      10)
   ani0.x = 150
   ani0.y = 375 - some
   ani0.animation.timePerFrame = 0.5

   local back_4_1 = jcslove_util.CreateInterfaceSprite(
      background,
      g_spritePath .. "IDvampireEU_town - no name/back_4.png")
   back_4_1.x = 600
   back_4_1.y = 550 - some

   local back_4_2 = jcslove_util.CreateInterfaceSprite(
      background,
      g_spritePath .. "IDvampireEU_town - no name/back_4.png")
   back_4_2.x = 2380
   back_4_2.y = 550 - some

   local back_5 = jcslove_util.CreateInterfaceSprite(
      midground,
      g_spritePath .. "IDvampireEU_town - no name/back_5.png")
   back_5.x = 100
   back_5.y = 550 - some

   g_clouds[1] = jcslove_util.CreateInterfaceSprite(
      midground,
      g_spritePath .. "IDvampireEU_town - no name/back_6.png")
   g_clouds[1].x = 2000
   g_clouds[1].y = 300
   g_clouds[1].velocity.x = g_cloudSpeed

   g_clouds[2] = jcslove_util.CreateInterfaceSprite(
      midground,
      g_spritePath .. "IDprofession - no name/back_11.png")
   g_clouds[2].x = 640
   g_clouds[2].y = 100
   g_clouds[2].velocity.x = g_cloudSpeed

   local back_10 = jcslove_util.CreateInterfaceSprite(
      background,
      g_spritePath .. "IDprofession - no name/back_10.png")
   back_10.x = 640
   back_10.y = 320

   g_trees[1] = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "ID11thFestival - no name/back_11.png")
   g_trees[1].x = 1300
   g_trees[1].y = 375

   local back_17_1 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "ID11thFestival - no name/back_17.png")
   back_17_1.x = 640
   back_17_1.y = 590

   local back_17_2 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "ID11thFestival - no name/back_17.png")
   back_17_2.x = 1838
   back_17_2.y = 590

   local back_19 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "ID11thFestival - no name/back_19.png")
   back_19.x = 1300
   back_19.y = 590

   -- Tile Map Start

   local enH0_0_1 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_0.png")
   enH0_0_1.x = 0 + (90 * 0)
   enH0_0_1.y = 650
   local enH0_0_2 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_0.png")
   enH0_0_2.x = 0 + (90 * 3)
   enH0_0_2.y = 650
   local enH0_0_3 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_0.png")
   enH0_0_3.x = 0 + (90 * 6)
   enH0_0_3.y = 650
   local enH0_0_4 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_0.png")
   enH0_0_4.x = 0 + (90 * 9)
   enH0_0_4.y = 650
   local enH0_0_5 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_0.png")
   enH0_0_5.x = 0 + (90 * 12)
   enH0_0_5.y = 650
   local enH0_0_11 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_0.png")
   enH0_0_11.x = 0 + (90 * 15)
   enH0_0_11.y = 650
   local enH0_0_12 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_0.png")
   enH0_0_12.x = 0 + (90 * 18)
   enH0_0_12.y = 650
   local enH0_0_13 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_0.png")
   enH0_0_13.x = 0 + (90 * 21)
   enH0_0_13.y = 650
   local enH0_0_14 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_0.png")
   enH0_0_14.x = 0 + (90 * 24)
   enH0_0_14.y = 650

   local enH0_1_1 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_1.png")
   enH0_1_1.x = 0 + (90 * 1)
   enH0_1_1.y = 650
   local enH0_1_2 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_1.png")
   enH0_1_2.x = 0 + (90 * 4)
   enH0_1_2.y = 650
   local enH0_1_3 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_1.png")
   enH0_1_3.x = 0 + (90 * 7)
   enH0_1_3.y = 650
   local enH0_1_4 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_1.png")
   enH0_1_4.x = 0 + (90 * 10)
   enH0_1_4.y = 650
   local enH0_1_5 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_1.png")
   enH0_1_5.x = 0 + (90 * 13)
   enH0_1_5.y = 650
   local enH0_1_11 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_1.png")
   enH0_1_11.x = 0 + (90 * 16)
   enH0_1_11.y = 650
   local enH0_1_12 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_1.png")
   enH0_1_12.x = 0 + (90 * 19)
   enH0_1_12.y = 650
   local enH0_1_13 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_1.png")
   enH0_1_13.x = 0 + (90 * 22)
   enH0_1_13.y = 650
   local enH0_1_14 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_1.png")
   enH0_1_14.x = 0 + (90 * 25)
   enH0_1_14.y = 650

   local enH0_2_1 = jcslove_util.CreateInterfaceSprite(
      gameground, g_spritePath .. "IDfallenLeaves - no name/enH0_2.png")
   enH0_2_1.x = 0 + (90 * 2)
   enH0_2_1.y = 650
   local enH0_2_2 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_2.png")
   enH0_2_2.x = 0 + (90 * 5)
   enH0_2_2.y = 650
   local enH0_2_3 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_2.png")
   enH0_2_3.x = 0 + (90 * 8)
   enH0_2_3.y = 650
   local enH0_2_4 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_2.png")
   enH0_2_4.x = 0 + (90 * 11)
   enH0_2_4.y = 650
   local enH0_2_5 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_2.png")
   enH0_2_5.x = 0 + (90 * 14)
   enH0_2_5.y = 650
   local enH0_2_11 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_2.png")
   enH0_2_11.x = 0 + (90 * 17)
   enH0_2_11.y = 650
   local enH0_2_12 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_2.png")
   enH0_2_12.x = 0 + (90 * 20)
   enH0_2_12.y = 650
   local enH0_2_13 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_2.png")
   enH0_2_13.x = 0 + (90 * 23)
   enH0_2_13.y = 650
   local enH0_2_14 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_2.png")
   enH0_2_14.x = 0 + (90 * 26)
   enH0_2_14.y = 650

   local bsc_0_1 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_0.png")
   bsc_0_1.x = 0 + (90 * 0)
   bsc_0_1.y = 650 + 48
   local bsc_0_2 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_0.png")
   bsc_0_2.x = 0 + (90 * 3)
   bsc_0_2.y = 650 + 48
   local bsc_0_3 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_0.png")
   bsc_0_3.x = 0 + (90 * 6)
   bsc_0_3.y = 650 + 48
   local bsc_0_4 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_0.png")
   bsc_0_4.x = 0 + (90 * 9)
   bsc_0_4.y = 650 + 48
   local bsc_0_5 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_0.png")
   bsc_0_5.x = 0 + (90 * 12)
   bsc_0_5.y = 650 + 48
   local bsc_0_11 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_0.png")
   bsc_0_11.x = 0 + (90 * 15)
   bsc_0_11.y = 650 + 48
   local bsc_0_12 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_0.png")
   bsc_0_12.x = 0 + (90 * 18)
   bsc_0_12.y = 650 + 48
   local bsc_0_13 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_0.png")
   bsc_0_13.x = 0 + (90 * 21)
   bsc_0_13.y = 650 + 48
   local bsc_0_14 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_0.png")
   bsc_0_14.x = 0 + (90 * 24)
   bsc_0_14.y = 650 + 48

   local bsc_1_1 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_1.png")
   bsc_1_1.x = 0 + (90 * 1)
   bsc_1_1.y = 650 + 48
   local bsc_1_2 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_1.png")
   bsc_1_2.x = 0 + (90 * 4)
   bsc_1_2.y = 650 + 48
   local bsc_1_3 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_1.png")
   bsc_1_3.x = 0 + (90 * 7)
   bsc_1_3.y = 650 + 48
   local bsc_1_4 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_1.png")
   bsc_1_4.x = 0 + (90 * 10)
   bsc_1_4.y = 650 + 48
   local bsc_1_5 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_1.png")
   bsc_1_5.x = 0 + (90 * 13)
   bsc_1_5.y = 650 + 48
   local bsc_1_11 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_1.png")
   bsc_1_11.x = 0 + (90 * 16)
   bsc_1_11.y = 650 + 48
   local bsc_1_12 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_1.png")
   bsc_1_12.x = 0 + (90 * 19)
   bsc_1_12.y = 650 + 48
   local bsc_1_13 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_1.png")
   bsc_1_13.x = 0 + (90 * 22)
   bsc_1_13.y = 650 + 48
   local bsc_1_14 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_1.png")
   bsc_1_14.x = 0 + (90 * 25)
   bsc_1_14.y = 650 + 48

   local bsc_2_1 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_2.png")
   bsc_2_1.x = 0 + (90 * 2)
   bsc_2_1.y = 650 + 48
   local bsc_2_2 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_2.png")
   bsc_2_2.x = 0 + (90 * 5)
   bsc_2_2.y = 650 + 48
   local bsc_2_3 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_2.png")
   bsc_2_3.x = 0 + (90 * 8)
   bsc_2_3.y = 650 + 48
   local bsc_2_4 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_2.png")
   bsc_2_4.x = 0 + (90 * 11)
   bsc_2_4.y = 650 + 48
   local bsc_2_5 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_2.png")
   bsc_2_5.x = 0 + (90 * 14)
   bsc_2_5.y = 650 + 48
   local bsc_2_11 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_2.png")
   bsc_2_11.x = 0 + (90 * 17)
   bsc_2_11.y = 650 + 48
   local bsc_2_12 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_2.png")
   bsc_2_12.x = 0 + (90 * 20)
   bsc_2_12.y = 650 + 48
   local bsc_2_13 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_2.png")
   bsc_2_13.x = 0 + (90 * 23)
   bsc_2_13.y = 650 + 48
   local bsc_2_14 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_2.png")
   bsc_2_14.x = 0 + (90 * 26)
   bsc_2_14.y = 650 + 48

   -- Create Lights
   g_lights[1] = jcslove_util.CreateInterfaceAnimation(
      foreground,
      g_spritePath .. "ID11thFestival - no name/",
      "ani.2_",
      ".png",
      2)
   g_lights[1].x = 1200
   g_lights[1].y = 125
   g_lights[1].animation.timePerFrame = 0.1

   -- Foreground bushes
   local fore_back_0 = jcslove_util.CreateInterfaceSprite(
      foreground,
      g_spritePath .. "IDprofession - no name/back_1.png")
   fore_back_0.x = 310
   fore_back_0.y = 400

   local stand_0_sign = jcslove_util.CreateInterfaceSprite(
      foreground,
      g_spritePath .. "ID2012037 - Orbis Tower Warning Sign/stand_0.png")
   stand_0_sign.x = 200
   stand_0_sign.y = 590

   local stand_0_ppl = jcslove_util.CreateInterfaceSprite(
      foreground,
      g_spritePath .. "ID0010300 - unknown/stand_0.png")
   stand_0_ppl.x = 1000
   stand_0_ppl.y = 450

   local say_0 = jcslove_util.CreateInterfaceAnimation(
      foreground,
      g_spritePath .. "ID2010009 - Lenario/",
      "say_",
      ".png",
      14)
   say_0.x = 350
   say_0.y = 600
   say_0.animation.timePerFrame = 0.3
   say_0.animation:FlipX(true)

   -- Platform
   local enH0_0_6 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_0.png")
   enH0_0_6.x = 925 + (45 * 1)
   enH0_0_6.y = 500
   local enH0_0_7 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_0.png")
   enH0_0_7.x = 925 + (45 * 4)
   enH0_0_7.y = 500

   local enH0_1_6 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_1.png")
   enH0_1_6.x = 925 + (45 * 2)
   enH0_1_6.y = 500
   local enH0_1_7 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_1.png")
   enH0_1_7.x = 925 + (45 * 5)
   enH0_1_7.y = 500

   local enH0_2_6 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_2.png")
   enH0_2_6.x = 925 + (45 * 3)
   enH0_2_6.y = 500

   local enH1_0_1 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH1_0.png")
   enH1_0_1.x = 925 + (45 * 1)
   enH1_0_1.y = 500 + 35
   local enH1_0_2 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH1_0.png")
   enH1_0_2.x = 925 + (45 * 4)
   enH1_0_2.y = 500 + 35

   local enH1_1_1 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH1_1.png")
   enH1_1_1.x = 925 + (45 * 2)
   enH1_1_1.y = 500 + 35
   local enH1_1_2 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH1_1.png")
   enH1_1_2.x = 925 + (45 * 5)
   enH1_1_2.y = 500 + 35

   local enH1_2_1 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH1_2.png")
   enH1_2_1.x = 925 + (45 * 3)
   enH1_2_1.y = 500 + 35
   -- >>>>>>>>>>> End Add Game Object into interface <<<<<<<<<

end

------------------------------------------------
-- Initialzie the Pet Scene
------------------------------------------------
function InitPetScene()
   -- >>>>>>>>>>> Start Create Interface and Scene <<<<<<<<<
   g_petScene = jcslove_scene:new()

   g_petSceneInterfaces[1] = jcslove_interface:new()
   g_petSceneInterfaces[2] = jcslove_interface:new()
   g_petSceneInterfaces[3] = jcslove_interface:new()
   g_petSceneInterfaces[4] = jcslove_interface:new()

   local background = g_petSceneInterfaces[1]
   local midground = g_petSceneInterfaces[2]
   local gameground = g_petSceneInterfaces[3]
   local foreground = g_petSceneInterfaces[4]

   -- set friction for each interface
   background.friction = g_backgroundFriction
   midground.friction = g_midgroundFriction
   gameground.friction = g_gamegroundFriction
   foreground.friction = g_foregroundFriction

   -- add interface to the scene
   g_petScene:add(background)
   g_petScene:add(midground)
   g_petScene:add(gameground)
   g_petScene:add(foreground)

   -- >>>>>>>>>>> End Create Interface and Scene <<<<<<<<<



   -- >>>>>>>>>>> Start Add Game Object into interface <<<<<<<<<
   local some = 60

   local back_0 = jcslove_util.CreateInterfaceSprite(
      background,
      g_spritePath .. "IDvampireEU_town - no name/back_0.png")
   back_0.x = 640
   back_0.y = 475 - some

   local back_1_1 = jcslove_util.CreateInterfaceSprite(
      background,
      g_spritePath .. "IDvampireEU_town - no name/back_1.png")
   back_1_1.x = 600
   back_1_1.y = 400 - some
   local back_1_2 = jcslove_util.CreateInterfaceSprite(
      background,
      g_spritePath .. "IDvampireEU_town - no name/back_1.png")
   back_1_2.x = 600 + 426
   back_1_2.y = 400 - some

   local back_2 = jcslove_util.CreateInterfaceSprite(
      background,
      g_spritePath .. "IDvampireEU_town - no name/back_2.png")
   back_2.x = 640
   back_2.y = 300 - some

   local ani_5 = jcslove_util.CreateInterfaceAnimation(
      midground,
      g_spritePath .. "ID11thFestival - no name/",
      "ani.5_",
      ".png",
      5)
   ani_5.x = 1000
   ani_5.y = 200 - some
   ani_5.animation.timePerFrame = 1

   local ani0 = jcslove_util.CreateInterfaceAnimation(
      midground,
      g_spritePath .. "IDvampireEU_town - no name/",
      "ani.0_",
      ".png",
      10)
   ani0.x = 150
   ani0.y = 375 - some
   ani0.animation.timePerFrame = 0.5

   local back_4_1 = jcslove_util.CreateInterfaceSprite(
      background,
      g_spritePath .. "IDvampireEU_town - no name/back_4.png")
   back_4_1.x = 600
   back_4_1.y = 550 - some

   local back_4_2 = jcslove_util.CreateInterfaceSprite(
      background,
      g_spritePath .. "IDvampireEU_town - no name/back_4.png")
   back_4_2.x = 2380
   back_4_2.y = 550 - some

   local back_5 = jcslove_util.CreateInterfaceSprite(
      midground,
      g_spritePath .. "IDvampireEU_town - no name/back_5.png")
   back_5.x = 100
   back_5.y = 550 - some

   g_clouds[1] = jcslove_util.CreateInterfaceSprite(
      midground,
      g_spritePath .. "IDvampireEU_town - no name/back_6.png")
   g_clouds[1].x = 2000
   g_clouds[1].y = 300
   g_clouds[1].velocity.x = g_cloudSpeed

   g_clouds[2] = jcslove_util.CreateInterfaceSprite(
      midground,
      g_spritePath .. "IDprofession - no name/back_11.png")
   g_clouds[2].x = 640
   g_clouds[2].y = 100
   g_clouds[2].velocity.x = g_cloudSpeed

   local back_10 = jcslove_util.CreateInterfaceSprite(
      background,
      g_spritePath .. "IDprofession - no name/back_10.png")
   back_10.x = 640
   back_10.y = 320

   g_trees[1] = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "ID11thFestival - no name/back_11.png")
   g_trees[1].x = 1300
   g_trees[1].y = 375

   local back_17_1 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "ID11thFestival - no name/back_17.png")
   back_17_1.x = 640
   back_17_1.y = 590

   local back_17_2 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "ID11thFestival - no name/back_17.png")
   back_17_2.x = 1838
   back_17_2.y = 590

   local back_19 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "ID11thFestival - no name/back_19.png")
   back_19.x = 1300
   back_19.y = 590

   -- Tile Map Start

   local enH0_0_1 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_0.png")
   enH0_0_1.x = 0 + (90 * 0)
   enH0_0_1.y = 650
   local enH0_0_2 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_0.png")
   enH0_0_2.x = 0 + (90 * 3)
   enH0_0_2.y = 650
   local enH0_0_3 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_0.png")
   enH0_0_3.x = 0 + (90 * 6)
   enH0_0_3.y = 650
   local enH0_0_4 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_0.png")
   enH0_0_4.x = 0 + (90 * 9)
   enH0_0_4.y = 650
   local enH0_0_5 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_0.png")
   enH0_0_5.x = 0 + (90 * 12)
   enH0_0_5.y = 650
   local enH0_0_11 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_0.png")
   enH0_0_11.x = 0 + (90 * 15)
   enH0_0_11.y = 650
   local enH0_0_12 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_0.png")
   enH0_0_12.x = 0 + (90 * 18)
   enH0_0_12.y = 650
   local enH0_0_13 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_0.png")
   enH0_0_13.x = 0 + (90 * 21)
   enH0_0_13.y = 650
   local enH0_0_14 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_0.png")
   enH0_0_14.x = 0 + (90 * 24)
   enH0_0_14.y = 650

   local enH0_1_1 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_1.png")
   enH0_1_1.x = 0 + (90 * 1)
   enH0_1_1.y = 650
   local enH0_1_2 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_1.png")
   enH0_1_2.x = 0 + (90 * 4)
   enH0_1_2.y = 650
   local enH0_1_3 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_1.png")
   enH0_1_3.x = 0 + (90 * 7)
   enH0_1_3.y = 650
   local enH0_1_4 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_1.png")
   enH0_1_4.x = 0 + (90 * 10)
   enH0_1_4.y = 650
   local enH0_1_5 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_1.png")
   enH0_1_5.x = 0 + (90 * 13)
   enH0_1_5.y = 650
   local enH0_1_11 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_1.png")
   enH0_1_11.x = 0 + (90 * 16)
   enH0_1_11.y = 650
   local enH0_1_12 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_1.png")
   enH0_1_12.x = 0 + (90 * 19)
   enH0_1_12.y = 650
   local enH0_1_13 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_1.png")
   enH0_1_13.x = 0 + (90 * 22)
   enH0_1_13.y = 650
   local enH0_1_14 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_1.png")
   enH0_1_14.x = 0 + (90 * 25)
   enH0_1_14.y = 650

   local enH0_2_1 = jcslove_util.CreateInterfaceSprite(
      gameground, g_spritePath .. "IDfallenLeaves - no name/enH0_2.png")
   enH0_2_1.x = 0 + (90 * 2)
   enH0_2_1.y = 650
   local enH0_2_2 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_2.png")
   enH0_2_2.x = 0 + (90 * 5)
   enH0_2_2.y = 650
   local enH0_2_3 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_2.png")
   enH0_2_3.x = 0 + (90 * 8)
   enH0_2_3.y = 650
   local enH0_2_4 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_2.png")
   enH0_2_4.x = 0 + (90 * 11)
   enH0_2_4.y = 650
   local enH0_2_5 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_2.png")
   enH0_2_5.x = 0 + (90 * 14)
   enH0_2_5.y = 650
   local enH0_2_11 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_2.png")
   enH0_2_11.x = 0 + (90 * 17)
   enH0_2_11.y = 650
   local enH0_2_12 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_2.png")
   enH0_2_12.x = 0 + (90 * 20)
   enH0_2_12.y = 650
   local enH0_2_13 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_2.png")
   enH0_2_13.x = 0 + (90 * 23)
   enH0_2_13.y = 650
   local enH0_2_14 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_2.png")
   enH0_2_14.x = 0 + (90 * 26)
   enH0_2_14.y = 650

   local bsc_0_1 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_0.png")
   bsc_0_1.x = 0 + (90 * 0)
   bsc_0_1.y = 650 + 48
   local bsc_0_2 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_0.png")
   bsc_0_2.x = 0 + (90 * 3)
   bsc_0_2.y = 650 + 48
   local bsc_0_3 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_0.png")
   bsc_0_3.x = 0 + (90 * 6)
   bsc_0_3.y = 650 + 48
   local bsc_0_4 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_0.png")
   bsc_0_4.x = 0 + (90 * 9)
   bsc_0_4.y = 650 + 48
   local bsc_0_5 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_0.png")
   bsc_0_5.x = 0 + (90 * 12)
   bsc_0_5.y = 650 + 48
   local bsc_0_11 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_0.png")
   bsc_0_11.x = 0 + (90 * 15)
   bsc_0_11.y = 650 + 48
   local bsc_0_12 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_0.png")
   bsc_0_12.x = 0 + (90 * 18)
   bsc_0_12.y = 650 + 48
   local bsc_0_13 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_0.png")
   bsc_0_13.x = 0 + (90 * 21)
   bsc_0_13.y = 650 + 48
   local bsc_0_14 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_0.png")
   bsc_0_14.x = 0 + (90 * 24)
   bsc_0_14.y = 650 + 48

   local bsc_1_1 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_1.png")
   bsc_1_1.x = 0 + (90 * 1)
   bsc_1_1.y = 650 + 48
   local bsc_1_2 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_1.png")
   bsc_1_2.x = 0 + (90 * 4)
   bsc_1_2.y = 650 + 48
   local bsc_1_3 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_1.png")
   bsc_1_3.x = 0 + (90 * 7)
   bsc_1_3.y = 650 + 48
   local bsc_1_4 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_1.png")
   bsc_1_4.x = 0 + (90 * 10)
   bsc_1_4.y = 650 + 48
   local bsc_1_5 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_1.png")
   bsc_1_5.x = 0 + (90 * 13)
   bsc_1_5.y = 650 + 48
   local bsc_1_11 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_1.png")
   bsc_1_11.x = 0 + (90 * 16)
   bsc_1_11.y = 650 + 48
   local bsc_1_12 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_1.png")
   bsc_1_12.x = 0 + (90 * 19)
   bsc_1_12.y = 650 + 48
   local bsc_1_13 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_1.png")
   bsc_1_13.x = 0 + (90 * 22)
   bsc_1_13.y = 650 + 48
   local bsc_1_14 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_1.png")
   bsc_1_14.x = 0 + (90 * 25)
   bsc_1_14.y = 650 + 48

   local bsc_2_1 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_2.png")
   bsc_2_1.x = 0 + (90 * 2)
   bsc_2_1.y = 650 + 48
   local bsc_2_2 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_2.png")
   bsc_2_2.x = 0 + (90 * 5)
   bsc_2_2.y = 650 + 48
   local bsc_2_3 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_2.png")
   bsc_2_3.x = 0 + (90 * 8)
   bsc_2_3.y = 650 + 48
   local bsc_2_4 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_2.png")
   bsc_2_4.x = 0 + (90 * 11)
   bsc_2_4.y = 650 + 48
   local bsc_2_5 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_2.png")
   bsc_2_5.x = 0 + (90 * 14)
   bsc_2_5.y = 650 + 48
   local bsc_2_11 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_2.png")
   bsc_2_11.x = 0 + (90 * 17)
   bsc_2_11.y = 650 + 48
   local bsc_2_12 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_2.png")
   bsc_2_12.x = 0 + (90 * 20)
   bsc_2_12.y = 650 + 48
   local bsc_2_13 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_2.png")
   bsc_2_13.x = 0 + (90 * 23)
   bsc_2_13.y = 650 + 48
   local bsc_2_14 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/bsc_2.png")
   bsc_2_14.x = 0 + (90 * 26)
   bsc_2_14.y = 650 + 48

   -- Create Lights
   g_lights[1] = jcslove_util.CreateInterfaceAnimation(
      foreground,
      g_spritePath .. "ID11thFestival - no name/",
      "ani.2_",
      ".png",
      2)
   g_lights[1].x = 1200
   g_lights[1].y = 125
   g_lights[1].animation.timePerFrame = 0.1

   -- Foreground bushes
   local fore_back_0 = jcslove_util.CreateInterfaceSprite(
      foreground,
      g_spritePath .. "IDprofession - no name/back_1.png")
   fore_back_0.x = 310
   fore_back_0.y = 400

   local stand_0_sign = jcslove_util.CreateInterfaceSprite(
      foreground,
      g_spritePath .. "ID2012037 - Orbis Tower Warning Sign/stand_0.png")
   stand_0_sign.x = 200
   stand_0_sign.y = 590

   -- Platform
   local enH0_0_6 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_0.png")
   enH0_0_6.x = 925 + (45 * 1)
   enH0_0_6.y = 500
   local enH0_0_7 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_0.png")
   enH0_0_7.x = 925 + (45 * 4)
   enH0_0_7.y = 500

   local enH0_1_6 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_1.png")
   enH0_1_6.x = 925 + (45 * 2)
   enH0_1_6.y = 500
   local enH0_1_7 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_1.png")
   enH0_1_7.x = 925 + (45 * 5)
   enH0_1_7.y = 500

   local enH0_2_6 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH0_2.png")
   enH0_2_6.x = 925 + (45 * 3)
   enH0_2_6.y = 500

   local enH1_0_1 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH1_0.png")
   enH1_0_1.x = 925 + (45 * 1)
   enH1_0_1.y = 500 + 35
   local enH1_0_2 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH1_0.png")
   enH1_0_2.x = 925 + (45 * 4)
   enH1_0_2.y = 500 + 35

   local enH1_1_1 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH1_1.png")
   enH1_1_1.x = 925 + (45 * 2)
   enH1_1_1.y = 500 + 35
   local enH1_1_2 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH1_1.png")
   enH1_1_2.x = 925 + (45 * 5)
   enH1_1_2.y = 500 + 35

   local enH1_2_1 = jcslove_util.CreateInterfaceSprite(
      gameground,
      g_spritePath .. "IDfallenLeaves - no name/enH1_2.png")
   enH1_2_1.x = 925 + (45 * 3)
   enH1_2_1.y = 500 + 35

   -- >>>>>>>>>>> End Add Game Object into interface <<<<<<<<<

end

------------------------------------------------
-- Create a pet
------------------------------------------------
-- @param tp: type of the pet u want to spawn.
------------------------------------------------
function CreateAPet(tp)

   -- create new instance
   local newPet = pet:new()

   -- add all animation in there.
   for index = 1, #g_actionOrder do

      newPet.animator
         :AddAndCreateSpriteSequence(
            g_spritePath .. tp .. "/",
            g_actionOrder[index],
            ".png",
            g_actionFrameCount[index])

      newPet.name = tp
   end

   -- auto pivot animator!
   newPet.animator:AutoPivot()

   -- return the create pet
   return newPet
end

------------------------------------------------
-- Initialize the collider in the scene
------------------------------------------------
function InitCollider()

   -- NOTE(jenchieh): these are created in the
   -- pet init function
   local background = g_petSceneInterfaces[1]
   local midground = g_petSceneInterfaces[2]
   local gameground = g_petSceneInterfaces[3]
   local foreground = g_petSceneInterfaces[4]

   -- create a random game object for ground
   g_colliders[1] = jcslove_gameobject:new()
   g_colliders[2] = jcslove_gameobject:new()
   g_colliders[3] = jcslove_gameobject:new()
   g_colliders[4] = jcslove_gameobject:new()

   -- set shape type
   g_colliders[1]:SetShapeType("rect")
   g_colliders[2]:SetShapeType("rect")
   g_colliders[3]:SetShapeType("rect")
   g_colliders[4]:SetShapeType("rect")

   g_colliders[1].x = -200
   g_colliders[1].y = 650
   g_colliders[1].shape.width = 4000
   g_colliders[1].shape.height = 10

   g_colliders[2].x = -100
   g_colliders[2].y = 200
   g_colliders[2].shape.width = 20
   g_colliders[2].shape.height = 500

   g_colliders[3].x = 2300
   g_colliders[3].y = 400
   g_colliders[3].shape.width = 20
   g_colliders[3].shape.height = 300

   g_colliders[4].x = 925
   g_colliders[4].y = 500
   g_colliders[4].shape.width = 270
   g_colliders[4].shape.height = 20


   -- add to interface
   gameground:add(g_colliders[1])
   gameground:add(g_colliders[2])
   gameground:add(g_colliders[3])
   gameground:add(g_colliders[4])

   -- add to collision manager
   collisionmanager:Add(g_colliders[1].shape, g_colliders[1]:GetShapeType())
   -- Block the pet on the side?
   if g_blockPets == true then
      collisionmanager:Add(g_colliders[2].shape, g_colliders[2]:GetShapeType())
      collisionmanager:Add(g_colliders[3].shape, g_colliders[3]:GetShapeType())
   end
   collisionmanager:Add(g_colliders[4].shape, g_colliders[4]:GetShapeType())
end


------------------------------------------------
-- Create the random pet.
------------------------------------------------
-- @param xPos: x position the pet spawn
-- @param yPos: y position the pet spawn
------------------------------------------------
function CreateRandomPet(xPos, yPos)

   local background = g_petSceneInterfaces[1]
   local midground = g_petSceneInterfaces[2]
   local gameground = g_petSceneInterfaces[3]
   local foreground = g_petSceneInterfaces[4]

   -- increase the pet count
   g_petsCount = g_petsCount + 1

   -- Create random pet.
   local randIndex = math.random(1, 14)
   local petName = ChooseAPet(randIndex)

   -- pass in random pet name.
   g_pets[g_petsCount] = CreateAPet(petName)

   g_pets[g_petsCount].x = xPos
   g_pets[g_petsCount].y = yPos

   g_pets[g_petsCount].animator:SwitchAnimation(4)

   -- random flip the pet in x-axis
   local doFlip = jcslove_util.IsPossible(50)
   if doFlip then
      g_pets[g_petsCount].goLeft = true
   end

   -- Add to the interface
   gameground:add(g_pets[g_petsCount])

   -- Play a Spawn sound
   soundmanager:PlayOneShot(g_soundPath .. g_spawnSound, ".mp3")

end

------------------------------------------------
-- Choose a pet
------------------------------------------------
-- @return name: name of the pet in
-- database array.
------------------------------------------------
function ChooseAPet(index)
   local petName = ""

   if index == 1 then
      petName = "Husky"
   elseif index == 2 then
      petName = "Monkey"
   elseif index == 3 then
      petName = "Panda"
   elseif index == 4 then
      petName = "Pink Bunny"
   elseif index == 5 then
      petName = "Skunk"
   elseif index == 6 then
      petName = "White Bunny"
   elseif index == 7 then
      petName = "White Tiger"
   elseif index == 8 then
      petName = "Black Kitty"
   elseif index == 9 then
      petName = "Black Pig"
   elseif index == 10 then
      petName = "Rudolph"
   elseif index == 11 then
      petName = "Penguin"
   elseif index == 12 then
      petName = "Mini Kargo"
   elseif index == 13 then
      petName = "Elephant"
   elseif index == 14 then
      petName = "Brown Puppy"
   else
      -- Error log
      jcslove_debug.Error(
         "Invalid index for the database load.")
   end

   return petName
end

------------------------------------------------
-- Camera movement
------------------------------------------------
function CameraMovement()
   local fixPosX = camera.x
   local fixPosY = camera.y

   if camera.x > g_maxCamX then
      fixPosX = g_maxCamX
   elseif camera.x < g_minCamX then
      fixPosX = g_minCamX
   end

   if camera.y > g_maxCamY then
      fixPosY = g_maxCamY
   elseif camera.y < g_minCamY then
      fixPosY = g_minCamY
   end

   camera:SetPositionXY(fixPosX, fixPosY)

end

------------------------------------------------
-- Interface Trigger
------------------------------------------------
function InterfaceTrigger()

   local background = g_petSceneInterfaces[1]
   local midground = g_petSceneInterfaces[2]
   local gameground = g_petSceneInterfaces[3]
   local foreground = g_petSceneInterfaces[4]

   if jcslove_input.GetKeyDown('u') then

      background.active = jcslove_util.FlipBool(background.active)
   end

   if jcslove_input.GetKeyDown('i') then
      midground.active = jcslove_util.FlipBool(midground.active)
   end

   if jcslove_input.GetKeyDown('o') then
      gameground.active = jcslove_util.FlipBool(gameground.active)
   end

   if jcslove_input.GetKeyDown('p') then
      foreground.active = jcslove_util.FlipBool(foreground.active)
   end
end
