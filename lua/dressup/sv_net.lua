net.Receive("Dressup_BuyItem", function(len,ply)
    local itemClass = net.ReadString()

    if(!DressUp.Decorations[itemClass])then
        DressUp.Config.PS_Notify(ply, DressUp.Language.NoFoundItem)
        return
    end

    local item = DressUp.Decorations[itemClass]

    if(!table.IsEmpty(item.AllowedUserGroups) && !table.HasValue(item.AllowedUserGroups, ply:GetUserGroup()))then
        DressUp.Config.PS_Notify(ply, DressUp.Language.NoPermissionPurchase)
        return
    end

    local canbuy, msg = item.CanPlayerBuy(ply)
    if(!canbuy)then
        if(msg)then
            DressUp.Config.PS_Notify(ply, msg)
        end
        return
    end

    if(DressUp.Config.PS_GetPoints(ply) < DressUp.Config.CalculateBuyPrice(ply,item))then
        DressUp.Config.PS_Notify(ply, string.format(DressUp.Language.NoEnoughPoint, DressUp.Config.PS_PointName))
        return
    end

	DressUp.Config.PS_TakePoints(ply, DressUp.Config.CalculateBuyPrice(ply,item))
    ply:DressUp_GiveItem(item.Class)
    DressUp.Config.PS_Notify(ply, string.format(DressUp.Language.PurchaseSuccess, item.Name))
end)

net.Receive("Dressup_SellItem", function(len,ply)
    local itemClass = net.ReadString()

    if(!table.HasValue(ply.DressUp_Data.Items, itemClass))then
        DressUp.Config.PS_Notify(ply, DressUp.Language.NoHaveItem)
        return 
    end

    local item = DressUp.Decorations[itemClass]

    local cansell, msg = item.CanPlayerSell(ply)
    if(!cansell)then
        if(msg)then
            DressUp.Config.PS_Notify(ply, msg)
        end
        return
    end

	DressUp.Config.PS_GivePoints(ply, DressUp.Config.CalculateSellPrice(ply,item))
    ply:DressUp_TakeItem(item.Class)
    DressUp.Config.PS_Notify(ply, string.format(DressUp.Language.SellSuccess, item.Name))
end)

net.Receive("DressUp_ClearDecoration", function(len,ply)
    local modelClass = net.ReadString()

    local modelItemsTbl = ply.DressUp_Data.ModelItems[modelClass]
    if(!modelItemsTbl)then
        return
    end
    
    for i=1,DressUp.Config.MaxDecorations do
        local item = modelItemsTbl[i]

        if(item)then
            ply:DressUp_GiveItem(item.class)
        end

        ply.DressUp_Data.ModelItems[modelClass][i] = nil
    end

    ply:DressUp_SaveData()
    ply:DressUp_SendData()

    ply:DressUp_SendAttachData(ply:GetModel())

    DressUp.Config.PS_Notify(ply, DressUp.Language.CleanSuccess)
end)

net.Receive("DressUp_AddDecoration", function(len,ply)
    local tbl = net.ReadTable()

    if(!DressUp.PlayerModels[tbl.class] or !DressUp.Decorations[tbl.item])then
        return
    end

    if(!ply:DressUp_HasItem(tbl.item))then
        DressUp.Config.PS_Notify(ply, DressUp.Language.NoHaveItem)
        return
    end

    local modelItemsTbl = ply.DressUp_Data.ModelItems[tbl.class]
    if(!modelItemsTbl)then
        ply.DressUp_Data.ModelItems[tbl.class] = {}
        modelItemsTbl = {}
    end

    local modelTbl = DressUp.PlayerModels[tbl.class]
    local nums = modelTbl.GetMaxDecorations and modelTbl:GetMaxDecorations(ply) or DressUp.Config.MaxDecorations

    if(#modelItemsTbl >= nums)then
        DressUp.Config.PS_Notify(ply, string.format(DressUp.Language.MostWears, nums))
        return
    end

    local item = DressUp.Decorations[tbl.item]

    local canequip, msg = item:CanPlayerEquip(ply)
    if(!canequip)then
        if(msg)then
            DressUp.Config.PS_Notify(ply, msg)
        end
        return
    end

    ply.DressUp_Data.ModelItems[tbl.class][#modelItemsTbl + 1] = {
        ["class"] = item.Class,
        ["equipLocation"] = item.DefaultBone,
        ["adjustPlacement"] = item.DefaultPlacement,
        ["adjustAngles"] = item.DefaultAngles,
        ["adjustSize"] = item.DefaultSize,
    }

    ply:DressUp_TakeItem(tbl.item)

    ply:DressUp_SaveData()
    ply:DressUp_SendData()

    ply:DressUp_SendAttachData(ply:GetModel())

    DressUp.Config.PS_Notify(ply, DressUp.Language.AddDone)
end)

net.Receive("DressUp_HosterDecoration", function(len,ply)
    local tbl = net.ReadTable()

    if(!DressUp.PlayerModels[tbl.class])then
        DressUp.Config.PS_Notify(ply, DressUp.Language.InvalidModel)
        return
    end

    local modelItemsTbl = ply.DressUp_Data.ModelItems[tbl.class]
    if(!modelItemsTbl)then
        DressUp.Config.PS_Notify(ply, DressUp.Language.InvalidModel)
        return
    end

    local item = modelItemsTbl[tbl.index]

    if(!item)then
        DressUp.Config.PS_Notify(ply, DressUp.Language.NoHolster)
        return
    end

    table.remove(ply.DressUp_Data.ModelItems[tbl.class], tbl.index)

    ply:DressUp_GiveItem(item.class)

    ply:DressUp_SaveData()
    ply:DressUp_SendData()

    ply:DressUp_SendAttachData(ply:GetModel())

    DressUp.Config.PS_Notify(ply, string.format(DressUp.Language.HolsteredItem, DressUp.Decorations[item.class].Name))
end)

net.Receive("DressUp_SaveDecoration", function(len,ply)
    local tbl = net.ReadTable()

    local modelItemsTbl = ply.DressUp_Data.ModelItems[tbl.modelClass]
    if(!modelItemsTbl)then
        DressUp.Config.PS_Notify(ply, DressUp.Language.InvalidModel)
        return
    end

    local item = modelItemsTbl[tbl.index]
    if(!item)then
        DressUp.Config.PS_Notify(ply, DressUp.Language.NoSaved)
        return
    end

    local itemMeta = DressUp.Decorations[item.class]
    local modelMeta = DressUp.PlayerModels[tbl.modelClass]

    --Server correction (to prevent malicious tampering by the client to exceed the limit)
    if(!DressUp.Config.DefaultBoneList[tbl.data.equipLocation] or (istable(modelMeta:GetLimitBones(ply)) && !table.HasValue(modelMeta:GetLimitBones(ply), tbl.data.equipLocation)))then
        DressUp.Config.PS_Notify(ply, DressUp.Language.BoneError)
        return
    end

    tbl.data.adjustAngles.p = math.Clamp(tbl.data.adjustAngles.p, itemMeta.AnglesLimit.min, itemMeta.AnglesLimit.max)
    tbl.data.adjustAngles.r = math.Clamp(tbl.data.adjustAngles.r, itemMeta.AnglesLimit.min, itemMeta.AnglesLimit.max)
    tbl.data.adjustAngles.y = math.Clamp(tbl.data.adjustAngles.y, itemMeta.AnglesLimit.min, itemMeta.AnglesLimit.max)

    tbl.data.adjustPlacement.x = math.Clamp(tbl.data.adjustPlacement.x, itemMeta.PlacementLimit.min, itemMeta.PlacementLimit.max)
    tbl.data.adjustPlacement.y = math.Clamp(tbl.data.adjustPlacement.y, itemMeta.PlacementLimit.min, itemMeta.PlacementLimit.max)
    tbl.data.adjustPlacement.z = math.Clamp(tbl.data.adjustPlacement.z, itemMeta.PlacementLimit.min, itemMeta.PlacementLimit.max)

    tbl.data.adjustSize.x = math.Clamp(tbl.data.adjustSize.x, itemMeta.SizeLimit.min, itemMeta.SizeLimit.max)
    tbl.data.adjustSize.y = math.Clamp(tbl.data.adjustSize.y, itemMeta.SizeLimit.min, itemMeta.SizeLimit.max)
    tbl.data.adjustSize.z = math.Clamp(tbl.data.adjustSize.z, itemMeta.SizeLimit.min, itemMeta.SizeLimit.max)

    ply.DressUp_Data.ModelItems[tbl.modelClass][tbl.index] = tbl.data

    ply:DressUp_SaveData()
    ply:DressUp_SendData()

    ply:DressUp_SendAttachData(ply:GetModel())

    DressUp.Config.PS_Notify(ply, DressUp.Language.Saved)
end)