
ENT.Base = "lvs_base_starfighter"

ENT.PrintName = "Vulture Droid"
ENT.Author = "Luna"
ENT.Information = "Droid Starfighter of the Trade Federation"
ENT.Category = "[LVS] - Star Wars"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/salza/vulture_droid.mdl"
ENT.GibModels = {
	"models/salza/vd_gib1.mdl",
	"models/salza/vd_gib2.mdl",
	"models/salza/vd_gib3.mdl",
	"models/salza/vd_gib4.mdl",
	"models/salza/vd_gib5.mdl",
}

ENT.AITEAM = 1

ENT.MaxVelocity = 2150
ENT.MaxThrust = 2150

ENT.TurnRatePitch = 1
ENT.TurnRateYaw = 1
ENT.TurnRateRoll = 1

ENT.ForceLinearMultiplier = 1

ENT.ForceAngleMultiplier = 1
ENT.ForceAngleDampingMultiplier = 1

ENT.MaxHealth = 250

function ENT:InitWeapons()
	self.FirePositions = {
		Vector(56.82,105.6,4),
		Vector(56.82,-105.6,-4),
		Vector(56.82,105.6,-4),
		Vector(56.82,-105.6,4)
	}

	local weapon = {}
	weapon.Icon = Material("lvs/weapons/mg.png")
	weapon.Ammo = 1200
	weapon.Delay = 0.1
	weapon.HeatRateUp = 0.25
	weapon.HeatRateDown = 1
	weapon.Attack = function( ent )
		ent.NumPrim = ent.NumPrim and ent.NumPrim + 1 or 1
		if ent.NumPrim > #ent.FirePositions then ent.NumPrim = 1 end

		local pod = ent:GetDriverSeat()

		if not IsValid( pod ) then return end

		local startpos = pod:LocalToWorld( pod:OBBCenter() )
		local trace = util.TraceHull( {
			start = startpos,
			endpos = (startpos + ent:GetForward() * 50000),
			mins = Vector( -10, -10, -10 ),
			maxs = Vector( 10, 10, 10 ),
			filter = ent:GetCrosshairFilterEnts()
		} )

		local bullet = {}
		bullet.Src 	= ent:LocalToWorld( ent.FirePositions[ent.NumPrim] )
		bullet.Dir 	= (trace.HitPos - bullet.Src):GetNormalized()
		bullet.Spread 	= Vector( 0.02,  0.02, 0 )
		bullet.TracerName = "lvs_laser_red"
		bullet.Force	= 10
		bullet.HullSize 	= 40
		bullet.Damage	= 10
		bullet.Velocity = 60000
		bullet.Attacker 	= ent:GetDriver()
		bullet.Callback = function(att, tr, dmginfo)
			local effectdata = EffectData()
				effectdata:SetStart( Vector(255,50,50) ) 
				effectdata:SetOrigin( tr.HitPos )
				effectdata:SetNormal( tr.HitNormal )
			util.Effect( "lvs_laser_impact", effectdata )
		end
		ent:LVSFireBullet( bullet )

		local effectdata = EffectData()
		effectdata:SetStart( Vector(255,50,50) )
		effectdata:SetOrigin( bullet.Src )
		effectdata:SetNormal( ent:GetForward() )
		effectdata:SetEntity( ent )
		util.Effect( "lvs_muzzle", effectdata )

		ent:TakeAmmo()

		ent.PrimarySND:PlayOnce( 100 + math.cos( CurTime() + self:EntIndex() * 1337 ) * 5 + math.Rand(-1,1), 1 )
	end
	weapon.OnSelect = function( ent ) ent:EmitSound("physics/metal/weapon_impact_soft3.wav") end
	weapon.OnOverheat = function( ent ) ent:EmitSound("lvs/overheat.wav") end
	self:AddWeapon( weapon )


	local weapon = {}
	weapon.Icon = Material("lvs/weapons/dual_mg.png")
	weapon.Ammo = 400
	weapon.Delay = 0.15
	weapon.HeatRateUp = 0.5
	weapon.HeatRateDown = 1
	weapon.Attack = function( ent )
		local bullet = {}
		bullet.Dir 	= ent:GetForward()
		bullet.Spread 	= Vector( 0.015,  0.015, 0 )
		bullet.TracerName = "lvs_laser_red"
		bullet.Force	= 10
		bullet.HullSize 	= 25
		bullet.Damage	= 20
		bullet.Velocity = 60000
		bullet.Attacker 	= ent:GetDriver()
		bullet.Callback = function(att, tr, dmginfo)
			local effectdata = EffectData()
				effectdata:SetStart( Vector(255,50,50) ) 
				effectdata:SetOrigin( tr.HitPos )
				effectdata:SetNormal( tr.HitNormal )
			util.Effect( "lvs_laser_impact", effectdata )
		end

		for i = -1,1,2 do
			bullet.Src 	= ent:LocalToWorld( Vector(30,15.2 * i,6.5) )

			local effectdata = EffectData()
			effectdata:SetStart( Vector(255,50,50) )
			effectdata:SetOrigin( bullet.Src )
			effectdata:SetNormal( ent:GetForward() )
			effectdata:SetEntity( ent )
			util.Effect( "lvs_muzzle", effectdata )

			ent:LVSFireBullet( bullet )
		end

		ent:TakeAmmo()

		ent.SecondarySND:PlayOnce( 100 + math.cos( CurTime() + self:EntIndex() * 1337 ) * 5 + math.Rand(-1,1), 1 )
	end
	weapon.OnSelect = function( ent ) ent:EmitSound("physics/metal/weapon_impact_soft3.wav") end
	weapon.OnOverheat = function( ent ) ent:EmitSound("lvs/overheat.wav") end
	self:AddWeapon( weapon )

	local weapon = {}
	weapon.Icon = Material("lvs/weapons/protontorpedo.png")
	weapon.UseableByAI = false
	weapon.Ammo = 4
	weapon.Delay = 0 -- this will turn weapon.Attack to a somewhat think function
	weapon.HeatRateUp = -0.5 -- cool down when attack key is held. This system fires on key-release.
	weapon.HeatRateDown = 0.25
	weapon.Attack = function( ent )
		local T = CurTime()

		if IsValid( ent._ProtonTorpedo ) then
			if (ent._nextMissleTracking or 0) > T then return end

			ent._nextMissleTracking = T + 0.1 -- 0.1 second interval because those find functions can be expensive

			ent._ProtonTorpedo:FindTarget( ent:GetPos(), ent:GetForward(), 30, 7500 )

			return
		end

		local T = CurTime()

		if (ent._nextMissle or 0) > T then return end

		ent._nextMissle = T + 0.5

		ent._swapMissile = not ent._swapMissile

		local Pos = Vector( 56.82, (ent._swapMissile and -105.6 or 105.6), 0 )

		local projectile = ents.Create( "lvs_concussionmissile" )
		projectile:SetPos( ent:LocalToWorld( Pos ) )
		projectile:SetAngles( ent:GetAngles() )
		projectile:SetParent( ent )
		projectile:Spawn()
		projectile:Activate()
		projectile:SetAttacker( ent:GetDriver() )
		projectile:SetEntityFilter( ent:GetCrosshairFilterEnts() )
		projectile:SetSpeed( ent:GetVelocity():Length() + 4000 )

		ent._ProtonTorpedo = projectile

		ent:SetNextAttack( CurTime() + 0.1 ) -- wait 0.1 second before starting to track
	end
	weapon.FinishAttack = function( ent )
		if not IsValid( ent._ProtonTorpedo ) then return end

		local projectile = ent._ProtonTorpedo

		projectile:Enable()
		projectile:EmitSound( "lvs/vehicles/naboo_n1_starfighter/proton_fire.mp3", 125 )
		ent:TakeAmmo()

		ent._ProtonTorpedo = nil

		local NewHeat = ent:GetHeat() + 0.75

		ent:SetHeat( NewHeat )
		if NewHeat >= 1 then
			ent:SetOverheated( true )
		end
	end
	weapon.OnSelect = function( ent ) ent:EmitSound("physics/metal/weapon_impact_soft3.wav") end
	weapon.OnOverheat = function( ent ) ent:EmitSound("lvs/overheat.wav") end
	self:AddWeapon( weapon )
end

sound.Add( {
	name = "LVS.VULTURE.FLYBY",
	sound = {"lvs/vehicles/vulturedroid/flyby.wav","lvs/vehicles/vulturedroid/flyby_a.wav","lvs/vehicles/vulturedroid/flyby_b.wav","lvs/vehicles/vulturedroid/flyby_c.wav"}
} )

ENT.FlyByAdvance = 0
ENT.FlyBySound = "LVS.VULTURE.FLYBY" 
ENT.DeathSound = "lvs/vehicles/generic_starfighter/crash.wav"

ENT.EngineSounds = {
	{
		sound = "lvs/vehicles/vulturedroid/loop.wav",
		Pitch = 80,
		PitchMin = 0,
		PitchMax = 255,
		PitchMul = 40,
		FadeIn = 0,
		FadeOut = 1,
		FadeSpeed = 1.5,
		UseDoppler = true,
	},
	{
		sound = "^lvs/vehicles/vulturedroid/dist.wav",
		Pitch = 80,
		PitchMin = 0,
		PitchMax = 255,
		PitchMul = 40,
		FadeIn = 0.35,
		FadeOut = 1,
		FadeSpeed = 1.5,
		UseDoppler = true,
		VolumeMin = 0,
		VolumeMax = 1,
		SoundLevel = 125,
	},
}