AddCSLuaFile("sh_init.lua")
AddCSLuaFile("sh_language.lua")
AddCSLuaFile("sh_config.lua")
AddCSLuaFile("sh_func.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_module.lua")
AddCSLuaFile("cl_preview.lua")
AddCSLuaFile("cl_net.lua")
AddCSLuaFile("cl_func.lua")
AddCSLuaFile("cl_font.lua")
AddCSLuaFile("cl_menu.lua")

include("sh_init.lua")
include("sh_config.lua")
include("sh_language.lua")
include("sh_func.lua")
include("sv_player.lua")
include("sv_entity.lua")
include("sv_module.lua")
include("sv_net.lua")

function DressUp:LoadDataProvider()
    include("providers/" .. DressUp.Config.DataProvider .. ".lua")
end
DressUp:LoadDataProvider()