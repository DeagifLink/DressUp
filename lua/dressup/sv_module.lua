util.AddNetworkString("DressUp_OpenPanel")
util.AddNetworkString("DressUp_GlobalMessage")
util.AddNetworkString("DressUp_SendData")
util.AddNetworkString("Dressup_BuyItem")
util.AddNetworkString("Dressup_SellItem")
util.AddNetworkString("DressUp_ClearDecoration")
util.AddNetworkString("DressUp_AddDecoration")
util.AddNetworkString("DressUp_HosterDecoration")
util.AddNetworkString("DressUp_SendPlayerAttachments")
util.AddNetworkString("DressUp_SaveDecoration")
util.AddNetworkString("DressUp_SaveAdminData")

--Chat Command
hook.Add("PlayerSay","DressUp_Chat",function(ply,txt,bTeam)
    if(string.lower(txt) == DressUp.Config.MenuChatCommand)then
        if(ply:DressUp_AdminAccess())then
            ply:DressUp_SendAdminData()
        end

        ply:DressUp_SendData()
		ply:DressUp_OpenPanel()
    end
end)

--Console Command
concommand.Add( DressUp.Config.MenuCommand, function( ply, cmd, args )
    if(ply:DressUp_AdminAccess())then
        ply:DressUp_SendAdminData()
    end

    ply:DressUp_SendData()
    ply:DressUp_OpenPanel()
end )

--Check data when player initial spawn
hook.Add("PlayerInitialSpawn", "DressUp_PlyInit", function(ply)
	timer.Simple(0, function()
		ply:DressUp_CheckPlayerData()
        timer.Simple(5, function()
            ply:DressUp_CheckErrorItems()
        end)
	end)
end)

--Dress up player when player SetModel
hook.Add("Player_SetModel", "DressUp_InitDecorations", function(ply, model)
	ply:DressUp_SendAttachData(model)
end)

--Save player data when the player leaves the server
hook.Add( "PlayerDisconnected", "DressUp_Playerleave", function(ply)
    ply:DressUp_SaveData()
end )

--Save players' data when server shutdown
hook.Add( "ShutDown", "DressUp_ShutDown", function()
    for k,p in pairs(player.GetAll())do
        p:DressUp_SaveData()
    end
end )

concommand.Add("dressup_giveitem", function(ply,cmd,args)
    if(ply:DressUp_AdminAccess() or !ply:IsPlayer())then
        local steamid64 = args[1]
        local item_class = args[2]

        local targetPlayer = player.GetBySteamID64(steamid64)
        if(!IsValid(targetPlayer))then
            if(!ply:IsPlayer())then
                print(DressUp.Language.InvalidPlayer)
            else
				DressUp.Config.PS_Notify(ply, DressUp.Language.InvalidPlayer)
            end
            return
        end

        local item = DressUp.Decorations[item_class]
        if(!item)then
            if(!ply:IsPlayer())then
                print(DressUp.Language.InvalidItem)
            else
                DressUp.Config.PS_Notify(ply, DressUp.Language.InvalidItem)
            end
            return
        end

        targetPlayer:DressUp_GiveItem(item_class)
        DressUp.Config.PS_Notify(ply, string.format(DressUp.Language.GiveItem, targetPlayer:Name(), item.Name))
        DressUp.Config.PS_Notify(targetPlayer, string.format(DressUp.Language.GetItem, targetPlayer:Name(), item.Name))
        ply:DressUp_SendAdminData()
    end
end)

concommand.Add("dressup_takeitem", function(ply,cmd,args)
    if(ply:DressUp_AdminAccess() or !ply:IsPlayer())then
        local steamid64 = args[1]
        local item_class = args[2]

        local targetPlayer = player.GetBySteamID64(steamid64)
        if(!IsValid(targetPlayer))then
            if(!ply:IsPlayer())then
                print(DressUp.Language.InvalidPlayer)
            else
                DressUp.Config.PS_Notify(ply, DressUp.Language.InvalidPlayer)
            end
            return
        end

        if(!targetPlayer:DressUp_HasItem(item_class))then
            if(!ply:IsPlayer())then
                print(DressUp.Language.InvalidItem)
            else
                DressUp.Config.PS_Notify(ply, DressUp.Language.InvalidItem)
            end
            return
        end

        local item = DressUp.Decorations[item_class]

        targetPlayer:DressUp_TakeItem(item_class)
        DressUp.Config.PS_Notify(ply, string.format(DressUp.Language.TakeItem, ((item and item.Name) or item_class), targetPlayer:Name()))
        ply:DressUp_SendAdminData()
    end
end)

concommand.Add("dressup_takemodelitem", function(ply,cmd,args)
    if(ply:DressUp_AdminAccess() or !ply:IsPlayer())then
        local steamid64 = args[1]
        local model_class = args[2]
        local item_index = tonumber(args[3])

        local targetPlayer = player.GetBySteamID64(steamid64)
        if(!IsValid(targetPlayer))then
            if(!ply:IsPlayer())then
                print(DressUp.Language.InvalidPlayer)
            else
                DressUp.Config.PS_Notify(ply, DressUp.Language.InvalidPlayer)
            end
            return
        end

        if(!targetPlayer.DressUp_Data.ModelItems[model_class] or !DressUp.PlayerModels[model_class])then
            if(!ply:IsPlayer())then
                print(DressUp.Language.InvalidModel)
            else
                DressUp.Config.PS_Notify(ply, DressUp.Language.InvalidModel)
            end
            return
        end

        local itemTbl = targetPlayer.DressUp_Data.ModelItems[model_class][item_index]

        if(!itemTbl or !DressUp.Decorations[itemTbl.class])then
            if(!ply:IsPlayer())then
                print(DressUp.Language.InvalidItem)
            else
                DressUp.Config.PS_Notify(ply, DressUp.Language.InvalidItem)
            end
            return
        end

        local item = DressUp.Decorations[itemTbl.class]

        table.remove(targetPlayer.DressUp_Data.ModelItems[model_class], item_index)

        DressUp.Config.PS_Notify(ply, string.format(DressUp.Language.TakeModelItem, DressUp.PlayerModels[model_class].Name, ((item and item.Name) or item_class), targetPlayer:Name()))
        
        targetPlayer:DressUp_SaveData()
        targetPlayer:DressUp_SendData()

        ply:DressUp_SendAttachData(ply:GetModel())
        
        ply:DressUp_SendAdminData()
    end
end)