/*
===============

BULLETS

sg:		6 * 4 = 24		/ 48 / 72 / 96 / 120
ssg:	14 * 4 = 56		/ 112 / 168 / 224 / 280

sg:		5 * 5 = 25		/ 50 / 75 / 100 / 125
ssg:	11 * 5 = 55		/ 110 / 165 / 220 / 275
ssg:	12 * 5 = 60		/ 120 / 180 / 240 / 300

===============
*/

vector(vector dir, vector spread) SpreadVector = 
{
	return dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;
}

/*
================
BulletImpact
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
vector(float damage, vector dir) BulletImpact =
{
	vector vel, org;
	
	vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2*trace_plane_normal;

	org = trace_endpos - dir*4;

	if (trace_ent.takedamage)
	{
		SpawnBlood (org, vel*40, damage);
		AddMultiDamage (trace_ent, damage);
	}
	else gunshot(org);

	return org;
}

float(entity t) HasBeenShotToDeath =
{
	if (t.multi_dmg < t.health) return FALSE;
	if (DamageCanKill(t,t.multi_dmg)) return TRUE;
	return FALSE;
}

/*
================
FireBullets

Used by shotgun, super shotgun, and enemy soldier firing
================
*/
void(float shotcount, vector dir, vector spread) FireBullets =
{
	FireBulletsEx(shotcount, dir, spread, 4);
}

void(float shotcount, vector dir, vector spread, float damage) FireBulletsEx =
{
	vector src, direction;
	entity ig;
	float s, lim;
	
	if (shotcount <= 0) return;
	
	makevectors(self.v_angle);

	if (trace_debug) dprint3("*** firing ", ftos(shotcount), " bullets *\n\n");
	for (s = 0; s < shotcount; s++)
	{
		src = self.origin + v_forward*10;
		src_z = self.absmin_z + self.size_z * 0.7;
		direction = SpreadVector(dir, spread);
		
		if (trace_debug) dprint("* firing a bullet *\n");
		
		lim = 0;
		// check for trace-through cases
		for (ig = self; ig != world; lim++)	// ig == world if we hit a wall or hit nothing
		{
			traceline2(src, src + direction*2048, ig, 0);
			
			// if we've already pelted a monster enough to kill it, let additional bullets add 
			// up for possible gibs (ala quake), but trace them again through the target for 
			// better crowd control feels (ala doom).
			// this is only noticeable with big hordes of weak guys, but it makes big hordes of
			// weak guys not feel like solid ammo-sponge walls.
			if (trace_ent.takedamage && 
				(trace_ent.flags & FL_MONSTER || trace_ent.classname == "player" ) && 
				// some id shootables are actually trigger_multiples with health and SOLID_BBOX, so this doesn't work (see e1m6):
				//( trace_ent.solid == SOLID_BBOX || trace_ent.solid == SOLID_SLIDEBOX ) &&	
				HasBeenShotToDeath(trace_ent) )
			{
				BulletImpact (2+2*random(), direction);

				// start 0.1 unit forward, or else when shooting an adjacent enemy we'll
				// just hit ourselves again
				src = trace_endpos + direction * 0.1;
				ig = trace_ent;
				if (trace_debug) dprint3("bullet hit ", ig.classname, ", continuing thru\n");
			}
			else
			{
				if (trace_debug) dprint("bullet reached world\n");
				ig = world;
			}
			if (lim > 8)
			{
				dprint("bullet pen limit exceeded\n");
				break;
			}
		}
		
		if (trace_fraction != 1.0)
		{
			BulletImpact (damage, direction);
		}
		
		if (trace_debug) dprint("bullet is over\n\n");
	}
}

/*
================
W_FireShotgun
================
*/
void() W_FireShotgun =
{
	local vector dir;
	float haste_factor;
	
	// for ai_nav:
	/*if (nav_w_nodeLink())
	{
		self.attack_finished = time + 0.5;
		return;
	}*/
	
	sound (self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);	

	self.punchangle_x = -2;
	makevectors(self.v_angle);
	
	self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	dir = aim (self, AUTOAIM_DIST);

	ClearMultiDamage ();
	FireBullets (6, dir, '0.04 0.04 0');

	if (has_haste(self)) {
		haste_factor = HASTE_FACTOR;
	} else {
		haste_factor = 1;
	}
	self.attack_finished = time + 0.5 * haste_factor;
	
	ApplyMultiDamage ();
}


/*
================
W_FireSuperShotgun
================
*/
void() W_FireSuperShotgun =
{
	local vector dir;
	float haste_factor;
	
	// for ai_nav:
	/*if (nav_w_nodeLinkSpecial())
	{
		self.attack_finished = time + 0.5;
		return;
	}*/

	if (self.currentammo == 1)
	{
		if (self.items & IT_SHOTGUN)
			W_FireShotgun ();
		return;
	}
		
	sound (self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);	

	self.punchangle_x = -4;
	
	self.currentammo = self.ammo_shells = self.ammo_shells - 2;
	dir = aim (self, AUTOAIM_DIST);

	ClearMultiDamage ();

	FireBullets (14, dir, '0.14 0.08 0');

	if (has_haste(self)) {
		haste_factor = HASTE_FACTOR;
	} else {
		haste_factor = 1;
	}
	self.attack_finished = time + 0.7 * haste_factor;
	
	ApplyMultiDamage ();
}

/*
================
W_FireQuadhotgun
================
*/
void() W_FireQuadShotgun =
{
	local vector dir;

	sound(self ,CHAN_WEAPON, "weapons/shotgn3.wav", 1, ATTN_NORM);
	self.punchangle_x = -2;
	self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	makevectors(self.v_angle);
	dir = aim(self, AUTOAIM_DIST);

	ClearMultiDamage();
	FireBulletsEx(18, dir, '0.15 0.02 0', 2);
	ApplyMultiDamage();
}

/*
================
RAILGUN
================
*/
/*void() W_FireRail =
{
	local vector dir;
	dir = aim(self, AUTOAIM_DIST);
	
};*/

void() rail_fade = {
	
	self.think = rail_fade;
	self.nextthink = time + 0.1;

	if (self.cnt == 6)
		self.alpha = 0.7;
	else if (self.cnt == 5)
		self.alpha = 0.4;
	else if (self.cnt == 4)
		self.alpha = 0.2;
	else if (self.cnt == 3)
		self.alpha = 0.15;
	else if (self.cnt == 2)
		self.alpha = 0.10;
	else if (self.cnt == 1) {
		self.alpha = 0.05;
		self.think = SUB_Remove;
		self.nextthink = time + 0.05;
		
	}	
	self.cnt = self.cnt - 1;
};

void() W_FireRail =
{
	local float timetoend;
	local vector	vel, org, dir, vec, src, loopsrc,  destination, dir2, dir3;
	local vector drawsrc;
	local entity thedude;
	local float traillen, segments;
	entity prj;
	
	if (self.ammo_cells < 6)
	{
		W_SelectBestWeapon();
		return;
	}
	
	self.weaponframe = 0;
	
	if (random() < 0.5)
		{
			self.weaponframe = 31;
			self.punchangle_z = -3;
		}
	else if (random() < 0.5)
		{
			self.weaponframe = 0;
			self.punchangle_z = -3;
		}
	else 
		{
			self.weaponframe = 15;
			self.punchangle_z = 3;
		}
	
	player_rail1();
	makevectors(self.v_angle);
	
	sound (self, CHAN_WEAPON, "weapons/rail.wav", 1, ATTN_NORM);

	self.currentammo = self.ammo_cells = self.ammo_cells - 6;

	org = self.origin + '0 0 16';

	dir = aim(self, AUTOAIM_DIST);
	src = self.origin + v_forward * 4;
	drawsrc = src;
	src_z = self.absmin_z + self.size_z * 0.84; // ~eye level
	drawsrc_z = self.absmin_z + self.size_z * 0.6; // ~ gun level
	destination = src + (dir * 8192);
	
	loopsrc = src;
	thedude = self;
	
	while ( !timetoend )
	{
		traceline2(loopsrc, destination, thedude, 0);
		if (trace_fraction != 1.0)
		{
			vel = normalize(dir);
			vel = vel + 2 * trace_plane_normal;
			vel = vel * 200;

			org = trace_endpos - dir*4;

			if (trace_ent.takedamage && trace_ent != self)
			{
				thedude = trace_ent;
				SpawnBlood (org, vel*0.2, 400);
				if (trace_ent != self) 
				{
					if (deathmatch != 0){
						T_Damage (trace_ent, self, self, 150);
						}
						else
						{
						T_Damage (trace_ent, self, self, 270);
							}

					
					// if we have the right amount of health add some velocity if we're not gibbing
					
					if (trace_ent.health <= 0)
					{
						trace_ent.velocity = '0 0 0';					
						trace_ent.velocity_z = 175;
						// zero out the velocity and give it some z velocity so its off ground
						trace_ent.flags = trace_ent.flags - (trace_ent.flags & FL_ONGROUND);
						// also set the flag
						
						// we don't want z velocity, so we're going to zero that out too.
						dir3 = BoundsCenter(self);
						dir3_z = 0;
						dir2 = trace_ent.origin;
						dir2_z = 0;
						dir2 = dir2 - dir3;
						dir2 = normalize(dir2);
						trace_ent.velocity = trace_ent.velocity + dir2*400;						
											
					}
				}
									
				//loopsrc = trace_endpos; 
				// Trace from inside of the hitted monster (vf)
				loopsrc = trace_endpos + (dir * 4);
			}
			else
			{
				WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
				WriteByte (MSG_BROADCAST, TE_GUNSHOT);
				WriteCoord (MSG_BROADCAST, org_x);
				WriteCoord (MSG_BROADCAST, org_y);
				WriteCoord (MSG_BROADCAST, org_z);

				timetoend = 1;
			}
		}
		else timetoend = 1;
	}
	
	//--- ALKALINE RAIL CODE
	// now using drawsrc instead of src now, so we trace damage from eye position and trail from gun position
	traceline2(drawsrc, destination, self, TRACE_NOMONSTERS);
	traillen = vlen(trace_endpos - drawsrc);
	segments = floor(traillen / 64);
	
	while (segments)
	{
		vec = normalize(trace_endpos - drawsrc);
		prj = spawn ();
		prj.owner = self;
		prj.movetype = MOVETYPE_NONE;
		prj.solid = SOLID_NOT;
		prj.angles = vectoangles(dir);
		prj.touch = SUB_Null;
		prj.classname = "railtrail";
		setmodel (prj, "progs/rail.mdl");
		setsize (prj, VEC_ORIGIN, VEC_ORIGIN);		
		//setorigin (prj, self.origin + '0 0 16');
		setorigin (prj, drawsrc + vec * 64 * segments);
		prj.velocity = '0 0 0';	
		prj.frame = 4;	
		prj.think = rail_fade;
		prj.nextthink = time + 0.2 + (segments*0.05); // delay fade time using segment number for neat effect (vf)
		segments = segments - 1;
		prj.cnt = 5;	
	}	
	
	local float haste_factor;
	
	if (has_haste(self)) {
		haste_factor = HASTE_FACTOR;
	} else {
		haste_factor = 1;
	}
	self.rail_nextshot = time + 1.4 * haste_factor;
	self.attack_finished = time + 1;
};

/*
================
W_FireRifle
================
*/
void() W_FireRifle =
{
	local vector dir;
	float haste_factor;
	
	sound (self, CHAN_WEAPON, "weapons/rifle.wav", 1, ATTN_NORM);	

	self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	
	makevectors(self.v_angle);
	dir = aim (self, AUTOAIM_DIST);

	ClearMultiDamage ();
	//FireBullets (1, dir, '0.001 0.001 0'); // no control over damage, anyway it's just a wrapper
	FireBulletsEx(1, dir, '0.001 0.001 0', 50);
	ApplyMultiDamage ();
	
	self.punchangle_x = -4;
	if (has_haste(self)) 
		haste_factor = HASTE_FACTOR;
	else haste_factor = 1;
	self.rifle_nextshot = time + 1.4 * haste_factor;
	self.attack_finished = time + 0.8;
};