/*
===============================================================================

PLAYER WEAPONS

individual weapons moved to their own files, as this one was getting long

===============================================================================
*/


// called by worldspawn
void() W_Precache =
{
	precache_sound ("weapons/r_exp3.wav");
	precache_sound ("weapons/rocket1i.wav");	// nailgun
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/guncock.wav");		// sg
	precache_sound ("weapons/ric1.wav");		// ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");		// ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");		// ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");		// super spikes
	precache_sound ("weapons/tink1.wav");		// spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav");		// grenade launcher
	precache_sound ("weapons/bounce.wav");		// grenade bounce
	precache_sound ("weapons/shotgn2.wav");		// ssg
	precache_sound ("weapons/shotgn3.wav");		// qsg
	precache_model2 ("progs/k_spike.mdl");
	precache_model ("progs/lavaball.mdl");	
	precache_sound ("weapons/lhit.wav");		//lightning
	precache_sound ("weapons/lstart.wav");		//lightning start
//	precache_sound ("items/damage3.wav");

// ax sounds	
	precache_sound ("weapons/ax1.wav");			// ax swoosh
	precache_sound2 ("weapons/axhit1.wav");		// ax hit meat
	precache_sound2 ("weapons/axhit2.wav");		// ax hit meat 2
	precache_sound ("player/axhit1.wav");		// ax hit me
	precache_sound ("player/axhit2.wav");		// ax hit world
	
	precache_sound ("zombie/z_hit.wav");
	
	

	precache_model ("progs/v_axe.mdl");
	precache_model ("progs/v_shot.mdl");
	precache_model ("progs/v_nail.mdl");
	precache_model ("progs/v_rock.mdl");
	precache_model ("progs/v_shot2.mdl");
	precache_model ("progs/v_shot3.mdl");
	precache_model ("progs/v_nail2.mdl");
	precache_model ("progs/v_rock2.mdl");
	precache_model ("progs/v_light.mdl");

}



/*
========
SuperDamageSound
========
*/
void() SuperDamageSound =
{
	if (!has_quad(self)) return;
	if (self.super_sound < time)
	{
		self.super_sound = time + 1;
		sound (self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
	}
}

float() W_CanSwitchWeapon =
{
	// Can't switch away from the quad shotgun either in the middle of the firing sequence, or
	// during the cooldown period.
	if (self.weapon == W_QUAD_SHOTGUN && time < self.attack_finished) {
		return FALSE;
	}
	return TRUE;
}

void() W_SetIdleWeaponFrame =
{
	self.weaponframe = 0;
}

void() W_SetCurrentAmmo =
{
	self.items = self.items - ( self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS) );
	
	if (self.weapon == W_SHOTGUN || self.weapon == W_SUPER_SHOTGUN || self.weapon == W_QUAD_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == W_NAILGUN || self.weapon == W_SUPER_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == W_GRENADE_LAUNCHER || self.weapon == W_ROCKET_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == W_LIGHTNING)
	{
		self.currentammo = self.ammo_cells;
		self.items = self.items | IT_CELLS;
	}
	else	// axes, etc
	{
		self.currentammo = 0;
	}
}

void() W_ResetWeaponState =
{
	player_run ();		// get out of any weapon firing states

	self.weaponframe = 0;
	//self.attack_finished = 0;	// don't lose attack debounce time from last attack,
		// if any, or picking up/switching weapons can cause double attacks
	
	if (self.weapon == W_AXE )
		self.weaponmodel = "progs/v_axe.mdl";
	else if (self.weapon == W_SHOTGUN)
		self.weaponmodel = "progs/v_shot.mdl";
	else if (self.weapon == W_SUPER_SHOTGUN)
		self.weaponmodel = "progs/v_shot2.mdl";
	else if (self.weapon == W_QUAD_SHOTGUN)
		self.weaponmodel = "progs/v_shot3.mdl";
	else if (self.weapon == W_NAILGUN)
		self.weaponmodel = "progs/v_nail.mdl";
	else if (self.weapon == W_SUPER_NAILGUN)
		self.weaponmodel = "progs/v_nail2.mdl";
	else if (self.weapon == W_GRENADE_LAUNCHER)
		self.weaponmodel = "progs/v_rock.mdl";
	else if (self.weapon == W_ROCKET_LAUNCHER)
		self.weaponmodel = "progs/v_rock2.mdl";
	else if (self.weapon == W_LIGHTNING)
		self.weaponmodel = "progs/v_light.mdl";
	else
		self.weaponmodel = string_null;

	W_SetCurrentAmmo();
}

float(float w) W_RankForWeapon =
{
	if (w == W_LIGHTNING)
		return 1;
	if (w == W_ROCKET_LAUNCHER)
		return 2;
	if (w == W_SUPER_NAILGUN)
		return 3;
	if (w == W_QUAD_SHOTGUN)
		return 4;
	if (w == W_GRENADE_LAUNCHER)
		return 5;
	if (w == W_SUPER_SHOTGUN)
		return 6;
	if (w == W_NAILGUN)
		return 7;
	return 8;
}

/*
=============
W_BetterWeapon

Deathmatch weapon change rules for picking up a weapon
=============
*/
void(float new) W_BetterWeapon =
{
	if (!W_CanSwitchWeapon()) {
		return;
	}

	if (!deathmatch)
	{
		// don't switch to explosive weapons with quad
		// 1.12: don't switch to explosives when invisible either, since you can't see the stupid viewmodel
		if ( (has_quad(self) || has_invis(self)) &&
			(new == W_ROCKET_LAUNCHER || new == W_GRENADE_LAUNCHER))
			return;
		// don't switch to a lightning gun when standing in water
		if (self.waterlevel >= 2 && new == W_LIGHTNING)
			return;
	}	
	if (!deathmatch || W_RankForWeapon (new) < W_RankForWeapon (self.weapon) )
		self.weapon = new;
	W_ResetWeaponState();
}

float() W_BestWeapon =
{
	local	float	it;
	
	self.lip = 0;	// reset nailgun barrel cycle
	
	it = self.items;
	
	if(self.ammo_nails >= 2 && (it & IT_SUPER_NAILGUN) )
		return W_SUPER_NAILGUN;
	if(self.ammo_shells >= 4 && (self.items2 & IT_QUAD_SHOTGUN))
		return W_QUAD_SHOTGUN;
	if(self.ammo_shells >= 2 && (it & IT_SUPER_SHOTGUN) )
		return W_SUPER_SHOTGUN;
	if (self.waterlevel <= 1 && self.ammo_cells >= 1 && (it & IT_LIGHTNING) )
		return W_LIGHTNING;
	if(self.ammo_nails >= 1 && (it & IT_NAILGUN) )
		return W_NAILGUN;
	if(self.ammo_shells >= 1 && (it & IT_SHOTGUN) )
		return W_SHOTGUN;
	return W_AXE;
}

void() W_SelectBestWeapon =
{
	if (!W_CanSwitchWeapon()) {
		return;
	}

	self.weapon = W_BestWeapon();
	W_ResetWeaponState();
}

float() W_CheckNoAmmo =
{
	if (self.currentammo > 0)
		return TRUE;

	if (self.weapon == IT_AXE)
		return TRUE;
	
	W_SelectBestWeapon ();
	return FALSE;
}

/*
============
W_Attack

An attack impulse can be triggered now
============
*/
void() W_Attack =
{
	if (!W_CheckNoAmmo ())
		return;
	if (self.customflags & (CFL_PLUNGE|CFL_LIMBO))
		return;
//	if (self.movetype == MOVETYPE_NOCLIP)
//		return;

	makevectors	(self.v_angle);			// calculate forward angle for velocity

	if (self.weapon == W_AXE)
	{
		player_axe();
		W_AxeSwing();
		return;
	}
	
	// moved after axe so that silent swings don't wake monsters
	self.show_hostile = time + 1;
	
	if (self.weapon == W_SHOTGUN)
	{
		player_shot1 ();
		W_FireShotgun ();
	}
	else if (self.weapon == W_SUPER_SHOTGUN)
	{
		player_shot1 ();
		W_FireSuperShotgun ();
	}
	else if (self.weapon == W_QUAD_SHOTGUN)
	{
		player_quad_shotgun();
	}
	else if (self.weapon == W_NAILGUN || self.weapon == W_SUPER_NAILGUN)
	{
		player_nail();
		W_FireSpikes ();
	}
	else if (self.weapon == W_GRENADE_LAUNCHER)
	{
		player_rocket1();
		W_FireGrenade();
	}
	else if (self.weapon == W_ROCKET_LAUNCHER)
	{
		player_rocket1();
		W_FireRocket();
	}

	else if (self.weapon == W_LIGHTNING)
	{
		player_light1();
		self.attack_finished = time + 0.1;
		sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
	}
}

/*
============
W_ChangeWeapon
============
*/
void() W_ChangeWeapon =
{
	local	float	it, fl, weap, no_ammo;

	if (!W_CanSwitchWeapon()) {
		return;
	}
	
	if (self.customflags & CFL_PLUNGE)
		return;
		
	fl = 0;
	no_ammo = FALSE;
	
	if (self.impulse == 1)
	{
		fl = IT_AXE;
		weap = W_AXE;
		it = self.items;
	}
	else if (self.impulse == 2)
	{
		fl = IT_SHOTGUN;
		weap = W_SHOTGUN;
		it = self.items;
		if (self.ammo_shells < 1)
			no_ammo = TRUE;
	}
	else if (self.impulse == 3)
	{
		if (self.items2 & IT_QUAD_SHOTGUN &&
			self.weapon != W_QUAD_SHOTGUN &&
			self.ammo_shells >= 4) {
			// We can select the quad shotgun.
			fl = IT_QUAD_SHOTGUN;
			weap = W_QUAD_SHOTGUN;
			it = self.items2;
		} else {
			// We either don't have the quad shotgun,
			// don't have enough ammo for it, or already have it
			// selected - use the super shotgun instead.
			fl = IT_SUPER_SHOTGUN;
			weap = W_SUPER_SHOTGUN;
			it = self.items;
			if (self.ammo_shells < 2) {
				no_ammo = TRUE;
			}
		}
	}		
	else if (self.impulse == 4)
	{
		fl = IT_NAILGUN;
		weap = W_NAILGUN;
		it = self.items;
		if (self.ammo_nails < 1)
			no_ammo = TRUE;
	}
	else if (self.impulse == 5)
	{
		fl = IT_SUPER_NAILGUN;
		weap = W_SUPER_NAILGUN;
		it = self.items;
		if (self.ammo_nails < 2)
			no_ammo = 1;
	}
	else if (self.impulse == 6)
	{
		fl = IT_GRENADE_LAUNCHER;
		weap = W_GRENADE_LAUNCHER;
		it = self.items;
		if (self.ammo_rockets < 1)
			no_ammo = 1;
	}
	else if (self.impulse == 7)
	{
		fl = IT_ROCKET_LAUNCHER;
		weap = W_ROCKET_LAUNCHER;
		it = self.items;
		if (self.ammo_rockets < 1)
			no_ammo = 1;
	}
	else if (self.impulse == 8)
	{
		fl = IT_LIGHTNING;
		weap = W_LIGHTNING;
		it = self.items;
		if (self.ammo_cells < 1)
			no_ammo = 1;
	}

	self.impulse = 0;

	if (!(it & fl)) {
		// Don't have the weapon
		sprint (self, "no weapon.\n");
		return;
	}
		
	if (no_ammo)
	{	// don't have the ammo
		sprint (self, "not enough ammo.\n");
		return;
	}

//
// set weapon, set ammo
//
	self.weapon = weap;
	W_ResetWeaponState();
}

/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
void() CycleWeaponCommand =
{
	local	float	it, am, fl;
	
	self.impulse = 0;

	if (!W_CanSwitchWeapon()) {
		return;
	}
	
	while (1)
	{
		am = 0;

		if (self.weapon == W_LIGHTNING)
		{
				self.weapon = W_AXE;
				fl = IT_AXE;
				it = self.items;
		}
		else if (self.weapon == W_AXE)
		{
			self.weapon = W_SHOTGUN;
			fl = IT_SHOTGUN;
			it = self.items;
			if (self.ammo_shells < 1)
				am = 1;
		}
		else if (self.weapon == W_SHOTGUN)
		{
			self.weapon = W_SUPER_SHOTGUN;
			fl = IT_SUPER_SHOTGUN;
			it = self.items;
			if (self.ammo_shells < 2)
				am = 1;
		}
		else if (self.weapon == W_SUPER_SHOTGUN)
		{
			self.weapon = W_QUAD_SHOTGUN;
			fl = IT_QUAD_SHOTGUN;
			it = self.items2;
			if (self.ammo_shells < 4)
				am = 1;
		}
		else if (self.weapon == W_QUAD_SHOTGUN)
		{
			self.weapon = W_NAILGUN;
			fl = IT_NAILGUN;
			it = self.items;
			if (self.ammo_nails < 1)
				am = 1;
		}
		else if (self.weapon == W_NAILGUN)
		{
			self.weapon = W_SUPER_NAILGUN;
			fl = IT_SUPER_NAILGUN;
			it = self.items;
			if (self.ammo_nails < 2)
				am = 1;
		}
		else if (self.weapon == W_SUPER_NAILGUN)
		{
			self.weapon = W_GRENADE_LAUNCHER;
			fl = IT_GRENADE_LAUNCHER;
			it = self.items;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == W_GRENADE_LAUNCHER)
		{
			self.weapon = W_ROCKET_LAUNCHER;
			fl = IT_ROCKET_LAUNCHER;
			it = self.items;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == W_ROCKET_LAUNCHER)
		{
			self.weapon = IT_LIGHTNING;
			if (self.ammo_cells < 1)
				am = 1;
		}
	
		if ( (it & fl) && am == 0)
		{
			W_ResetWeaponState ();
			return;
		}
	}

}

/*
============
CycleWeaponReverseCommand

Go to the prev weapon with ammo
============
*/
void() CycleWeaponReverseCommand =
{
	local	float	it, am, fl;
	
	self.impulse = 0;

	if (!W_CanSwitchWeapon()) {
		return;
	}

	while (1)
	{
		am = 0;

		if (self.weapon == W_LIGHTNING)
		{
			self.weapon = W_ROCKET_LAUNCHER;
			fl = IT_ROCKET_LAUNCHER;
			it = self.items;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == W_ROCKET_LAUNCHER)
		{
			self.weapon = W_GRENADE_LAUNCHER;
			fl = IT_GRENADE_LAUNCHER;
			it = self.items;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == W_GRENADE_LAUNCHER)
		{
			self.weapon = W_SUPER_NAILGUN;
			fl = IT_SUPER_NAILGUN;
			it = self.items;
			if (self.ammo_nails < 2)
				am = 1;
		}
		else if (self.weapon == W_SUPER_NAILGUN)
		{
			self.weapon = W_NAILGUN;
			fl = IT_NAILGUN;
			it = self.items;
			if (self.ammo_nails < 1)
				am = 1;
		}
		else if (self.weapon == W_NAILGUN)
		{
			self.weapon = W_QUAD_SHOTGUN;
			fl = IT_QUAD_SHOTGUN;
			it = self.items2;
			if (self.ammo_shells < 4)
				am = 1;
		}
		else if (self.weapon == W_QUAD_SHOTGUN)
		{
			self.weapon = W_SUPER_SHOTGUN;
			fl = IT_SUPER_SHOTGUN;
			it = self.items;
			if (self.ammo_shells < 2)
				am = 1;
			
		}
		else if (self.weapon == W_SUPER_SHOTGUN)
		{
			self.weapon = W_SHOTGUN;
			fl = IT_SHOTGUN;
			it = self.items;
			if (self.ammo_shells < 1)
				am = 1;
		}
		else if (self.weapon == W_SHOTGUN)
		{
			self.weapon = W_AXE;
			fl = IT_AXE;
			it = self.items;
		}
		else if (self.weapon == W_AXE)
		{
			self.weapon = W_LIGHTNING;
			fl = IT_LIGHTNING;
			it = self.items;
			if (self.ammo_cells < 1)
				am = 1;
		}
	
		if ( (it & fl) && am == 0)
		{
			W_ResetWeaponState ();
			return;
		}
	}
}

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_WeaponFrame =
{
	if (self.impulse)
		ImpulseCommands();

	if (time < self.attack_finished)
		return;

	// check for attack
	if (self.button0)
	{
		SuperDamageSound ();
		W_Attack ();
	}
}

// impulses also moved to their own file
