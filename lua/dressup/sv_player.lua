local Player = FindMetaTable("Player")

function Player:DressUp_OpenPanel()
    net.Start("DressUp_OpenPanel")
    net.Send(self)
end

function Player:DressUp_GlobalMessage(msg)
    net.Start("DressUp_GlobalMessage")
    net.WriteString(msg)
    net.Send(self)
end

function Player:DressUp_CheckPlayerData()
    DressUp:CheckPlayerData(self)
end

function Player:DressUp_SendData()
    local dataJson = util.Compress(util.TableToJSON(self.DressUp_Data or {}))
    local dataBytes = #dataJson

    net.Start("DressUp_SendData")
    net.WriteUInt(dataBytes, 16)
    net.WriteData(dataJson, dataBytes)
    net.Send(self)
end

function Player:DressUp_SaveData()
    DressUp:SavePlayerData(self)
end

function Player:DressUp_GiveItem(class)
    self.DressUp_Data.Items[#self.DressUp_Data.Items + 1] = class

    self:DressUp_SaveData()
    self:DressUp_SendData()
end

function Player:DressUp_TakeItem(class)
    table.RemoveByValue(self.DressUp_Data.Items, class)

    self:DressUp_SaveData()
    self:DressUp_SendData()
end

function Player:DressUp_HasItem(itemClass)
    return table.HasValue(self.DressUp_Data.Items, itemClass)
end

function Player:DressUp_SendAttachData(model)
    local tbl = table.GetByMemberValue(DressUp.PlayerModels, "Model", model)

    if(istable(tbl) && istable(self.DressUp_Data))then
        local modelItems = self.DressUp_Data.ModelItems[tbl.Class]
		if(modelItems)then
			local dataJson = util.Compress(util.TableToJSON(modelItems))
			local dataBytes = #dataJson

			net.Start("DressUp_SendPlayerAttachments")
			net.WriteUInt(dataBytes, 16)
			net.WriteData(dataJson, dataBytes)
			net.WriteEntity(self)
			net.Broadcast()
		end
    else
        local dataJson = util.Compress(util.TableToJSON({}))
		local dataBytes = #dataJson

        net.Start("DressUp_SendPlayerAttachments")
        net.WriteUInt(dataBytes, 16)
        net.WriteData(dataJson, dataBytes)
        net.WriteEntity(self)
        net.Broadcast()
    end
end

function Player:DressUp_AdminAccess()
    local canAccess = false

    if(DressUp.Config.AdminCanAccessAdminTab && self:IsAdmin())then
        canAccess = true
    end

    if(DressUp.Config.SuperAdminCanAccessAdminTab && self:IsSuperAdmin())then
        canAccess = true
    end

    return canAccess
end

function Player:DressUp_SendAdminData()
    for k,p in pairs(player.GetAll())do
        if(p:IsBot())then continue end

        local dataJson = util.Compress(util.TableToJSON(p.DressUp_Data))
        local dataByte = #dataJson

        net.Start("DressUp_SaveAdminData")
        net.WriteEntity(p)
        net.WriteUInt(dataByte, 16)
        net.WriteData(dataJson, dataByte)
        net.Send(self)
    end
end

function Player:DressUp_CheckErrorItems()
    local errorItem = 0

    for k,v in pairs(table.Copy(self.DressUp_Data.Items))do
        if(!DressUp.Decorations[v])then
            errorItem = errorItem + 1
            table.RemoveByValue(self.DressUp_Data.Items, v)
        end
    end

    local tmp = table.Copy(self.DressUp_Data.ModelItems)
    for modelClass,modelTbl in pairs(tmp)do
        for i=#modelTbl, 1, -1 do
            if(!DressUp.Decorations[modelTbl[i].class])then
                errorItem = errorItem + 1
                table.remove(self.DressUp_Data.ModelItems[modelClass], i)
            end
        end
    end

    if(errorItem > 0)then
        self:DressUp_SaveData()
        self:DressUp_SendData()
    end
end