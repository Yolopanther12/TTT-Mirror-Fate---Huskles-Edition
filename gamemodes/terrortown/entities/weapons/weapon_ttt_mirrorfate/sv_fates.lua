mirrorFateFates = {}

-- If the player is not instantly killed by startDeath then it is up to you to make sure they
-- die at some point. The exception to this is if cleanUpDeath is called before you killing-effects.
-- cleanUpDeath SHOULD AVOID KILLING THE PLAYER IF POSSIBLE IF THEY'RE STILL ALIVE.

table.insert(mirrorFateFates, {
	infoText = "Your killer will die a holy death!",
	startDeath = function(victim, killer)
		killer:EmitSound("gamefreak/holy.wav")
		killer:SetGravity(0.01)
		killer:SetVelocity(Vector(0,0, 250))

		local timerName = "ttt_MirrorFate_HolyDeath_" .. tostring(killer:SteamID64())
		timer.Create(timerName, 5, 1, function()
			if IsValid(killer) then
				local fate = ents.Create("weapon_ttt_mirrorfate")
				local dmginfo = DamageInfo()
				dmginfo:SetDamage(10000)
				dmginfo:SetAttacker(victim)
				dmginfo:SetInflictor(fate)
				dmginfo:SetDamageType(DMG_GENERIC)
				killer:TakeDamageInfo(dmginfo)
				killer:SetGravity(1)
			end
		end)
	end,
	cleanUpDeath = function(killer)
		timer.Remove("ttt_MirrorFate_HolyDeath_" .. tostring(killer:SteamID64()))
	end
})

table.insert(mirrorFateFates, {
	infoText = "Your killer will burn in Hell!",
	startDeath = function(victim, killer)
		local fate = ents.Create("weapon_ttt_mirrorfate")

		local dmg = DamageInfo()
		dmg:SetDamage(5)
		dmg:SetAttacker(victim)
		dmg:SetInflictor(fate)
		dmg:SetDamageType(DMG_BURN)

		killer:EmitSound("gamefreak/evillaugh.mp3")

		local timerName = "ttt_MirrorFate_HellDeath_" .. tostring(killer:SteamID64())
		timer.Create(timerName, 0.25, 0, function()
			if IsValid(killer) && killer:Alive() then
				killer:TakeDamageInfo(dmg)
				killer:Ignite(0.2)
			else
				timer.Remove(timerName)
			end
		end)
	end,
	cleanUpDeath = function(killer)
		timer.Remove("ttt_MirrorFate_HellDeath_" .. tostring(killer:SteamID64()))
	end
})

table.insert(mirrorFateFates, {
	infoText = "Your killer will explode!",
	startDeath = function(victim, killer)
		local fate = ents.Create("weapon_ttt_mirrorfate")

		local dmginfo = DamageInfo()
		dmginfo:SetDamage(10000)
		dmginfo:SetAttacker(victim)
		dmginfo:SetDamageType(DMG_BLAST)
		dmginfo:SetInflictor(fate)

		local effectdata = EffectData()
		killer:EmitSound(Sound("ambient/explosions/explode_4.wav"))
		util.BlastDamageInfo(dmginfo, killer:GetPos(), 200)
		effectdata:SetStart(killer:GetPos() + Vector(0,0,10))
		effectdata:SetOrigin(killer:GetPos() + Vector(0,0,10))
		effectdata:SetScale(1)
		util.Effect("HelicopterMegaBomb", effectdata)
	end,
	cleanUpDeath = function(killer) end
})

table.insert(mirrorFateFates, {
	infoText = "Your killer will die of a heart-attack!",
	startDeath = function(victim, killer)
		local fate = ents.Create("weapon_ttt_mirrorfate")

		local dmginfo = DamageInfo()
		dmginfo:SetDamage(10000)
		dmginfo:SetAttacker(victim)
		dmginfo:SetInflictor(fate)
		dmginfo:SetDamageType(DMG_GENERIC)
		killer:TakeDamageInfo(dmginfo)
	end,
	cleanUpDeath = function(killer) end
})