DressUp.Config = {}

DressUp.Config.CommunityName = "DressUp"           --Menu Title

DressUp.Config.MessageTitle = "DressUp"			--Chat box prefix

DressUp.Config.MaxDecorations = 5                   --The maximum number of decorations that each model can wear(You can customize different models in the playermodels file)

DressUp.Config.DataProvider = "flatfile"               --DataProvider(pdata、flatfile、mysql)

DressUp.Config.MenuKey = "F4"                       --Key to open the menu(F1-F12)

DressUp.Config.MenuChatCommand = "!dressup"         --Chat command to open the menu

DressUp.Config.MenuCommand = "dressup"         --Console command to open the menu

DressUp.Config.AdminCanAccessAdminTab = true        --Can Admin use Admin Panel?
DressUp.Config.SuperAdminCanAccessAdminTab = true   --Can Superadmin use Admin Panel?

DressUp.Config.DefaultBoneList = {				--List of bones that can be bound by default
    ["ValveBiped.Bip01_Head1"] = true,
    ["ValveBiped.Bip01_Spine"] = true,
    ["ValveBiped.Bip01_Spine1"] = true,
    ["ValveBiped.Bip01_Spine2"] = true,
    ["ValveBiped.Bip01_R_UpperArm"] = true,
    ["ValveBiped.Bip01_L_UpperArm"] = true,
    ["ValveBiped.Bip01_R_Forearm"] = true,
    ["ValveBiped.Bip01_L_Forearm"] = true,
    ["ValveBiped.Bip01_R_Hand"] = true,
    ["ValveBiped.Bip01_L_Hand"] = true,
    ["ValveBiped.Bip01_Pelvis"] = true,
    ["ValveBiped.Bip01_L_Thigh"] = true,
    ["ValveBiped.Bip01_R_Thigh"] = true,
    ["ValveBiped.Bip01_R_Calf"] = true,
    ["ValveBiped.Bip01_L_Calf"] = true,
    ["ValveBiped.Bip01_R_Foot"] = true,
    ["ValveBiped.Bip01_L_Foot"] = true,
}

DressUp.Config.CalculateBuyPrice = function(ply, item)   --Calculate purchase price
	return item.Price
end

DressUp.Config.CalculateSellPrice = function(ply, item)      --Calculate sell price
	return math.Round(item.Price * 0.75)
end

DressUp.Config.PS_PointName = function()
    return PS.Config.PointsName
end

DressUp.Config.PS_GetPoints = function(ply)
    return ply:PS_GetPoints()
end

DressUp.Config.PS_GivePoints = function(ply, points)
    ply:PS_GivePoints(points)
end

DressUp.Config.PS_TakePoints = function(ply, points)
    ply:PS_TakePoints(points)
end

DressUp.Config.PS_Notify = function(ply, msg)
    ply:PS_Notify(msg)
end