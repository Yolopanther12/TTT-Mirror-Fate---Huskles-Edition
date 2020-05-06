include("newshared.lua")

SWEP.PrintName = "Mirror Fate"
SWEP.Slot = 7
SWEP.ViewModelFlip = true
SWEP.Icon = "vgui/ttt/icon_timer"
SWEP.EquipMenuData = {
	type = "item_weapon",
	name = "Mirror Fate",
	desc = "If you get killed, your assassin will die too!\n\nLeft-Click to change assassin's fate.\nRight-Click to change assassin's death time.\nReload to Reset!"
}

function SWEP:PrimaryAttack() end
function SWEP:SecondaryAttack() end
function SWEP:Reload() end
