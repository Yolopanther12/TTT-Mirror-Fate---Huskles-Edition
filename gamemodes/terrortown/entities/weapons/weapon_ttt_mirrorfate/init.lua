AddCSLuaFile("newshared.lua")
AddCSLuaFile("cl_init.lua")
resource.AddFile("materials/vgui/ttt/icon_timer.vmt")

include("newshared.lua")
include("sv_fates.lua")

if #mirrorFateFates == 0 then
	ErrorNoHalt("[TTT Mirror Fate] There are no death fates configured! This item will definitely break if used!")
end

local tttMFMinFateTime = CreateConVar("ttt_mirror_fate_min_fate_time", 0, bit.bor(FCVAR_ARCHIVE), "The minimum amount of time you can set for Mirror Fate. Should be a multiple of 10.")
local tttMFMaxFateTime = CreateConVar("ttt_mirror_fate_max_fate_time", 60, bit.bor(FCVAR_ARCHIVE), "The maximum amount of time you can set for Mirror Fate. Should be a multiple of 10.")

local function getMinTime() return tttMFMinFateTime:GetInt() end
local function getMaxTime() return tttMFMaxFateTime:GetInt() end

-- Just a wrapper around PlayerMsg so I don't need to put the [Mirror Fate] header text in every message
local function sendPlyMessage(ply, message)
	if !IsValid(ply) then return end

	ply:PlayerMsg(
		Color(250, 0, 0), "[Mirror Fate] ",
		message.unpack()
	)
end

-- Initialize default values
local function initializeMF(ply)
	ply.mirrorFateFate = 1
	ply.mirrorFateTime = getMinTime()
	sendPlyMessage({Color(250, 250, 250), mirrorFateFates[ply.mirrorFateFate].infoText})
	sendPlyMessage({Color(250, 250, 250), "Your killer will die " .. tostring(ply.mirrorFateTime) .. " seconds after killing you."})
end

function SWEP:WasBought(buyer)
	if IsValid(buyer) then
		initializeMF()
	end
end

-- Cycle fate options
function SWEP:PrimaryAttack()
	local ply = self.Owner
	local newFate = (ply.mirrorFateFate % #mirrorFateFates) + 1 -- Cycles fates 1 -> 2 -> ... -> #mirrorFateFates then wraps back to 1.
	ply.mirrorFateFate = newFate
	sendPlyMessage(ply, {Color(250, 250, 250), mirrorFateFates[newFate].infoText})
end

-- Cycle time options
function SWEP:SecondaryAttack()
	local ply = self.Owner
	local newTime = ply.mirrorFateTime + 10 -- Timer increases in steps of 10 seconds
	if newTime > getMaxTime() then
		newTime = getMinTime()
	end

	ply.mirrorFateTime = newTime
	sendPlyMessage(ply, {Color(250, 250, 250), "Your killer will die " .. tostring(newTime) .. " seconds after killing you."})
end

-- Reset options to default values
function SWEP:Reload()
	local ply = self.Owner
	initializeMF(ply)
end

local function tryCleanUpMFDeath(ply, removeTimer)
	local timerName = "ttt_MirrorFate_" .. tostring(ply:SteamID64())
	if timer.Exists(timerName) then
		if removeTimer then -- This should be false if we're replacing one mirror fate with another
			timer.Remove(timerName)
		end

		mirrorFateFates[ply.currentMFFate].cleanUpDeath(ply)
	end
end

local function startMirrorFateTimer(mirrorFateOwner, mirrorFateVictim, time, fate)
	local timerName = "ttt_MirrorFate_" .. tostring(mirrorFateVictim:SteamID64())

	-- Check if this person already has an upcoming fate.
	if timer.Exists(timerName) then
		local timeLeft = timer.TimeLeft(timerName)
		if timeLeft < time then -- If the victim's upcoming fate occurs sooner than our new one then we disallow setting a new fate.
			sendPlyMessage(mirrorFateOwner, {
				Color(250, 250, 250), "Someone else has already chosen a fate for your killer! It will occur in " .. tostring(timeLeft) .. " seconds."
			})

			return
		else -- Send a message to the original "fate-setter" to let them know their fate has been overridden.
			sendPlyMessage(mirrorFateVictim.currentMFKiller, {
				Color(250, 250, 250), "Someone else has set a sooner fate for your victim! It will occur in " .. tostring(timeLeft) .. " seconds."
			})

			tryCleanUpMFDeath(mirrorFateVictim, false)
		end
	end

	mirrorFateVictim.currentMFKiller = mirrorFateOwner
	mirrorFateVictim.currentMFFate = fate

	-- Schedule the victim's fate
	timer.Create(timerName, time, 1, function()
		if IsValid(mirrorFateVictim) && mirrorFateVictim:Alive() then
			mirrorFateFates[fate].startDeath(mirrorFateOwner, mirrorFateVictim)
			sendPlyMessage(mirrorFateVictim, {
				Color(250, 250, 250), "You have experienced the ",
				Color(255, 0, 0) ,"fate ",
				Color(250, 250, 250) ,"your victim chose."
			})
			sendPlyMessage(mirrorFateOwner, {
				Color(250, 250, 250), "Your killer has experienced your chosen ",
				Color(255,0,0), "fate."
			})
		end
	end)

	sendPlyMessage(mirrorFateOwner, {
		Color(250, 250, 250), "Your killer will experience your chosen ",
		Color(250, 0, 0), "fate ",
		Color(250, 250, 250), "in " .. tostring(time) .. " seconds."
	})
end

hook.Add("DoPlayerDeath", "ttt_MirrorFate_DoPlayerDeath_TrySetFateTimer", function(victim, killer, damageInfo)
	-- Check if the victim was supposed to experience a mirror fate death
	local timerName = "ttt_MirrorFate_" .. tostring(victim:SteamID64())
	if timer.Exists(timerName) then
		sendPlyMessage(victim.currentMFKiller, {Color(250, 250, 250), "Your victim died before experiencing your chosen fate!"})
		tryCleanUpMFDeath(victim, true)
	end

	if IsValid(killer) && killer:IsPlayer() then
		-- Check if the victim's killer should experience a mirror fate death
		if victim:HasWeapon("weapon_ttt_mirrorfate") then
			if killer:Alive() then
				startMirrorFateTimer(victim, killer, victim.mirrorFateTime, victim.mirrorFateFate)
			else
				sendPlyMessage(victim, {Color(250, 250, 250), "Your killer is already dead!"})
			end
		else
			sendPlyMessage(victim, {Color(250, 250, 250), "Unable to determine your killer."})
		end
	end
end)

hook.Add("PlayerSpawn", "ttt_MirrorFate_PlayerSpawn_RemoveFateTimer", function(ply)
	tryCleanUpMFDeath(ply, true)
end)

hook.Add("TTTPrepareRound", "ttt_MirrorFate_TTTPrepareRound_RemoveFateTimer", function()
	for key, ply in pairs(player.GetAll()) do
		tryCleanUpMFDeath(ply, true)
	end
end)
