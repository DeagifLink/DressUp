function DressUp:InitPlayerData(ply)
    local newData = {
        Items = {},
        ModelItems = {},
    }

    ply:SetPData("Dressup_Data", util.TableToJSON(newData))
    ply.DressUp_Data = newData

    ply:DressUp_SendData()
end

function DressUp:CheckPlayerData(ply)
    local pdata = ply:GetPData("Dressup_Data", "")
    if(pdata == "")then
        DressUp:InitPlayerData(ply)
    else
        ply.DressUp_Data = util.JSONToTable(pdata)
        ply:DressUp_SendData()
    end
end

function DressUp:SavePlayerData(ply)
    local tmp = table.Copy(ply.DressUp_Data)

    ply:SetPData("Dressup_Data", util.TableToJSON(tmp))
end