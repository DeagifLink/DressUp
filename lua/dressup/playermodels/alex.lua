PLAYERMODEL.Name = "Alex"
PLAYERMODEL.Model = "models/player/alyx.mdl"

function PLAYERMODEL:GetMaxDecorations(ply)
    return DressUp.Config.MaxDecorations
end

function PLAYERMODEL:GetLimitBones(ply)
    return false
end