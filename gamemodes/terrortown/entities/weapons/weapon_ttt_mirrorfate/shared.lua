SWEP.Author = "Yolopanther"
SWEP.Contact = "asdf"
SWEP.Purpose = "Fun"
SWEP.Instructions = "ASDF"

SWEP.Base = "weapon_tttbase"
SWEP.Kind = WEAPON_EQUIP2
SWEP.AutoSpawnable = false SWEP.AmmoEnt = "nil"
SWEP.ViewModel = "models/weapons/v_watch.mdl"
SWEP.WorldModel = "models/weapons/w_watch.mdl"
SWEP.AllowDrop = false
SWEP.IsSilent = false
SWEP.NoSignts = false
SWEP.CanBuy = {ROLE_TRAITOR, ROLE_DETECTIVE}

function SWEP:OnDrop()
	self:Remove()
end
