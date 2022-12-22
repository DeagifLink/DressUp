DressUp.HoverModelClass = DressUp.HoverModelClass or nil
DressUp.HoverModelAttachments = DressUp.HoverModelAttachments or nil
DressUp.HoverModelClientModels = DressUp.HoverModelClientModels or {}
local PANEL = {}

local CirMat = Material("particle/Particle_Ring_Wave_Additive")

function PANEL:Init()
	self:SetModel(LocalPlayer():GetModel())
	
	self.Zoom = 100
	self.MinZoom = 20
	self.MaxZoom = 200
	
	
	self.Height = 40
	self.MinHeight = 0
	self.MaxHeight = 100
	
	self.CamPos = Vector(self.Zoom,0,self.Height)
	self.ViewPos = Vector(0,0,self.Height-5)
	
	self.CamAngle = (self.ViewPos - self.CamPos):Angle()
	self:SetAnimated(false)
	
	self.RingBurstDelay = CurTime()
	self.RingBurstCount = 0
	self.ZoomTime = CurTime()
	self.RingBurst = {}
	
	self.ZoomTime = CurTime() + 0.3
	self.CamUpTime = CurTime() + 0.3
end

function PANEL:OnCursorEntered()
	self.Hovering = true
end

function PANEL:OnCursorExited()
	self.Hovering = false
end

function PANEL:OnMouseWheeled(mc)
	self.ZoomHere = self.ZoomHere or self.Zoom
	
	self.ZoomHere = self.ZoomHere - mc *10
	self.ZoomHere = math.min(self.ZoomHere,self.MaxZoom)
	self.ZoomHere = math.max(self.ZoomHere,self.MinZoom)

	self.ZoomTime = CurTime() + 0.6
end

function PANEL:Think()
	
	self.ZoomHere = self.ZoomHere or self.Zoom
	self.Zoom = Lerp(FrameTime()*10,self.Zoom,self.ZoomHere)
	
	
	if !self.Hovering then return end
	
		if input.IsMouseDown(MOUSE_LEFT) then
			if !self.LM then
				self.LM = true
				local MX,MY = gui.MousePos()
				self.LastMousePos_X = MX
				self.LastMousePos_Y = MY
			else
				local CX,CY = gui.MousePos()
				local DX,DY = self.LastMousePos_X-CX,self.LastMousePos_Y-CY
				
				if DY > 0.01 then
					self.CamUpTime = CurTime() + 0.6
				end
				
				self.CamAngle.y = self.CamAngle.y - DX/150
				
				self.Height = self.Height - DY/30
				self.Height = math.min(self.Height,self.MaxHeight)
				self.Height = math.max(self.Height,self.MinHeight)
	
				self.CamPos = Vector(self.Zoom,0,self.Height)
				self.ViewPos = Vector(0,0,self.Height-5)
				
				self.LastMousePos_X = CX
				self.LastMousePos_Y = CY
				
			end
		else
			if self.LM then
				self.LM = false
			end
		end
end

function PANEL:LayoutEntity( ent ) end

function PANEL:Paint()

	self.CamPos = Vector(math.sin(self.CamAngle.y)*self.Zoom,math.cos(self.CamAngle.y)*self.Zoom,self.Height)
	if ( !IsValid( self.Entity ) ) then return end
	

	local x, y = self:LocalToScreen( 0, 0 )

	self:LayoutEntity( self.Entity )

	local w, h = self:GetSize()
	cam.Start3D( self.CamPos, (self.ViewPos - self.CamPos):Angle(), self.fFOV, x, y, w, h, 5, 4096 )

	render.SuppressEngineLighting( true )
	render.SetLightingOrigin( self.Entity:GetPos() )
	render.ResetModelLighting( self.colAmbientLight.r/255, self.colAmbientLight.g/255, self.colAmbientLight.b/255 )
	render.SetColorModulation( self.colColor.r/255, self.colColor.g/255, self.colColor.b/255 )
	render.SetBlend( math.min(self:GetAlpha()/255,self.colColor.a/255) )

	for i=0, 6 do
		local col = self.DirectionalLight[ i ]
		if ( col ) then
			render.SetModelLighting( i, col.r/255, col.g/255, col.b/255 )
		end
	end
	self.Entity:DrawModel()

	self:DrawOtherModels()
				
	render.SetBlend(1)
	render.SuppressEngineLighting( false )
	cam.End3D()
	
	self.LastPaint = RealTime()
	

		local AnimationLerp = FrameTime()
		AnimationLerp = AnimationLerp * 5
		-- ZOOM
			local Col1 = Color(255,255,255,255)
			local Col2 = Color(255,255,255,255)
			self.ZoomAlpha = self.ZoomAlpha or 0
			if self.ZoomTime and self.ZoomTime > CurTime() then
				self.ZoomAlpha = Lerp(AnimationLerp,self.ZoomAlpha,255)
			else
				self.ZoomAlpha = Lerp(AnimationLerp,self.ZoomAlpha,0)
			end
			
			if self.ZoomAlpha > 0 then
				draw.SimpleText(DressUp.Language.Zoom, "DU_Menu_ModelText", self:GetWide()-30,self:GetTall()/2-140, Color(Col2.r,Col2.g,Col2.b,self.ZoomAlpha),TEXT_ALIGN_CENTER)
				surface.SetDrawColor( Color(Col1.r,Col1.g,Col1.b,self.ZoomAlpha*0.4) )
				surface.DrawRect( self:GetWide()-30, self:GetTall()/2-120, 1, 240 )
				
				local Percent = (self.Zoom - self.MinZoom) / (self.MaxZoom - self.MinZoom)
				local PosY = self:GetTall()/2-120 + Percent*230
				
				surface.SetDrawColor( Color(Col2.r,Col2.g,Col2.b,self.ZoomAlpha*0.8) )
				surface.DrawRect( self:GetWide()-40, PosY, 20, 10 )
			end
		-- Height
			local Col1 = Color(255,255,255,255)
			local Col2 = Color(255,255,255,255)
			self.CamUpAlpha = self.CamUpAlpha or 0
			if self.CamUpTime and self.CamUpTime > CurTime() then
				self.CamUpAlpha = Lerp(AnimationLerp,self.CamUpAlpha,255)
			else
				self.CamUpAlpha = Lerp(AnimationLerp,self.CamUpAlpha,0)
			end
			
			if self.CamUpAlpha > 0 then
				draw.SimpleText(DressUp.Language.Move, "DU_Menu_ModelText", 30,self:GetTall()/2-140, Color(Col2.r,Col2.g,Col2.b,self.CamUpAlpha),TEXT_ALIGN_CENTER)
				surface.SetDrawColor( Color(Col1.r,Col1.g,Col1.b,self.CamUpAlpha*0.4) )
				surface.DrawRect( 30, self:GetTall()/2-120, 1, 240 )
				
				local Percent = (self.Height - self.MinHeight) / (self.MaxHeight - self.MinHeight)
				local PosY = self:GetTall()/2-120 + Percent*230
				
				surface.SetDrawColor( Color(Col2.r,Col2.g,Col2.b,self.CamUpAlpha*0.8) )
				surface.DrawRect( 20, PosY, 20, 10 )
			end
		
end

function PANEL:DrawOtherModels()
	local ply = LocalPlayer()

	local tbl = table.GetByMemberValue(DressUp.PlayerModels, "Model", self:GetModel())

	DressUp.HoverModelAttachments = nil

	if(istable(tbl))then
		local modelTbl = DressUp.MyData.ModelItems[tbl.Class]
		if(modelTbl)then
			DressUp.HoverModelAttachments = modelTbl
		end
	else
		tbl = table.GetByMemberValue(DressUp.PlayerModels, "Model", self:GetModel())
		if(istable(tbl))then
			local modelTbl = DressUp.MyData.ModelItems[tbl.Class]
			if(modelTbl)then
				DressUp.HoverModelAttachments = modelTbl
			end
		end
	end
	
	if istable(DressUp.HoverModelAttachments) then
		for k,item in pairs(DressUp.HoverModelAttachments)do
			local pos = Vector()
			local ang = Angle()
			if(!DressUp.Decorations[item.class])then continue end
			local model = DressUp.Decorations[item.class].Model

			local modelAttachs = DressUp.HoverModelClientModels[tbl.Class]

			if(modelAttachs)then
				local attach = modelAttachs[k]

				if(attach)then
					local bone_id = self.Entity:LookupBone(item.equipLocation)
					if not bone_id then return end
					
					pos, ang = self.Entity:GetBonePosition(bone_id)

					local tmp_Vector, tmp_Angle, tmp_Size = item.adjustPlacement, item.adjustAngles, item.adjustSize

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

					DressUp.HoverModelClientModels[tbl.Class][k]:DrawModel()
				end
			end
		end
	end
end

vgui.Register('DModelPreview', PANEL, 'DModelPanel')
