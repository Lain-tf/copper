/*==============================================================================
 GAUNT (Originally from Quoth - Kell/Necros/Preach)

 Rebuilt from the ground-up for use in Snack Pack 3 by Fairweather.
 Utilized the frames from the AD version, thanks to SimonOC,
 but the rest is mainly either original code, or cannibalized
 from other places in the Copper mod.

 The only difference between this monster and the one featured in Quoth
 were fitting it within the new Nightmare mode framework (Copper 1.3 Nightmare)
 and the cutting of the Perch ability due to time constraints.
 Otherwise, this can be considered functionally identical.
==============================================================================*/

// (000) Perched on a ledge (idling)
$frame perch1 perch2 perch3 perch4 perch5 perch6 perch7 perch8
$frame perch9 perch10 perch11 perch12 perch13 perch14 perch15 perch16

// (016) Lift off from perch position
$frame launch1 launch2 launch3 launch4 launch5 launch6 launch7 launch8

// (024) Idling in mid air
$frame hover1 hover2 hover3 hover4 hover5 hover6 hover7 hover8
$frame hover9 hover10 hover11 hover12 hover13 hover14 hover15 hover16
$frame hover17 hover18 hover19 hover20

// (044) range attack (lightning/plasma)
$frame attack1 attack2 attack3 attack4 attack5 attack6 attack7 attack8 
$frame attack9 attack10 attack11 attack12 attack13 attack14 attack15 attack16 
$frame attack17 attack18 attack19 attack20

// (064) Start of dive attack
$frame swoopStart1 swoopStart2 swoopStart3 swoopStart4
$frame swoopStart5 swoopStart6 swoopStart7 swoopStart8

// (072) Looped version of dive attack
$frame swoop1 swoop2 swoop3 swoop4 swoop5

// (077) Something, not sure what
$frame drop1 drop2 drop3 drop4 drop5

// (082) Swing wing around infront
$frame painA1 painA2 painA3 painA4 painA5 painA6

// (088) Knock head backward
$frame painB1 painB2 painB3 painB4 painB5

// (093) Fall backwards
$frame deathA1 deathA2 deathA3 deathA4 deathA5 deathA6 deathA7 deathA8

// (101) Fall forward
$frame deathB1 deathB2 deathB3 deathB4 deathB5 deathB6 deathB7 deathB8

//============================================================================
void() gaunt_idle1 = [ $hover1, gaunt_idle2 ] {ai_stand(); gaunt_idle();}
void() gaunt_idle2 = [ $hover2, gaunt_idle3 ] {ai_stand();}
void() gaunt_idle3 = [ $hover3, gaunt_idle4 ] {ai_stand();}
void() gaunt_idle4 = [ $hover4, gaunt_idle5 ] {ai_stand();}
void() gaunt_idle5 = [ $hover5, gaunt_idle6 ] {ai_stand();}
void() gaunt_idle6 = [ $hover6, gaunt_idle7 ] {ai_stand();}
void() gaunt_idle7 = [ $hover7, gaunt_idle8 ] {ai_stand();}
void() gaunt_idle8 = [ $hover8, gaunt_idle9 ] {ai_stand();}
void() gaunt_idle9 = [ $hover9, gaunt_idle10 ] {ai_stand();}
void() gaunt_idle10 = [ $hover10, gaunt_idle11 ] {ai_stand();}
void() gaunt_idle11 = [ $hover11, gaunt_idle12 ] {ai_stand();}
void() gaunt_idle12 = [ $hover12, gaunt_idle13 ] {ai_stand();}
void() gaunt_idle13 = [ $hover13, gaunt_idle14 ] {ai_stand();}
void() gaunt_idle14 = [ $hover14, gaunt_idle15 ] {ai_stand();}
void() gaunt_idle15 = [ $hover15, gaunt_idle16 ] {ai_stand();}
void() gaunt_idle16 = [ $hover16, gaunt_idle17 ] {ai_stand();}
void() gaunt_idle17 = [ $hover17, gaunt_idle18 ] {ai_stand();}
void() gaunt_idle18 = [ $hover18, gaunt_idle19 ] {ai_stand();}
void() gaunt_idle19 = [ $hover19, gaunt_idle20 ] {ai_stand();}
void() gaunt_idle20 = [ $hover20, gaunt_idle1 ] {ai_stand();}

void()	gaunt_idle =
{
	if (random() < 0.3)
		{
		if (random() < 0.33)
		sound (self, CHAN_VOICE, "gaunt/idle1.wav", 1, ATTN_NORM);
		else if (random() < 0.66)
		sound (self, CHAN_VOICE, "gaunt/idle2.wav", 1, ATTN_NORM);
		else
		sound (self, CHAN_VOICE, "gaunt/idle3.wav", 1, ATTN_NORM);
		}
}

//============================================================================
void() gaunt_walk1 = [ $hover1, gaunt_walk2 ] {ai_walk(8); self.attack_state = AS_STRAIGHT;}
void() gaunt_walk2 = [ $hover2, gaunt_walk3 ] {ai_walk(8);}
void() gaunt_walk3 = [ $hover3, gaunt_walk4 ] {ai_walk(8);}
void() gaunt_walk4 = [ $hover4, gaunt_walk5 ] {ai_walk(8);}
void() gaunt_walk5 = [ $hover5, gaunt_walk6 ] {ai_walk(8);}
void() gaunt_walk6 = [ $hover6, gaunt_walk7 ] {ai_walk(8);}
void() gaunt_walk7 = [ $hover7, gaunt_walk8 ] {ai_walk(8);}
void() gaunt_walk8 = [ $hover8, gaunt_walk9 ] {ai_walk(8);}
void() gaunt_walk9 = [ $hover9, gaunt_walk10 ] {ai_walk(8);}
void() gaunt_walk10 = [ $hover10, gaunt_walk11 ] {ai_walk(8);}
void() gaunt_walk11 = [ $hover11, gaunt_walk12 ] {ai_walk(8);}
void() gaunt_walk12 = [ $hover12, gaunt_walk13 ] {ai_walk(8);}
void() gaunt_walk13 = [ $hover13, gaunt_walk14 ] {ai_walk(8);}
void() gaunt_walk14 = [ $hover14, gaunt_walk15 ] {ai_walk(8);}
void() gaunt_walk15 = [ $hover15, gaunt_walk16 ] {ai_walk(8);}
void() gaunt_walk16 = [ $hover16, gaunt_walk17 ] {ai_walk(8);}
void() gaunt_walk17 = [ $hover17, gaunt_walk18 ] {ai_walk(8);}
void() gaunt_walk18 = [ $hover18, gaunt_walk19 ] {ai_walk(8);}
void() gaunt_walk19 = [ $hover19, gaunt_walk20 ] {ai_walk(8);}
void() gaunt_walk20 = [ $hover20, gaunt_walk1 ] {ai_walk(8);}

//============================================================================
void() gaunt_run1 = [ $hover1, gaunt_run2 ] {ai_run(8); self.attack_state = AS_STRAIGHT;}
void() gaunt_run2 = [ $hover2, gaunt_run3 ] {ai_run(8);}
void() gaunt_run3 = [ $hover3, gaunt_run4 ] {ai_run(8);}
void() gaunt_run4 = [ $hover4, gaunt_run5 ] {ai_run(8);}
void() gaunt_run5 = [ $hover5, gaunt_run6 ] {ai_run(8);}
void() gaunt_run6 = [ $hover6, gaunt_run7 ] {ai_run(8);}
void() gaunt_run7 = [ $hover7, gaunt_run8 ] {ai_run(8);}
void() gaunt_run8 = [ $hover8, gaunt_run9 ] {ai_run(8);}
void() gaunt_run9 = [ $hover9, gaunt_run10 ] {ai_run(8);}
void() gaunt_run10 = [ $hover10, gaunt_run11 ] {ai_run(8);}
void() gaunt_run11 = [ $hover11, gaunt_run12 ] {ai_run(8);}
void() gaunt_run12 = [ $hover12, gaunt_run13 ] {ai_run(8);}
void() gaunt_run13 = [ $hover13, gaunt_run14 ] {ai_run(8);}
void() gaunt_run14 = [ $hover14, gaunt_run15 ] {ai_run(8);}
void() gaunt_run15 = [ $hover15, gaunt_run16 ] {ai_run(8);}
void() gaunt_run16 = [ $hover16, gaunt_run17 ] {ai_run(8);}
void() gaunt_run17 = [ $hover17, gaunt_run18 ] {ai_run(8);}
void() gaunt_run18 = [ $hover18, gaunt_run19 ] {ai_run(8);}
void() gaunt_run19 = [ $hover19, gaunt_run20 ] {ai_run(8);}
void() gaunt_run20 = [ $hover20, gaunt_run1 ] {ai_run(8);}

void() gaunt_spawn_effect =
{
	entity o;
	self.buddy = spawn();
	o = self.buddy;
	setmodel (o, "progs/g_fx.mdl");
	setorigin (o, self.origin);
	o.angles = self.angles;
	o.nextthink = time + 0.8;
	o.think = SUB_Remove;
}

void(float fxframe) gaunt_lightning_fx = 
{
	self.effects = self.effects | EF_MUZZLEFLASH;
	self.buddy.frame = fxframe;
	setorigin(self.buddy, self.origin - VEC_ORIGIN);
	self.buddy.angles = self.angles;
}

void() gaunt_fire_3x =
{
	gaunt_spawn_effect();
	gaunt_fire3();
}

//----------------------------------------------------------------------
void() gaunt_fire1 = [ $attack1, gaunt_fire2 ] {
	self.effects = self.effects | EF_MUZZLEFLASH;
	gaunt_spawn_effect();
	self.attack_state = AS_SLIDING;
	ai_face();
	ai_run_slide(8);
}
void() gaunt_fire2  = [ $attack2, gaunt_fire3    ] {ai_face(); ai_run_slide(8);}
void() gaunt_fire3  = [ $attack3, gaunt_fire4    ] {ai_face(); ai_run_slide(8); gaunt_lightning_fx(1);}
void() gaunt_fire4  = [ $attack4, gaunt_fire5    ] {ai_face(); ai_run_slide(8); gaunt_lightning_fx(2);}
void() gaunt_fire5  = [ $attack5, gaunt_fire6    ] {ai_face(); ai_run_slide(8); gaunt_lightning_fx(3);}
void() gaunt_fire6  = [ $attack6, gaunt_fire7    ] {ai_face(); ai_run_slide(8); gaunt_lightning_fx(4);}
void() gaunt_fire7  = [ $attack7, gaunt_fire8    ] {ai_face(); ai_run_slide(8); gaunt_lightning_fx(5);}
void() gaunt_fire8  = [ $attack8, gaunt_fire9    ] {ai_face(); ai_run_slide(8); gaunt_lightning_fx(6);}
void() gaunt_fire9  = [ $attack9, gaunt_fire10   ] {ai_face(); ai_run_slide(8); gaunt_lightning_fx(7);}
void() gaunt_fire10 = [ $attack10, gaunt_fire11  ] {ai_face(); ai_run_slide(8); gaunt_lightning_fx(8);}
void() gaunt_fire11 = [ $attack11, gaunt_fire12  ] {ai_face(); ai_run_slide(8); GauntCastLightning(); sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);}
void() gaunt_fire12 = [ $attack12, gaunt_fire13  ] {ai_face(); ai_run_slide(8); GauntCastLightning();}
void() gaunt_fire13 = [ $attack13, gaunt_fire14  ] {ai_face(); ai_run_slide(8); GauntCastLightning();}
void() gaunt_fire14 = [ $attack14, gaunt_fire15  ] {ai_face(); ai_run_slide(8); GauntCastLightning();}
void() gaunt_fire15 = [ $attack15, gaunt_fire16  ] {ai_face(); ai_run_slide(8); GauntCastLightning();
		if (vlen(self.origin - enemy_vispos()) < SHAM_LIGHTNING_RANGE)
			ai_check_refire(gaunt_fire_3x);}
void() gaunt_fire16 = [ $attack16, gaunt_fire17  ] {ai_face(); ai_run_slide(8);}
void() gaunt_fire17 = [ $attack17, gaunt_fire18  ] {ai_face(); ai_run_slide(8);}
void() gaunt_fire18 = [ $attack18, gaunt_fire19  ] {ai_face(); ai_run_slide(8);}
void() gaunt_fire19 = [ $attack19, gaunt_fire20  ] {ai_face(); ai_run_slide(8);}
void() gaunt_fire20 = [ $attack20, gaunt_run1    ] {ai_face(); ai_run_slide(8); ai_attack_finished(1.5 + random());}

void() GauntCastLightning =
{
	vector	org, dir;
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	org = self.origin + '0 0 -8';
	makevectors(self.angles);
	
	// shamblers look weird when their lightning jumps around seeking the player
	if (has_invis(self.enemy) && (time > self.dmgtime + 1))
	{
		dir = v_forward;
	}
	else
	{
		ai_face();
		//old grunt target-lag code, so that the lightning shoots behind the player if they're strafing
		dir = enemy_vispos() - self.enemy.velocity*0.14;
		dir = normalize (dir - self.origin);
		//removed the "no ass-lightning" code, since the Quoth gaunt has ass-lightning
	}

	traceline2(org, self.origin + dir * SHAM_LIGHTNING_RANGE, self, TRACE_NOMONSTERS);

	ClearMultiDamage();
	LightningBeam (org, trace_endpos, self, 9);
	ApplyMultiDamage();
}

//============================================================================
// PAIN
//============================================================================
// Long - Swing wing around infront
void() 	gaunt_painA1 =[ $painA1, gaunt_painA2 ] {sound (self, CHAN_VOICE, "gaunt/pain.wav", 1, ATTN_NORM);}
void() 	gaunt_painA2 =[ $painA2, gaunt_painA3 ] {}
void() 	gaunt_painA3 =[ $painA3, gaunt_painA4 ] {}
void() 	gaunt_painA4 =[ $painA4, gaunt_painA5 ] {}
void() 	gaunt_painA5 =[ $painA5, gaunt_painA6 ] {}
void() 	gaunt_painA6 =[ $painA6, gaunt_run1 ] {}

// Short - Knock head backward
void() 	gaunt_painB1 =[ $painB1, gaunt_painB2 ] {sound (self, CHAN_VOICE, "gaunt/pain.wav", 1, ATTN_NORM);}
void() 	gaunt_painB2 =[ $painB2, gaunt_painB3 ] {}
void() 	gaunt_painB3 =[ $painB3, gaunt_painB4 ] {}
void() 	gaunt_painB4 =[ $painB4, gaunt_painB5 ] {}
void() 	gaunt_painB5 =[ $painB5, gaunt_run1 ] {}

//----------------------------------------------------------------------
void(entity attacker, float damage) gaunt_pain =
{
    // make sure any electricity is hidden
    if (self.buddy)
	{
		self.buddy.think = SUB_Remove;
		self.buddy.nextthink = time;
	}

	if (random()*70 > damage)
		return;		// didn't flinch

	if (self.pain_finished > time)
	{
		return;
	}

	self.velocity = VEC_ORIGIN;
	self.pain_finished = time + 3;

    if (random() > 0.5)
	    gaunt_painA1();
    else
        gaunt_painB1();	
}

//============================================================================
void() gaunt_deathA1 = [ $deathA1, gaunt_deathA2 ] {}
void() gaunt_deathA2 = [ $deathA2, gaunt_deathA3 ] {}
void() gaunt_deathA3 = [ $deathA3, gaunt_deathA4 ] {self.solid = SOLID_NOT;}
void() gaunt_deathA4 = [ $deathA4, gaunt_deathA5 ] {}
void() gaunt_deathA5 = [ $deathA5, gaunt_deathA6 ] {}
void() gaunt_deathA6 = [ $deathA6, gaunt_deathA7 ] {
	if (self.velocity_z == 0)
		self.nextthink = time + 0.05;
	else //loop until it stops falling.
		self.think = gaunt_deathA6;
}
void() gaunt_deathA7 = [ $deathA7, gaunt_deathA8 ] {}
void() gaunt_deathA8 = [ $deathA8, gaunt_deathA8 ] {}

//----------------------------------------------------------------------
void() gaunt_deathB1 = [ $deathB1, gaunt_deathB2 ] {}
void() gaunt_deathB2 = [ $deathB2, gaunt_deathB3 ] {}
void() gaunt_deathB3 = [ $deathB3, gaunt_deathB4 ] {self.solid = SOLID_NOT;}
void() gaunt_deathB4 = [ $deathB4, gaunt_deathB5 ] {}
void() gaunt_deathB5 = [ $deathB5, gaunt_deathB6 ] {}
void() gaunt_deathB6 = [ $deathB6, gaunt_deathB7 ] {
	if (self.velocity_z == 0)
		self.nextthink = time + 0.05;
	else //loop until it stops falling.
		self.think = gaunt_deathB6;
};
void() gaunt_deathB7 = [ $deathB7, gaunt_deathB8 ] {}
void() gaunt_deathB8 = [ $deathB8, gaunt_deathB8 ] {}

//----------------------------------------------------------------------

void() gaunt_die =
{
	sound (self, CHAN_VOICE, "gaunt/death.wav", 1, ATTN_NORM);

    if (self.buddy)
	{
		self.buddy.think = SUB_Remove;
		self.buddy.nextthink = time;
	}

	self.movetype = MOVETYPE_STEP;
	self.velocity_x = -100 + 200 * random();
	self.velocity_y = -100 + 200 * random();
	self.velocity_z = 150 + 100 * random();

    // check for gib
	if (self.health < -90)
	{
		Gib ("progs/h_gaunt.mdl", self.health);
		return;
	}
	else if (random() < 0.5)
        gaunt_deathA1();
    else
        gaunt_deathB1();
}

float() GauntCheckAttack =
{
	float chance;

	if (enemy_range == RANGE_MELEE)
		chance = 0.9;
	else if (enemy_range == RANGE_NEAR)
		chance = 0.3;
	else if (enemy_range == RANGE_MID)
		chance = 0.05;
	else
		chance = 0;

	if (random () < chance)
	{
		self.attack_state = AS_MISSILE;
		return TRUE;
	}

	return FALSE;
}

void() monster_gaunt_spawn =
{
	self.classname = "monster_gaunt";
		
	self.solid = SOLID_SLIDEBOX;
	//self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/gaunt.mdl");

	self.yaw_speed = 40;
	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.health = 375;
	self.attack_state = AS_SLIDING;

    self.th_checkattack = GauntCheckAttack;
	self.th_pain = gaunt_pain; 
	self.th_die = gaunt_die;
    self.th_stand = gaunt_idle1;
    self.th_walk = gaunt_walk1;
    self.th_run = gaunt_run1;
    self.th_missile = gaunt_fire1;

	if (self.deathtype == string_null)
		self.deathtype = "was charred by a Gaunt";

	self.height = zeroconvertdefault(self.height, 35);
	self.jump_flag = self.height;	// remember original value for short term nav tweaking
	flymonster_start();
}

void() monster_gaunt_spawner = {mon_spawner_use(monster_gaunt_spawn);}

/*QUAKED monster_gaunt (1 0 0) (-32 -32 -24) (32 32 40) AMBUSH ? ? ? TRIGGERED NOTFOG NOTELEFRAG INSTAWAKE
Gaunt, 120 health points.

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
@PointClass base(Monster) size(-32 -32 -24, 32 32 64) model({ "path": ":progs/gaunt.mdl" }) = monster_gaunt : "Gaunt" []
*/
void() monster_gaunt =
{
	if (!SUB_ShouldSpawn()) return;
	if (nomonster()) return;
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/gaunt.mdl");
	precache_model ("progs/h_gaunt.mdl");
	precache_model ("progs/g_fx.mdl");

	precache_sound ("gaunt/death.wav");
	precache_sound ("gaunt/idle1.wav");
	precache_sound ("gaunt/idle2.wav");
	precache_sound ("gaunt/idle3.wav");
	precache_sound ("gaunt/pain.wav");
	precache_sound ("gaunt/sight.wav");

	self.yaw_speed = 40;
	self.health = 375;
	self.attack_state = AS_SLIDING;
	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	if ( monster_spawnsetup( monster_gaunt_spawner ) ) return;
	
	addmonster(1);
	monster_gaunt_spawn();
}