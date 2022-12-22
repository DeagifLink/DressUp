DECORATION.Name = "Pan"
DECORATION.Model = "models/props_misc/pan-2.mdl"
DECORATION.Price = 1000

DECORATION.AllowedUserGroups = {}

DECORATION.DefaultBone = "ValveBiped.Bip01_Head1"

DECORATION.DefaultPlacement = {x = 9, y = 0, z = 1.5}
DECORATION.PlacementLimit = {min = -15, max = 15}

DECORATION.DefaultAngles = {p = 0, y = 0, r = 90}
DECORATION.AnglesLimit = {min = 0, max = 360}

DECORATION.DefaultSize = {x = 1, y = 1, z = 1}
DECORATION.SizeLimit = {min = 0.5, max = 1.5}

DECORATION.CanPlayerBuy = function(ply)
    return true
end

DECORATION.CanPlayerSell = function(ply)
    return true
end

function DECORATION:CanPlayerEquip(ply)
    return true
end