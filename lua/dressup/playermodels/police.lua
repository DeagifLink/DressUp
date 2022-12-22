PLAYERMODEL.Name = "Police"
PLAYERMODEL.Model = "models/player/police.mdl"

function PLAYERMODEL:GetMaxDecorations(ply)
    return DressUp.Config.MaxDecorations
end

function PLAYERMODEL:GetLimitBones(ply)
    return false
end