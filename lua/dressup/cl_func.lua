function DressUp:GlobalMessage(msg)
    chat.AddText(Color(67,114,224), "[" .. DressUp.Config.MessageTitle .. "] ", Color(255,255,255),msg)
end

function DressUp:ClientModelMenuReLoad()
    for class,tbl in pairs(DressUp.MyData.ModelItems)do
        if(not DressUp.HoverModelClientModels[class])then
            DressUp.HoverModelClientModels[class] = {}
        end

        for i=1, #DressUp.MyData.ModelItems[class] do
            if !DressUp.Decorations[DressUp.MyData.ModelItems[class][i].class] then continue end
            DressUp.HoverModelClientModels[class][i] = ClientsideModel(DressUp.Decorations[DressUp.MyData.ModelItems[class][i].class].Model, RENDERGROUP_OPAQUE)
            DressUp.HoverModelClientModels[class][i]:SetNoDraw(true)
        end
    end
end 

function DressUp:ClearDecorations(class)
    Derma_Query(
    DressUp.Language.ClearMessage,
    DressUp.Language.ClearTitle,
    DressUp.Language.Yes,
    function() 
        net.Start("DressUp_ClearDecoration")
        net.WriteString(class)
        net.SendToServer()

        DressUp:CloseAllPanel()
        timer.Simple(0.5, function()
            DressUp:EditDecorations(class)
        end)
    end,
	DressUp.Language.No,
	function() end)
end

function DressUp:EditDecorations(class)
    DressUp:CloseAllPanel()

    local ply = LocalPlayer()

    if(IsValid(DressUp.Menu.Frame))then
        if IsValid(DressUp.Menu.EditDecorationPanel) then
            DressUp.Menu.EditDecorationPanel:SetVisible(false)
            DressUp.Menu.EditDecorationPanel = nil
        end

        DressUp.Menu.EditDecorationPanel = vgui.Create("DScrollPanel", DressUp.Menu.Frame)
        DressUp.Menu.EditDecorationPanel:SetPos(0, 80)
        DressUp.Menu.EditDecorationPanel:SetSize(DressUp.Menu.WIDTH-420, DressUp.Menu.HEIGHT-80)
        DressUp.Menu.EditDecorationPanel:SetVisible(true)
        local vbar = DressUp.Menu.EditDecorationPanel:GetVBar()
        vbar:SetWide(10)

        function vbar:Paint(w,h) end
        function vbar.btnUp:Paint(w,h) end
        function vbar.btnDown:Paint(w,h) end
        function vbar.btnGrip:Paint(w, h)
            draw.RoundedBox(5,1,0,w-2,h,Color(50, 50, 50, 150))
        end

        DressUp.Menu.EditDecorationPanel.Paint = function(self,w,h) end

        if(!DressUp.PlayerModels[class])then return end

        local modelTbl = DressUp.PlayerModels[class]
        DressUp.Menu.PreviewPanel:SetModel(DressUp.PlayerModels[class].Model)

        DressUp.Menu.ModelPanel = vgui.Create("DPanel", DressUp.Menu.EditDecorationPanel)
        DressUp.Menu.ModelPanel:SetPos(20, 5)
        DressUp.Menu.ModelPanel:SetSize(200, 80)
        DressUp.Menu.ModelPanel.Paint = function(self,w,h)
            draw.RoundedBox(5, 0, 0, w, h, Color(57, 60, 67))
            draw.RoundedBox(5, 1, 1, w-2, h-2, Color(33, 36, 43))
        end

        local SpawnIcon = vgui.Create( "SpawnIcon" , DressUp.Menu.ModelPanel )
        SpawnIcon:SetPos( 2, 2 )
        SpawnIcon:SetSize(80, 80)
        SpawnIcon:SetModel(modelTbl.Model)

        local button = vgui.Create("DButton", DressUp.Menu.ModelPanel)
        button:SetSize(200,80)
        button:SetText("")
        button.Paint = function(self,w,h)
            if(self:IsHovered())then
                draw.RoundedBox(5, 1, 1, w-2, h-2, Color(150,150,150,10))
            end
            draw.SimpleText(modelTbl.Name, "DU_Menu_ItemName", 140, 40, Color(255, 255, 255), 1, 1)
        end

        button.DoClick = function()
            local Menu = DermaMenu()

            local subMenu, AddOption = Menu:AddSubMenu(DressUp.Language.Add)
            AddOption:SetIcon("icon16/add.png")

            if(#DressUp.MyData.Items > 0)then
                for k,itemClass in pairs(DressUp.MyData.Items)do
                    if(!DressUp.Decorations[itemClass])then continue end
                    subMenu:AddOption(DressUp.Decorations[itemClass].Name, function() DressUp:AddDecoration(class, itemClass) end)
                end
            else
                local empty = subMenu:AddOption(DressUp.Language.No_Decorations)
                empty:SetIcon("icon16/cancel.png")
            end

            local ClearAll = Menu:AddOption( DressUp.Language.Remove_Decorations )
            ClearAll:SetIcon( "icon16/delete.png" )
            function ClearAll:DoClick()
                DressUp:ClearDecorations(class)
            end

            Menu:Open()
        end

        DressUp.Menu.SelectModelGrid = vgui.Create("DGrid", DressUp.Menu.EditDecorationPanel)
        DressUp.Menu.SelectModelGrid:SetPos(20, 100)
        DressUp.Menu.SelectModelGrid:SetCols(1)
        DressUp.Menu.SelectModelGrid:SetColWide(DressUp.Menu.WIDTH-420-40)
        DressUp.Menu.SelectModelGrid:SetRowHeight(90)

        local nums = DressUp.Config.MaxDecorations

        if(DressUp.MyData.ModelItems[class] && #DressUp.MyData.ModelItems[class] > nums)then
            nums = #DressUp.MyData.ModelItems[class]
        end

        local modelItems = DressUp.MyData.ModelItems[class] or {}

        for i=1, nums do
            local itemTbl = modelItems[i] or nil

            local item = nil
            if(itemTbl)then
                item = DressUp.Decorations[itemTbl.class] or nil
            end

            local panel = vgui.Create("DPanel")
            panel:SetSize(DressUp.Menu.WIDTH-420-40, 80)

            panel.Paint = function(self,w,h)
                draw.RoundedBox(5, 0, 0, w, h, Color(57, 60, 67))
                draw.RoundedBox(5, 1, 1, w-2, h-2, Color(33, 36, 43))
            end

            if(item)then
                local DModelPanel = vgui.Create("DModelPanel", panel)
                DModelPanel:SetPos(5, 5)
                DModelPanel:SetModel(item.Model)
                DModelPanel:SetSize(70,70)
                DModelPanel:SetLookAt(DModelPanel.Entity:GetPos() + Vector(0,0,0))
                DModelPanel:SetCamPos(DModelPanel.Entity:GetPos() + Vector(30,0,0))
            end

            local button = vgui.Create("DButton", panel)
            button:SetSize(DressUp.Menu.WIDTH-420-40, 80)
            button:SetText("")
            button.Paint = function(self,w,h)
                if(self:IsHovered())then
                    draw.RoundedBox(5, 1, 1, w-2, h-2, Color(150,150,150,10))
                end
                draw.SimpleText(item and i .. "." .. item.Name or "", "DU_Menu_ItemName", 100, 40, Color(255, 255, 255), 0, 1)
            end

            button.DoClick = function()
                if(!itemTbl)then return end

                local Menu = DermaMenu()
                    
                local Edit = Menu:AddOption( DressUp.Language.Edit )
                Edit:SetIcon( "icon16/wand.png" )
                function Edit:DoClick()
                    DressUp:EditItem(class, i)
                end

                local Holster = Menu:AddOption( DressUp.Language.Holster )
                Holster:SetIcon( "icon16/cancel.png" )
                function Holster:DoClick()
                    DressUp:HosterItem(class, i)
                end

                Menu:Open()
            end

            DressUp.Menu.SelectModelGrid:AddItem(panel)
        end
    end
end

function DressUp:AddDecoration(class, itemClass)
    net.Start("DressUp_AddDecoration")
    net.WriteTable({["class"] = class,["item"] = itemClass})
    net.SendToServer()

    if IsValid(DressUp.Menu.EditDecorationPanel) then
        DressUp.Menu.EditDecorationPanel:SetVisible(false)
        DressUp.Menu.EditDecorationPanel = nil
    end

    timer.Simple(0.5, function()
        DressUp:ClientModelMenuReLoad()
        DressUp:EditDecorations(class)
    end)
end

function DressUp:HosterItem(class, index)
    Derma_Query(
    DressUp.Language.HolsterMessage,
    DressUp.Language.HolsterTitle,
    DressUp.Language.Yes,
    function()
        net.Start("DressUp_HosterDecoration")
        net.WriteTable({["class"] = class,["index"] = index})
        net.SendToServer()

        if IsValid(DressUp.Menu.EditDecorationPanel) then
            DressUp.Menu.EditDecorationPanel:SetVisible(false)
            DressUp.Menu.EditDecorationPanel = nil
        end
    
        timer.Simple(0.5, function()
            DressUp:ClientModelMenuReLoad()
            DressUp:EditDecorations(class)
        end)
    end,
    DressUp.Language.No,
    function() end)
end

function DressUp:EditItem(modelClass, index)
    DressUp:CloseAllPanel()

    local ply = LocalPlayer()
    local itemClass = DressUp.MyData.ModelItems[modelClass][index].class

    local itemMeta = DressUp.Decorations[itemClass]

    local modelTbl = DressUp.PlayerModels[modelClass]
    DressUp.Menu.PreviewPanel:SetModel(modelTbl.Model)

    if(IsValid(DressUp.Menu.Frame))then
        if IsValid(DressUp.Menu.EditItemPanel) then
            DressUp.Menu.EditItemPanel:SetVisible(false)
            DressUp.Menu.EditItemPanel = nil
        end

        DressUp.Menu.EditItemPanel = vgui.Create("DScrollPanel", DressUp.Menu.Frame)
        DressUp.Menu.EditItemPanel:SetPos(0, 80)
        DressUp.Menu.EditItemPanel:SetSize(DressUp.Menu.WIDTH-420, DressUp.Menu.HEIGHT-80)
        DressUp.Menu.EditItemPanel:SetVisible(true)
        local vbar = DressUp.Menu.EditItemPanel:GetVBar()
        vbar:SetWide(10)

        function vbar:Paint(w,h) end
        function vbar.btnUp:Paint(w,h) end
        function vbar.btnDown:Paint(w,h) end
        function vbar.btnGrip:Paint(w, h)
            draw.RoundedBox(5,1,0,w-2,h,Color(50, 50, 50, 150))
        end

        DressUp.Menu.EditItemPanel.Paint = function(self,w,h) end

        DressUp.Menu.NowEditDecoration = vgui.Create("DPanel", DressUp.Menu.EditItemPanel)
        DressUp.Menu.NowEditDecoration:SetPos(20, 20)
        DressUp.Menu.NowEditDecoration:SetSize(200, 80)
        DressUp.Menu.NowEditDecoration.Paint = function(self,w,h)
            draw.RoundedBox(5, 0, 0, w, h, Color(57, 60, 67))
            draw.RoundedBox(5, 1, 1, w-2, h-2, Color(33, 36, 43))

            draw.SimpleText(itemMeta.Name, "DU_Menu_ItemName", w/2+h/2, h/2, Color(255, 255, 255), 1, 1)
        end

        local DModelPanel = vgui.Create("DModelPanel", DressUp.Menu.NowEditDecoration)
        DModelPanel:SetModel(itemMeta.Model)
        DModelPanel:SetSize(80,80)
        DModelPanel:SetLookAt(DModelPanel.Entity:GetPos() + Vector(0,0,0))
        DModelPanel:SetCamPos(DModelPanel.Entity:GetPos() + Vector(30,0,0))

        DressUp.Menu.EditItemCancelButton = vgui.Create("DButton", DressUp.Menu.EditItemPanel)
        DressUp.Menu.EditItemCancelButton:SetPos(DressUp.Menu.WIDTH-420-200, 20)
        DressUp.Menu.EditItemCancelButton:SetSize(180, 80)
        DressUp.Menu.EditItemCancelButton:SetText("")
        DressUp.Menu.EditItemCancelButton.Paint = function(self,w,h)
            draw.RoundedBox(5, 0, 0, w, h, Color(57, 60, 67))
            draw.RoundedBox(5, 1, 1, w-2, h-2, Color(33, 36, 43))

            if(self:IsHovered())then
                draw.RoundedBox(5, 1, 1, w-2, h-2, Color(150,150,150,10))
            end

            draw.SimpleText(DressUp.Language.Cancel, "DU_Menu_ItemName", w/2, h/2, Color(255, 255, 255), 1, 1)
        end
        DressUp.Menu.EditItemCancelButton.DoClick = function()
            Derma_Query(
            DressUp.Language.CancelMessage,
            DressUp.Language.CancelTitle,
            DressUp.Language.Yes,
            function()
                DressUp:CloseAllPanel()
                DressUp:EditDecorations(modelClass)
            end,
            DressUp.Language.No,
            function() end)
        end

        DressUp.Menu.EditItemBonePanel = vgui.Create("DPanel", DressUp.Menu.EditItemPanel)
        DressUp.Menu.EditItemBonePanel:SetPos(50, 115)
        DressUp.Menu.EditItemBonePanel:SetSize(DressUp.Menu.WIDTH-420-100, 60)
        DressUp.Menu.EditItemBonePanel.Paint = function(self,w,h)
            draw.RoundedBox(5, 0, 0, w, h, Color(57, 60, 67))
            draw.RoundedBox(5, 1, 1, w-2, h-2, Color(33, 36, 43))

            draw.RoundedBox(10, w*0.25+10, 7, w*0.75-20, 46, Color(26,29,36))

            draw.SimpleText(DressUp.Language.Bone, "DU_Menu_ItemName", w/8, h/2, Color(255, 255, 255), 1, 1)
        end

        DressUp.Menu.EditItemBoneComboBox = vgui.Create( "DComboBox" , DressUp.Menu.EditItemBonePanel )
        DressUp.Menu.EditItemBoneComboBox:SetPos( DressUp.Menu.EditItemBonePanel:GetWide()*0.25+10, 7 )
        DressUp.Menu.EditItemBoneComboBox:SetSize( DressUp.Menu.EditItemBonePanel:GetWide()*0.75-20, 43 )
        DressUp.Menu.EditItemBoneComboBox:SetValue(DressUp.MyData.ModelItems[modelClass][index].equipLocation)
        DressUp.Menu.EditItemBoneComboBox:SetFont("DU_Menu_ItemName")

        DressUp.Menu.EditItemBoneComboBox.Paint = function(self,w,h) end

        DressUp.Menu.EditItemBoneComboBox.OnSelect = function( _, _, value )
            DressUp.MyData.ModelItems[modelClass][index].equipLocation = value
        end

        if(istable(modelTbl:GetLimitBones(ply)))then
            for _, boneName in pairs(modelTbl:GetLimitBones(ply)) do
                if(DressUp.Menu.PreviewPanel.Entity:LookupBone(boneName))then
                    DressUp.Menu.EditItemBoneComboBox:AddChoice(boneName)
                end
            end
        else
            for _, boneName in pairs(table.GetKeys(DressUp.Config.DefaultBoneList)) do
                if(DressUp.Menu.PreviewPanel.Entity:LookupBone(boneName))then
                    DressUp.Menu.EditItemBoneComboBox:AddChoice(boneName)
                end
            end
        end

        DressUp.Menu.EditItemPositionPanel = vgui.Create("DPanel", DressUp.Menu.EditItemPanel)
        DressUp.Menu.EditItemPositionPanel:SetPos(50, 185)
        DressUp.Menu.EditItemPositionPanel:SetSize(DressUp.Menu.WIDTH-420-100, 60)
        DressUp.Menu.EditItemPositionPanel.Paint = function(self,w,h)
            draw.RoundedBox(5, 0, 0, w, h, Color(57, 60, 67))
            draw.RoundedBox(5, 1, 1, w-2, h-2, Color(33, 36, 43))

            draw.RoundedBox(10, w*0.25+10, 7, w*0.25-20, 46, Color(26,29,36))
            draw.RoundedBox(10, w*0.5+10, 7, w*0.25-20, 46, Color(26,29,36))
            draw.RoundedBox(10, w*0.75+10, 7, w*0.25-20, 46, Color(26,29,36))

            draw.SimpleText(DressUp.Language.Position, "DU_Menu_ItemName", w/8, h/2, Color(255, 255, 255), 1, 1)
        end

        DressUp.Menu.EditItemPositionXWang = vgui.Create("DNumberWang", DressUp.Menu.EditItemPositionPanel)
        DressUp.Menu.EditItemPositionXWang:SetPos(DressUp.Menu.EditItemPositionPanel:GetWide()*0.25+10, 7)
        DressUp.Menu.EditItemPositionXWang:SetSize(DressUp.Menu.EditItemPositionPanel:GetWide()*0.25-20, 46)
        DressUp.Menu.EditItemPositionXWang:SetFont("DU_Menu_ItemName")
        DressUp.Menu.EditItemPositionXWang:SetMin(itemMeta.PlacementLimit.min)
        DressUp.Menu.EditItemPositionXWang:SetMax(itemMeta.PlacementLimit.max)
        DressUp.Menu.EditItemPositionXWang:SetValue(DressUp.MyData.ModelItems[modelClass][index].adjustPlacement.x)
        DressUp.Menu.EditItemPositionXWang.Paint = function(self,w,h)
            self:DrawTextEntryText( Color( 81,81,81 ), Color( 30, 130, 255 ), Color( 81,81,81 ) )
        end

        function DressUp.Menu.EditItemPositionXWang:OnValueChanged(val)
            DressUp.MyData.ModelItems[modelClass][index].adjustPlacement.x = math.Clamp(val, itemMeta.PlacementLimit.min, itemMeta.PlacementLimit.max)
        end

        DressUp.Menu.EditItemPositionYWang = vgui.Create("DNumberWang", DressUp.Menu.EditItemPositionPanel)
        DressUp.Menu.EditItemPositionYWang:SetPos(DressUp.Menu.EditItemPositionPanel:GetWide()*0.5+10, 7)
        DressUp.Menu.EditItemPositionYWang:SetSize(DressUp.Menu.EditItemPositionPanel:GetWide()*0.25-20, 46)
        DressUp.Menu.EditItemPositionYWang:SetFont("DU_Menu_ItemName")
        DressUp.Menu.EditItemPositionYWang:SetMin(itemMeta.PlacementLimit.min)
        DressUp.Menu.EditItemPositionYWang:SetMax(itemMeta.PlacementLimit.max)
        DressUp.Menu.EditItemPositionYWang:SetValue(DressUp.MyData.ModelItems[modelClass][index].adjustPlacement.y)
        DressUp.Menu.EditItemPositionYWang.Paint = function(self,w,h)
            self:DrawTextEntryText( Color( 81,81,81 ), Color( 30, 130, 255 ), Color( 81,81,81 ) )
        end

        function DressUp.Menu.EditItemPositionYWang:OnValueChanged(val)
            DressUp.MyData.ModelItems[modelClass][index].adjustPlacement.y = math.Clamp(val, itemMeta.PlacementLimit.min, itemMeta.PlacementLimit.max)
        end

        DressUp.Menu.EditItemPositionZWang = vgui.Create("DNumberWang", DressUp.Menu.EditItemPositionPanel)
        DressUp.Menu.EditItemPositionZWang:SetPos(DressUp.Menu.EditItemPositionPanel:GetWide()*0.75+10, 7)
        DressUp.Menu.EditItemPositionZWang:SetSize(DressUp.Menu.EditItemPositionPanel:GetWide()*0.25-20, 46)
        DressUp.Menu.EditItemPositionZWang:SetFont("DU_Menu_ItemName")
        DressUp.Menu.EditItemPositionZWang:SetMin(itemMeta.PlacementLimit.min)
        DressUp.Menu.EditItemPositionZWang:SetMax(itemMeta.PlacementLimit.max)
        DressUp.Menu.EditItemPositionZWang:SetValue(DressUp.MyData.ModelItems[modelClass][index].adjustPlacement.z)
        DressUp.Menu.EditItemPositionZWang.Paint = function(self,w,h)
            self:DrawTextEntryText( Color( 81,81,81 ), Color( 30, 130, 255 ), Color( 81,81,81 ) )
        end

        function DressUp.Menu.EditItemPositionZWang:OnValueChanged(val)
            DressUp.MyData.ModelItems[modelClass][index].adjustPlacement.z = math.Clamp(val, itemMeta.PlacementLimit.min, itemMeta.PlacementLimit.max)
        end

        DressUp.Menu.EditItemAnglePanel = vgui.Create("DPanel", DressUp.Menu.EditItemPanel)
        DressUp.Menu.EditItemAnglePanel:SetPos(50, 255)
        DressUp.Menu.EditItemAnglePanel:SetSize(DressUp.Menu.WIDTH-420-100, 60)
        DressUp.Menu.EditItemAnglePanel.Paint = function(self,w,h)
            draw.RoundedBox(5, 0, 0, w, h, Color(57, 60, 67))
            draw.RoundedBox(5, 1, 1, w-2, h-2, Color(33, 36, 43))

            draw.RoundedBox(10, w*0.25+10, 7, w*0.25-20, 46, Color(26,29,36))
            draw.RoundedBox(10, w*0.5+10, 7, w*0.25-20, 46, Color(26,29,36))
            draw.RoundedBox(10, w*0.75+10, 7, w*0.25-20, 46, Color(26,29,36))

            draw.SimpleText(DressUp.Language.Angel, "DU_Menu_ItemName", w/8, h/2, Color(255, 255, 255), 1, 1)
        end

        DressUp.Menu.EditItemAnglePWang = vgui.Create("DNumberWang", DressUp.Menu.EditItemAnglePanel)
        DressUp.Menu.EditItemAnglePWang:SetPos(DressUp.Menu.EditItemAnglePanel:GetWide()*0.25+10, 7)
        DressUp.Menu.EditItemAnglePWang:SetSize(DressUp.Menu.EditItemAnglePanel:GetWide()*0.25-20, 46)
        DressUp.Menu.EditItemAnglePWang:SetFont("DU_Menu_ItemName")
        DressUp.Menu.EditItemAnglePWang:SetMin(itemMeta.AnglesLimit.min)
        DressUp.Menu.EditItemAnglePWang:SetMax(itemMeta.AnglesLimit.max)
        DressUp.Menu.EditItemAnglePWang:SetValue(DressUp.MyData.ModelItems[modelClass][index].adjustAngles.p)
        DressUp.Menu.EditItemAnglePWang.Paint = function(self,w,h)
            self:DrawTextEntryText( Color( 81,81,81 ), Color( 30, 130, 255 ), Color( 81,81,81 ) )
        end

        function DressUp.Menu.EditItemAnglePWang:OnValueChanged(val)
            DressUp.MyData.ModelItems[modelClass][index].adjustAngles.p = math.Clamp(val, itemMeta.AnglesLimit.min, itemMeta.AnglesLimit.max)
        end

        DressUp.Menu.EditItemAngleYWang = vgui.Create("DNumberWang", DressUp.Menu.EditItemAnglePanel)
        DressUp.Menu.EditItemAngleYWang:SetPos(DressUp.Menu.EditItemAnglePanel:GetWide()*0.5+10, 7)
        DressUp.Menu.EditItemAngleYWang:SetSize(DressUp.Menu.EditItemAnglePanel:GetWide()*0.25-20, 46)
        DressUp.Menu.EditItemAngleYWang:SetFont("DU_Menu_ItemName")
        DressUp.Menu.EditItemAngleYWang:SetMin(itemMeta.AnglesLimit.min)
        DressUp.Menu.EditItemAngleYWang:SetMax(itemMeta.AnglesLimit.max)
        DressUp.Menu.EditItemAngleYWang:SetValue(DressUp.MyData.ModelItems[modelClass][index].adjustAngles.y)
        DressUp.Menu.EditItemAngleYWang.Paint = function(self,w,h)
            self:DrawTextEntryText( Color( 81,81,81 ), Color( 30, 130, 255 ), Color( 81,81,81 ) )
        end

        function DressUp.Menu.EditItemAngleYWang:OnValueChanged(val)
            DressUp.MyData.ModelItems[modelClass][index].adjustAngles.y = math.Clamp(val, itemMeta.AnglesLimit.min, itemMeta.AnglesLimit.max)
        end

        DressUp.Menu.EditItemAngleRWang = vgui.Create("DNumberWang", DressUp.Menu.EditItemAnglePanel)
        DressUp.Menu.EditItemAngleRWang:SetPos(DressUp.Menu.EditItemAnglePanel:GetWide()*0.75+10, 7)
        DressUp.Menu.EditItemAngleRWang:SetSize(DressUp.Menu.EditItemAnglePanel:GetWide()*0.25-20, 46)
        DressUp.Menu.EditItemAngleRWang:SetFont("DU_Menu_ItemName")
        DressUp.Menu.EditItemAngleRWang:SetMin(itemMeta.AnglesLimit.min)
        DressUp.Menu.EditItemAngleRWang:SetMax(itemMeta.AnglesLimit.max)
        DressUp.Menu.EditItemAngleRWang:SetValue(DressUp.MyData.ModelItems[modelClass][index].adjustAngles.r)
        DressUp.Menu.EditItemAngleRWang.Paint = function(self,w,h)
            self:DrawTextEntryText( Color( 81,81,81 ), Color( 30, 130, 255 ), Color( 81,81,81 ) )
        end

        function DressUp.Menu.EditItemAngleRWang:OnValueChanged(val)
            DressUp.MyData.ModelItems[modelClass][index].adjustAngles.r = math.Clamp(val, itemMeta.AnglesLimit.min, itemMeta.AnglesLimit.max)
        end

        DressUp.Menu.EditItemSizePanel = vgui.Create("DPanel", DressUp.Menu.EditItemPanel)
        DressUp.Menu.EditItemSizePanel:SetPos(50, 325)
        DressUp.Menu.EditItemSizePanel:SetSize(DressUp.Menu.WIDTH-420-100, 60)
        DressUp.Menu.EditItemSizePanel.Paint = function(self,w,h)
            draw.RoundedBox(5, 0, 0, w, h, Color(57, 60, 67))
            draw.RoundedBox(5, 1, 1, w-2, h-2, Color(33, 36, 43))

            draw.RoundedBox(10, w*0.25+10, 7, w*0.25-20, 46, Color(26,29,36))
            draw.RoundedBox(10, w*0.5+10, 7, w*0.25-20, 46, Color(26,29,36))
            draw.RoundedBox(10, w*0.75+10, 7, w*0.25-20, 46, Color(26,29,36))

            draw.SimpleText(DressUp.Language.Size, "DU_Menu_ItemName", w/8, h/2, Color(255, 255, 255), 1, 1)
        end

        DressUp.Menu.EditItemSizeXWang = vgui.Create("DNumberWang", DressUp.Menu.EditItemSizePanel)
        DressUp.Menu.EditItemSizeXWang:SetPos(DressUp.Menu.EditItemSizePanel:GetWide()*0.25+10, 7)
        DressUp.Menu.EditItemSizeXWang:SetSize(DressUp.Menu.EditItemSizePanel:GetWide()*0.25-20, 46)
        DressUp.Menu.EditItemSizeXWang:SetFont("DU_Menu_ItemName")
        DressUp.Menu.EditItemSizeXWang:SetMin(itemMeta.SizeLimit.min)
        DressUp.Menu.EditItemSizeXWang:SetMax(itemMeta.SizeLimit.max)
        DressUp.Menu.EditItemSizeXWang:SetValue(DressUp.MyData.ModelItems[modelClass][index].adjustSize.x)
        DressUp.Menu.EditItemSizeXWang.Paint = function(self,w,h)
            self:DrawTextEntryText( Color( 81,81,81 ), Color( 30, 130, 255 ), Color( 81,81,81 ) )
        end

        function DressUp.Menu.EditItemSizeXWang:OnValueChanged(val)
            DressUp.MyData.ModelItems[modelClass][index].adjustSize.x = math.Clamp(val, itemMeta.SizeLimit.min, itemMeta.SizeLimit.max)
        end

        DressUp.Menu.EditItemSizeYWang = vgui.Create("DNumberWang", DressUp.Menu.EditItemSizePanel)
        DressUp.Menu.EditItemSizeYWang:SetPos(DressUp.Menu.EditItemSizePanel:GetWide()*0.5+10, 7)
        DressUp.Menu.EditItemSizeYWang:SetSize(DressUp.Menu.EditItemSizePanel:GetWide()*0.25-20, 46)
        DressUp.Menu.EditItemSizeYWang:SetFont("DU_Menu_ItemName")
        DressUp.Menu.EditItemSizeYWang:SetMin(itemMeta.SizeLimit.min)
        DressUp.Menu.EditItemSizeYWang:SetMax(itemMeta.SizeLimit.max)
        DressUp.Menu.EditItemSizeYWang:SetValue(DressUp.MyData.ModelItems[modelClass][index].adjustSize.y)
        DressUp.Menu.EditItemSizeYWang.Paint = function(self,w,h)
            self:DrawTextEntryText( Color( 81,81,81 ), Color( 30, 130, 255 ), Color( 81,81,81 ) )
        end

        function DressUp.Menu.EditItemSizeYWang:OnValueChanged(val)
            DressUp.MyData.ModelItems[modelClass][index].adjustSize.y = math.Clamp(val, itemMeta.SizeLimit.min, itemMeta.SizeLimit.max)
        end

        DressUp.Menu.EditItemSizeZWang = vgui.Create("DNumberWang", DressUp.Menu.EditItemSizePanel)
        DressUp.Menu.EditItemSizeZWang:SetPos(DressUp.Menu.EditItemSizePanel:GetWide()*0.75+10, 7)
        DressUp.Menu.EditItemSizeZWang:SetSize(DressUp.Menu.EditItemSizePanel:GetWide()*0.25-20, 46)
        DressUp.Menu.EditItemSizeZWang:SetFont("DU_Menu_ItemName")
        DressUp.Menu.EditItemSizeZWang:SetMin(itemMeta.SizeLimit.min)
        DressUp.Menu.EditItemSizeZWang:SetMax(itemMeta.SizeLimit.max)
        DressUp.Menu.EditItemSizeZWang:SetValue(DressUp.MyData.ModelItems[modelClass][index].adjustSize.z)
        DressUp.Menu.EditItemSizeZWang.Paint = function(self,w,h)
            self:DrawTextEntryText( Color( 81,81,81 ), Color( 30, 130, 255 ), Color( 81,81,81 ) )
        end

        function DressUp.Menu.EditItemSizeZWang:OnValueChanged(val)
            DressUp.MyData.ModelItems[modelClass][index].adjustSize.z = math.Clamp(val, itemMeta.SizeLimit.min, itemMeta.SizeLimit.max)
        end

        DressUp.Menu.EditItemDoneButton = vgui.Create("DButton", DressUp.Menu.EditItemPanel)
        DressUp.Menu.EditItemDoneButton:SetPos(DressUp.Menu.EditItemPanel:GetWide()/2-90, 395)
        DressUp.Menu.EditItemDoneButton:SetSize(180, 80)
        DressUp.Menu.EditItemDoneButton:SetText("")
        DressUp.Menu.EditItemDoneButton.Paint = function(self,w,h)
            draw.RoundedBox(5, 0, 0, w, h, Color(57, 60, 67))
            draw.RoundedBox(5, 1, 1, w-2, h-2, Color(33, 36, 43))

            if(self:IsHovered())then
                draw.RoundedBox(5, 1, 1, w-2, h-2, Color(150,150,150,10))
            end

            draw.SimpleText(DressUp.Language.Done, "DU_Menu_ItemName", w/2, h/2, Color(255, 255, 255), 1, 1)
        end

        DressUp.Menu.EditItemDoneButton.DoClick = function()
            Derma_Query(
            DressUp.Language.SaveMessage,
            DressUp.Language.SaveTitle,
            DressUp.Language.Yes,
            function()
                local tbl = {
                    ["modelClass"] = modelClass,
                    ["index"] = index,
                    ["data"] = DressUp.MyData.ModelItems[modelClass][index],
                }

                net.Start("DressUp_SaveDecoration")
                net.WriteTable(tbl)
                net.SendToServer()

                DressUp:CloseAllPanel()
                DressUp:EditDecorations(modelClass)
            end,
            DressUp.Language.No,
            function() end)
        end
    end
end