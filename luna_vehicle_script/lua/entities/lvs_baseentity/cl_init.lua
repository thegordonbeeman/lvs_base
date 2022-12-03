include("shared.lua")

	surface.CreateFont( "LFS_FONT", {
		font = "Verdana",
		extended = false,
		size = 20,
		weight = 2000,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = true,
		additive = false,
		outline = false,
	} )
	
function ENT:LVSHudPaint( X, Y, ply )
	local Radius = 100

	local Test = self:GetSteer()

	local Test2 = Vector( Test.x, Test.y, 0)
	local Test2Dir = Test2:GetNormalized()
	local Test2Len = Test2:Length()

	surface.DrawCircle( X * 0.5, Y * 0.5, Radius, Color( 255, 0, 0 ) )

	surface.DrawCircle( X * 0.5 + Test2Dir.x * math.abs(Test.x) * Radius, Y * 0.5 + Test2Dir.y * math.abs(Test.y) * Radius, 5, Color( 255, 0, 0 ) )

	local Throttle = math.Round(self:GetThrottle() * 100,0)

	draw.SimpleText( "THR", "LFS_FONT", 10, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( Throttle.."%" , "LFS_FONT", 120, 10, Col, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
end

function ENT:LVSCalcViewFirstPerson( view, ply )
	view.drawviewer = true

	return self:LVSCalcViewThirdPerson( view, ply )
end

function ENT:LVSCalcViewThirdPerson( view, ply )
	self._lerpPos = self._lerpPos or self:GetPos()

	local Delta = RealFrameTime()

	local TargetPos = self:LocalToWorld( Vector(500,0,250) )

	local Sub = TargetPos - self._lerpPos
	local Dir = Sub:GetNormalized()
	local Dist = Sub:Length()

	self._lerpPos = self._lerpPos + (TargetPos - self:GetForward() * 900 - Dir * 100 - self._lerpPos) * Delta * 12

	local vel = self:GetVelocity()

	view.origin = self._lerpPos
	view.angles = self:GetAngles()

	return view
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:DrawTranslucent()
end

function ENT:Initialize()
end

function ENT:Think()
end

function ENT:OnRemove()
end

function ENT:GetCrosshairFilterEnts()
	if not istable( self.CrosshairFilterEnts ) then
		self.CrosshairFilterEnts = {self}

		-- lets ask the server to build the filter for us because it has access to constraint.GetAllConstrainedEntities() 
		net.Start( "lvs_player_request_filter" )
			net.WriteEntity( self )
		net.SendToServer()
	end

	return self.CrosshairFilterEnts
end