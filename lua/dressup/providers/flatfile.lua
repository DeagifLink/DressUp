function DressUp:InitPlayerData(ply)
    if not file.IsDir("dressup", "DATA") then
		file.CreateDir("dressup")
	end

    local filename = string.Replace(ply:SteamID(), ':', '_')

    local newData = {
        Items = {},
        ModelItems = {},
    }

    file.Write("dressup/" .. filename .. ".txt", util.TableToJSON(newData))
    ply.DressUp_Data = newData

    ply:DressUp_SendData()
end

function DressUp:CheckPlayerData(ply)
    if not file.IsDir("dressup", "DATA") then
		file.CreateDir("dressup")
	end

    local filename = string.Replace(ply:SteamID(), ':', '_')

    if(!file.Exists("dressup/" .. filename .. ".txt", "DATA"))then
        DressUp:InitPlayerData(ply)
    else
        ply.DressUp_Data = util.JSONToTable(file.Read("dressup/" .. filename .. ".txt", "DATA"))
        ply:DressUp_SendData()
    end
end

function DressUp:SavePlayerData(ply)
    if not file.IsDir("dressup", "DATA") then
		file.CreateDir("dressup")
	end

    local filename = string.Replace(ply:SteamID(), ':', '_')

    local tmp = table.Copy(ply.DressUp_Data)
    file.Write("dressup/" .. filename .. ".txt", util.TableToJSON(tmp))
end