/*
==============================================================================

Fixer Bot
	ironically does the exact opposite of that

OG code from lun/bmFbr, adapted by fw

==============================================================================
*/

$cd id1/models/a_fixer
$origin 0 0 24
$base wizbase	
$skin wizbase

// (001-010) Stand by mode (spinning bottom part)
$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8
$frame stand9 stand10

// (011-020) Opening up top spikes
$frame wakeup1 wakeup2 wakeup3 wakeup4 wakeup5 wakeup6 wakeup7 wakeup8
$frame wakeup9 wakeup10

// (021-030) Walking animation + top spikes
$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8
$frame walk9 walk10

// (031-040) Open the middle part
$frame open1 open2 open3 open4 open5 open6 open7 open8
$frame open9 open10

// (041-050) Run animation
$frame run1 run2 run3 run4 run5 run6 run7 run8
$frame run9 run10

// (051-060) Spin Attack
$frame spin1 spin2 spin3 spin4 spin5 spin6 spin7 spin8
$frame spin9 spin10

// (061-070) Mine Attack
$frame mine1 mine2 mine3 mine4 mine5 mine6 mine7 mine8
$frame mine9 mine10

// (071-080) Idle 1 - spin + dance top spikes
$frame idleA1 idleA2 idleA3 idleA4 idleA5 idleA6 idleA7 idleA8
$frame idleA9 idleA10

// (081-090) Idle 2 - spin + tilt around body
$frame idleB1 idleB2 idleB3 idleB4 idleB5 idleB6 idleB7 idleB8
$frame idleB9 idleB10

// (091-100) Laser Attack
$frame laser1 laser2 laser3 laser4 laser5 laser6 laser7 laser8
$frame laser9 laser10

float()	fixerCheckAttack =
{
	local vector	spot1, spot2;	
	local float		chance;

	if (time < self.attack_finished)
		return FALSE;
	if (!enemy_vis)
		return FALSE;

	if (enemy_range >= RANGE_FAR)
	{
		if (self.attack_state != AS_STRAIGHT)
		{
			self.attack_state = AS_STRAIGHT;
			fxr_run1 ();
		}
		return FALSE;
	}
	
	// see if any entities are in the way of the shot
	if (!has_invis(self.enemy))	// but not if we can't
	{
		// see if any entities are in the way of the shot
		spot1 = self.origin + self.view_ofs;
		spot2 = self.enemy.origin + self.enemy.view_ofs;

		traceline2(spot1, spot2, self, TRACE_WATER);

		if (trace_ent != self.enemy)
		{	// don't have a clear shot, so move to a side
			if (self.attack_state != AS_STRAIGHT)
			{
				self.attack_state = AS_STRAIGHT;
				fxr_run1 ();
			}
			return FALSE;
		}
	}
	
	if (enemy_range == RANGE_MELEE)
		chance = 0.9;
	else if (enemy_range == RANGE_NEAR)
		chance = 0.6;
	else if (enemy_range == RANGE_MID)
		chance = 0.2;
	else
		chance = 0;

	if (random () < chance)
	{
		self.attack_state = AS_MISSILE;
		return TRUE;
	}

	if (enemy_range == RANGE_MID)
	{
		if (self.attack_state != AS_STRAIGHT)
		{
			self.attack_state = AS_STRAIGHT;
			fxr_run1 ();
		}
	}
	else
	{
		// no circle strafing when we're really close ... because it's annoying
		if (enemy_range == RANGE_MELEE)
		{
			self.attack_state = AS_STRAIGHT;
			fxr_run1 ();
			return TRUE;
		}
		if (self.attack_state != AS_SLIDING)
		{
			self.attack_state = AS_SLIDING;
			fxr_side1 ();
		}
	}
	
	return FALSE;
}

void()	fixerAttackFinished =
{
	if (enemy_range >= RANGE_MID || !enemy_vis)
	{
		self.attack_state = AS_STRAIGHT;
		self.think = fxr_run1;
	}
	else
	{
		self.attack_state = AS_SLIDING;
		self.think = fxr_side1;
	}
}

void() fxr_idlesound =
{
	if (self.show_hostile > time) return;
local float wr;
	wr = random() * 5;

	if (self.wait < time)
	{
	 	self.wait = time + 2;
	 	if (wr > 4.5) 
	 		sound (self, CHAN_VOICE, "fixer/widle1.wav", 1,  ATTN_IDLE);
	 	if (wr < 1.5)
	 		sound (self, CHAN_VOICE, "fixer/widle2.wav", 1, ATTN_IDLE);
	}
	return;
}

void()	fxr_stand1	=[	$hover1,		fxr_stand2	] {ai_stand();}
void()	fxr_stand2	=[	$hover2,		fxr_stand3	] {ai_stand();}
void()	fxr_stand3	=[	$hover3,		fxr_stand4	] {ai_stand();}
void()	fxr_stand4	=[	$hover4,		fxr_stand5	] {ai_stand();}
void()	fxr_stand5	=[	$hover5,		fxr_stand6	] {ai_stand();}
void()	fxr_stand6	=[	$hover6,		fxr_stand7	] {ai_stand();}
void()	fxr_stand7	=[	$hover7,		fxr_stand8	] {ai_stand();}
void()	fxr_stand8	=[	$hover8,		fxr_stand1	] {ai_stand();}

void()	fxr_walk1	=[	$hover1,		fxr_walk2	] {ai_walk(8);
fxr_idlesound();}
void()	fxr_walk2	=[	$hover2,		fxr_walk3	] {ai_walk(8);}
void()	fxr_walk3	=[	$hover3,		fxr_walk4	] {ai_walk(8);}
void()	fxr_walk4	=[	$hover4,		fxr_walk5	] {ai_walk(8);}
void()	fxr_walk5	=[	$hover5,		fxr_walk6	] {ai_walk(8);}
void()	fxr_walk6	=[	$hover6,		fxr_walk7	] {ai_walk(8);}
void()	fxr_walk7	=[	$hover7,		fxr_walk8	] {ai_walk(8);}
void()	fxr_walk8	=[	$hover8,		fxr_walk1	] {ai_walk(8);}

void()	fxr_side1	=[	$hover1,		fxr_side2	] {ai_run(16);
fxr_idlesound();}
void()	fxr_side2	=[	$hover2,		fxr_side3	] {ai_run(16);}
void()	fxr_side3	=[	$hover3,		fxr_side4	] {ai_run(16);}
void()	fxr_side4	=[	$hover4,		fxr_side5	] {ai_run(16);}
void()	fxr_side5	=[	$hover5,		fxr_side6	] {ai_run(16);}
void()	fxr_side6	=[	$hover6,		fxr_side7	] {ai_run(16);}
void()	fxr_side7	=[	$hover7,		fxr_side8	] {ai_run(16);}
void()	fxr_side8	=[	$hover8,		fxr_side1	] {ai_run(16);}

void()	fxr_run1	=[	$fly1,		fxr_run2	] {ai_run(32);
fxr_idlesound();
}
void()	fxr_run2	=[	$fly2,		fxr_run3	] {ai_run(32);}
void()	fxr_run3	=[	$fly3,		fxr_run4	] {ai_run(32);}
void()	fxr_run4	=[	$fly4,		fxr_run5	] {ai_run(32);}
void()	fxr_run5	=[	$fly5,		fxr_run6	] {ai_run(32);}
void()	fxr_run6	=[	$fly6,		fxr_run7	] {ai_run(32);}
void()	fxr_run7	=[	$fly7,		fxr_run8	] {ai_run(32);}
void()	fxr_run8	=[	$fly8,		fxr_run9	] {ai_run(32);}
void()	fxr_run9	=[	$fly9,		fxr_run10	] {ai_run(32);}
void()	fxr_run10	=[	$fly10,		fxr_run11	] {ai_run(32);}
void()	fxr_run11	=[	$fly11,		fxr_run12	] {ai_run(32);}
void()	fxr_run12	=[	$fly12,		fxr_run13	] {ai_run(32);}
void()	fxr_run13	=[	$fly13,		fxr_run14	] {ai_run(32);}
void()	fxr_run14	=[	$fly14,		fxr_run1	] {ai_run(32);}

void()	fxr_fast1	=[	$spin1,		fxr_fast2	] {ai_face(); fx_trail(self.origin, self.enemy.origin, 1);}
void()	fxr_fast2	=[	$spin2,		fxr_fast3	] {ai_face(); fx_trail(self.origin, self.enemy.origin, 1);}
void()	fxr_fast3	=[	$spin3,		fxr_fast4	] {ai_face(); fx_trail(self.origin, self.enemy.origin, 1);}
void()	fxr_fast4	=[	$spin4,		fxr_fast5	] {ai_face(); fx_trail(self.origin, self.enemy.origin, 1);}
void()	fxr_fast5	=[	$spin5,		fxr_fast6	] {ai_face(); fx_trail(self.origin, self.enemy.origin, 1);}
void()	fxr_fast6	=[	$spin6,		fxr_fast7	] {ai_face(); fx_trail(self.origin, self.enemy.origin, 1);}
void()	fxr_fast7	=[	$spin7,		fxr_fast8	] {ai_face(); fx_trail(self.origin, self.enemy.origin, 1);}
void()	fxr_fast8	=[	$spin8,		fxr_fast9	] {ai_face(); fx_trail(self.origin, self.enemy.origin, 1);}
void()	fxr_fast9	=[	$spin9,		fxr_fast10	] {ai_face(); fx_trail(self.origin, self.enemy.origin, 1);}
void()	fxr_fast10	=[	$spin10,		fxr_fast11	] {ai_face();}
void()	fxr_fast11	=[	$mine5,		fxr_fast12	] {ai_face();}
void()	fxr_fast12	=[	$mine6,		fxr_fast13	] {ai_face();}
void()	fxr_fast13	=[	$mine7,		fxr_fast14	] {ai_face(); fxr_aim(1.5);}
void()	fxr_fast14	=[	$mine8,		fxr_fast15	] {ai_face();}
void()	fxr_fast15	=[	$mine9,		fxr_fast16	] {ai_face(); fxr_rail_shoot(); self.effects = EF_MUZZLEFLASH;}
void()	fxr_fast16	=[	$mine10,		fxr_run1	] {ai_face(); ai_attack_finished(2); fixerAttackFinished();}

void()	fxr_pain1	=[	$pain1,		fxr_pain2	] {ai_nop();PainFinished(0.2);}
void()	fxr_pain2	=[	$pain2,		fxr_pain3	] {ai_nop();}
void()	fxr_pain3	=[	$pain3,		fxr_pain4	] {ai_nop();}
void()	fxr_pain4	=[	$pain4,		fxr_run1	] {ai_nop();}

void()	fxr_death1	=[	$death1,		fxr_death2	]
{
	self.velocity_x = -100 + 300*random();
	self.velocity_y = -100 + 300*random();
	self.velocity_z = 200 + 200*random();
	self.flags = not(self.flags, FL_ONGROUND);
	sound (self, CHAN_VOICE, "fixer/wdeath.wav", 1, ATTN_NORM);
}
void()	fxr_death2	=[	$death2,		fxr_death3	] {}
void()	fxr_death3	=[	$death3,		fxr_death4	] {self.solid = SOLID_NOT; self.flags = not(self.flags, FL_ONGROUND);}
void()	fxr_death4	=[	$death4,		fxr_death5	] {}
void()	fxr_death5	=[	$death5,		fxr_death6	] {}
void()	fxr_death6	=[	$death6,		fxr_death7	] {}
void()	fxr_death7	=[	$death7,		fxr_death8	] {}
void()	fxr_death8	=[	$death8,		SUB_Null	] 
	{
	PostDeathLogic(); 
	sound (self, CHAN_BODY, "weapons/r_exp3.wav", 1, ATTN_NORM);
	BecomeExplosion();
	}

void() fxr_die =
{
// check for gib
	if (self.health < -40)
	{
		Gib ("progs/h_shams.mdl", self.health);
		return;
	}

	fxr_death1 ();
}


void(entity attacker, float damage) fxr_Pain =
{
	sound (self, CHAN_VOICE, "fixer/wpain.wav", 1, ATTN_NORM);
	if (random()*40 < damage)
		return; // didn't flinch

	dprint("bruh");
	fxr_pain1 ();
}

void(float aheadframes) fxr_aim = {
	vector vel;

	vel = self.enemy.velocity;
	vel_z = 0;
	self.dest1 = self.enemy.origin + vel*(aheadframes/10);
};

void() fxr_rail_shoot =
{
	local vector src, vec, shotdest;
	local float shotdistance, segments, enemydistance, endsegment;
	
	//if !(visible(self.enemy))
	//	return;
		
	//T_Damage(self.enemy, self, self, 50, DMGTYPE_BALLISTIC);

	makevectors(self.angles);
	src = self.origin + v_forward * 2;
	
	enemydistance = vlen(src - self.enemy.origin);

	if (enemydistance < 128) // too close, aim directly at enemy
		shotdest = normalize(self.enemy.origin - src)*1000 + self.enemy.origin;
	else
		shotdest = normalize(self.dest1 - src)*1000 + self.dest1;

	traceline2(src, shotdest, self, TRACE_WATER);
	
	if (trace_fraction < 1) {
		if (trace_ent.health > 0) T_Damage(trace_ent, self, self, 40);
	}

	shotdistance = vlen(src - trace_endpos);

	//	how many railbeam models do we need to draw
	float beammdl_length = 64;
	segments = floor(shotdistance / beammdl_length);
	endsegment = TRUE;

	while (segments) {
		vec = normalize(trace_endpos - src);

		entity newmis = spawn();
		newmis.classname = "railbeam";

		setmodel(newmis, "progs/e2/proj_rail.mdl");
		setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);	
		setorigin(newmis, src + vec * beammdl_length * segments);

		newmis.frame = 0;
		newmis.angles = vectoangles(vec);
		newmis.owner = self;

		newmis.think = rail_fade;
		newmis.nextthink = time + 0.6;

		newmis.cnt = 5;

		segments = segments - 1;

		// Plays impact sound where the shot hits (at the last segment).
		// Segments are drawn in an inverse order, so the last one is the first to spawn.
		if (endsegment) {
			endsegment = FALSE;
			//sound(newmis, CHAN_AUTO, "rider/thump.wav", 1, ATTN_STATIC);
		}
	}
}

void() fxr_rail_fade = {
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
		self.nextthink = time + 0.1;
	}	

	self.cnt = self.cnt - 1;
};


void() monster_fixer_spawn =
{
	self.classname = "monster_fixer";
		
	self.solid = SOLID_SLIDEBOX;
	//self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/e3/mon_fixer.mdl");

	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	self.health = 160;

	self.th_stand = fxr_stand1;
	self.th_walk = fxr_walk1;
	self.th_run = fxr_run1;
	self.th_missile = fxr_fast1;
	self.th_pain = fxr_Pain;
	self.th_die = fxr_die;
	self.th_checkattack = fixerCheckAttack;

	if (self.deathtype == string_null)
		self.deathtype = "was broken by a fixer";

	flymonster_start ();
}

void() monster_fixer_spawner = {mon_spawner_use(monster_fixer_spawn);}

/*QUAKED monster_fixer (1 0 0) (-16 -16 -24) (16 16 40) AMBUSH ? ? ? TRIGGERED NOTFOG NOTELEFRAG INSTAWAKE
The fixer, 80 health points.

Flags:
"ambush" only wake up on seeing the player, not another monster getting angry

"Triggered"	will not spawn until triggered - triggering again will wake him up. Set 'count' to make this a multi-use spawner.
"NoTfog" 	supress teleport glitter when spawned with 'triggered'
"NoTelefrag" will silently fail to spawn if doing so would telefrag an existing monster. will try again automatically 2x/second until it succeeds.
"Instawake" spawn angry at activator

Keys:
"target" entity to trigger when killed
"targetname" entity name
*/
/*FGD
@PointClass base(Monster) size(-16 -16 -24, 16 16 40) model({ "path": ":progs/e3/mon_fixer.mdl" }) = monster_fixer : "fixer" []
*/
void() monster_fixer =
{
	if (!SUB_ShouldSpawn()) return;
	if (nomonster()) return;
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/e3/mon_fixer.mdl");
	precache_model ("progs/h_shams.mdl");
	precache_model ("progs/w_spike.mdl");
	precache_model ("progs/e2/proj_rail.mdl");

	precache_sound ("fixer/hit.wav");		// used by c code
	precache_sound ("fixer/wattack.wav");
	precache_sound ("fixer/wdeath.wav");
	precache_sound ("fixer/widle1.wav");
	precache_sound ("fixer/widle2.wav");
	precache_sound ("fixer/wpain.wav");
	precache_sound ("fixer/wsight.wav");

	self.health = 160;
	//setsize (self, '-16 -16 -24', '16 16 40');
	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	if ( monster_spawnsetup( monster_fixer_spawner ) ) return;
	
	addmonster(1);
	monster_fixer_spawn();
}