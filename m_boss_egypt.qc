// morph.qc

$skin aztec
$skin pharoah
$skin roman
$skin florskin

$frame mfstand1
//$frame mfup01 mfup02 mfup03 mfup04 mfup05 mfup06
//$frame mfup07 mfup08 mfup09 mfup10 mfup11 mfup12

$frame start01 start02 start03 start04 start05 start06
$frame start07 start08 start09 start10 start11 start12
$frame start13 start14 start15 start16 start17 start18
$frame start19 start20 start21 start22 start23 start24
$frame start25 start26 start27 start28 start29 start30 start31

$frame mfrun01 mfrun02 mfrun03 mfrun04 mfrun05 mfrun06
$frame mfrun07 mfrun08 mfrun09 mfrun10 mfrun11

$frame mfwlk01 mfwlk02 mfwlk03 mfwlk04 mfwlk05 mfwlk06 mfwlk07 mfwlk08
$frame mfwlk09 mfwlk10 mfwlk11 mfwlk12 mfwlk13

$frame mfata01 mfata02 mfata03 mfata04 mfata05
$frame mfata06 mfata07 mfata08 mfata09

$frame mfatb01 mfatb02 mfatb03 mfatb04 mfatb05 mfatb06
$frame mfatb07 mfatb08 mfatb09 mfatb10 mfatb11

$frame mfatc01 mfatc02 mfatc03 mfatc04 mfatc05 mfatc06
$frame mfatc07 mfatc08 mfatc09 mfatc10 mfatc11 mfatc12
$frame mfatc13 mfatc14 mfatc15 mfatc16

$frame mfknck01 mfknck02 mfknck03 mfknck04 mfknck05 mfknck06
$frame mfknck07 mfknck08 mfknck09 mfknck10 mfknck11 mfknck12

$frame mfpain01 mfpain02 mfpain03 mfpain04 mfpain05
$frame mfpain06 mfpain07 mfpain08 mfpain09 mfpain10

$frame mfpbin01 mfpbin02 mfpbin03 mfpbin04 mfpbin05
$frame mfpbin06 mfpbin07

$frame mfdth01 mfdth02 mfdth03 mfdth04 mfdth05
$frame mfdth06 mfdth07 mfdth08 mfdth09 mfdth10
$frame mfdth11 mfdth12 mfdth13 mfdth14 mfdth15
$frame mfdth16 mfdth17 mfdth18 mfdth19 mfdth20
$frame mfdth21 

.float	childrenSpawned;

void() boss_egypt_teleport;

// ========================
// standing
// ========================
void() boss_egypt_stand1 = [ $mfstand1, boss_egypt_stand1 ] { ai_stand(); };

// ========================
// movement
// ========================
void() boss_egypt_walk1  = [ $mfwlk01, boss_egypt_walk2  ] {ai_walk(8);};
void() boss_egypt_walk2  = [ $mfwlk02, boss_egypt_walk3  ] {ai_walk(4);};
void() boss_egypt_walk3  = [ $mfwlk03, boss_egypt_walk4  ] {ai_walk(6);};
void() boss_egypt_walk4  = [ $mfwlk04, boss_egypt_walk5  ] {ai_walk(7);};
void() boss_egypt_walk5  = [ $mfwlk05, boss_egypt_walk6  ] {ai_walk(12);};
void() boss_egypt_walk6  = [ $mfwlk06, boss_egypt_walk7  ] {ai_walk(9);};
void() boss_egypt_walk7  = [ $mfwlk07, boss_egypt_walk8  ] {ai_walk(6);};
void() boss_egypt_walk8  = [ $mfwlk08, boss_egypt_walk9  ] {ai_walk(7);};
void() boss_egypt_walk9  = [ $mfwlk09, boss_egypt_walk10 ] {ai_walk(4);};
void() boss_egypt_walk10 = [ $mfwlk10, boss_egypt_walk11 ] {ai_walk(5);};
void() boss_egypt_walk11 = [ $mfwlk11, boss_egypt_walk12 ] {ai_walk(12);};
void() boss_egypt_walk12 = [ $mfwlk12, boss_egypt_walk13 ] {ai_walk(11);};
void() boss_egypt_walk13 = [ $mfwlk13, boss_egypt_walk1  ] {ai_walk(7);};
 
void() boss_egypt_run1 = [ $mfrun01, boss_egypt_run2 ] { ai_run(7);};
void() boss_egypt_run2 = [ $mfrun02, boss_egypt_run3 ] { ai_run(18);};
void() boss_egypt_run3 = [ $mfrun03, boss_egypt_run4 ] { ai_run(16);};
void() boss_egypt_run4 = [ $mfrun04, boss_egypt_run5 ] { ai_run(21);};
void() boss_egypt_run5 = [ $mfrun05, boss_egypt_run6 ] { ai_run(11);};
void() boss_egypt_run6 = [ $mfrun06, boss_egypt_run7 ] { ai_run(9);};
void() boss_egypt_run7 = [ $mfrun07, boss_egypt_run8 ] { ai_run(8);};
void() boss_egypt_run8 = [ $mfrun08, boss_egypt_run9 ] { ai_run(10);};
void() boss_egypt_run9 = [ $mfrun09, boss_egypt_run10 ] {ai_run(16);};
void() boss_egypt_run10 =[ $mfrun10, boss_egypt_run11 ] {ai_run(18);};
void() boss_egypt_run11 =[ $mfrun11, boss_egypt_run1 ] { ai_run(12);};

// ========================
// new attack code
// ========================
void() boss_egypt_stab2 =
{
	local float		dist;
	local float		attackDamage;
	local vector	org, dir;
	
	if (!self.enemy)
		return;
	if (!CanDamage (self.enemy, self.origin))
		return;

	ai_face();

	dir = self.enemy.origin - self.origin + self.enemy.view_ofs;
	dist = vlen ( dir );
	dir = normalize ( dir );
	makevectors (self.angles);

	if ( dist <= 90 )
	{
		sound (self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_STATIC);
	    attackDamage = (random() * 10) + 20;
		T_Damage (self.enemy, self, self, attackDamage);
		SpawnBlood ( self.enemy.origin, v_forward * 150, 14);
	}
	else
	{
		self.effects = self.effects | EF_MUZZLEFLASH;
		org = self.origin + v_forward * 80 + v_right * 4 + '0 0 4';
		launch_laser(org, dir * 600);
		if ( dist )
		{
			launch_laser(org, (dir + v_right * 0.04) * 600);
			launch_laser(org, (dir - v_right * 0.04) * 600);
		}
		else
		{
			launch_laser(org, (dir + v_right * 0.10) * 600);
			launch_laser(org, (dir - v_right * 0.10) * 600);	
		}
	}	
};

// ========================
// hand to hand attack
// ========================

void() boss_egypt_attack01 = [ $mfatb01, boss_egypt_attack02 ] {ai_face();};
void() boss_egypt_attack02 = [ $mfatb02, boss_egypt_attack03 ] {ai_face();};
void() boss_egypt_attack03 = [ $mfatb03, boss_egypt_attack04 ] {ai_face();};
void() boss_egypt_attack04 = [ $mfatb04, boss_egypt_attack05 ] {ai_face();};
void() boss_egypt_attack05 = [ $mfatb05, boss_egypt_attack06 ] {ai_face();};
void() boss_egypt_attack06 = [ $mfatb06, boss_egypt_attack07 ] {ai_face();};
void() boss_egypt_attack07 = [ $mfatb07, boss_egypt_attack08 ] {boss_egypt_stab2();};
void() boss_egypt_attack08 = [ $mfatb08, boss_egypt_attack09 ] {ai_face();};
void() boss_egypt_attack09 = [ $mfatb09, boss_egypt_attack10 ] {ai_face();};
void() boss_egypt_attack10 = [ $mfatb10, boss_egypt_attack11 ] {ai_face();};
void() boss_egypt_attack11 = [ $mfatb11, boss_egypt_attack12 ] {ai_face();};
void() boss_egypt_attack12 = [ $mfatb01, boss_egypt_run1     ] {ai_face();};

void() boss_egypt_bigattack01 = [ $mfatc01, boss_egypt_bigattack02 ] { ai_face(); };
void() boss_egypt_bigattack02 = [ $mfatc02, boss_egypt_bigattack03 ] { ai_face(); };
void() boss_egypt_bigattack03 = [ $mfatc03, boss_egypt_bigattack04 ] { ai_face(); };
void() boss_egypt_bigattack04 = [ $mfatc04, boss_egypt_bigattack05 ] { ai_face(); };
void() boss_egypt_bigattack05 = [ $mfatc05, boss_egypt_bigattack06 ] { ai_face(); };
void() boss_egypt_bigattack06 = [ $mfatc06, boss_egypt_bigattack07 ] { ai_face(); };
void() boss_egypt_bigattack07 = [ $mfatc07, boss_egypt_bigattack08 ] { ai_face(); };
void() boss_egypt_bigattack08 = [ $mfatc08, boss_egypt_bigattack09 ] { ai_face(); };
void() boss_egypt_bigattack09 = [ $mfatc09, boss_egypt_bigattack10 ] { ai_face(); };
void() boss_egypt_bigattack10 = [ $mfatc10, boss_egypt_bigattack11 ] { boss_egypt_stab2();};
void() boss_egypt_bigattack11 = [ $mfatc11, boss_egypt_bigattack12 ] { ai_face(); };
void() boss_egypt_bigattack12 = [ $mfatc12, boss_egypt_bigattack13 ] { ai_face(); };
void() boss_egypt_bigattack13 = [ $mfatc13, boss_egypt_bigattack14 ] { ai_face(); };
void() boss_egypt_bigattack14 = [ $mfatc14, boss_egypt_bigattack15 ] { ai_face(); };
void() boss_egypt_bigattack15 = [ $mfatc15, boss_egypt_bigattack16 ] { ai_face(); };
void() boss_egypt_bigattack16 = [ $mfatc16, boss_egypt_bigattack17 ] { ai_face(); };
void() boss_egypt_bigattack17 = [ $mfatc01, boss_egypt_run1        ] { ai_face(); };

void() boss_egypt_smack = 
{
    local vector    delta;
    local float     ldmg;

	if (!self.enemy)
		return;
	if (!CanDamage (self.enemy, self.origin))
		return;

	ai_face();

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 100)
		return;
		
    ldmg = (random() * 10) + 10;
	T_Damage (self.enemy, self, self, ldmg);
	
	makevectors (self.angles);
	self.enemy.velocity = v_forward * 100 + '0 0 100';
};

void() boss_egypt_knockback01 = [ $mfknck01, boss_egypt_knockback02 ] { ai_face(); };
void() boss_egypt_knockback02 = [ $mfknck02, boss_egypt_knockback03 ] { ai_face(); };
void() boss_egypt_knockback03 = [ $mfknck03, boss_egypt_knockback04 ] { ai_face(); };
void() boss_egypt_knockback04 = [ $mfknck04, boss_egypt_knockback05 ] { ai_face(); };
void() boss_egypt_knockback05 = [ $mfknck05, boss_egypt_knockback06 ] { ai_face(); };
void() boss_egypt_knockback06 = [ $mfknck06, boss_egypt_knockback07 ] { ai_face(); };
void() boss_egypt_knockback07 = [ $mfknck07, boss_egypt_knockback08 ] { ai_face(); };
void() boss_egypt_knockback08 = [ $mfknck08, boss_egypt_knockback09 ] { ai_face(); };
void() boss_egypt_knockback09 = [ $mfknck09, boss_egypt_knockback10 ] { boss_egypt_smack(); };
void() boss_egypt_knockback10 = [ $mfknck10, boss_egypt_knockback11 ] { ai_face(); };
void() boss_egypt_knockback11 = [ $mfknck11, boss_egypt_knockback12 ] { ai_face(); };
void() boss_egypt_knockback12 = [ $mfknck12, boss_egypt_run1        ] { ai_face(); };

void() boss_egypt_attack =
{
	local float 	attackChoice;
	
	attackChoice = random();
	
	if (attackChoice < 0.50)
		boss_egypt_bigattack01();
	else if (attackChoice < 0.75)
		boss_egypt_attack01();
	else
		boss_egypt_knockback01();
};

// ========================
// ranged attack
// ========================
void() boss_egypt_fire =
{
	local vector org, dir;

	ai_face();
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	
	makevectors (self.angles);
	org = self.origin + v_forward * 62 + v_right * 18 + '0 0 37';
	dir = normalize ( self.enemy.origin - org);
	launch_laser(org, dir * 600);
	if ( vlen (self.enemy.origin - self.origin) > 400 )
	{
		launch_laser(org, (dir + v_right * 0.04) * 600);
		launch_laser(org, (dir - v_right * 0.04) * 600);
	}
	else
	{
		launch_laser(org, (dir + v_right * 0.10) * 600);
		launch_laser(org, (dir - v_right * 0.10) * 600);	
	}

};

void() boss_egypt_fire1 = [ $mfata01, boss_egypt_fire2 ] {ai_face();};
void() boss_egypt_fire2 = [ $mfata02, boss_egypt_fire3 ] {ai_face();};
void() boss_egypt_fire3 = [ $mfata03, boss_egypt_fire4 ] {ai_face();};
void() boss_egypt_fire4 = [ $mfata04, boss_egypt_fire5 ] {boss_egypt_fire();};
void() boss_egypt_fire5 = [ $mfata05, boss_egypt_fire6 ] {ai_face();};
void() boss_egypt_fire6 = [ $mfata06, boss_egypt_fire7 ] {ai_face();};
void() boss_egypt_fire7 = [ $mfata07, boss_egypt_fire8 ] {ai_face();};
void() boss_egypt_fire8 = [ $mfata08, boss_egypt_fire9] {ai_face();};
void() boss_egypt_fire9 = [ $mfata09, boss_egypt_run1 ] {ai_face();};

// ========================
// pain
// ========================
void() boss_egypt_painA1 = [ $mfpain01, boss_egypt_painA2 ] {};
void() boss_egypt_painA2 = [ $mfpain02, boss_egypt_painA3 ] {};
void() boss_egypt_painA3 = [ $mfpain03, boss_egypt_painA4 ] {};
void() boss_egypt_painA4 = [ $mfpain04, boss_egypt_painA5 ] {};
void() boss_egypt_painA5 = [ $mfpain05, boss_egypt_painA6 ] {};
void() boss_egypt_painA6 = [ $mfpain06, boss_egypt_painA7 ] {};
void() boss_egypt_painA7 = [ $mfpain07, boss_egypt_painA8 ] {};
void() boss_egypt_painA8 = [ $mfpain08, boss_egypt_painA9 ] {};
void() boss_egypt_painA9 = [ $mfpain09, boss_egypt_painA10 ] {};
void() boss_egypt_painA10 = [ $mfpain10, boss_egypt_run1 ] {boss_egypt_teleport();};

void() boss_egypt_painB1 = [ $mfpbin01, boss_egypt_painB2 ] {};
void() boss_egypt_painB2 = [ $mfpbin02, boss_egypt_painB3 ] {};
void() boss_egypt_painB3 = [ $mfpbin03, boss_egypt_painB4 ] {};
void() boss_egypt_painB4 = [ $mfpbin04, boss_egypt_painB5 ] {};
void() boss_egypt_painB5 = [ $mfpbin05, boss_egypt_painB6 ] {};
void() boss_egypt_painB6 = [ $mfpbin06, boss_egypt_painB7 ] {};
void() boss_egypt_painB7 = [ $mfpbin07, boss_egypt_run1 ] {boss_egypt_teleport();};

void(entity attacker, float damage) boss_egypt_pain =
{
	local float painChoice;

	if (skill == 3)
	{
		if (random() > 0.5)
			boss_egypt_teleport();
		return;
	}
	
	if (self.pain_finished > time)
		return;
	if (random() > 0.25)
		return;
	
	painChoice = random();
	self.pain_finished = time + 2;

	sound (self, CHAN_VOICE, "guard/pain1.wav", 1, ATTN_NORM );

	if ( painChoice > 0.6)
		self.think = boss_egypt_painB1;
	else
		self.think = boss_egypt_painA1;
	
	self.nextthink = time + 0.1;
};

// ========================
// die
// ========================
void() boss_egypt_die1 = [ $mfdth01, boss_egypt_die2 ] {};
void() boss_egypt_die2 = [ $mfdth02, boss_egypt_die3 ] {};
void() boss_egypt_die3 = [ $mfdth03, boss_egypt_die4 ] {};
void() boss_egypt_die4 = [ $mfdth04, boss_egypt_die5 ] {};
void() boss_egypt_die5 = [ $mfdth05, boss_egypt_die6 ] {self.skin = 1;};
void() boss_egypt_die6 = [ $mfdth06, boss_egypt_die7 ] {};
void() boss_egypt_die7 = [ $mfdth07, boss_egypt_die8 ] {};
void() boss_egypt_die8 = [ $mfdth08, boss_egypt_die9 ] {};
void() boss_egypt_die9 = [ $mfdth09, boss_egypt_die10 ] {};
void() boss_egypt_die10 = [ $mfdth10, boss_egypt_die11 ] {self.skin = 2;};
void() boss_egypt_die11 = [ $mfdth11, boss_egypt_die12 ] {};
void() boss_egypt_die12 = [ $mfdth12, boss_egypt_die13 ] {};
void() boss_egypt_die13 = [ $mfdth13, boss_egypt_die14 ] {};
void() boss_egypt_die14 = [ $mfdth14, boss_egypt_die15 ] {};
void() boss_egypt_die15 = [ $mfdth15, boss_egypt_die16 ] {self.skin = 3;};
void() boss_egypt_die16 = [ $mfdth16, boss_egypt_die17 ] {};
void() boss_egypt_die17 = [ $mfdth17, boss_egypt_die18 ] {};
void() boss_egypt_die18 = [ $mfdth18, boss_egypt_die19 ] {};
void() boss_egypt_die19 = [ $mfdth19, boss_egypt_die20 ] {};
void() boss_egypt_die20 = [ $mfdth20, boss_egypt_die21 ] {};
void() boss_egypt_die21 = [ $mfdth21, boss_egypt_die21 ] 
{
	remove(self);
};

void() boss_egypt_die =
{
 	sound ( self, CHAN_VOICE, "guard/death.wav", 1, ATTN_NORM);
    self.solid = SOLID_NOT;
    self.think = boss_egypt_die1;
    self.nextthink = time + 0.1;
};


// ========================
// hide in floor
// ========================
void() boss_egypt_wake1 = [ $start01, boss_egypt_wake2 ] 
{
	sound ( self, CHAN_VOICE, "guard/see1.wav", 1, ATTN_NORM );
};
void() boss_egypt_wake2 = [ $start02, boss_egypt_wake3 ] {};
void() boss_egypt_wake3 = [ $start03, boss_egypt_wake4 ] {};
void() boss_egypt_wake4 = [ $start04, boss_egypt_wake5 ] {};
void() boss_egypt_wake5 = [ $start05, boss_egypt_wake6 ] {};
void() boss_egypt_wake6 = [ $start06, boss_egypt_wake7 ] {};
void() boss_egypt_wake7 = [ $start07, boss_egypt_wake8 ] {};
void() boss_egypt_wake8 = [ $start08, boss_egypt_wake9 ] {};
void() boss_egypt_wake9 = [ $start09, boss_egypt_wake10 ] {self.skin = 2;};
void() boss_egypt_wake10 = [ $start10, boss_egypt_wake11 ] {};
void() boss_egypt_wake11 = [ $start11, boss_egypt_wake12 ] {};
void() boss_egypt_wake12 = [ $start12, boss_egypt_wake13 ] {};
void() boss_egypt_wake13 = [ $start13, boss_egypt_wake14 ] {};
void() boss_egypt_wake14 = [ $start14, boss_egypt_wake15 ] {};
void() boss_egypt_wake15 = [ $start15, boss_egypt_wake16 ] {};
void() boss_egypt_wake16 = [ $start16, boss_egypt_wake17 ] {};
void() boss_egypt_wake17 = [ $start17, boss_egypt_wake18 ] {self.skin = 1;};
//void() boss_egypt_wake18 = [ $start18, boss_egypt_wake20 ] {};
void() boss_egypt_wake18 = [ $start18, boss_egypt_wake19 ] {};
void() boss_egypt_wake19 = [ $start19, boss_egypt_wake20 ] {};
void() boss_egypt_wake20 = [ $start20, boss_egypt_wake21 ] {};
void() boss_egypt_wake21 = [ $start21, boss_egypt_wake22 ] {};
void() boss_egypt_wake22 = [ $start22, boss_egypt_wake23 ] {};
void() boss_egypt_wake23 = [ $start23, boss_egypt_wake24 ] {};
void() boss_egypt_wake24 = [ $start24, boss_egypt_wake25 ] {};
void() boss_egypt_wake25 = [ $start25, boss_egypt_wake26 ] {self.skin = 0;};
void() boss_egypt_wake26 = [ $start26, boss_egypt_wake27 ] {};
void() boss_egypt_wake27 = [ $start27, boss_egypt_wake28 ] {};
void() boss_egypt_wake28 = [ $start28, boss_egypt_wake29 ] {};
void() boss_egypt_wake29 = [ $start29, boss_egypt_wake30 ] {};
void() boss_egypt_wake30 = [ $start30, boss_egypt_wake31 ] {};
void() boss_egypt_wake31 = [ $start31, boss_egypt_stand1 ] 
{
	self.solid = SOLID_SLIDEBOX;
	self.takedamage = DAMAGE_AIM;
	//setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	
	self.th_stand = boss_egypt_stand1;
	self.th_walk = boss_egypt_walk1;
	self.th_run = boss_egypt_run1;
	
	///	Hack to stop copper from killing Guardian on touch, 
	///	when spawning...
	self.mins = self.mins + '4 4 0';
	self.maxs = self.maxs - '4 4 0';
	
	walkmonster_start();
	
	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	//walkmonster_start_go();
};

void(entity theMorph) boss_egypt_setup =
{
	local	entity	temp_self;
	
	self.classname = "monster_morph";

	theMorph.solid = SOLID_SLIDEBOX;
	theMorph.movetype = MOVETYPE_STEP;
	
	self.model = "progs/boss_egypt.mdl";
	
	setmodel (theMorph, theMorph.model);
	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	
	theMorph.th_stand = boss_egypt_wake1;
	theMorph.th_walk = boss_egypt_wake1;
	theMorph.th_run = boss_egypt_wake1;
	theMorph.th_missile = boss_egypt_fire1;
	theMorph.th_melee = boss_egypt_attack;
	theMorph.th_pain = boss_egypt_pain;
	theMorph.th_die = boss_egypt_die;
	theMorph.th_checkattack = CheckAttack;
	
	if (self.deathtype == string_null)
		self.deathtype = "was crushed by a Guardian";
	
	theMorph.takedamage = DAMAGE_NO;
	theMorph.flags = theMorph.flags | FL_MONSTER;
	theMorph.ideal_yaw = theMorph.angles * '0 1 0';
	if (!theMorph.yaw_speed)
		theMorph.yaw_speed = 20;
	theMorph.view_ofs = '0 0 25';
	theMorph.frame = $start01;

	theMorph.effects = theMorph.effects | EF_DIMLIGHT;
	theMorph.health = 2000;

	theMorph.skin = 3;
	
	//theMorph.spawnflags = theMorph.spawnflags | MORPH_EGYPT;
	
	temp_self = self;
	self = theMorph;
	boss_egypt_wake1();
	self = temp_self;
};

void() boss_egypt_teleport =
{
	local entity    theDest;
	local entity	theChild;
	
	if (self.childrenSpawned > (1+skill))
		return;
		
    theDest = find_dest();
    if (theDest == world)
        return;
	
	theChild = spawn();
	theChild.model = "progs/morph_eg.mdl";
	theChild.angles = theDest.mangle;
	theChild.owner = self;
	theChild.enemy = self.enemy;
	theChild.goalentity = self.goalentity;
	theChild.mangle = theDest.mangle;
	theChild.classname = "monster_morph";
	theChild.spawnflags = theChild.spawnflags | MORPH_EGYPT;
	morph_setup (theChild);
	setorigin (theChild, theDest.origin);
	droptofloor(0,0);

	theChild.think = morph_wake1;
	theChild.nextthink = time + 0.3;
};

void() monster_boss_egypt_spawn =
{
	boss_egypt_setup(self);
};

void() monster_boss_egypt_spawner = {mon_spawner_use(monster_boss_egypt_spawn);}

/*QUAKED monster_boss_egypt (1 0 0) (-32 -32 -24) (32 32 64)
The morphing monster.

If the monster has a targetname (triggered by something) he will rise up out of the floor when triggered.
*/
void() monster_boss_egypt =
{
	if (!SUB_ShouldSpawn()) return;
	if (deathmatch || cvar("nomonsters") != 0)
	{
		remove(self);
		return;
	}

	precache_model ("progs/boss_egypt.mdl");
	precache_model ("progs/morph_eg.mdl");
	
	precache_model2 ("progs/laser.mdl");
	precache_sound2 ("enforcer/enfire.wav");
	precache_sound2 ("enforcer/enfstop.wav");
	precache_sound2 ("guard/death.wav");
	precache_sound2 ("guard/pain1.wav");
	precache_sound2 ("guard/see1.wav");
	
	self.health = 2000;
	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	
	if ( monster_spawnsetup( monster_boss_egypt_spawner ) ) return;
	
	addmonster(1);
	monster_boss_egypt_spawn();
};