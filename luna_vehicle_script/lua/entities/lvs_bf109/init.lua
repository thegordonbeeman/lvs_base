AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:OnSpawn( PObj )
	self:SetBodygroup( 14, 1 ) 
	self:SetBodygroup( 13, 1 ) 

	PObj:SetMass( 5000 )

	self:AddDriverSeat( Vector(32,0,67.5), Angle(0,-90,0) )

	for i = 1, 10 do
		self:AddPassengerSeat( Vector(32,0,67.5), Angle(0,-90,0) )
	end

	self:AddWheel( Vector(78.12,55,15.16), 13, 600 )
	self:AddWheel( Vector(78.12,-55,15.16), 13, 600 )
	self:AddWheel( Vector(-146.61,0,76), 13, 1200, LVS.WHEEL_STEER_REAR )

	self:AddEngine( Vector(115,0,75) )

	self:AddRotor( Vector(160,0,75) )
end

function ENT:OnLandingGearToggled( IsDeployed )
	self:EmitSound( "lvs/vehicles/bf109/gear.wav" )
end

function ENT:OnEngineActiveChanged( Active )
	if Active then
		self:EmitSound( "lvs/vehicles/bf109/engine_start.wav" )
	else
		self:EmitSound( "lvs/vehicles/bf109/engine_stop.wav" )
	end
end