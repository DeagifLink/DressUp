--Override SetModel function, make it run the hook
local Entity = FindMetaTable("Entity")

if ( !Entity.SetNewModel ) then Entity.SetNewModel = Entity.SetModel; end

function Entity:SetModel(model)
    if(self:IsPlayer())then
        hook.Run("Player_SetModel", self, model)
    end
	self:SetNewModel(model)
end