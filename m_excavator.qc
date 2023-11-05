/*
==============================================================================

EXCAVATOR

==============================================================================
*/

$cd id1/models/excavator
$origin 0 0 24
$base excbase
$skin excbase

$frame bind // ignore

$frame wake1 wake2 wake3 wake4 wake5

$frame fly1 fly2 fly3 fly4 fly5 fly6 fly7 fly8 fly9 fly10 fly11 fly12
$frame fly13 fly14 fly15 fly16 fly17 fly18 fly19 fly20

$frame fly_loop // ignore

$frame kamiinit1 kamiinit2 kamiinit3 kamiinit4 kamiinit5 kamiinit6 kamiinit7

$frame kamigo1 kamigo2 kamigo3 kamigo4 kamigo5
$frame kamigo6 kamigo7 kamigo8 kamigo9 kamigo10
$frame kamigo11 kamigo12

$frame kamiloop1 kamiloop2 kamiloop3 kamiloop4
$frame kamiloop5 kamiloop6 kamiloop7 kamiloop8 kamiloop9 kamiloop10

$frame s_shot1 s_shot2 s_shot3 s_shot4 s_shot5
$frame s_shot6 s_shot7 s_shot8 s_shot9 s_shot10

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame painb1 painb2 painb3 painb4 painb5 painb6

.float suicidebomb;

/*
 *==================
 * Excavator idle
 *==================
 */
 void() exca_stand1  = [ $wake1, exca_stand1 ] {ai_stand();}

/*
 *==================
 * Excavator fly/run
 *==================
 */
 void() excavator_run1  = [ $fly1, excavator_run2 ] {ai_run(16);}
 void() excavator_run2  = [ $fly2, excavator_run3 ] {ai_run(16);}
 void() excavator_run3  = [ $fly3, excavator_run4 ] {ai_run(16);}
 void() excavator_run4  = [ $fly4, excavator_run5 ] {ai_run(16);}
 void() excavator_run5  = [ $fly5, excavator_run6 ] {ai_run(16);}
 void() excavator_run6  = [ $fly6, excavator_run7 ] {ai_run(16);}
 void() excavator_run7  = [ $fly7, excavator_run8 ] {ai_run(16);}
 void() excavator_run8  = [ $fly8, excavator_run9 ] {ai_run(16);}
 void() excavator_run9  = [ $fly9, excavator_run10 ] {ai_run(16);}
 void() excavator_run10 = [ $fly10, excavator_run11 ] {ai_run(16);}
 void() excavator_run11 = [ $fly11, excavator_run12 ] {ai_run(16);}
 void() excavator_run12 = [ $fly12, excavator_run13 ] {ai_run(16);}
 void() excavator_run13 = [ $fly13, excavator_run14 ] {ai_run(16);}
 void() excavator_run14 = [ $fly14, excavator_run15 ] {ai_run(16);}
 void() excavator_run15 = [ $fly15, excavator_run16 ] {ai_run(16);}
 void() excavator_run16 = [ $fly16, excavator_run17 ] {ai_run(16);}
 void() excavator_run17 = [ $fly17, excavator_run18 ] {ai_run(16);}
 void() excavator_run18 = [ $fly18, excavator_run19 ] {ai_run(16);}
 void() excavator_run19 = [ $fly19, excavator_run20 ] {ai_run(16);}
 void() excavator_run20 = [ $fly20, excavator_run1 ] {ai_run(16);}
 
 /*
 *==================
 * Excavator "walk"
 *==================
 */
 void() excavator_walk1  = [ $fly1, excavator_walk2 ] {ai_walk(8);}
 void() excavator_walk2  = [ $fly2, excavator_walk3 ] {ai_walk(8);}
 void() excavator_walk3  = [ $fly3, excavator_walk4 ] {ai_walk(8);}
 void() excavator_walk4  = [ $fly4, excavator_walk5 ] {ai_walk(8);}
 void() excavator_walk5  = [ $fly5, excavator_walk6 ] {ai_walk(8);}
 void() excavator_walk6  = [ $fly6, excavator_walk7 ] {ai_walk(8);}
 void() excavator_walk7  = [ $fly7, excavator_walk8 ] {ai_walk(8);}
 void() excavator_walk8  = [ $fly8, excavator_walk9 ] {ai_walk(8);}
 void() excavator_walk9  = [ $fly9, excavator_walk10 ] {ai_walk(8);}
 void() excavator_walk10 = [ $fly10, excavator_walk11 ] {ai_walk(8);}
 void() excavator_walk11 = [ $fly11, excavator_walk12 ] {ai_walk(8);}
 void() excavator_walk12 = [ $fly12, excavator_walk13 ] {ai_walk(8);}
 void() excavator_walk13 = [ $fly13, excavator_walk14 ] {ai_walk(8);}
 void() excavator_walk14 = [ $fly14, excavator_walk15 ] {ai_walk(8);}
 void() excavator_walk15 = [ $fly15, excavator_walk16 ] {ai_walk(8);}
 void() excavator_walk16 = [ $fly16, excavator_walk17 ] {ai_walk(8);}
 void() excavator_walk17 = [ $fly17, excavator_walk18 ] {ai_walk(8);}
 void() excavator_walk18 = [ $fly18, excavator_walk19 ] {ai_walk(8);}
 void() excavator_walk19 = [ $fly19, excavator_walk20 ] {ai_walk(8);}
 void() excavator_walk20 = [ $fly20, excavator_walk1 ] {ai_walk(8);}

/*
 *============================
 * Excavator "kamikaze" attack
 *============================
 */

void() excavator_kamikaze_touch =
{
	if ((other.classname == "spike") || (other.classname == "rocket") || (other.classname == "grenade")) 
	{
		return; // don't explode on projectiles
	}

	T_RadiusDamage(self, self, 60, world);
	T_Damage(self, self.enemy, self.enemy, 100, DMGTYPE_MELEE);
	BecomeExplosion();
	
};


float EXCAVATOR_KSPEED = 600;
float EXCAVATOR_TURNRATE = 300; 


vector(entity targ, float turnrate) ExcavTurnToward =
{
	vector	vel, aimdir, temp, temp2, out;

	temp = targ.origin + '0 0 -16'; //vertical offset for aiming at

	aimdir = temp - self.origin;
	aimdir = normalize(aimdir);
	vel = normalize(self.velocity);
	
	temp = CrossProduct(vel, aimdir);
	out = rotateVectorAround(vel, temp, turnrate * 0.1);
	
	// don't turn past the desired direction
	temp2 = CrossProduct(out, aimdir);
	if ((temp * temp2) < 0)
		return aimdir;
	return out;
};


void() excavator_kamikaze_move =
{
	local float dot, rate;
	
	setsize (self, '-16 -16 16', '16 16 48');
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	
	rate = EXCAVATOR_TURNRATE;
	dot = normalize( self.velocity ) * normalize( self.enemy.origin - self.origin );

	if ( dot > 0 )
		rate *= max(1, 1.5 * (1 - dot));

	self.velocity = EXCAVATOR_KSPEED * ExcavTurnToward( self.enemy, rate);
};


void() excavator_correct_angles =
{
	// change pitch as well, used instead of ai_face
	self.angles = vectoangles(self.velocity);
};

void() excavator_kamikaze1  = [ $kamiinit1, excavator_kamikaze2  ] { ai_face(); self.suicidebomb = 1;} //excavator shouldn't infight after kami, causes bugs
void() excavator_kamikaze2  = [ $kamiinit2, excavator_kamikaze3  ] { ai_face();}
void() excavator_kamikaze3  = [ $kamiinit3, excavator_kamikaze4  ] { ai_face(); }
void() excavator_kamikaze4  = [ $kamiinit4, excavator_kamikaze5  ] { ai_face(); }
void() excavator_kamikaze5  = [ $kamiinit5, excavator_kamikaze6  ] { ai_face(); }
void() excavator_kamikaze6  = [ $kamiinit6, excavator_kamikaze7  ] { ai_face(); }
void() excavator_kamikaze7  = [ $kamigo1,   excavator_kamikaze8  ] { ai_face(); }
void() excavator_kamikaze8  = [ $kamigo2,   excavator_kamikaze9  ] { ai_face(); }
void() excavator_kamikaze9  = [ $kamigo3,   excavator_kamikaze10 ] { ai_face(); }
void() excavator_kamikaze10 = [ $kamigo4,   excavator_kamikaze11 ] { ai_face(); }
void() excavator_kamikaze11 = [ $kamigo5,   excavator_kamikaze12 ] { ai_face(); }
void() excavator_kamikaze12 = [ $kamigo6,   excavator_kamikaze13 ] { ai_face(); }
void() excavator_kamikaze13 = [ $kamigo7,   excavator_kamikaze14 ] { ai_face(); }
void() excavator_kamikaze14 = [ $kamigo8,   excavator_kamikaze15 ] { ai_face(); }
void() excavator_kamikaze15 = [ $kamigo9,   excavator_kamikaze16 ] { ai_face(); }
void() excavator_kamikaze16 = [ $kamigo10,  excavator_kamikaze17 ] { ai_face(); }
void() excavator_kamikaze17 = [ $kamigo11,  excavator_kamikaze23 ] { ai_face(); makevectors(self.angles); self.velocity = EXCAVATOR_KSPEED * v_forward; }
// loop point
void() excavator_kamikaze23 = [ $kamiloop1, excavator_kamikaze24 ] { excavator_correct_angles(); excavator_kamikaze_move(); }
void() excavator_kamikaze24 = [ $kamiloop2, excavator_kamikaze25 ] { excavator_correct_angles(); }
void() excavator_kamikaze25 = [ $kamiloop3, excavator_kamikaze26 ] { excavator_correct_angles(); excavator_kamikaze_move(); }
void() excavator_kamikaze26 = [ $kamiloop4, excavator_kamikaze27 ] { excavator_correct_angles(); }
void() excavator_kamikaze27 = [ $kamiloop5, excavator_kamikaze28 ] { excavator_correct_angles(); excavator_kamikaze_move(); }
void() excavator_kamikaze28 = [ $kamiloop6, excavator_kamikaze29 ] { excavator_correct_angles(); }
void() excavator_kamikaze29 = [ $kamiloop7, excavator_kamikaze30 ] { excavator_correct_angles(); excavator_kamikaze_move(); }
void() excavator_kamikaze30 = [ $kamiloop8, excavator_kamikaze23 ] { excavator_correct_angles(); }
void() excavator_kamikaze31 = [ $kamiloop9, excavator_kamikaze23 ] { excavator_correct_angles(); excavator_kamikaze_move(); }


void() excavator_kamikaze_start =
{
	//self.movetype = MOVETYPE_FLYMISSILE; //? to not interract with ai_face
	sound (self, CHAN_VOICE, "exca/ex_kami.wav", 1, ATTN_NORM);
	self.touch = excavator_kamikaze_touch;
	excavator_kamikaze1();
};

 /*
 *==================
 * Excavator pain
 *==================
 */

 void() excavator_pain1 = [ $pain1, excavator_pain2 ] {ai_nop(); PainFinished(1);}
 void() excavator_pain2 = [ $pain2, excavator_pain3 ] {ai_nop();}
 void() excavator_pain3 = [ $pain3, excavator_pain4 ] {ai_nop();}
 void() excavator_pain4 = [ $pain4, excavator_pain5 ] {ai_nop();}
 void() excavator_pain5 = [ $pain5, excavator_pain6 ] {ai_nop();}
 void() excavator_pain6 = [ $pain6, excavator_run1 ] {ai_nop();}

void(entity attacker, float damage) excavator_pain =
{

	if ((self.health < 340) && (self.touch != excavator_kamikaze_touch)) 
	{		
		excavator_kamikaze_start();
		return;
	}

	if (self.touch == excavator_kamikaze_touch) 
	{
		return; // No flinch
	}

	if ((random() * 70) + 20 > damage)
	{
		return;
	}
	
	if ((random() > 0.5))
	{
		sound (self, CHAN_VOICE, "exca/ex_pain1.wav", 1, ATTN_NORM);
		excavator_pain1();
	}
	else
	{
		sound (self, CHAN_VOICE, "exca/ex_pain2.wav", 1, ATTN_NORM);
		excavator_pain1();		
	}
};


void() excavator_fire = {

	vector org, vec;
	local float r;
	local entity e;
	r = random();

	self.effects = self.effects | EF_MUZZLEFLASH;

	org = self.origin + '0 0 35';
	vec = normalize(enemy_vispos() - org + enemy_aim_vertical());
	
	makevectors(self.angles);	
	if (angledif(self.ideal_yaw, self.angles_y) > 80)	// no ass rockets
	{
		vec_x = v_forward_x;
		vec_y = v_forward_y;
		vec = normalize(vec);
	}
	
//	if (enemy_range == RANGE_NEAR)
//	{
//	
//		e = launch_rocket(org, vec * 550);	
//		e.dmg = 20;
//
//		vec = normalize(enemy_vispos() - org + enemy_aim_vertical());
//		vec = normalize(vec + (v_right * 0.2));		
//		e = launch_rocket(org, vec * 550);
//		e.dmg = 20;		
//		
//		vec = normalize(enemy_vispos() - org + enemy_aim_vertical());		
//		vec = normalize(vec - (v_right * 0.2));		
//		e = launch_rocket(org, vec * 550);		
//		e.dmg = 20;		
//	
//	}
//	else
//	{	
		e = launch_rocket(org, vec * 700);
		SUB_ChangeModel (e, "progs/e2/proj_crystal.mdl");
		e.dmg = 40;
//	}

};


void()	excavator_fire1	= [ $s_shot1, excavator_fire2 ] {ai_face(); self.effects = self.effects | EF_MUZZLEFLASH;}
void()	excavator_fire2	= [ $s_shot2, excavator_fire3 ] {sound (self, CHAN_WEAPON, "exca/ex_fire.wav", 1, ATTN_NORM);}
void()	excavator_fire3	= [ $s_shot3, excavator_fire4 ] {}
void()	excavator_fire4	= [ $s_shot4, excavator_fire5 ] {}
void()	excavator_fire5	= [ $s_shot5, excavator_fire6 ] {}
void()	excavator_fire6	= [ $s_shot6, excavator_fire7 ] {}
void()	excavator_fire7	= [ $s_shot7, excavator_fire8 ] {}
void()	excavator_fire8	= [ $s_shot8, excavator_fire9 ] {excavator_fire();}
void()	excavator_fire9	= [ $s_shot9, excavator_fire10 ] {}
void()	excavator_fire10 = [ $s_shot10, excavator_run1 ] { 
	// Finished attacking
	if (enemy_range >= RANGE_MID || !enemy_vis)
	{
		self.attack_state = AS_STRAIGHT;	
	}
	else
	{
		self.attack_state = AS_SLIDING;
	}
	
	self.think = excavator_run1;
	ai_attack_finished(1.25);
}

void() excavator_die =
{
	ThrowGib ("progs/e2/gib_excavatord.mdl", 100);
	ThrowGib ("progs/e2/gib_excavatorc.mdl", 100);
	ThrowGib ("progs/e2/gib_excavatorb.mdl", 100);
	ThrowGib ("progs/e2/gib_excavatora.mdl", 100);
	BecomeExplosion();
};

/*
=================
ExcavatorCheckAttack
=================
*/
float()	ExcavatorCheckAttack =
{
	local vector	spot1, spot2;	
	local float		chance;

	if (time < self.attack_finished) {
		return FALSE;
	}

	if (!enemy_vis) {
		return FALSE;
	}

	if (enemy_range >= RANGE_FAR)
	{
		if (self.attack_state != AS_STRAIGHT)
		{
			self.attack_state = AS_STRAIGHT;
			excavator_run1();
		}
		return FALSE;
	}

	// see if any entities are in the way of the shot
	if (!has_invis(self.enemy))	// but not if we can't see him
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
				excavator_run1();
			}
			return FALSE;
		}
	}

//	if (enemy_range == RANGE_MELEE)
//		chance = 0.7;
//	else if (enemy_range == RANGE_NEAR)
//		chance = 0.5;
//	else if (enemy_range == RANGE_MID)
//		chance = 0.8;
//	else
		chance = 1;

	if (random() < chance)
	{
		self.attack_state = AS_MISSILE;
		return TRUE;
	}

	if (enemy_range == RANGE_MID)
	{
		if (self.attack_state != AS_STRAIGHT)
		{
			self.attack_state = AS_STRAIGHT;
			excavator_run1();
		}
	}
	else
	{
		// no circle strafing when we're really close ... because it's annoying
		if (enemy_range == RANGE_MELEE)
		{
			self.attack_state = AS_STRAIGHT;
			excavator_run1();
			return TRUE;
		}
		if (self.attack_state != AS_SLIDING)
		{
			self.attack_state = AS_SLIDING;
			excavator_run1();
		}
	}
	
	return FALSE;
};

void() monster_excavator_spawn =
{
	self.classname = "monster_excavator";
		
	self.solid = SOLID_SLIDEBOX;

	setmodel(self, "progs/e2/mon_excavator.mdl");

	setsize (self, '-32 -32 -16', '32 32 72');
	self.health = 600;

	self.th_stand = exca_stand1;
	self.th_walk = excavator_walk1;
	self.th_run = excavator_run1;
	self.th_missile = excavator_fire1;
	self.th_pain = excavator_pain;
	self.th_die = excavator_die;
	self.th_checkattack = ExcavatorCheckAttack;
	self.yaw_speed = 30;

	if (self.deathtype == string_null)
		self.deathtype = "was deconstructed by a Construct";

	flymonster_start();
};

void() monster_excavator_spawner = {mon_spawner_use(monster_excavator_spawn);}

/*QUAKED monster_excavator (1 0 0) (-32 -32 -24) (32 32 40) AMBUSH ? ? ? TRIGGERED NOTFOG NOTELEFRAG INSTAWAKE
Excavator, 200 health points

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
@PointClass base(Monster) size(-32 -32 -16, 32 32 72) model({ "path": ":progs/e2/mon_excavator.mdl" }) = monster_excavator : "Excavator" []
*/
void() monster_excavator =
{
	if (!SUB_ShouldSpawn()) return;
	if (nomonster()) return;
	if (deathmatch)
	{
		remove(self);
		return;
	}
    
	precache_model("progs/e2/mon_excavator.mdl");
	
	precache_model("progs/e2/proj_crystal.mdl");
	precache_model("progs/e2/gib_excavatora.mdl");
	precache_model("progs/e2/gib_excavatorb.mdl");
	precache_model("progs/e2/gib_excavatorc.mdl");	
	precache_model("progs/e2/gib_excavatord.mdl");
		
	precache_sound ("exca/ex_alert1.wav");
	precache_sound ("exca/ex_alert2.wav");
	precache_sound ("exca/ex_kami.wav");
	precache_sound ("exca/ex_pain1.wav");
	precache_sound ("exca/ex_pain2.wav");
	precache_sound ("exca/ex_fire.wav");

	self.health = 600;	
	setsize (self, '-32 -32 -16', '32 32 72');
	if (monster_spawnsetup(monster_excavator_spawner)) {
		return;
	}
	
	addmonster(1);
	monster_excavator_spawn();
};