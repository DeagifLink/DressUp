PLAYERMODEL.Name = "Dr.Kleiner"
PLAYERMODEL.Model = "models/player/kleiner.mdl"

function PLAYERMODEL:GetMaxDecorations(ply)
    return DressUp.Config.MaxDecorations
end

function PLAYERMODEL:GetLimitBones(ply)
    return false
end