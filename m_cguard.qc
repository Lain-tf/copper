/*
==============================================================================

KNIGHT

==============================================================================
*/

$cd id1/models/knight2
$origin 0 0 24
$base base
$skin skin

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12

$frame standb1 standb2 standb3 standb4 standb5 standb6 standb7 standb8 standb9
$frame standb10 standb11 standb12 standb13 standb14 standb15 standb16 standb17
$frame standb18 standb19 standb20 standb21 standb22 standb23

$frame standc1 standc2 standc3 standc4 standc5 standc6 standc7 standc8 standc9
$frame standc10 standc11 standc12 standc13 standc14 standc15 standc16 standc17
$frame standc18 standc19 standc20 standc21 standc22 standc23 standc24 standc25
$frame standc26 standc27 standc28 standc29 standc30 standc31 standc32 standc33
$frame standc34 standc35

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9
$frame walk10 walk11 walk12 walk13 walk14 walk15

$frame run1 run2 run3 run4 run5 run6 run7 run8 run9 run10

$frame attack1 attack2 attack3 attack4 attack5 attack6 attack7 attack8 attack9 
$frame attack10 attack11 attack12

$frame pain1 pain2 pain3 pain4 pain5 pain6 pain7

$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10 death11 death12

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9 deathb10 deathb11 deathb12 deathb13 deathb14 deathb15
$frame deathb16 deathb17

$frame melee1 melee2 melee3 melee4 melee5 melee6 melee7 melee8 melee9 
$frame melee10 melee11 melee12 melee13 melee14

$frame meleeb1 meleeb2 meleeb3 meleeb4 meleeb5 meleeb6 meleeb7 meleeb8 meleeb9 
$frame meleeb10 meleeb11 meleeb12 meleeb13 meleeb14 meleeb15 meleeb16 meleeb17
$frame meleeb18

void() cguard_SelectIdle =
{
	float rng;
	
	rng = random();
	
	if(rng < 0.05)
		cguard_standc1();
	else if (rng < 0.2)
		cguard_standb1();
	else
		cguard_stand1();
};

/*
=============
cguard_Melee
=============
*/
void(float overHead) cguard_Melee =
{
	local vector	delta;
	local float 	ldmg, angleDifference;

	if (!self.enemy)
		return;		// removed before stroke
	if (!CanDamage (self.enemy, self.origin))
		return;
	
	if(overHead)
		ai_charge(30);
	else
		ai_charge(10);

	
	delta = self.enemy.origin - self.origin;
	
	if (vlen(delta) > 90)
		return;
	
	//if (vlensqr(delta) > 90*90)
	//	return;
		
	ldmg = (random() + random() + random()) * 4;
	
	angleDifference = angledif(self.ideal_yaw, self.angles_y);
	if (angleDifference < 80) // no damage from ass
	{
		T_DamageMelee (self.enemy, self, ldmg);
	}
};

/*
=============
cguard_Shoot
=============
*/
void() cguard_Shoot =
{
	vector org, vec, right;
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, "cguard/laser.wav", 1, ATTN_NORM);
	
	vec = normalize(enemy_vispos() - self.origin);
	right = CrossProduct(vec, '0 0 1');
	
	org = self.origin + (vec * 34) + (right * -7) + '0 0 3';
	vec = normalize(enemy_vispos() - org + enemy_aim_vertical());
	
	makevectors(self.angles);	
	if (angledif(self.ideal_yaw, self.angles_y) > 80)	// no ass lasers
	{
		vec_x = v_forward_x;
		vec_y = v_forward_y;
		vec = normalize(vec);
	}
	
	launch_laser(org, vec * 600);
};

//===========================================================================
//	Sound handling
//===========================================================================
void() cguard_idle_sound =
{
	if (random() < 0.2 && time > self.show_hostile)
		sound (self, CHAN_VOICE, "cguard/idle.wav", 1, ATTN_NORM);
};

void() cguard_pain_sound =
{
	if (random() < 0.5)
		sound (self, CHAN_VOICE, "cguard/injure1.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "cguard/injure2.wav", 1, ATTN_NORM);
};

void() cguard_death_sound =
{
	if (random() < 0.5)
		sound (self, CHAN_VOICE, "cguard/death1.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "cguard/death2.wav", 1, ATTN_NORM);
};

void() cguard_swing_sound =
{
	if (random() < 0.5)
		sound (self, CHAN_VOICE, "cguard/melee1.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "cguard/meleeswing.wav", 1, ATTN_NORM);
}

//===========================================================================

void()	cguard_stand1	=[	$stand1,	cguard_stand2	] {ai_stand();cguard_idle_sound();}
void()	cguard_stand2	=[	$stand2,	cguard_stand3	] {ai_stand();}
void()	cguard_stand3	=[	$stand3,	cguard_stand4	] {ai_stand();}
void()	cguard_stand4	=[	$stand4,	cguard_stand5	] {ai_stand();}
void()	cguard_stand5	=[	$stand5,	cguard_stand6	] {ai_stand();}
void()	cguard_stand6	=[	$stand6,	cguard_stand7	] {ai_stand();}
void()	cguard_stand7	=[	$stand7,	cguard_stand8	] {ai_stand();}
void()	cguard_stand8	=[	$stand8,	cguard_stand9	] {ai_stand();}
void()	cguard_stand9	=[	$stand9,	cguard_stand10	] {ai_stand();}
void()	cguard_stand10	=[	$stand10,	cguard_stand11	] {ai_stand();}
void()	cguard_stand11	=[	$stand11,	cguard_stand12	] {ai_stand();}
void()	cguard_stand12	=[	$stand12,	cguard_stand1	] {ai_stand(); cguard_SelectIdle();}

//===========================================================================

void()	cguard_standb1	=[	$standb1,	cguard_standb2	] {ai_stand();cguard_idle_sound();}
void()	cguard_standb2	=[	$standb2,	cguard_standb3	] {ai_stand();}
void()	cguard_standb3	=[	$standb3,	cguard_standb4	] {ai_stand();}
void()	cguard_standb4	=[	$standb4,	cguard_standb5	] {ai_stand();}
void()	cguard_standb5	=[	$standb5,	cguard_standb6	] {ai_stand();}
void()	cguard_standb6	=[	$standb6,	cguard_standb7	] {ai_stand();}
void()	cguard_standb7	=[	$standb7,	cguard_standb8	] {ai_stand();}
void()	cguard_standb8	=[	$standb8,	cguard_standb9	] {ai_stand();}
void()	cguard_standb9	=[	$standb9,	cguard_standb10	] {ai_stand();}
void()	cguard_standb10	=[	$standb10,	cguard_standb11	] {ai_stand();}
void()	cguard_standb11	=[	$standb11,	cguard_standb12	] {ai_stand();}
void()	cguard_standb12	=[	$standb12,	cguard_standb13	] {ai_stand();}
void()	cguard_standb13	=[	$standb13,	cguard_standb14	] {ai_stand();}
void()	cguard_standb14	=[	$standb14,	cguard_standb15	] {ai_stand();}
void()	cguard_standb15	=[	$standb15,	cguard_standb16	] {ai_stand();}
void()	cguard_standb16	=[	$standb16,	cguard_standb17	] {ai_stand();}
void()	cguard_standb17	=[	$standb17,	cguard_standb18	] {ai_stand();}
void()	cguard_standb18	=[	$standb18,	cguard_standb19	] {ai_stand();}
void()	cguard_standb19	=[	$standb19,	cguard_standb20	] {ai_stand();}
void()	cguard_standb20	=[	$standb20,	cguard_standb21	] {ai_stand();}
void()	cguard_standb21	=[	$standb21,	cguard_standb22	] {ai_stand();}
void()	cguard_standb22	=[	$standb22,	cguard_standb23	] {ai_stand();}
void()	cguard_standb23	=[	$standb23,	cguard_stand1	] {ai_stand();}

//===========================================================================

void()	cguard_standc1	=[	$standc1,	cguard_standc2	] {ai_stand();}
void()	cguard_standc2	=[	$standc2,	cguard_standc3	] {ai_stand();}
void()	cguard_standc3	=[	$standc3,	cguard_standc4	] {ai_stand();}
void()	cguard_standc4	=[	$standc4,	cguard_standc5	] {ai_stand();}
void()	cguard_standc5	=[	$standc5,	cguard_standc6	] {ai_stand();}
void()	cguard_standc6	=[	$standc6,	cguard_standc7	] {ai_stand();}
void()	cguard_standc7	=[	$standc7,	cguard_standc8	] {ai_stand();}
void()	cguard_standc8	=[	$standc8,	cguard_standc9	] {ai_stand();}
void()	cguard_standc9	=[	$standc9,	cguard_standc10	] {ai_stand();}
void()	cguard_standc10	=[	$standc10,	cguard_standc11	] {ai_stand();}
void()	cguard_standc11	=[	$standc11,	cguard_standc12	] {ai_stand();}
void()	cguard_standc12	=[	$standc12,	cguard_standc13	] {ai_stand();}
void()	cguard_standc13	=[	$standc13,	cguard_standc14	] {ai_stand();}
void()	cguard_standc14	=[	$standc14,	cguard_standc15	] {ai_stand();}
void()	cguard_standc15	=[	$standc15,	cguard_standc16	] {ai_stand();}
void()	cguard_standc16	=[	$standc16,	cguard_standc17	] {ai_stand();}
void()	cguard_standc17	=[	$standc17,	cguard_standc18	] {ai_stand();}
void()	cguard_standc18	=[	$standc18,	cguard_standc19	] {ai_stand();}
void()	cguard_standc19	=[	$standc19,	cguard_standc20	] {ai_stand();}
void()	cguard_standc20	=[	$standc20,	cguard_standc21	] {ai_stand();}
void()	cguard_standc21	=[	$standc21,	cguard_standc22	] {ai_stand();}
void()	cguard_standc22	=[	$standc22,	cguard_standc23	] {ai_stand();}
void()	cguard_standc23	=[	$standc23,	cguard_standc24	] {ai_stand();}
void()	cguard_standc24	=[	$standc24,	cguard_standc25	] {ai_stand();}
void()	cguard_standc25	=[	$standc25,	cguard_standc26	] {ai_stand();}
void()	cguard_standc26	=[	$standc26,	cguard_standc27	] {ai_stand();}
void()	cguard_standc27	=[	$standc27,	cguard_standc28	] {ai_stand();}
void()	cguard_standc28	=[	$standc28,	cguard_standc29	] {ai_stand();}
void()	cguard_standc29	=[	$standc29,	cguard_standc30	] {ai_stand();}
void()	cguard_standc30	=[	$standc30,	cguard_standc31	] {ai_stand();}
void()	cguard_standc31	=[	$standc31,	cguard_standc32	] {ai_stand();}
void()	cguard_standc32	=[	$standc32,	cguard_standc33	] {ai_stand();}
void()	cguard_standc33	=[	$standc33,	cguard_standc34	] {ai_stand();}
void()	cguard_standc34	=[	$standc34,	cguard_standc35	] {ai_stand();}
void()	cguard_standc35	=[	$standc35,	cguard_stand1	] {ai_stand();}

//===========================================================================

void()	cguard_walk1	=[	$walk1,		cguard_walk2	] {ai_walk(4);}
void()	cguard_walk2	=[	$walk2,		cguard_walk3	] {ai_walk(4);}
void()	cguard_walk3	=[	$walk3,		cguard_walk4	] {ai_walk(4);}
void()	cguard_walk4	=[	$walk4,		cguard_walk5	] {ai_walk(4);}
void()	cguard_walk5	=[	$walk5,		cguard_walk6	] {ai_walk(4);}
void()	cguard_walk6	=[	$walk6,		cguard_walk7	] {ai_walk(4);}
void()	cguard_walk7	=[	$walk7,		cguard_walk8	] {ai_walk(4);}
void()	cguard_walk8	=[	$walk8,		cguard_walk9	] {ai_walk(4);}
void()	cguard_walk9	=[	$walk9,		cguard_walk10	] {ai_walk(4);}
void()	cguard_walk10	=[	$walk10,	cguard_walk11	] {ai_walk(4);}
void()	cguard_walk11	=[	$walk11,	cguard_walk12	] {ai_walk(4);}
void()	cguard_walk12	=[	$walk12,	cguard_walk13	] {ai_walk(4);}
void()	cguard_walk13	=[	$walk13,	cguard_walk14	] {ai_walk(4);}
void()	cguard_walk14	=[	$walk14,	cguard_walk15	] {ai_walk(4);}
void()	cguard_walk15	=[	$walk15,	cguard_walk1	] {ai_walk(4);}

//===========================================================================

void()	cguard_run1		=[	$run1,		cguard_run2		] {ai_run(11);}
void()	cguard_run2		=[	$run2,		cguard_run3		] {ai_run(20);}
void()	cguard_run3		=[	$run3,		cguard_run4		] {ai_run(20);}
void()	cguard_run4		=[	$run4,		cguard_run5		] {ai_run(11);}
void()	cguard_run5		=[	$run5,		cguard_run6		] {ai_run(11);}
void()	cguard_run6		=[	$run6,		cguard_run7		] {ai_run(20);}
void()	cguard_run7		=[	$run7,		cguard_run8		] {ai_run(20);}
void()	cguard_run8		=[	$run8,		cguard_run9		] {ai_run(20);}
void()	cguard_run9		=[	$run9,		cguard_run10	] {ai_run(11);}
void()	cguard_run10	=[	$run10,		cguard_run1		] {ai_run(11);}

//============================================================================

void()	cguard_attack1		=[	$attack1,	cguard_attack2	]	{ai_face();}
void()	cguard_attack2		=[	$attack2,	cguard_attack3	]	{ai_face();}
void()	cguard_attack3		=[	$attack3,	cguard_attack4	]	{ai_face();}
void()	cguard_attack4		=[	$attack4,	cguard_attack5	]	{ai_face();}
void()	cguard_attack5		=[	$attack5,	cguard_attack6	]	{ai_face();}
void()	cguard_attack6		=[	$attack6,	cguard_attack7	]	{ai_face();}
void()	cguard_attack7		=[	$attack7,	cguard_attack8	]	{ai_face();}
void()	cguard_attack8		=[	$attack8,	cguard_attack9	]	{cguard_Shoot();}
void()	cguard_attack9		=[	$attack9,	cguard_attack10	]	{}
void()	cguard_attack10		=[	$attack10,	cguard_attack11	]	{ai_face();}
void()	cguard_attack11		=[	$attack11,	cguard_attack12	]	{ai_face();}
void()	cguard_attack12		=[	$attack12,	cguard_run1		]	{ai_face();}

//============================================================================

void()	cguard_melee1	=[	$melee1,	cguard_melee2	] {ai_face();}
void()	cguard_melee2	=[	$melee2,	cguard_melee3	] {ai_face();}
void()	cguard_melee3	=[	$melee3,	cguard_melee4	] {ai_face();}
void()	cguard_melee4	=[	$melee4,	cguard_melee5	] {ai_face();}
void()	cguard_melee5	=[	$melee5,	cguard_melee6	] {ai_face();}
void()	cguard_melee6	=[	$melee6,	cguard_melee7	] {ai_face(); cguard_swing_sound();}
void()	cguard_melee7	=[	$melee7,	cguard_melee8	] {ai_face();}
void()	cguard_melee8	=[	$melee8,	cguard_melee9	] {cguard_Melee(FALSE);}
void()	cguard_melee9	=[	$melee9,	cguard_melee10	] {cguard_Melee(FALSE);}
void()	cguard_melee10	=[	$melee10,	cguard_melee11	] {cguard_Melee(FALSE);}
void()	cguard_melee11	=[	$melee11,	cguard_melee12	] {}
void()	cguard_melee12	=[	$melee12,	cguard_melee13	] {}
void()	cguard_melee13	=[	$melee13,	cguard_melee14	] {}
void()	cguard_melee14	=[	$melee14,	cguard_run1		] {}

//============================================================================

void()	cguard_meleeb1	=[	$meleeb1,	cguard_meleeb2	] {ai_face();}
void()	cguard_meleeb2	=[	$meleeb2,	cguard_meleeb3	] {ai_face();}
void()	cguard_meleeb3	=[	$meleeb3,	cguard_meleeb4	] {ai_face();}
void()	cguard_meleeb4	=[	$meleeb4,	cguard_meleeb5	] {ai_face();}
void()	cguard_meleeb5	=[	$meleeb5,	cguard_meleeb6	] {ai_face(); cguard_swing_sound();}
void()	cguard_meleeb6	=[	$meleeb6,	cguard_meleeb7	] {ai_face();}
void()	cguard_meleeb7	=[	$meleeb7,	cguard_meleeb8	] {cguard_Melee(TRUE);}
void()	cguard_meleeb8	=[	$meleeb8,	cguard_meleeb9	] {cguard_Melee(TRUE);}
void()	cguard_meleeb9	=[	$meleeb9,	cguard_meleeb10	] {cguard_Melee(TRUE);}
void()	cguard_meleeb10	=[	$meleeb10,	cguard_meleeb11	] {cguard_Melee(TRUE);}
void()	cguard_meleeb11	=[	$meleeb11,	cguard_meleeb12	] {}
void()	cguard_meleeb12	=[	$meleeb12,	cguard_meleeb13	] {}
void()	cguard_meleeb13	=[	$meleeb13,	cguard_meleeb14	] {}
void()	cguard_meleeb14	=[	$meleeb14,	cguard_meleeb15	] {}
void()	cguard_meleeb15	=[	$meleeb15,	cguard_meleeb16	] {}
void()	cguard_meleeb16	=[	$meleeb16,	cguard_meleeb17	] {}
void()	cguard_meleeb17	=[	$meleeb17,	cguard_meleeb18	] {}
void()	cguard_meleeb18	=[	$meleeb18,	cguard_run1		] {}

//============================================================================

void()	cguard_pain1	=[	$pain1,		cguard_pain2	] {ai_pain(-11);}
void()	cguard_pain2	=[	$pain2,		cguard_pain3	] {cguard_pain_sound();}
void()	cguard_pain3	=[	$pain3,		cguard_pain4	] {}
void()	cguard_pain4	=[	$pain4,		cguard_pain5	] {}
void()	cguard_pain5	=[	$pain5,		cguard_pain6	] {}
void()	cguard_pain6	=[	$pain6,		cguard_pain7	] {ai_pain(2);}
void()	cguard_pain7	=[	$pain7,		cguard_run1		] {ai_pain(2);}

//============================================================================

void()	cguard_death1	=[	$death1,	cguard_death2	] {}
void()	cguard_death2	=[	$death2,	cguard_death3	] {}
void()	cguard_death3	=[	$death3,	cguard_death4	] {}
void()	cguard_death4	=[	$death4,	cguard_death5	] {cguard_death_sound();}
void()	cguard_death5	=[	$death5,	cguard_death6	] {}
void()	cguard_death6	=[	$death6,	cguard_death7	] {}
void()	cguard_death7	=[	$death7,	cguard_death8	] {}
void()	cguard_death8	=[	$death8,	cguard_death9	] {self.solid = SOLID_NOT;}
void()	cguard_death9	=[	$death9,	cguard_death10	] {}
void()	cguard_death10	=[	$death10,	cguard_death11	] {}
void()	cguard_death11	=[	$death11,	cguard_death12	] {}
void()	cguard_death12	=[	$death12,	cguard_death12	] {}

void()	cguard_deathb1	=[	$deathb1,	cguard_deathb2	] {}
void()	cguard_deathb2	=[	$deathb2,	cguard_deathb3	] {}
void()	cguard_deathb3	=[	$deathb3,	cguard_deathb4	] {}
void()	cguard_deathb4	=[	$deathb4,	cguard_deathb5	] {}
void()	cguard_deathb5	=[	$deathb5,	cguard_deathb6	] {cguard_death_sound();}
void()	cguard_deathb6	=[	$deathb6,	cguard_deathb7	] {}
void()	cguard_deathb7	=[	$deathb7,	cguard_deathb8	] {}
void()	cguard_deathb8	=[	$deathb8,	cguard_deathb9	] {}
void()	cguard_deathb9	=[	$deathb9,	cguard_deathb10	] {}
void()	cguard_deathb10	=[	$deathb10,	cguard_deathb11	] {}
void()	cguard_deathb11	=[	$deathb11,	cguard_deathb12	] {}
void()	cguard_deathb12	=[	$deathb12,	cguard_deathb13	] {}
void()	cguard_deathb13	=[	$deathb13,	cguard_deathb14	] {}
void()	cguard_deathb14	=[	$deathb14,	cguard_deathb15	] {self.solid = SOLID_NOT;}
void()	cguard_deathb15	=[	$deathb15,	cguard_deathb16	] {}
void()	cguard_deathb16	=[	$deathb16,	cguard_deathb17	] {}
void()	cguard_deathb17	=[	$deathb17,	cguard_deathb17	] {}

void() cguard_die =
{
// check for gib
	if (self.health < -80)
	{
		//	Gib
		return;
	}

	if (random() > 0.5)
		cguard_death1();
	else
		cguard_deathb1();
}

void() cguard_pain_go =
{
	cguard_pain1 ();
	PainFinished(4);
}

void(entity attacker, float damage)	cguard_pain =
{
	
	if (self.pain_finished > time)
		return;

	if (time - self.pain_finished > 20)
	{	// always go into pain frame if it has been a while
		cguard_pain_go();
		return;
	}
	
	if ( ( random() < 0.2 ) )
		return;		// didn't flinch
	
	if ( ( random()*30 > damage ) )
		return;		// didn't flinch

	cguard_pain_go();
}

void() cguard_melee =
{
	if (random() < 0.5 )
		cguard_melee1 ();
	else
		cguard_meleeb1 ();
}


void() monster_cguard_spawn =
{
	self.classname = "monster_cguard";
		
	self.solid = SOLID_SLIDEBOX;

	setmodel (self, "progs/cguard.mdl");

	setsize (self, '-16 -16 -24', '16 16 40');

	self.th_stand = cguard_stand1;
	self.th_walk = cguard_walk1;
	self.th_run = cguard_run1;
	self.th_melee = cguard_melee;
	self.th_missile = cguard_attack1;
	self.th_pain = cguard_pain;
	self.th_die = cguard_die;
	self.th_checkattack = CheckAttack;
	
	self.yaw_speed = 30;

	if (self.deathtype == string_null)
		self.deathtype = "was crystalized by Guard";

	walkmonster_start ();
}

void() monster_cguard_spawner = {mon_spawner_use(monster_cguard_spawn);}

/*QUAKED monster_cguard (1 0 0) (-16 -16 -24) (16 16 40) AMBUSH ? ? ? TRIGGERED NOTFOG NOTELEFRAG INSTAWAKE
Crystalline Guard, 250 health points.

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
@PointClass base(Monster) size(-16 -16 -24, 16 16 40) model({ "path": ":progs/cguard.mdl" }) = monster_cguard : "Crystalline Guard:" []
*/
void() monster_cguard =
{
	if (!SUB_ShouldSpawn()) return;
	if (nomonster()) return;
	if (deathmatch)
	{
		remove(self);
		return;
	}
	
	precache_model2 ("progs/cguard.mdl");
	precache_model2 ("progs/laser.mdl");
	
	precache_sound2 ("cguard/death1.wav");
	precache_sound2 ("cguard/death2.wav");
	precache_sound2 ("cguard/idle.wav");
	precache_sound2 ("cguard/injure1.wav");
	precache_sound2 ("cguard/injure2.wav");
	precache_sound2 ("cguard/laser.wav");
	precache_sound2 ("cguard/laserhit.wav");
	precache_sound2 ("cguard/melee1.wav");
	precache_sound2 ("cguard/meleeswing.wav");
	precache_sound2 ("cguard/sight1.wav");
	precache_sound2 ("cguard/sight2.wav");
	precache_sound2 ("cguard/sight3.wav");
	precache_sound2 ("cguard/sight4.wav");
	
	self.health = 250;
	setsize (self, '-16 -16 -24', '16 16 40');
	if ( monster_spawnsetup( monster_cguard_spawner ) ) return;
	
	addmonster(1);
	monster_cguard_spawn();
}
