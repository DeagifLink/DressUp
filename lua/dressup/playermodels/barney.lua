PLAYERMODEL.Name = "Barney"
PLAYERMODEL.Model = "models/player/barney.mdl"

function PLAYERMODEL:GetMaxDecorations(ply)
    return DressUp.Config.MaxDecorations
end

function PLAYERMODEL:GetLimitBones(ply)
    return false
end