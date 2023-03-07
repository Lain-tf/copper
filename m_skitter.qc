/*
==============================================================================

skitter

==============================================================================
*/
$cd id1/models/skitter
$origin 0 0 24
$base base
$skin skin

$frame run1 run2 run3 run4 run5 run6

$frame leap1 leap2 leap3 leap4 leap5 leap6 leap7

$frame ded

/*
================
skitter_bite

================
*/
void() skitter_bite =
{
	vector	delta;

	if (!self.enemy)
		return;

	ai_charge(10);

	if (!CanDamage (self.enemy, self.origin))
		return;

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 100)
		return;
		
	T_DamageMelee (self.enemy, self, 8 + random() * 8);
}

void()	skitter_JumpTouchGround =
{
	if (!checkbottom(self))
	{
		if (self.flags & FL_ONGROUND)
		{	// jump randomly to not get hung up
			self.touch = SUB_Null;
			self.think = skitter_leap1;
			self.nextthink = time + 0.1;
		}
		return;	// not on ground yet
	}

	self.touch = SUB_Null;
	self.think = skitter_run1;
	self.nextthink = time + 0.1;
}

void()	skitter_JumpTouch =
{
	if (self.health <= 0)
		return;
		
	if (other.classname != "monster_skitter" &&	// pack skitters whose bboxes brush each other during leaps wind up killing each other
		other.takedamage)
	{	
		if ( vlen(self.velocity) > 300 )
		{
			if (other.classname != "player" || time > self.touch_time)	// fix for landing on the player's head
			{
				if (other.classname == "player")
				{
					self.touch_time = time + 0.2;
				}
				T_DamageMelee (other, self, 10 + 10*random());	
			}
		}
	}
	skitter_JumpTouchGround();
}

void() skitter_airthink =
{
	self.think = skitter_airthink;
	self.nextthink = time + 0.1;
	
	// if three seconds pass, assume skitter is stuck and jump again
	if (time >= self.lifetime_finished)
	{
		skitter_leap1();
		return;
	}
	// we aren't moving, assume leap is over so we don't get stuck
	if (self.origin == self.oldorigin && self.flags & FL_ONGROUND)
	{
		skitter_run1();
		return;
	}
	self.oldorigin = self.origin;
}

void() skitter_stand1	=[	$run1,	skitter_stand2	] {ai_stand();}
void() skitter_stand2	=[	$run1,	skitter_stand3	] {ai_stand();}
void() skitter_stand3	=[	$run1,	skitter_stand4	] {ai_stand();}
void() skitter_stand4	=[	$run1,	skitter_stand5	] {ai_stand();}
void() skitter_stand5	=[	$run1,	skitter_stand6	] {ai_stand();}
void() skitter_stand6	=[	$run1,	skitter_stand7	] {ai_stand();}
void() skitter_stand7	=[	$run1,	skitter_stand8	] {ai_stand();}
void() skitter_stand8	=[	$run1,	skitter_stand9	] {ai_stand();}
void() skitter_stand9	=[	$run1,	skitter_stand1	] {ai_stand();}

void() skitter_walk1	=[	$run1 ,	skitter_walk2	] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "dog/idle.wav", 1, ATTN_IDLE);
ai_walk(8);}
void() skitter_walk2	=[	$run2 ,	skitter_walk3	] {ai_walk(8);}
void() skitter_walk3	=[	$run3 ,	skitter_walk4	] {ai_walk(8);}
void() skitter_walk4	=[	$run4 ,	skitter_walk5	] {ai_walk(8);}
void() skitter_walk5	=[	$run5 ,	skitter_walk6	] {ai_walk(8);}
void() skitter_walk6	=[	$run6 ,	skitter_walk1   ] {ai_walk(8);}

void() skitter_run1		=[	$run1  ,	skitter_run2	] {
	if (random() < 0.2 && time > self.show_hostile)
		sound (self, CHAN_VOICE, "dog/idle.wav", 1, ATTN_IDLE);
	ai_run(16);
}
void() skitter_run2		=[	$run2  ,	skitter_run3	] {ai_run(32);}
void() skitter_run3		=[	$run3  ,	skitter_run4	] {ai_run(32);}
void() skitter_run4		=[	$run4  ,	skitter_run5	] {ai_run(32);}
void() skitter_run5		=[	$run5  ,	skitter_run6	] {ai_run(32);}
void() skitter_run6		=[	$run6  ,	skitter_run1	] {ai_run(32);}

void() skitter_atta1	=[	$leap1,	skitter_atta2	] {ai_charge(10);}
void() skitter_atta2	=[	$leap2,	skitter_atta3	] {ai_charge(10);}
void() skitter_atta3	=[	$leap3,	skitter_atta4	] {ai_charge(10);}
void() skitter_atta4	=[	$leap4,	skitter_atta5	] {
sound (self, CHAN_VOICE, "dog/dattack1.wav", 1, ATTN_NORM);
skitter_bite();}
void() skitter_atta5	=[	$leap5,	skitter_atta6	] {ai_charge(10);}
void() skitter_atta6	=[	$leap6,	skitter_atta7	] {ai_charge(10);}
void() skitter_atta7	=[	$leap7,	skitter_run1	] {ai_charge(10);}

void() skitter_leap1	=[	$leap1,		skitter_leap2	] {ai_face();}
void() skitter_leap2	=[	$leap2,		skitter_leap3	]
{
	ai_face();
	ai_attack_finished(0.2);
	if (self.flags & FL_ONGROUND || self.velocity_z == 0)
	{	
		makevectors (self.angles);
		self.flags = not(self.flags, FL_ONGROUND);
		self.velocity = v_forward * 450 + '0 0 200';
		self.touch = skitter_JumpTouch;
	}
}
void() skitter_leap3	=[	$leap3,		skitter_leap4	] {}
void() skitter_leap4	=[	$leap4,		skitter_leap5	] {}
void() skitter_leap5	=[	$leap5,		skitter_leap6	] {}
void() skitter_leap6	=[	$leap6,		skitter_leap7	] {}
void() skitter_leap7	=[	$leap7,		skitter_airthink] { 
	self.oldorigin = self.origin;
	self.lifetime_finished = time + 1;
}

void() skitter_pain1	=[	$run1,	skitter_pain2	] {}
void() skitter_pain2	=[	$run1,	skitter_pain3	] {}
void() skitter_pain3	=[	$run1,	skitter_pain4	] {}
void() skitter_pain4	=[	$run1,	skitter_run1	] {}

void() skitter_painb1	=[	$run1,	skitter_painb2	] {}
void() skitter_painb2	=[	$run1,	skitter_painb3	] {}
void() skitter_painb3	=[	$run1,	skitter_painb4	] {}
void() skitter_painb4	=[	$run1,	skitter_painb5	] {}
void() skitter_painb5	=[	$run1,	skitter_painb6	] {}
void() skitter_painb6	=[	$run1,	skitter_run1	] {}

void(entity attacker, float damage) skitter_pain =
{
	if (time < self.pain_finished) return;
	if (random() > .8) return;
	sound (self, CHAN_VOICE, "dog/dpain1.wav", 1, ATTN_NORM);

	if (random() > 0.5)
	{
		skitter_pain1 ();
		PainFinished(0.4);
	}
	else
	{
		skitter_painb1 ();
		PainFinished(.6);
	}
}

void() skitter_die1		=[	$ded,	skitter_die2	] {}
void() skitter_die2		=[	$ded,	skitter_die3	] {}
void() skitter_die3		=[	$ded,	skitter_die4	] {	self.solid = SOLID_NOT; }
void() skitter_die4		=[	$ded,	skitter_die5	] {}
void() skitter_die5		=[	$ded,	skitter_die6	] {}
void() skitter_die6		=[	$ded,	skitter_die7	] {}
void() skitter_die7		=[	$ded,	skitter_die8	] {}
void() skitter_die8		=[	$ded,	skitter_die9	] {}
void() skitter_die9		=[	$ded,	SUB_Null	] {PostDeathLogic();}

void() skitter_dieb1	=[	$ded,	skitter_dieb2	] {}
void() skitter_dieb2	=[	$ded,	skitter_dieb3	] {}
void() skitter_dieb3	=[	$ded,	skitter_dieb4	] {	self.solid = SOLID_NOT;}
void() skitter_dieb4	=[	$ded,	skitter_dieb5	] {}
void() skitter_dieb5	=[	$ded,	skitter_dieb6	] {}
void() skitter_dieb6	=[	$ded,	skitter_dieb7	] {}
void() skitter_dieb7	=[	$ded,	skitter_dieb8	] {}
void() skitter_dieb8	=[	$ded,	skitter_dieb9	] {}
void() skitter_dieb9	=[	$ded,	SUB_Null	] {PostDeathLogic();}


void() skitter_die =
{
// check for gib
	if (self.health < -35)
	{
		Gib ("progs/h_dog.mdl", self.health);
		return;
	}

// regular death
	sound (self, CHAN_VOICE, "dog/ddeath.wav", 1, ATTN_NORM);

	if (random() > 0.5)
		skitter_die1 ();
	else
		skitter_dieb1 ();
}

//============================================================================

/*
==============
CheckskitterMelee

Returns TRUE if a melee attack would hit right now
==============
*/
float()	CheckskitterMelee =
{
	if (enemy_range == RANGE_MELEE && z_overlap(self.enemy))
	{	// FIXME: check canreach
		self.attack_state = AS_MELEE;
		return TRUE;
	}
	return FALSE;
}

/*
==============
CheckskitterJump
==============
*/
float()	CheckskitterJump =
{
	local	vector	dist;
	local	float	d;

	if (self.origin_z + self.mins_z > self.enemy.origin_z + self.enemy.mins_z
	+ 0.75 * self.enemy.size_z)
		return FALSE;
		
	if (self.origin_z + self.maxs_z < self.enemy.origin_z + self.enemy.mins_z
	+ 0.25 * self.enemy.size_z)
		return FALSE;
		
	dist = self.enemy.origin - self.origin;
	dist_z = 0;
	
	d = vlen(dist);
	
	if (d < 80)
		return FALSE;
		
	if (d > 150)
		return FALSE;
		
	return TRUE;
}

float()	skitterCheckAttack =
{
// if close enough for slashing, go for it
	if (CheckskitterMelee ())
	{
		self.attack_state = AS_MELEE;
		return TRUE;
	}
	
	if (CheckskitterJump ())
	{
		self.attack_state = AS_MISSILE;
		return TRUE;
	}
	
	return FALSE;
}


//===========================================================================


void() monster_skitter_spawn =
{
	self.classname = "monster_skitter";
		
	self.solid = SOLID_SLIDEBOX;
	//self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/e3/mon_skitter.mdl");

	setsize (self, '-16 -16 -24', '16 16 16');
	self.health = 80;
	self.customflags |= CFL_MELEEONLY;

	self.th_stand = skitter_stand1;
	self.th_walk = skitter_walk1;
	self.th_run = skitter_run1;
	self.th_pain = skitter_pain;
	self.th_die = skitter_die;
	self.th_melee = skitter_atta1;
	self.th_missile = skitter_leap1;
	self.th_checkattack = skitterCheckAttack;

	if (self.deathtype == string_null)
		self.deathtype = "was scat by a Skitterer";

	walkmonster_start();
}

void() monster_skitter_spawner = {mon_spawner_use(monster_skitter_spawn);}

/*QUAKED monster_skitter (1 0 0) (-32 -32 -24) (32 32 40) AMBUSH ? ? ? TRIGGERED NOTFOG NOTELEFRAG INSTAWAKE
skitter (Skitterer), 25 health points.

Flags:
"ambush" only wake up on seeing the player, not another monster getting angry
"Triggered"	will not spawn until triggered - triggering again will wake him up. Set 'count' to make this a multi-use spawner.
"NoTfog" 	supress teleport glitter when spawned with 'triggered'
"NoTelefrag" will silently fail to spawn if doing so would telefrag an existing monster. will try again automatically 2x/second until it succeeds.
"Instawake" spawn angry at activator

Keys:
"target" entity to trigger when killed
"targetname" entity name
"movedir" set to a velocity to make the monster jump on awakening
*/
/*FGD
@PointClass base(Monster) size(-32 -32 -24, 32 32 40) model({ "path": ":progs/e3/mon_skitter.mdl" }) = monster_skitter : "Skitterer" []
*/
void() monster_skitter =
{
	if (!SUB_ShouldSpawn()) return;
	if (nomonster()) return;
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/h_dog.mdl");
	precache_model ("progs/e3/mon_skitter.mdl");

	precache_sound ("dog/dattack1.wav");
	precache_sound ("dog/ddeath.wav");
	precache_sound ("dog/dpain1.wav");
	precache_sound ("dog/dsight.wav");
	precache_sound ("dog/idle.wav");

	self.health = 80;
	setsize (self, '-16 -16 -24', '16 16 16');
	if ( monster_spawnsetup( monster_skitter_spawner ) ) return;

	addmonster(1);
	monster_skitter_spawn();
}
