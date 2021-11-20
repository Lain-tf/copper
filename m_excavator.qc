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

$frame fly1 fly2 fly3 fly4 fly5 fly6 fly7 fly8 fly9 fly10
$frame fly11 fly12

$frame fly_loop // ignore

$frame attack1 attack2 attack3 attack4 attack5 attack6
$frame attack7 attack8 attack9 attack10 attack11 attack12

$frame kamiinit1 kamiinit2 kamiinit3 kamiinit4 kamiinit5 kamiinit6
$frame kamiinit7 kamiinit8 kamiinit9 kamiinit10 kamiinit11 kamiinit12
$frame kamiinit13 kamiinit14 kamiinit15 kamiinit16 kamiinit17

$frame kamikaze1 kamikaze2 kamikaze3 kamikaze4 kamikaze5 kamikaze6
$frame kamikaze7 kamikaze8 kamikaze9 kamikaze10 kamikaze11 kamikaze12
$frame kamikaze13 kamikaze14 kamikaze15 kamikaze16

$frame pain1 pain2 pain3 pain4 pain5 pain6

/*
 *==================
 * Excavator fly/run
 *==================
 */
 void() excavator_run1 = [ $fly1, excavator_run2 ] {ai_run(16);}
 void() excavator_run2 = [ $fly2, excavator_run3 ] {ai_run(16);}
 void() excavator_run3 = [ $fly3, excavator_run4 ] {ai_run(16);}
 void() excavator_run4 = [ $fly4, excavator_run5 ] {ai_run(16);}
 void() excavator_run5 = [ $fly5, excavator_run6 ] {ai_run(16);}
 void() excavator_run6 = [ $fly6, excavator_run7 ] {ai_run(16);}
 void() excavator_run7 = [ $fly7, excavator_run8 ] {ai_run(16);}
 void() excavator_run8 = [ $fly8, excavator_run9 ] {ai_run(16);}
 void() excavator_run9 = [ $fly9, excavator_run10 ] {ai_run(16);}
 void() excavator_run10 = [ $fly10, excavator_run11 ] {ai_run(16);}
 void() excavator_run11 = [ $fly11, excavator_run12 ] {ai_run(16);}
 void() excavator_run12 = [ $fly12, excavator_run1 ] {ai_run(16);}

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
	Killed(self,self.enemy);
	BecomeExplosion ();
	
}

void(float speed) excavator_kamikaze_move =
{
	self.movetype = MOVETYPE_FLY;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	makevectors(self.angles);
	self.velocity = v_forward * speed;
}

void() excavator_kamikaze1 = [ $kamiinit1, excavator_kamikaze2 ] {ai_face(); excavator_kamikaze_move(300);}
void() excavator_kamikaze2 = [ $kamiinit2, excavator_kamikaze3 ] {}
void() excavator_kamikaze3 = [ $kamiinit3, excavator_kamikaze4 ] {}
void() excavator_kamikaze4 = [ $kamiinit4, excavator_kamikaze5 ] {ai_face(); excavator_kamikaze_move(375);}
void() excavator_kamikaze5 = [ $kamiinit5, excavator_kamikaze6 ] {}
void() excavator_kamikaze6 = [ $kamiinit6, excavator_kamikaze7 ] {}
void() excavator_kamikaze7 = [ $kamiinit7, excavator_kamikaze8 ] {ai_face(); excavator_kamikaze_move(450);}
void() excavator_kamikaze8 = [ $kamiinit8, excavator_kamikaze9 ] {}
void() excavator_kamikaze9 = [ $kamiinit9, excavator_kamikaze10 ] {}
void() excavator_kamikaze10 = [ $kamiinit10, excavator_kamikaze11 ] {ai_face(); excavator_kamikaze_move(500);}
void() excavator_kamikaze11 = [ $kamiinit11, excavator_kamikaze12 ] {}
void() excavator_kamikaze12 = [ $kamiinit12, excavator_kamikaze13 ] {}
void() excavator_kamikaze13 = [ $kamiinit13, excavator_kamikaze14 ] {ai_face(); excavator_kamikaze_move(600);}
void() excavator_kamikaze14 = [ $kamiinit14, excavator_kamikaze15 ] {}
void() excavator_kamikaze15 = [ $kamiinit15, excavator_kamikaze16 ] {}
void() excavator_kamikaze16 = [ $kamiinit16, excavator_kamikaze17 ] {ai_face(); excavator_kamikaze_move(600);}
void() excavator_kamikaze17 = [ $kamiinit17, excavator_kamikaze18 ] {}
void() excavator_kamikaze18 = [ $kamikaze1, excavator_kamikaze19 ] {}
void() excavator_kamikaze19 = [ $kamikaze2, excavator_kamikaze20 ] {ai_face(); excavator_kamikaze_move(600);}
void() excavator_kamikaze20 = [ $kamikaze3, excavator_kamikaze21 ] {}
void() excavator_kamikaze21 = [ $kamikaze4, excavator_kamikaze22 ] {}
void() excavator_kamikaze22 = [ $kamikaze5, excavator_kamikaze23 ] {ai_face(); excavator_kamikaze_move(600);}
void() excavator_kamikaze23 = [ $kamikaze6, excavator_kamikaze24 ] {}
void() excavator_kamikaze24 = [ $kamikaze7, excavator_kamikaze25 ] {}
void() excavator_kamikaze25 = [ $kamikaze8, excavator_kamikaze26 ] {ai_face(); excavator_kamikaze_move(600);}
void() excavator_kamikaze26 = [ $kamikaze9, excavator_kamikaze27 ] {}
void() excavator_kamikaze27 = [ $kamikaze10, excavator_kamikaze28 ] {}
void() excavator_kamikaze28 = [ $kamikaze11, excavator_kamikaze29 ] {ai_face(); excavator_kamikaze_move(600);}
void() excavator_kamikaze29 = [ $kamikaze12, excavator_kamikaze30 ] {}
void() excavator_kamikaze30 = [ $kamikaze13, excavator_kamikaze31 ] {}
void() excavator_kamikaze31 = [ $kamikaze14, excavator_kamikaze32 ] {ai_face(); excavator_kamikaze_move(600);}
void() excavator_kamikaze32 = [ $kamikaze15, excavator_kamikaze33 ] {}
void() excavator_kamikaze33 = [ $kamikaze16, excavator_kamikaze18 ] {}

void() excavator_kamikaze_start =
{
	self.touch = excavator_kamikaze_touch;
	excavator_kamikaze1();
}

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

	if ((self.health < 200) && (self.touch != excavator_kamikaze_touch)) 
	{		
		excavator_kamikaze_start();
		return;
	}

	if (self.touch == excavator_kamikaze_touch) 
	{
		return; // No flinch
	}

	if ((random() * 70) + 40 > damage)
	{
		return;
	}

	excavator_pain1();
};


void() excavator_fire = {

	vector org, vec;
	local float r;
	local entity e;
	r = random();

	self.effects = self.effects | EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	org = self.origin + '0 0 35';
	vec = normalize(enemy_vispos() - org + enemy_aim_vertical());
	
	makevectors(self.angles);	
	if (angledif(self.ideal_yaw, self.angles_y) > 80)	// no ass rockets
	{
		vec_x = v_forward_x;
		vec_y = v_forward_y;
		vec = normalize(vec);
	}
	
	if (enemy_range == RANGE_NEAR)
	{
	
		e = launch_rocket(org, vec * 700);	
		e.dmg = 40;

		vec = normalize(enemy_vispos() - org + enemy_aim_vertical());
		vec = normalize(vec + (v_right * 0.2));		
		e = launch_rocket(org, vec * 600);
		e.dmg = 40;		
		
		vec = normalize(enemy_vispos() - org + enemy_aim_vertical());		
		vec = normalize(vec - (v_right * 0.2));		
		e = launch_rocket(org, vec * 600);		
		e.dmg = 40;		
	
	}
	else
	{	
		e = launch_rocket(org, vec * 700);
		e.dmg = 40;
	}

};


void()	excavator_fire1	= [ $attack1, excavator_fire2 ] {
	ai_face();
}
void()	excavator_fire2	= [ $attack2, excavator_fire3 ] {}
void()	excavator_fire3	= [ $attack3, excavator_fire4 ] {}
void()	excavator_fire4	= [ $attack4, excavator_fire5 ] {}
void()	excavator_fire5	= [ $attack5, excavator_fire6 ] {}
void()	excavator_fire6	= [ $attack6, excavator_fire7 ] {excavator_fire();}
void()	excavator_fire7	= [ $attack7, excavator_fire8 ] {}
void()	excavator_fire8	= [ $attack8, excavator_fire9 ] {}
void()	excavator_fire9	= [ $attack9, excavator_fire10 ] {}
void()	excavator_fire10 = [ $attack10, excavator_fire11 ] {}
void()	excavator_fire11 = [ $attack11, excavator_fire12 ] {}
void()	excavator_fire12 = [ $attack12, excavator_run1 ] { 
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
	BecomeExplosion();
}

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

	if (enemy_range == RANGE_MELEE)
		chance = 0.5;
	else if (enemy_range == RANGE_NEAR)
		chance = 0.4;
	else if (enemy_range == RANGE_MID)
		chance = 0.2;
	else
		chance = 0;

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
}

void() monster_excavator_spawn =
{
	self.classname = "monster_excavator";
		
	self.solid = SOLID_SLIDEBOX;

	setmodel(self, "progs/mon_excavator.mdl");

	setsize (self, VEC_HULL2_MIN, '32 32 40');
	self.health = 600;

	self.th_stand = wiz_stand1;
	self.th_walk = wiz_walk1;
	self.th_run = excavator_run1;
	self.th_missile = excavator_fire1;
	self.th_pain = excavator_pain;
	self.th_die = excavator_die;
	self.th_checkattack = ExcavatorCheckAttack;
	self.yaw_speed = 30;

	if (self.deathtype == string_null)
		self.deathtype = "was caved in by an Excavator";

	flymonster_start();
}

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
@PointClass base(Monster) size(-32 -32 -24) (32 32 40) model({ "path": ":progs/mon_excavator.mdl" }) = monster_excavator : "Excavator" []
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
    
	precache_model("progs/mon_excavator.mdl");

	self.health = 600;	
	setsize (self, VEC_HULL2_MIN, '32 32 40');
	if (monster_spawnsetup(monster_excavator_spawner)) {
		return;
	}
	
	addmonster(1);
	monster_excavator_spawn();
}
