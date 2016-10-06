-- ========================================================================
-- $File: pet.lua $
-- $Date: 2016-09-23 12:49:45 $
-- $Revision: $
-- $Creator: Jen-Chieh Shen $
-- $Notice: See LICENSE.txt for modification and distribution information $
--                   Copyright (c) 2016 by Shen, Jen-Chieh $
-- ========================================================================


require ("JCSLOVELua_Framework/code/jcslove")


pet =
   {
      isGrounded = false,

      lastFrameX = 0,
      lastFrameY = 0,

      -- NOTE(jenchieh): how many action do
      -- this pet have.
      action = 6,


      -- >>>>>> right/left <<<<<<<
      rl_time = 2,
      rl_adjustTime = 1.5,

      rl_realTime = 0,      -- contain the real action time.
      rl_timer = 0,

      -- check to see if we can reset our time zone.
      rl_walked = false,
      rl_walkSpeed = 100,


      -- >>>>>> jumping <<<<<<<
      jumped = false,       -- trigger detection
      jumpForce = 150,

      jmp_time = 7,
      jmp_adjustTime = 1.5,

      jmp_realTime = 0,
      jmp_timer = 0,

      jmp_jumped = true,


      -- >>>>>> blink <<<<<<<
      blink_time = 5,
      blink_adjustTime = 1.5,

      blink_realTime = 0,
      blink_timer = 0,
      blinked = false,

      currentAnimationName = "",

      goLeft = false,
   }




pet.__index = pet
setmetatable(pet, { __index = jcslove_gameobject } )

------------------------------------------------
-- Constructor
------------------------------------------------
function pet.new(init)
   local newPet = jcslove_gameobject:new(init)
   setmetatable(newPet, pet)

   newPet:SetShapeType("circ")
   newPet.shape.radius = 33

   return newPet
end

------------------------------------------------
-- Update logic
------------------------------------------------
-- @param dt: delta time
------------------------------------------------
function pet:update(dt)

   self:DoWalk(dt)
   self:DoJump(dt)
   self:SpriteAction()
   --self:BlinkEyes(dt)

   local collisionManager = jcslove_collisionmanager:GetInstance()

   self.shape.x = self.shape.x + (self.velocity.x * dt)

   if collisionManager:CheckCollide(self.shape, self:GetShapeType()) then
      --DEBUGGING(jenchieh): testing
      self.velocity.x = 0

      -- TODO(jenchieh): Set on top of the collision.
      -- NOTE(jenchieh): set to last frame position
      self.shape.x = self.lastFrameX
   end


   -- DESCRIPTION(jenchieh): not on the ground.
   if self.isGrounded == false then
      -- apply gravity
      self.velocity.y = self.velocity.y +
         (jcslove_physics.GRAVITY * dt) * jcslove_physics.GRAVITY_PRODUCT

      --self:DoAnimation("jump")
   end


   self.shape.y = self.shape.y + (self.velocity.y * dt)

   if collisionManager:CheckCollide(self.shape, self:GetShapeType()) then

      -- DESCRIPTION(jenchieh): on the ground.
      self.isGrounded = true

      self.velocity.y = 0
      self.shape.y = self.lastFrameY

      if self.velocity.x == 0 then

         if self.currentAnimationName ~= "blink" and
            self.currentAnimationName ~= "stand"
         then
            self:DoAnimation("stand")
         end
      else
         self:DoAnimation("move")
      end
   else
      self.isGrounded = false
   end


   self.lastFrameX = self.shape.x
   self.lastFrameY = self.shape.y

   -- NOTE(jenchieh): base function call.
   -- Apply force.
   jcslove_gameobject.update(self, dt)


end

------------------------------------------------
-- Update graphics
------------------------------------------------
function pet:draw()

   -- NOTE(jenchieh): base function call.
   jcslove_gameobject.draw(self)
end

------------------------------------------------
-- Algorithm determine when the pet blink
-- their eyes.
------------------------------------------------
function pet:BlinkEyes(dt)

   -- cannot do the blink while in the
   -- air or running.
   if self.velocity.x ~= 0 or
      self.isGrounded == false
   then
      return
   end


   -- reset time zone?
   if self.blinked == true then
      self:ResetBlinkTimeZone()
      self:DoAnimation("stand")
   end

   self.blink_timer = self.blink_timer + dt

   -- Exit out of function call if the
   -- time dose not reach yet.
   if self.blink_timer < self.blink_realTime then
      return
   end

   -- Do blink!

   self:DoAnimation("blink")

   self.blinked = true
end

------------------------------------------------
--Algorithm determine when todo the walk action.
------------------------------------------------
-- @param dt: delta time
------------------------------------------------
function pet:DoWalk(dt)

   if self.rl_walked then
      self:ResetWalkTimeZone()
   end

   -- do timer
   self.rl_timer = self.rl_timer + dt

   -- Exit out of function call if the
   -- time dose not reach yet.
   if self.rl_timer < self.rl_realTime then
      return
   end

   -- proof we did the walk action.
   self.rl_walked = true

   -- Do nothing if is in the air!
   if self.isGrounded == false then
      return
   end

   local chosenDirection = 0


   local goRight = jcslove_util.IsPossible(50)
   local goLeft = jcslove_util.IsPossible(50)
   local goIdle = jcslove_util.IsPossible(40)

   -- going right
   if goRight then
      self.velocity.x = self.rl_walkSpeed
      self:DoAnimation("move")
      self.goLeft = false

      chosenDirection = chosenDirection + 1
   end

   -- going left
   if goLeft then
      self.velocity.x = -self.rl_walkSpeed
      self:DoAnimation("move")
      self.goLeft = true

      chosenDirection = chosenDirection + 1
   end

   -- dont move!
   if goIdle then
      self.velocity.x = 0
      self:DoAnimation("stand")

      chosenDirection = chosenDirection + 1
   end

   -- If there are two direction possible
   -- Randomly chose one direction
   if chosenDirection <= 2 then
      local randDirection = math.random(1, 3)

      if randDirection == 1 then
         self.velocity.x = self.rl_walkSpeed
         self:DoAnimation("move")
         self.goLeft = false
      elseif randDirection == 2 then
         self.velocity.x = -self.rl_walkSpeed
         self:DoAnimation("move")
         self.goLeft = true
      elseif randDirection == 3 then
         self.velocity.x = 0
         self:DoAnimation("stand")
      end
   end

end

------------------------------------------------
-- Algorithm determine when todo the jump action.
------------------------------------------------
-- @param dt: delta time
------------------------------------------------
function pet:DoJump(dt)

   if self.jmp_jumped then
      self:ResetJumpTimeZone()
   end

   self.jmp_timer = self.jmp_timer + dt

   -- Exit out of function call if the
   -- time dose not reach yet.
   if self.jmp_timer < self.jmp_realTime then
      return
   end

   -- do jumping
   self:Jump()

   -- reset timer.
   self.jmp_timer = 0

   -- is not grounded anymore
   self.isGrounded = false
end

------------------------------------------------
-- The actual jumping action.
------------------------------------------------
function pet:Jump()

   -- check if is grounded
   if self.isGrounded == false then
      return
   end

   -- apply force.
   self.velocity.y = -math.abs(self.jumpForce)

   -- do jumping animation.
   self:DoAnimation("jump")

   -- do acting.
   self.jmp_jumped = true
end

------------------------------------------------
-- Reset the blink time zone.
------------------------------------------------
function pet:ResetBlinkTimeZone()
   -- reset the time
   self.blink_realTime =
      self.blink_time +
      math.random(-self.blink_adjustTime, self.blink_adjustTime)


   self.blinked = false

   self.blink_timer = 0
end

------------------------------------------------
-- Reset the walk time zone.
-- NOTE(jenchieh): in order to get slightly changes.
------------------------------------------------
function pet:ResetWalkTimeZone()

   -- reset the time
   self.rl_realTime =
      self.rl_time +
      math.random(-self.rl_adjustTime, self.rl_adjustTime)

   self.rl_walked = false

   -- reset timer
   self.rl_timer = 0
end

------------------------------------------------
-- Reset the jump time zone.
-- NOTE(jenchieh): in order to get slightly changes.
------------------------------------------------
function pet:ResetJumpTimeZone()

   -- reset the time
   self.jmp_realTime =
      self.jmp_time +
      math.random(-self.jmp_adjustTime, self.jmp_adjustTime)

   -- turn off the trigger
   self.jmp_jumped = false

   -- reset timer
   self.jmp_timer = 0
end

------------------------------------------------
-- Do animation base on action type.
--
-- NOTE(jenchieh): plz level design the pet
-- action here.
------------------------------------------------
-- @param tp: type of action
------------------------------------------------
function pet:DoAnimation(tp)

   -- record down the current animation name.
   self.currentAnimationName = tp

   if tp == "stand" then
      self.animator:SwitchAnimation(2)
   elseif tp == "blink" then
      self.animator:SwitchAnimation(1)
   elseif tp == "move" then
      self.animator:SwitchAnimation(3)
   elseif tp == "jump" then
      self.animator:SwitchAnimation(4)
   else
      jcslove_debug.Error("Wrong type doing animation.")
   end

end

------------------------------------------------
-- Simple flip the sprite base on the direction.
------------------------------------------------
function pet:SpriteAction()

   if self.goLeft then
      self.animator:FlipX(false)
   else
      self.animator:FlipX(true)
   end
end
