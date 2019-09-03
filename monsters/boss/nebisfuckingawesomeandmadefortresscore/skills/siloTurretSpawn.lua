--------------------------------------------------------------------------------
siloTurretSpawn = {}

function siloTurretSpawn.enter()
  if not hasTarget() then return nil end
  
  self.active = false
  self.finished = false
  self.leftFinished = false
  self.rightFinished = false
  self.canFire = false
  self.leftSiloOffset = config.getParameter("siloTurretSpawn.leftSiloOffset")
  self.rightSiloOffset = config.getParameter("siloTurretSpawn.rightSiloOffset")
  self.monsterLevel = monster.level() - 1
  
  return {
    fireDuration = config.getParameter("siloTurretSpawn.fireDuration", 1),
    windupDuration = config.getParameter("siloTurretSpawn.windupDuration", 1),
	monsterCount = config.getParameter("siloTurretSpawn.monsterCount", 5),
	monsters = config.getParameter("siloTurretSpawn.monsters"),
    monsterTypes = config.getParameter("siloTurretSpawn.monsterTypes"),
    monsterCount = config.getParameter("siloTurretSpawn.monsterCount"),
    monsterTestPoly = config.getParameter("siloTurretSpawn.monsterTestPoly"),
    spawnOnGround = config.getParameter("siloTurretSpawn.spawnOnGround"),
    spawnAnimation = config.getParameter("siloTurretSpawn.spawnAnimation"),
    spawnRangeX = config.getParameter("siloTurretSpawn.spawnRangeX"),
    spawnRangeY = config.getParameter("siloTurretSpawn.spawnRangeY"),
    spawnTolerance = config.getParameter("siloTurretSpawn.spawnTolerance"),
    spawnAnimationStatus = config.getParameter("siloTurretSpawn.spawnAnimationStatus"),
	entityId = nil
  }
end

function siloTurretSpawn.enteringState(stateData)
  if stateData.entityId then if world.entityExists(stateData.entityId) then return true end end
  if not hasTarget() then return true end
  monster.setActiveSkillName("siloTurretSpawn")
  self.firstChoice = math.random(1, 2)
  self.secondChoice = math.random(1, 2)
  animator.playSound("ventAlert")
end

function siloTurretSpawn.update(dt, stateData)
  if not hasTarget() then return true end
  
  if animator.animationState("topLeftSilo") == "risen" and not self.active then
	self.active = true
  end
  if animator.animationState("topLeftSilo") == "risen" and not self.active then
	self.active = true
  end
  
  if self.active and stateData.windupDuration > 0 and not self.canFire then
    stateData.windupDuration = stateData.windupDuration - dt
	
	if stateData.windupDuration <= 0 and not self.canFire then
      self.canFire = true
	end
  end
  
  if self.active then
	if animator.animationState("topLeftSilo") == "risen" and self.canFire and not self.finished then
	  for i = 1, math.random(stateData.monsterCount) do
	    --Calculate initial x and y offset for the spawn position
	    local xOffset = math.random((self.leftSiloOffset[1] - stateData.spawnRangeX), self.leftSiloOffset[1])
	    --xOffset = xOffset * util.randomChoice({-1, 1})
	    local yOffset = math.random(self.leftSiloOffset[2], (stateData.spawnRangeY + self.leftSiloOffset[2]))
	    local position = vec2.add(entity.position(), {xOffset, yOffset})
	  
	    --Optionally correct the position by finding the ground below the projected position
	    local correctedPositionAndNormal = {position, nil}
	    if stateData.spawnOnGround then
	  	  correctedPositionAndNormal = world.lineTileCollisionPoint(position, vec2.add(position, {0, -50})) or {position, 0}
	    end
	  
	    --Resolve the monster poly collision to ensure that we can place an monster at the designated position
	    local resolvedPosition = world.resolvePolyCollision(stateData.monsterTestPoly, correctedPositionAndNormal[1], stateData.spawnTolerance)
	  
	    if resolvedPosition then
		  --Spawn the monster and optionally force the monster spawn effect on them
		  stateData.entityId = world.spawnMonster(util.randomChoice(stateData.monsterTypes), resolvedPosition, {level = self.monsterLevel, aggressive = true})
		  if stateData.spawnAnimation then
		    world.callScriptedEntity(entityId, "status.addEphemeralEffect", stateData.spawnAnimationStatus)
		  end
	    end
	  end
	  self.finished = true
	end
	if animator.animationState("topLeftSilo") == "risen" and self.canFire and not self.finished then

	  for i = 1, math.random(stateData.monsterCount) do
	    --Calculate initial x and y offset for the spawn position
	    local xOffset = math.random(self.rightSiloOffset[1], (self.rightSiloOffset[1] + stateData.spawnRangeX))
	    --xOffset = xOffset * util.randomChoice({-1, 1})
	    local yOffset = math.random(self.rightSiloOffset[2], (stateData.spawnRangeY + self.rightSiloOffset[2]))
	    local position = vec2.add(entity.position(), {xOffset, yOffset})
	  
	    --Optionally correct the position by finding the ground below the projected position
	    local correctedPositionAndNormal = {position, nil}
	    if stateData.spawnOnGround then
	  	  correctedPositionAndNormal = world.lineTileCollisionPoint(position, vec2.add(position, {0, -50})) or {position, 0}
	    end
	  
	    --Resolve the monster poly collision to ensure that we can place an monster at the designated position
	    local resolvedPosition = world.resolvePolyCollision(stateData.monsterTestPoly, correctedPositionAndNormal[1], stateData.spawnTolerance)
	  
	    if resolvedPosition then
		  --Spawn the monster and optionally force the monster spawn effect on them
		  local entityId = world.spawnMonster(util.randomChoice(stateData.monsterTypes), resolvedPosition, {level = self.monsterLevel, aggressive = true})
		  if stateData.spawnAnimation then
		    world.callScriptedEntity(entityId, "status.addEphemeralEffect", stateData.spawnAnimationStatus)
		  end
	    end
	  end
	  self.finished = true
	end
	
	if self.finished then
      stateData.fireDuration = stateData.fireDuration - dt
	  
	  if stateData.fireDuration <= 0 then
	    return true
	  end
	end
  end


  if self.secondChoice ~= self.firstChoice and not self.active then
	if animator.animationState("topLeftSilo") == "idle" and animator.animationState("topLeftSilo") == "idle" then
	  animator.setAnimationState("topLeftSilo", "rise")
	  animator.setAnimationState("topLeftSilo", "rise")
	end
  elseif not self.active then
    if self.firstChoice == 1 then	
	  if animator.animationState("topLeftSilo") == "idle" then
	    animator.setAnimationState("topLeftSilo", "rise")
	  end
	elseif self.firstChoice == 2 then
	  if animator.animationState("topLeftSilo") == "idle" then
	    animator.setAnimationState("topLeftSilo", "rise")
	  end
	end
  end

  return false
end

function siloTurretSpawn.leavingState(stateData)
  self.active = false
  self.canFire = false
end