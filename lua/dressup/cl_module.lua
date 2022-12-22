DressUp.MenuKeys = {
    ["F1"] = KEY_F1,
    ["F2"] = KEY_F2,
    ["F3"] = KEY_F3,
    ["F4"] = KEY_F4,
    ["F5"] = KEY_F5,
    ["F6"] = KEY_F6,
    ["F7"] = KEY_F7,
    ["F8"] = KEY_F8,
    ["F9"] = KEY_F9,
    ["F10"] = KEY_F10,
    ["F11"] = KEY_F11,
    ["F12"] = KEY_F12,
}

--Key
hook.Add("SetupMove", "DressUp_Key", function(ply, mvd, cmd)
    if(DressUp.MenuKeys[DressUp.Config.MenuKey] && input.WasKeyPressed( DressUp.MenuKeys[DressUp.Config.MenuKey]))then
        if DressUp.Menu.Frame then
            DressUp.Menu.Frame:SetVisible(false)
            DressUp.Menu.Frame = nil
        else
            RunConsoleCommand(DressUp.Config.MenuCommand)
        end
    end
end)

hook.Add('PostPlayerDraw', 'DressUp_PostPlayerDraw', function(ply)
    if not (DressUp.PlayerAttachMents[ply] or DressUp.PlayerItemTable[ply]) then return end

    for i=1, #DressUp.PlayerAttachMents[ply] do
        if(!DressUp.PlayerItemTable[ply][i] or !ply:Alive())then
            DressUp.PlayerAttachMents[ply][i]:SetNoDraw(true)
            continue
        end

        local attach = DressUp.PlayerAttachMents[ply][i]

        local tbl = DressUp.PlayerItemTable[ply][i]

        if(attach)then
            local pos = Vector()
            local ang = Angle()

            local bone_id = ply:LookupBone(tbl.equipLocation)
			if not bone_id then return end

            pos, ang = ply:GetBonePosition(bone_id)

            local tmp_Vector, tmp_Angle, tmp_Size = tbl.adjustPlacement, tbl.adjustAngles, tbl.adjustSize
            pos = pos + (ang:Forward() * tmp_Vector.x) + (ang:Up() * tmp_Vector.z) + (ang:Right() * tmp_Vector.y)

            ang:RotateAroundAxis(ang:Forward(), tmp_Angle.p)
            ang:RotateAroundAxis(ang:Up(), tmp_Angle.y)
            ang:RotateAroundAxis(ang:Right(), tmp_Angle.r)

            attach:SetPos(pos)
			attach:SetAngles(ang)

            local size = Vector(1, 1, 1)
            size = size * Vector(tmp_Size.x, tmp_Size.y, tmp_Size.z)
            local mat = Matrix()
            mat:Scale(size)
            attach:EnableMatrix('RenderMultiply', mat)

            DressUp.PlayerAttachMents[ply][i]:DrawModel()
        end
    end
end)