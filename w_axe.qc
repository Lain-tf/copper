/*
===============

THE AXE

===============
*/

// SOUNDS

void() W_AxeWhiffSound =
{
		sound (self, CHAN_OTHER, "weapons/ax1.wav", 1, ATTN_NORM);
}

void() W_AxeHitSound =
{
	if (random() < 0.5)
		sound (self, CHAN_WEAPON, "weapons/axhit1.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_WEAPON, "weapons/axhit2.wav", 1, ATTN_NORM);
}


void(float foff) W_AxeCycle =
{
	// lip and touch_time are overloaded on the player for animation event timing
	// lip = 10fps player anim clock (axe animates at 20 so player has to think on 20s)
	// touch_time = timer for the actual weapon attack trace event
	self.weaponframe = min(57, self.weaponframe + foff);
	
	// entire axe swing anim is scheduled to be done by now
	if (self.attack_finished <= time)
	{
		// stop the player anim cycle and restore normal thinking
		W_SetIdleWeaponFrame();
		player_run();
		return;
	}
	
	if (self.touch_time && self.touch_time <= time)
	{
		self.touch_time = 0;
		W_FireAxe();
	}
	// time for a regular animation think
	else if (self.lip <= time)
	{
		self.think1();	// advance the player anim on the standard 10fps clock
		self.lip = time + 0.1;
	}
	self.nextthink = time + 0.05;
}

void() W_AxeThink = { self.think = W_AxeThink; W_AxeCycle(1);  } 
void() W_AxeThinkReverse = {  self.think = W_AxeThinkReverse; W_AxeCycle(-1); } 

void() W_AxeSwing =
{
	float haste_factor;
	if (has_haste(self)) {
		haste_factor = HASTE_FACTOR;
	} else {
		haste_factor = 1;
	}

	W_AxeWhiffSound();
		self.weaponframe = 10 * (floor(4.99 * random()));
		self.touch_time = time + 0.1;
		self.attack_finished = time + 0.49 * haste_factor;
	self.think1 = player_axe;
	W_AxeThink();
}

/*
================
W_VoidAxe_Find
================
*/
void() W_VoidAxe_Find =
{
	makevectors(self.v_angle);
	entity axe_find = world;
	entity best_find = world;
	float best_dist = 16384;
	while (1) //find which voidaxe destination the player is currently looking at, regardless of walls or other entities
	{
		axe_find = find(axe_find, classname, "info_voidaxe_destination");
		if (!axe_find) break;
		vector destdir = axe_find.origin - (self.origin + self.view_ofs);
		float vdist = destdir * v_forward;
		if (vdist < best_dist)
        {
		vector vorg = v_forward * vdist;
		float rdist = vlen(vorg - destdir);
		if (rdist < 64)
		{
		best_find = axe_find;
		best_dist = vdist;
		}
	}
}
	self.buddy = best_find;
	if (best_find) //check if the player *can* actually see their destination
	{
		local vector org;
		org = self.origin + self.view_ofs;
		traceline2(org, best_find.origin, self, 0);
			if (trace_fraction == 1 && (self.buddy.vaxe_timeout < time) || (self.buddy.vaxe_timeout == 0))
			{
				self.buddy.state = 1;
				particle(best_find.origin + '0 0 32', VEC_ORIGIN, 238, 2);
			}
			else
			{
				self.buddy.state = 0;
			}
	}
}


/*
================
W_FireAxe
================
*/
void() W_FireAxe =
{


	vector	source, org;
	local vector toss;
	if (self.health <= 0)
		return;
	
	makevectors (self.v_angle);
			
		if (self.buddy != world && self.buddy.state == 1)
	{
		vector saveview = self.v_angle;
		teleport(self, self.buddy, 3, 1);
		self.buddy.vaxe_timeout = time + 5; //set a cooldown on the individual voidaxe teleport destination
		makevectors (self.v_angle);
		self.angles = saveview;
		self.velocity = v_forward * 200;
		return;
	}
		
		source = self.origin + self.view_ofs;//'0 0 16';
	
		if (self.berserk_finished > time)		
			traceline2(source, source + v_forward * (96), self, 0);
		else
			traceline2(source, source + v_forward * (64), self, 0);		
			
		if (trace_fraction == 1.0) 
			return;
		
		self.show_hostile = time + 1;	// wake monsters up
		
		org = trace_endpos - v_forward*4;

		BerserkSound();

		if (trace_ent.takedamage)
		{
			trace_ent.customflags = trace_ent.customflags | CFL_AXEHITME;
			SpawnBlood (org, '0 0 0', 20);
			
			if (self.berserk_finished > time)
				T_Damage (trace_ent, self, self, 264);			
			else			
				T_Damage (trace_ent, self, self, 24);
			
			
			if (has_berserk(self))
			{
				if (trace_ent.classname == "player" && (trace_ent.health < 1))
				{
					toss = v_forward;
					toss_z = 0;
					if (has_berserk(self))
						toss = normalize(toss) * 800;
					else if (has_quad(self))
						toss = normalize(toss) * 400;
					else	
					// how would this even happen ^	
						toss = normalize(toss) * 200;
					toss_z = 100;
					//bprint(vtos(toss));
					//bprint("\n");
					//toss *=  - vlen(head.maxs - head.mins)
					trace_ent.origin_z = trace_ent.origin_z + 1;
					trace_ent.velocity = toss;
					trace_ent.flags = not(trace_ent.flags, FL_ONGROUND);
				}
			}
			
			if (trace_ent.flags & FL_MONSTER)
			{
				if (trace_ent.type == "zombie")
					zombie_knockdown(trace_ent);
				W_AxeHitSound();
			}
			else
			{
				sound (self, CHAN_WEAPON, "zombie/z_hit.wav", 1, ATTN_IDLE);
			}
			
			// beserk doubled the knockback with the axe but removed the quad knockback
			// do knockback with berserk
			if (has_berserk(self))
			{
				if ((trace_ent.movetype == MOVETYPE_STEP || trace_ent.movetype == MOVETYPE_WALK) && 
					// don't swat bosses or other non-standard-sized enemies around
					trace_ent.type != "boss")
				{
					toss = v_forward;
					toss_z = 0;
					if (has_berserk(self))
						toss = normalize(toss) * 800;
					else if (has_quad(self))
						toss = normalize(toss) * 400;
					else	
						toss = normalize(toss) * 200;
					// how would this even happen ^	
					toss_z = 100;
					//bprint(vtos(toss));
					//bprint("\n");
					//toss *=  - vlen(head.maxs - head.mins)
					trace_ent.origin_z = trace_ent.origin_z + 1;
					trace_ent.velocity = toss;
					trace_ent.flags = not(trace_ent.flags, FL_ONGROUND);
				}
			}
		}
		else
		{	// hit wall
			sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
			gunshot(org);
		}
}

