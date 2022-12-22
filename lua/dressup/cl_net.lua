net.Receive("DressUp_OpenPanel", function()
    DressUp:OpenPanel()
end)

net.Receive("DressUp_GlobalMessage", function()
    local msg = net.ReadString()

    DressUp:GlobalMessage(msg)
end)

net.Receive("DressUp_SendData", function()
    local dataBytes = net.ReadUInt(16)
    local dataJson = net.ReadData(dataBytes)
    
    local dataTable = util.JSONToTable(util.Decompress(dataJson))

    DressUp.Menu.OrignialData = table.Copy(dataTable)
    DressUp.MyData = table.Copy(dataTable)
end)

net.Receive("DressUp_SendPlayerAttachments", function()
    local dataBytes = net.ReadUInt(16)
    local dataJson = net.ReadData(dataBytes)
    local ply = net.ReadEntity()

    local dataTable = util.JSONToTable(util.Decompress(dataJson))

    DressUp.PlayerAttachMents[ply] = DressUp.PlayerAttachMents[ply] or {}
    DressUp.PlayerItemTable[ply] = dataTable

    for i=1, #DressUp.PlayerAttachMents[ply] do
        DressUp.PlayerAttachMents[ply][i]:SetNoDraw(true)
    end

    for i=1, #dataTable do
        if(!DressUp.Decorations[dataTable[i].class])then continue end

        local attach = DressUp.PlayerAttachMents[ply][i]
        if(!attach)then
            DressUp.PlayerAttachMents[ply][i] = ClientsideModel(DressUp.Decorations[dataTable[i].class].Model, RENDERGROUP_OPAQUE)
            attach = DressUp.PlayerAttachMents[ply][i]
        else
            attach:SetModel(DressUp.Decorations[dataTable[i].class].Model)
        end

        attach:DrawModel()
    end
end)

net.Receive("DressUp_SaveAdminData", function()
    local p = net.ReadEntity()
    local dataByte = net.ReadUInt(16)
    local dataJson = net.ReadData(dataByte)
    local dataTable = util.JSONToTable(util.Decompress(dataJson))

    DressUp.AdminData[p] = dataTable
end)