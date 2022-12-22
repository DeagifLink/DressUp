DressUp = DressUp or {}

MsgC(Color(0,255,0), "[DressUp] Loading...\n")

DressUp.PlayerModels = DressUp.PlayerModels or {}
function DressUp:LoadAllPlayerModels()
    DressUp.PlayerModels = {}

    local files, _ = file.Find("dressup/playermodels/*.lua", "LUA")
    for _, name in pairs(files)do
        name = string.Replace(name, ".lua", "")

        PLAYERMODEL = {}
        PLAYERMODEL.Class = name

        function PLAYERMODEL:GetMaxDecorations(ply)
            return DressUp.Config.MaxDecorations
        end

        function PLAYERMODEL:GetLimitBones(ply)
            return false
        end

        if(SERVER)then AddCSLuaFile("dressup/playermodels/" .. name .. ".lua") end
        include("dressup/playermodels/" .. name .. ".lua")

        if(!PLAYERMODEL.Name)then
            MsgC(Color(255, 0, 0), "[DressUp] Waring: " .. name .. " has no Name\n")
            continue
        end

        if(!PLAYERMODEL.Model)then
            MsgC(Color(255, 0, 0), "[DressUp] Waring: " .. name .. " has no Model\n")
            continue
        end

        DressUp.PlayerModels[name] = PLAYERMODEL

        PLAYERMODEL = {}
    end
end
DressUp:LoadAllPlayerModels()



DressUp.Decorations = DressUp.Decorations or {}
function DressUp:LoadAllDecorations()
    DressUp.Decorations = {}
    local emptyfunc = function() end

    local files, _ = file.Find("dressup/decorations/*.lua", "LUA")
    for _, name in pairs(files)do
        name = string.Replace(name, ".lua", "")

        DECORATION = {}
        DECORATION.Class = name
        DECORATION.AllowedUserGroups = {}

        DECORATION.CanPlayerBuy = function(ply)
            return true
        end
        
        DECORATION.CanPlayerSell = function(ply)
            return true
        end

        function DECORATION:CanPlayerEquip(ply)
            return true
        end

        DECORATION.GetLimitBones = {}

        DECORATION.DefaultBone = "ValveBiped.Bip01_Head1"

        DECORATION.DefaultPlacement = {x = 0, y = 0, z = 0}
        DECORATION.PlacementLimit = {min = -15, max = 15}

        DECORATION.DefaultAngles = {p = 0, y = 0, r = 0}
        DECORATION.AnglesLimit = {min = 0, max = 360}

        DECORATION.DefaultSize = {x = 1, y = 1, z = 1}
        DECORATION.SizeLimit = {min = 0.5, max = 1.5}

        if(SERVER)then AddCSLuaFile("dressup/decorations/" .. name .. ".lua") end
        include("dressup/decorations/" .. name .. ".lua")

        if(!DECORATION.Name)then
            MsgC(Color(255, 0, 0), "[DressUp] Waring: " .. name .. " has no Name\n")
            continue
        end

        if(!DECORATION.Model)then
            MsgC(Color(255, 0, 0), "[DressUp] Waring: " .. name .. " has no Model\n")
            continue
        end

        if(!DECORATION.Price)then
            MsgC(Color(255, 0, 0), "[DressUp] Waring: " .. name .. " has no Price\n")
            continue
        end

        DressUp.Decorations[name] = DECORATION

        DECORATION = {}
    end
end
DressUp:LoadAllDecorations()

MsgC(Color(0,255,0), "[DressUp] Loading completed!\n")