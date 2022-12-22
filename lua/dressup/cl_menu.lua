DressUp.Menu = DressUp.Menu or {}
DressUp.Menu.Frame = DressUp.Menu.Frame or nil

DressUp.Menu.WIDTH = math.Clamp(1280, 0, ScrW())
DressUp.Menu.HEIGHT = 9/16 * DressUp.Menu.WIDTH

function DressUp:OpenPanel()
    if not DressUp.Menu.Frame then
        local ply = LocalPlayer()
        DressUp.Menu.NowPage = DressUp.Menu.Buttons[1].Name
        
        DressUp.Menu.WIDTH = math.Clamp(1280, 0, ScrW())
        DressUp.Menu.HEIGHT = 9/16 * DressUp.Menu.WIDTH

        DressUp.Menu.Frame = vgui.Create("DFrame")
        DressUp.Menu.Frame:SetSize(DressUp.Menu.WIDTH,DressUp.Menu.HEIGHT)
        DressUp.Menu.Frame:Center()
        DressUp.Menu.Frame:SetDraggable(false)
        DressUp.Menu.Frame:ShowCloseButton(false)
        DressUp.Menu.Frame:SetTitle("")
        DressUp.Menu.Frame:MakePopup()

        DressUp.Menu.Frame.Paint = function(self,w,h)
            draw.RoundedBox(10, 0, 0, w, h, Color(26,29,36))
            draw.RoundedBox(10, DressUp.Menu.WIDTH-420, 0, 420, DressUp.Menu.HEIGHT,Color(33,36,43))
            draw.RoundedBox(0, 20, 79, DressUp.Menu.WIDTH-420-40, 1, Color(100, 100, 100, 100))
            draw.RoundedBox(0, DressUp.Menu.WIDTH-420+20, 8, 64, 64, Color(100, 100, 100, 100))

            draw.SimpleText(DressUp.Config.CommunityName, "DU_Menu_Title", 100, 36, Color(255, 145, 145), 1, 1)
            draw.SimpleText("by D.Deagif", "DU_Menu_Title2", 130, 60, Color(49,71,94), 1, 1)
            draw.SimpleText(ply:Name(), "DU_Menu_PlayerName", DressUp.Menu.WIDTH-420+100, 28, Color(255, 255, 255), 0, 1)
            draw.SimpleText(DressUp.Config.PS_PointName() .. ": " .. DressUp.Config.PS_GetPoints(ply), "DU_Menu_PlayerPoints", DressUp.Menu.WIDTH-420+100, 50, Color(130, 130, 130), 0, 1)
        end

        DressUp.Menu.CloseButton = vgui.Create("DButton", DressUp.Menu.Frame)
        DressUp.Menu.CloseButton:SetPos(DressUp.Menu.WIDTH-60,20)
        DressUp.Menu.CloseButton:SetSize(40,40)
        DressUp.Menu.CloseButton:SetText("")
        DressUp.Menu.CloseButton.Paint = function(self,w,h)
            draw.SimpleText("×", "DU_Menu_Close", w/2, h/2, Color(255,255,255),1,1)
        end
        DressUp.Menu.CloseButton.DoClick = function()
            DressUp:ClientModelMenuReLoad()
            DressUp.Menu.Frame:SetVisible(false)
            DressUp.Menu.Frame = nil
        end

        DressUp.Menu.Avatar = vgui.Create("AvatarImage", DressUp.Menu.Frame)
        DressUp.Menu.Avatar:SetPos(DressUp.Menu.WIDTH-420+23,11)
        DressUp.Menu.Avatar:SetSize(58,58)
        DressUp.Menu.Avatar:SetPlayer(ply, 58)

        DressUp.Menu.PreviewPanel = vgui.Create('DModelPreview', DressUp.Menu.Frame)
        DressUp.Menu.PreviewPanel:SetModel(ply:GetModel())
        DressUp.Menu.PreviewPanel:SetSize(400, DressUp.Menu.HEIGHT-100)
        DressUp.Menu.PreviewPanel:SetPos(DressUp.Menu.WIDTH-410, 90)
        DressUp.Menu.PreviewPanel.ZoomHere = 50

        local btn_posX = 210
        for k, btn in pairs(DressUp.Menu.Buttons)do
            local button = vgui.Create("DButton", DressUp.Menu.Frame)
            button:SetSize(100,79)
            button:SetPos(btn_posX,0)
            button:SetText("")
            button.Paint = function(self,w,h)
                if(self:IsHovered() or DressUp.Menu.NowPage == btn.Name)then
                    draw.RoundedBox(0,0,0,w,h,Color(38, 41, 46))
                end

                draw.SimpleText(btn.Name, "DU_Menu_TheButton", w/2, h/2, Color(255,255,255),1,1)
            end

            button.DoClick = function()
                DressUp.Menu.NowPage = btn.Name
                btn.Func()
            end

            btn.Init()

            btn_posX = btn_posX + 100 
        end

        DressUp.Menu.Buttons[1].Func()
    end
end

function DressUp:CloseAllPanel()
    DressUp.Menu.PreviewPanel:SetModel(LocalPlayer():GetModel())

    DressUp.MyData = table.Copy(DressUp.Menu.OrignialData)

    DressUp.Menu.BuyDecorationPanel:SetVisible(false)
    DressUp.Menu.SelectModelPanel:SetVisible(false)
    DressUp.Menu.MyDecorationPanel:SetVisible(false)
    DressUp.Menu.AdminPanel:SetVisible(false)

    if(IsValid(DressUp.Menu.EditDecorationPanel))then
        DressUp.Menu.EditDecorationPanel:SetVisible(true)
    end

    if(IsValid(DressUp.Menu.EditDecorationPanel))then
        DressUp.Menu.EditDecorationPanel:SetVisible(false)
    end

    if(IsValid(DressUp.Menu.EditItemPanel))then
        DressUp.Menu.EditItemPanel:SetVisible(false)
    end

    for k,btn in pairs(DressUp.Menu.Buttons)do
        btn.Init()
    end
end

DressUp.Menu.Buttons = {
    {
        Name = DressUp.Language.ShopTitle,

        Func = function()
            DressUp:CloseAllPanel()

            DressUp:ClientModelMenuReLoad()

            DressUp.Menu.BuyDecorationPanel:SetVisible(true)
        end,

        Init = function()
            local ply = LocalPlayer()

            DressUp.Menu.BuyDecorationPanel = vgui.Create("DScrollPanel", DressUp.Menu.Frame)
            DressUp.Menu.BuyDecorationPanel:SetPos(0, 80)
            DressUp.Menu.BuyDecorationPanel:SetSize(DressUp.Menu.WIDTH-420, DressUp.Menu.HEIGHT-80)
            DressUp.Menu.BuyDecorationPanel:SetVisible(false)
            local vbar = DressUp.Menu.BuyDecorationPanel:GetVBar()
            vbar:SetWide(10)

            function vbar:Paint(w,h) end
            function vbar.btnUp:Paint(w,h) end
            function vbar.btnDown:Paint(w,h) end
            function vbar.btnGrip:Paint(w, h)
                draw.RoundedBox(5,1,0,w-2,h,Color(50, 50, 50, 150))
            end

            DressUp.Menu.BuyDecorationPanel.Paint = function(self,w,h) end

            DressUp.Menu.DecoratrionSearchShow = DressUp.Language.Search
            DressUp.Menu.DecoratrionTextEntry = vgui.Create("DTextEntry" , DressUp.Menu.BuyDecorationPanel)
            DressUp.Menu.DecoratrionTextEntry:SetPos(DressUp.Menu.WIDTH-420-250,10)
            DressUp.Menu.DecoratrionTextEntry:SetSize(220,42)
            DressUp.Menu.DecoratrionTextEntry:SetFont("DU_Menu_ItemName")
            DressUp.Menu.DecoratrionTextEntry.Paint = function(self,w,h)
                surface.SetDrawColor(60,62,60)
                surface.DrawOutlinedRect(0,0,w,h,2)
                self:DrawTextEntryText( Color( 60,62,60 ), Color( 155,155,231 ), Color( 255, 255, 255 ) )
                draw.SimpleText(DressUp.Menu.DecoratrionSearchShow,"DU_Menu_ItemName",3,h/2,Color(60,62,60),0,1)
            end

            local function DressUp_LoadMyDecoratrions(filter)
                if(DressUp.Menu.BuyDecorationGrid)then
                    DressUp.Menu.BuyDecorationGrid:SetVisible(false)
                    DressUp.Menu.BuyDecorationGrid = nil
                end

                local buttonWide = (DressUp.Menu.WIDTH-420-110)/5

                DressUp.Menu.BuyDecorationGrid = vgui.Create("DGrid", DressUp.Menu.BuyDecorationPanel)
                DressUp.Menu.BuyDecorationGrid:SetPos(35, 80)
                DressUp.Menu.BuyDecorationGrid:SetCols(5)
                DressUp.Menu.BuyDecorationGrid:SetColWide(buttonWide+10)
                DressUp.Menu.BuyDecorationGrid:SetRowHeight(buttonWide+10)

                for k,item in pairs(DressUp.Decorations)do
                    if(filter != "")then
                        local hasValue,_ = string.find(string.lower(item.Name), string.lower(filter))
                        if(!hasValue)then
                            continue
                        end
                    end

                    local panel = vgui.Create("DPanel")
                    panel:SetSize(buttonWide, buttonWide)
                    panel.Paint = function(self,w,h)
                        draw.RoundedBox(5, 0, 0, w, h, Color(57, 60, 67))
                        draw.RoundedBox(5, 1, 1, w-2, h-2, Color(33, 36, 43))
                    end

                    local DModelPanel = vgui.Create("DModelPanel", panel)
                    DModelPanel:SetModel(item.Model)
                    DModelPanel:SetSize(buttonWide,buttonWide)
                    DModelPanel:SetLookAt(DModelPanel.Entity:GetPos() + Vector(0,0,0))
                    DModelPanel:SetCamPos(DModelPanel.Entity:GetPos() + Vector(30,0,0))

                    local button = vgui.Create("DButton", panel)
                    button:SetSize(buttonWide,buttonWide)
                    button:SetText("")
                    button.Paint = function(self,w,h)
                        if(self:IsHovered())then
                            draw.RoundedBox(5, 1, 1, buttonWide-2, buttonWide-2, Color(150,150,150,10))
                            draw.RoundedBox(5, 1, buttonWide-20, buttonWide-2, 19, Color(0, 0, 0, 100))
                            draw.SimpleText("-" .. DressUp.Config.CalculateBuyPrice(ply,item), "DU_Menu_ItemName", buttonWide/2, buttonWide-11, Color(255, 255, 255), 1, 1)
                        else
                            draw.RoundedBox(5, 1, buttonWide-20, buttonWide-2, 19, Color(0, 0, 0, 100))
                            draw.SimpleText(item.Name, "DU_Menu_ItemName", buttonWide/2, buttonWide-11, Color(255, 255, 255), 1, 1)
                        end
                    end

                    button.DoClick = function()
                        local menu = DermaMenu()

                        menu:AddOption( DressUp.Language.Buy, function()
                            Derma_Query(
                                string.format(DressUp.Language.BuyMessage, item.Name),
                                DressUp.Language.BuyTitle,
                                DressUp.Language.Yes,
                                function() 
                                    net.Start("Dressup_BuyItem")
                                    net.WriteString(item.Class)
                                    net.SendToServer()
                                end,
                                DressUp.Language.No,
                                function() end
                            )
                        end )

                        menu:Open()
                    end

                    DressUp.Menu.BuyDecorationGrid:AddItem(panel)
                end
            end
            DressUp_LoadMyDecoratrions("")
            DressUp.Menu.DecoratrionTextEntry.OnChange = function()
                if(DressUp.Menu.DecoratrionSearchShow != "")then
                    DressUp.Menu.DecoratrionSearchShow = ""
                end
                DressUp_LoadMyDecoratrions(DressUp.Menu.DecoratrionTextEntry:GetValue())
            end
        end,
    },

    {
        Name = DressUp.Language.ModelsTitle,

        Func = function()
            DressUp:CloseAllPanel()

            DressUp:ClientModelMenuReLoad()

            DressUp.Menu.SelectModelPanel:SetVisible(true)
        end,

        Init = function()
            local ply = LocalPlayer()

            DressUp.Menu.SelectModelPanel = vgui.Create("DScrollPanel", DressUp.Menu.Frame)
            DressUp.Menu.SelectModelPanel:SetPos(0, 80)
            DressUp.Menu.SelectModelPanel:SetSize(DressUp.Menu.WIDTH-420, DressUp.Menu.HEIGHT-80)
            DressUp.Menu.SelectModelPanel:SetVisible(false)
            local vbar = DressUp.Menu.SelectModelPanel:GetVBar()
            vbar:SetWide(10)

            function vbar:Paint(w,h) end
            function vbar.btnUp:Paint(w,h) end
            function vbar.btnDown:Paint(w,h) end
            function vbar.btnGrip:Paint(w, h)
                draw.RoundedBox(5,1,0,w-2,h,Color(50, 50, 50, 150))
            end

            DressUp.Menu.SelectModelPanel.Paint = function(self,w,h) end

            DressUp.Menu.ModelSearchShow = DressUp.Language.Search
            DressUp.Menu.ModelSearchEntry = vgui.Create("DTextEntry" , DressUp.Menu.SelectModelPanel)
            DressUp.Menu.ModelSearchEntry:SetPos(DressUp.Menu.WIDTH-420-250,10)
            DressUp.Menu.ModelSearchEntry:SetSize(220,42)
            DressUp.Menu.ModelSearchEntry:SetFont("DU_Menu_ItemName")
            DressUp.Menu.ModelSearchEntry.Paint = function(self,w,h)
                surface.SetDrawColor(60,62,60)
                surface.DrawOutlinedRect(0,0,w,h,2)
                self:DrawTextEntryText( Color( 60,62,60 ), Color( 155,155,231 ), Color( 255, 255, 255 ) )
                draw.SimpleText(DressUp.Menu.ModelSearchShow,"DU_Menu_ItemName",3,h/2,Color(60,62,60),0,1)
            end

            local function DressUp_LoadMyModels(filter)
                if(DressUp.Menu.SelectModelGrid)then
                    DressUp.Menu.SelectModelGrid:SetVisible(false)
                    DressUp.Menu.SelectModelGrid = nil
                end

                local buttonWide = (DressUp.Menu.WIDTH-420-110)/5

                DressUp.Menu.SelectModelGrid = vgui.Create("DGrid", DressUp.Menu.SelectModelPanel)
                DressUp.Menu.SelectModelGrid:SetPos(35, 80)
                DressUp.Menu.SelectModelGrid:SetCols(5)
                DressUp.Menu.SelectModelGrid:SetColWide(buttonWide+10)
                DressUp.Menu.SelectModelGrid:SetRowHeight(buttonWide+10)

                for k,modelTbl in pairs(DressUp.PlayerModels)do
                    if(filter != "")then
                        local hasValue,_ = string.find(string.lower(modelTbl.Name), string.lower(filter))
                        if(!hasValue)then
                            continue
                        end
                    end

                    local panel = vgui.Create("DPanel")
                    panel:SetSize(buttonWide, buttonWide)
                    panel.Paint = function(self,w,h)
                        draw.RoundedBox(5, 0, 0, w, h, Color(57, 60, 67))
                        draw.RoundedBox(5, 1, 1, w-2, h-2, Color(33, 36, 43))
                    end

                    local SpawnIcon = vgui.Create( "SpawnIcon" , panel )
                    SpawnIcon:SetPos( 2, 2 )
                    SpawnIcon:SetSize(buttonWide-4, buttonWide-4)
                    SpawnIcon:SetModel(modelTbl.Model)

                    local button = vgui.Create("DButton", panel)
                    button:SetSize(buttonWide,buttonWide)
                    button:SetText("")
                    button.Paint = function(self,w,h)
                        if(self:IsHovered())then
                            draw.RoundedBox(5, 1, 1, buttonWide-2, buttonWide-2, Color(150,150,150,10))
                        end
                        draw.RoundedBox(5, 1, buttonWide-20, buttonWide-2, 19, Color(0, 0, 0, 100))
                        draw.SimpleText(modelTbl.Name, "DU_Menu_ItemName", buttonWide/2, buttonWide-11, Color(255, 255, 255), 1, 1)
                    end

                    button.DoClick = function()
                        local Menu = DermaMenu()
                            
                        local EditModel = Menu:AddOption( DressUp.Language.Edit )
                        EditModel:SetIcon( "icon16/bricks.png" )
                        function EditModel:DoClick()
                            DressUp:EditDecorations(modelTbl.Class)
                        end

                        Menu:Open()
                    end

                    DressUp.Menu.SelectModelGrid:AddItem(panel)
                end
            end
            DressUp_LoadMyModels("")
            DressUp.Menu.ModelSearchEntry.OnChange = function()
                if(DressUp.Menu.ModelSearchShow != "")then
                    DressUp.Menu.ModelSearchShow = ""
                end
                DressUp_LoadMyModels(DressUp.Menu.ModelSearchEntry:GetValue())
            end
        end,
    },

    {
        Name = DressUp.Language.BackpackTitle,

        Func = function()
            DressUp:CloseAllPanel()

            DressUp:ClientModelMenuReLoad()

            DressUp.Menu.MyDecorationPanel:SetVisible(true)
        end,

        Init = function()
            local ply = LocalPlayer()

            DressUp.Menu.MyDecorationPanel = vgui.Create("DScrollPanel", DressUp.Menu.Frame)
            DressUp.Menu.MyDecorationPanel:SetPos(0, 80)
            DressUp.Menu.MyDecorationPanel:SetSize(DressUp.Menu.WIDTH-420, DressUp.Menu.HEIGHT-80)
            DressUp.Menu.MyDecorationPanel:SetVisible(false)
            local vbar = DressUp.Menu.MyDecorationPanel:GetVBar()
            vbar:SetWide(10)

            function vbar:Paint(w,h) end
            function vbar.btnUp:Paint(w,h) end
            function vbar.btnDown:Paint(w,h) end
            function vbar.btnGrip:Paint(w, h)
                draw.RoundedBox(5,1,0,w-2,h,Color(50, 50, 50, 150))
            end

            DressUp.Menu.MyDecorationPanel.Paint = function(self,w,h) end

            DressUp.Menu.MyDecoratrionSearchShow = DressUp.Language.Search
            DressUp.Menu.MyDecoratrionDTextEntry = vgui.Create("DTextEntry" , DressUp.Menu.MyDecorationPanel)
            DressUp.Menu.MyDecoratrionDTextEntry:SetPos(DressUp.Menu.WIDTH-420-250,10)
            DressUp.Menu.MyDecoratrionDTextEntry:SetSize(220,42)
            DressUp.Menu.MyDecoratrionDTextEntry:SetFont("DU_Menu_ItemName")
            DressUp.Menu.MyDecoratrionDTextEntry.Paint = function(self,w,h)
                surface.SetDrawColor(60,62,60)
                surface.DrawOutlinedRect(0,0,w,h,2)
                self:DrawTextEntryText( Color( 60,62,60 ), Color( 155,155,231 ), Color( 255, 255, 255 ) )
                draw.SimpleText(DressUp.Menu.MyDecoratrionSearchShow,"DU_Menu_ItemName",3,h/2,Color(60,62,60),0,1)
            end

            local function DressUp_LoadMyDecoratrions(filter)
                if(DressUp.Menu.MyDecorationGrid)then
                    DressUp.Menu.MyDecorationGrid:SetVisible(false)
                    DressUp.Menu.MyDecorationGrid = nil
                end

                local buttonWide = (DressUp.Menu.WIDTH-420-110)/5

                DressUp.Menu.MyDecorationGrid = vgui.Create("DGrid", DressUp.Menu.MyDecorationPanel)
                DressUp.Menu.MyDecorationGrid:SetPos(35, 80)
                DressUp.Menu.MyDecorationGrid:SetCols(5)
                DressUp.Menu.MyDecorationGrid:SetColWide(buttonWide+10)
                DressUp.Menu.MyDecorationGrid:SetRowHeight(buttonWide+10)

                for k,class in pairs(DressUp.MyData.Items)do
                    if(!DressUp.Decorations[class])then continue end
                    local item = DressUp.Decorations[class]

                    if(filter != "")then
                        local hasValue,_ = string.find(string.lower(item.Name), string.lower(filter))
                        if(!hasValue)then
                            continue
                        end
                    end

                    local panel = vgui.Create("DPanel")
                    panel:SetSize(buttonWide, buttonWide)
                    panel.Paint = function(self,w,h)
                        draw.RoundedBox(5, 0, 0, w, h, Color(57, 60, 67))
                        draw.RoundedBox(5, 1, 1, w-2, h-2, Color(33, 36, 43))
                    end

                    local DModelPanel = vgui.Create("DModelPanel", panel)
                    DModelPanel:SetModel(item.Model)
                    DModelPanel:SetSize(buttonWide,buttonWide)
                    DModelPanel:SetLookAt(DModelPanel.Entity:GetPos() + Vector(0,0,0))
                    DModelPanel:SetCamPos(DModelPanel.Entity:GetPos() + Vector(30,0,0))

                    local button = vgui.Create("DButton", panel)
                    button:SetSize(buttonWide,buttonWide)
                    button:SetText("")
                    button.Paint = function(self,w,h)
                        if(self:IsHovered())then
                            draw.RoundedBox(5, 1, 1, buttonWide-2, buttonWide-2, Color(150,150,150,10))
                            draw.RoundedBox(5, 1, buttonWide-20, buttonWide-2, 19, Color(0, 0, 0, 100))
                            draw.SimpleText("+" .. DressUp.Config.CalculateSellPrice(ply,item), "DU_Menu_ItemName", buttonWide/2, buttonWide-11, Color(255, 255, 255), 1, 1)
                        else
                            draw.RoundedBox(5, 1, buttonWide-20, buttonWide-2, 19, Color(0, 0, 0, 100))
                            draw.SimpleText(item.Name, "DU_Menu_ItemName", buttonWide/2, buttonWide-11, Color(255, 255, 255), 1, 1)
                        end
                    end

                    button.DoClick = function()
                        local menu = DermaMenu()

                        menu:AddOption( DressUp.Language.Sell, function()
                            Derma_Query(
                            string.format(DressUp.Language.SellMessage, item.Name),
                            DressUp.Language.SellTitle,
                            DressUp.Language.Yes,
                            function() 
                                panel:SetVisible(false)
                                net.Start("Dressup_SellItem")
                                net.WriteString(class)
                                net.SendToServer()
                            end,
                            DressUp.Language.No,
                            function() end)
                        end )

                        menu:Open()
                    end

                    DressUp.Menu.MyDecorationGrid:AddItem(panel)
                end
            end
            DressUp_LoadMyDecoratrions("")
            DressUp.Menu.MyDecoratrionDTextEntry.OnChange = function()
                if(DressUp.Menu.MyDecoratrionSearchShow != "")then
                    DressUp.Menu.MyDecoratrionSearchShow = ""
                end
                DressUp_LoadMyDecoratrions(DressUp.Menu.MyDecoratrionDTextEntry:GetValue())
            end
        end,
    },

    {
        Name = DressUp.Language.AdminTitle,

        Func = function()
            DressUp:CloseAllPanel()

            DressUp:ClientModelMenuReLoad()

            DressUp.Menu.AdminPanel:SetVisible(true)
        end,

        Init = function()
            local ply = LocalPlayer()

            DressUp.Menu.AdminPanel = vgui.Create("DScrollPanel", DressUp.Menu.Frame)
            DressUp.Menu.AdminPanel:SetPos(0, 80)
            DressUp.Menu.AdminPanel:SetSize(DressUp.Menu.WIDTH-420, DressUp.Menu.HEIGHT-80)
            DressUp.Menu.AdminPanel:SetVisible(false)
            local vbar = DressUp.Menu.AdminPanel:GetVBar()
            vbar:SetWide(10)

            function vbar:Paint(w,h) end
            function vbar.btnUp:Paint(w,h) end
            function vbar.btnDown:Paint(w,h) end
            function vbar.btnGrip:Paint(w, h)
                draw.RoundedBox(5,1,0,w-2,h,Color(50, 50, 50, 150))
            end

            local canAccess = false

            if(DressUp.Config.AdminCanAccessAdminTab && ply:IsAdmin())then
                canAccess = true
            end

            if(DressUp.Config.SuperAdminCanAccessAdminTab && ply:IsSuperAdmin())then
                canAccess = true
            end

            DressUp.Menu.AdminPanel.Paint = function(self,w,h)
                if(!canAccess)then
                    draw.SimpleText(DressUp.Language.NoPermission, "DU_Menu_ItemName", w/2, 50, Color(150, 150, 150), 1, 1)
                end
            end

            if(canAccess)then
                DressUp.Menu.PlayerNameSearchShow = DressUp.Language.Search
                DressUp.Menu.PlayerNameSearchDTextEntry = vgui.Create("DTextEntry" , DressUp.Menu.AdminPanel)
                DressUp.Menu.PlayerNameSearchDTextEntry:SetPos(DressUp.Menu.WIDTH-420-250,10)
                DressUp.Menu.PlayerNameSearchDTextEntry:SetSize(220,42)
                DressUp.Menu.PlayerNameSearchDTextEntry:SetFont("DU_Menu_ItemName")
                DressUp.Menu.PlayerNameSearchDTextEntry.Paint = function(self,w,h)
                    surface.SetDrawColor(60,62,60)
                    surface.DrawOutlinedRect(0,0,w,h,2)
                    self:DrawTextEntryText( Color( 60,62,60 ), Color( 155,155,231 ), Color( 255, 255, 255 ) )
                    draw.SimpleText(DressUp.Menu.PlayerNameSearchShow,"DU_Menu_ItemName",3,h/2,Color(60,62,60),0,1)
                end

                local function DressUp_LoadOnlinePlayers(filter)
                    if(DressUp.Menu.AdminGrid)then
                        DressUp.Menu.AdminGrid:SetVisible(false)
                        DressUp.Menu.AdminGrid = nil
                    end

                    DressUp.Menu.AdminGrid = vgui.Create("DGrid", DressUp.Menu.AdminPanel)
                    DressUp.Menu.AdminGrid:SetPos(35, 60)
                    DressUp.Menu.AdminGrid:SetCols(1)
                    DressUp.Menu.AdminGrid:SetColWide(DressUp.Menu.AdminPanel:GetWide()-70)
                    DressUp.Menu.AdminGrid:SetRowHeight(50)

                    for k,p in pairs(player.GetAll())do
                        if(p:IsBot())then continue end
                        if(filter != "")then
                            local hasValue,_ = string.find(string.lower(p:Name()), string.lower(filter))
                            if(!hasValue)then
                                continue
                            end
                        end

                        local pPanel = vgui.Create("DPanel")
                        pPanel:SetSize(DressUp.Menu.AdminPanel:GetWide()-70,40)
                        pPanel.Paint = function(self,w,h)
                            draw.RoundedBox(5, 0, 0, w, h, Color(57, 60, 67))
                            draw.RoundedBox(5, 1, 1, w-2, h-2, Color(33, 36, 43))

                            if(IsValid(p))then
                                draw.SimpleText(p:Name(), "DU_Menu_ItemName", 50, h/2, Color(255,255,255),0,1)
                                draw.SimpleText(p:SteamID64(), "DU_Menu_ItemName", w-10, h/2, Color(100,100,100),2,1)
                            end
                        end

                        local pAvatar = vgui.Create("AvatarImage", pPanel)
                        pAvatar:SetPos(5,5)
                        pAvatar:SetSize(30,30)
                        pAvatar:SetPlayer(p,30)

                        local pButton = vgui.Create("DButton", pPanel)
                        pButton:SetPos(0,0)
                        pButton:SetSize(pPanel:GetWide(),pPanel:GetTall())
                        pButton:SetText("")
                        pButton.Paint = function(self,w,h)
                            if(self:IsHovered())then
                                draw.RoundedBox(5, 1, 1, w-2, h-2, Color(150,150,150,10))
                            end
                        end

                        pButton.DoClick = function()
                            local menu = DermaMenu() 

                            local copyID = menu:AddOption( DressUp.Language.CopySteamID64, function()
                                if(IsValid(p))then
                                    SetClipboardText(p:SteamID64())
                                end
                            end )

                            copyID:SetIcon("icon16/page_copy.png")
                            
                            local giveMenu, giveItem = menu:AddSubMenu(DressUp.Language.Give)
                            giveItem:SetIcon("icon16/add.png")

                            for k,v in pairs(DressUp.Decorations)do
                                local itemButton = giveMenu:AddOption(v.Name, function()
                                    if(IsValid(p))then
                                        RunConsoleCommand("dressup_giveitem", p:SteamID64(), v.Class)
                                    end
                                end)
                            end

                            local takeMenu, takeItem = menu:AddSubMenu(DressUp.Language.Take)
                            takeItem:SetIcon("icon16/delete.png")

                            if(IsValid(p))then
                                for k,v in pairs(DressUp.AdminData[p].Items)do
                                    local itemMeta = DressUp.Decorations[v]
                                    if(!itemMeta)then continue end
                                    local itemButton = takeMenu:AddOption(itemMeta.Name, function()
                                        if(IsValid(p))then
                                            RunConsoleCommand("dressup_takeitem", p:SteamID64(), v)
                                        end
                                    end)
                                end
                            end

                            local modelMenu, modelItem = menu:AddSubMenu(DressUp.Language.TakeFModels)
                            modelItem:SetIcon("icon16/user.png")

                            if(IsValid(p))then
                                for k,v in pairs(DressUp.AdminData[p].ModelItems)do
                                    local modelMeta = DressUp.PlayerModels[k]
                                    if(!modelMeta)then continue end

                                    local modelInMenu, modelInItem = modelMenu:AddSubMenu(modelMeta.Name)

                                    for i,classTbl in pairs(DressUp.AdminData[p].ModelItems[k])do
                                        local itemMeta = DressUp.Decorations[classTbl.class]
                                        if(!itemMeta)then continue end
                                        local modelitemButton = modelInMenu:AddOption(itemMeta.Name, function()
                                            if(IsValid(p))then
                                                RunConsoleCommand("dressup_takemodelitem", p:SteamID64(), k, i)
                                            end
                                        end)
                                    end
                                end
                            end

                            menu:Open()
                        end

                        DressUp.Menu.AdminGrid:AddItem(pPanel)
                    end
                end
                
                DressUp_LoadOnlinePlayers("")
                DressUp.Menu.PlayerNameSearchDTextEntry.OnChange = function()
                    if(DressUp.Menu.PlayerNameSearchShow != "")then
                        DressUp.Menu.PlayerNameSearchShow = ""
                    end
                    DressUp_LoadOnlinePlayers(DressUp.Menu.PlayerNameSearchDTextEntry:GetValue())
                end


            end
        end,
    },
}