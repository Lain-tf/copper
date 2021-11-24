/*
==============================================================================

KAMIKAZE

==============================================================================
*/
$frame run1 run2 run3 run4 run5 run6 run7 run8 run9 run10 run11

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10 walk11 walk12 walk13

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9 stand10
$frame stand11 stand12 stand13 stand14 stand15 stand16 stand17 stand18 stand19 
$frame stand20 stand21 stand22 stand23 stand24 stand25

$frame stuned1 stuned2 stuned3 stuned4 stuned5 stuned6 stuned7 stuned8 stuned9 stuned10

$frame stunned1 stunned2 stunned3 stunned4 stunned5 stunned6 stunned7 stunned8 stunned9 stunned10

$frame stunnned1 stunnned2 stunnned3 stunnned4 stunnned5 stunnned6 stunnned7 stunnned8 stunnned9 stunnned10

void(float dist)kami_run;
 
void()	kami_stand1		=[	$stand1,	kami_stand2		] {ai_stand();}
void()	kami_stand2		=[	$stand2,	kami_stand3		] {ai_stand();}
void()	kami_stand3		=[	$stand3,	kami_stand4		] {ai_stand();}
void()	kami_stand4		=[	$stand4,	kami_stand5		] {ai_stand();}
void()	kami_stand5		=[	$stand5,	kami_stand6		] {ai_stand();}
void()	kami_stand6		=[	$stand6,	kami_stand7		] {ai_stand();}
void()	kami_stand7		=[	$stand7,	kami_stand8		] {ai_stand();}
void()	kami_stand8		=[	$stand8,	kami_stand9		] {ai_stand();}
void()	kami_stand9		=[	$stand9,	kami_stand10	] {ai_stand();}
void()	kami_stand10	=[	$stand10,	kami_stand11	] {ai_stand();}
void()	kami_stand11	=[	$stand11,	kami_stand12	] {ai_stand();}
void()	kami_stand12	=[	$stand12,	kami_stand13	] {ai_stand();}
void()	kami_stand13	=[	$stand13,	kami_stand14	] {ai_stand();}
void()	kami_stand14	=[	$stand14,	kami_stand15	] {ai_stand();}
void()	kami_stand15	=[	$stand15,	kami_stand16	] {ai_stand();}
void()	kami_stand16	=[	$stand16,	kami_stand17	] {ai_stand();}
void()	kami_stand17	=[	$stand17,	kami_stand18	] {ai_stand();}
void()	kami_stand18	=[	$stand18,	kami_stand19	] {ai_stand();}
void()	kami_stand19	=[	$stand19,	kami_stand20	] {ai_stand();}
void()	kami_stand20	=[	$stand20,	kami_stand21	] {ai_stand();}
void()	kami_stand21	=[	$stand21,	kami_stand22	] {ai_stand();}
void()	kami_stand22	=[	$stand22,	kami_stand23	] {ai_stand();}
void()	kami_stand23	=[	$stand23,	kami_stand24	] {ai_stand();}
void()	kami_stand24	=[	$stand24,	kami_stand25	] {ai_stand();}
void()	kami_stand25	=[	$stand25,	kami_stand1		] {ai_stand();}

void()	kami_stuned1	=[	$stuned1,	kami_stuned2	] {}
void()	kami_stuned2	=[	$stuned2,	kami_stuned3	] {}
void()	kami_stuned3	=[	$stuned3,	kami_stuned4	] {}
void()	kami_stuned4	=[	$stuned4,	kami_stuned5	] {}
void()	kami_stuned5	=[	$stuned5,	kami_stuned6	] {}
void()	kami_stuned6	=[	$stuned6,	kami_stuned7	] {}
void()	kami_stuned7	=[	$stuned7,	kami_stuned8	] {}
void()	kami_stuned8	=[	$stuned8,	kami_stuned9	] {}
void()	kami_stuned9	=[	$stuned9,	kami_run1		] {}

void()	kami_stunned1	=[	$stunned1,	kami_stunned2	] {}
void()	kami_stunned2	=[	$stunned2,	kami_stunned3	] {}
void()	kami_stunned3	=[	$stunned3,	kami_stunned4	] {}
void()	kami_stunned4	=[	$stunned4,	kami_stunned5	] {}
void()	kami_stunned5	=[	$stunned5,	kami_stunned6	] {}
void()	kami_stunned6	=[	$stunned6,	kami_stunned7	] {}
void()	kami_stunned7	=[	$stunned7,	kami_stunned8	] {}
void()	kami_stunned8	=[	$stunned8,	kami_stunned9	] {}
void()	kami_stunned9	=[	$stunned9,	kami_run1		] {}
//i wasn't typing that 3 times, go fuck yourself - lain
void()	kami_stunnned1	=[	$stunnned1,	kami_stunnned2	] {}
void()	kami_stunnned2	=[	$stunnned2,	kami_stunnned3	] {}
void()	kami_stunnned3	=[	$stunnned3,	kami_stunnned4	] {}
void()	kami_stunnned4	=[	$stunnned4,	kami_stunnned5	] {}
void()	kami_stunnned5	=[	$stunnned5,	kami_stunnned6	] {}
void()	kami_stunnned6	=[	$stunnned6,	kami_stunnned7	] {}
void()	kami_stunnned7	=[	$stunnned7,	kami_stunnned8	] {}
void()	kami_stunnned8	=[	$stunnned8,	kami_stunnned9	] {}
void()	kami_stunnned9	=[	$stunnned9,	kami_run1		] {}


void()	kami_walk1		=[	$walk1,		kami_walk2		] {ai_walk(3);}
void()	kami_walk2		=[	$walk2,		kami_walk3		] {ai_walk(2);}
void()	kami_walk3		=[	$walk3,		kami_walk4		] {ai_walk(4);}
void()	kami_walk4		=[	$walk4,		kami_walk5		] {ai_walk(3);}
void()	kami_walk5		=[	$walk5,		kami_walk6		] {ai_walk(3);}
void()	kami_walk6		=[	$walk6,		kami_walk7		] {ai_walk(3);}
void()	kami_walk7		=[	$walk7,		kami_walk8		] {ai_walk(3);}
void()	kami_walk8		=[	$walk8,		kami_walk9		] {ai_walk(2);}
void()	kami_walk9		=[	$walk9,		kami_walk10		] {ai_walk(4);}
void()	kami_walk10		=[	$walk10,	kami_walk11		] {ai_walk(3);}
void()	kami_walk11		=[	$walk11,	kami_walk12		] {ai_walk(3);}
void()	kami_walk12		=[	$walk12,	kami_walk13		] {ai_walk(3);}
void()	kami_walk13		=[	$walk13,	kami_walk1		] {ai_walk(3);}

void()	kami_run1		=[	$run1,		kami_run2		] {
	kami_run(28);
	Kami_Forget();
}
void()	kami_run2		=[	$run2,		kami_run3		] {kami_run(28);}
void()	kami_run3		=[	$run3,		kami_run4		] {kami_run(28);}
void()	kami_run4		=[	$run4,		kami_run5		] {kami_run(28);}
void()	kami_run5		=[	$run5,		kami_run6		] {kami_run(28);}
void()	kami_run6		=[	$run6,		kami_run7		] {kami_run(28);}
void()	kami_run7		=[	$run7,		kami_run8		] {kami_run(28);}
void()	kami_run8		=[	$run8,		kami_run9		] {kami_run(28);}
void()	kami_run9		=[	$run9,		kami_run10		] {kami_run(28);}
void()	kami_run10		=[	$run10,		kami_run11		] {kami_run(28);}
void()	kami_run11		=[	$run11,		kami_run1		] {kami_run(28);}

float(entity e) kami_visible =
{
	return (visible(e) && !has_invis(e));
}

void() Kami_Forget =
{
	if (!self.rad_time)	// time to be RAD
	{
		// we just woke up, don't forget right away, because if we were awoken
		// by another monster waking we'll just stay here.
		self.rad_time = time + 60;
	}
	
	if (time < self.rad_time)
		return;
		
	if (!kami_visible(self.enemy))
	{
		if (kami_visible(self.oldenemy))
		{
			self.enemy = self.oldenemy;
		}
		else
		{
			self.enemy = world;
		}
		self.oldenemy = world;
	}
	if (!self.enemy)
	{
		self.rad_time = 0;	// reset the clock
		ai_stand();
	}
}

/*
float(float dist, float dmg) KamiBlastRadius =
{
	local	float	final_dmg;
	
	if(dist < 32)
		return	dmg;
	else if(dist > 192)
		return 0;
	
	final_dmg = (dist - 32) / 16;
	final_dmg = final_dmg * final_dmg * (-1);
	final_dmg = ceil(final_dmg + 100) / 100;
	final_dmg = final_dmg * dmg;
	
	return final_dmg;
};
*/

float(float dist, float dmg) KamiBlastRadius =
{
	local	float	final_dmg;
	
	if(dist < 32)
		return	dmg;
	else if(dist > 190)
		return 0;
	
	final_dmg = 0.02 * dist + 0.93;
	final_dmg = sin(final_dmg * 57.32484);
	final_dmg = 50 * final_dmg + 50;

	final_dmg = final_dmg / 100;
	final_dmg = rint(final_dmg * dmg);
	
	return final_dmg;
}

void() kami_explode =
{
	sound (self, CHAN_VOICE, "zombie/z_gib.wav", 1, ATTN_NORM);
	GibSpray ("progs/gib3.mdl", self.health);
	
	T_RadiusDamage_Custom (self, self, 190, 60, KamiBlastRadius, world);
	sound (self, CHAN_BODY, "weapons/r_exp3.wav", 1, ATTN_NORM);
	BecomeExplosion();
}

void()	kami_die =
{
	if (self.think == kami_explode)
		return;	// already exploding
	self.enemy = activator;
	self.think = kami_explode;
	self.nextthink = time + 0.05;	// infini-kami crash fixed
};

void(entity attacker, float damage)	kami_pain =
{
	self.rad_time = time + 60;

	if (self.pain_finished > time)
		return;
	PainFinished(1.5);
	
		if (self.frame <= 49)
	{
		if ((self.frame == 1) || (self.frame == 5) || (self.frame == 6) || (self.frame == 11))
			{
			kami_stuned1();
			}
		
		if ((self.frame == 3) || (self.frame == 8) || (self.frame == 9))
			{
			kami_stunned1();
			}
		
		if ((self.frame == 2) || (self.frame == 4) || (self.frame == 7) || (self.frame == 10))
			{
			kami_stunnned1();
			}
		
		if ((self.frame >= 11) && (self.frame <= 49))
			{
			kami_stuned1();	
			}
		
		
	}

	sound (self, CHAN_VOICE, "kamikaze/kami_pain.wav", 1, ATTN_NORM);
};

float()	KamiCheckDistance =
{
	//float	dist;
	//vector	d;
	//float	r;
	
	/*if(self.enemy)
	{
		d = eyeline(self.enemy);
		r = vlen(d);
		
		dist = range(self.enemy);
		dprint("distance: ");
		dprint(ftos(r));
		dprint("\n");
		
	}*/
	
	if (EntitiesTouching(self, self.enemy))
		return TRUE;
	
	if (range(self.enemy) == RANGE_HUG)// && z_overlap(self.enemy))
	{
		return TRUE;
	}
	return FALSE;
};

void() KamiScream =
{
	if(self.cnt <= 0)
	{
		sound (self, CHAN_VOICE, "kamikaze/kami_scream.wav", 1, ATTN_NORM);
		self.cnt = 6;
	}
	else
	{
		self.cnt--;
	}
};

void(float dist)kami_run =
{
	if(!KamiCheckDistance())
	{
		ai_run(dist);
		KamiScream();
	}
	else
	{
		Killed(self,self.enemy);
	}
};

//===========================================================================

void() monster_kamikaze_spawn =
{
	self.classname = "monster_kamikaze";
		
	self.solid = SOLID_SLIDEBOX;

	setmodel (self, "progs/kamikaze.mdl");

	setsize (self, '-16 -16 -24', '16 16 24');
	self.health = 40;
	
	self.cnt = 0;
	self.rad_time = 0;
	
	self.customflags |= CFL_MELEEONLY;
	self.customflags |= CFL_EPSKINS;

	self.th_stand = kami_stand1;
	self.th_walk = kami_walk1;
	self.th_run = kami_run1;
	self.th_die = kami_die;
	self.th_pain = kami_pain;
	self.th_checkattack = CheckAttack;

	if (self.deathtype == string_null)
		self.deathtype = "was detonated by a Kamikaze";

	walkmonster_start ();
};

void() monster_kamikaze_spawner = {mon_spawner_use(monster_kamikaze_spawn);}

/*QUAKED monster_kamikaze (1 0 0) (-16 -16 -24) (16 16 24) AMBUSH ? ? ? TRIGGERED NOTFOG NOTELEFRAG INSTAWAKE
Kamikaze, 40 health points.

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
@PointClass base(Monster) size(-16 -16 -24, 16 16 24) model({ "path": ":progs/kamikaze.mdl" }) = monster_kamikaze : "Kamikaze" []
*/
void() monster_kamikaze =
{
	if (!SUB_ShouldSpawn()) return;
	if (nomonster()) return;
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/kamikaze.mdl");

	precache_sound ("kamikaze/kami_idle.wav");
	precache_sound ("kamikaze/kami_scream.wav");
	precache_sound ("kamikaze/kami_pain.wav");
	precache_sound ("zombie/z_gib.wav");

	self.health = 40;
	setsize (self, '-16 -16 -24', '16 16 24');

	if ( monster_spawnsetup( monster_kamikaze_spawner ) ) return;
	
	addmonster(1);
	monster_kamikaze_spawn();
};