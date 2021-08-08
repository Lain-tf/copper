/*
==============================================================================

Brute

==============================================================================
*/

$cd id1/models/brute_c
$origin 0 0 24
$base base		
$skin base

$frame stand_a1 stand_a2 stand_a3 stand_a4 stand_a5 stand_a6 stand_a7 stand_a8
$frame stand_b1 stand_b2 stand_b3 stand_b4 stand_b5 stand_b6 stand_b7 stand_b8 stand_b9 stand_b10 stand_b11 stand_b12 stand_b13 stand_b14 stand_b15 stand_b16 stand_b17 stand_b18

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10 walk11 walk12 walk13 walk14 walk15 walk16 walk17 walk18 walk19 walk20 walk21 walk22 walk23
$frame run1 run2 run3 run4 run5 run6 run7 run8 run9 run10

$frame attack_a1 attack_a2 attack_a3 attack_a4 attack_a5 attack_a6 attack_a7 attack_a8 attack_a9 attack_a10
$frame attack_a11 attack_a12 attack_a13 attack_a14 attack_a15 attack_a16 attack_a17 attack_a18 attack_a19 attack_a20
$frame attack_a21 attack_a22 attack_a23 attack_a24 attack_a25 attack_a26 attack_a27 attack_a28 attack_a29 attack_a30
$frame attack_a31 attack_a32

$frame attack_b1 attack_b2 attack_b3 attack_b4 attack_b5 attack_b6 attack_b7 attack_b8 attack_b9 attack_b10
$frame attack_b11 attack_b12 attack_b13 attack_b14 attack_b15 attack_b16 attack_b17 attack_b18 attack_b19 attack_b20
$frame attack_b21 attack_b22 attack_b23 attack_b24 attack_b25 attack_b26 attack_b27 attack_b28 attack_b29 attack_b30
$frame attack_b31 attack_b32 attack_b33 attack_b34 attack_b35

$frame melee_a1 melee_a2 melee_a3 melee_a4 melee_a5 melee_a6 melee_a7 melee_a8 melee_a9 melee_a10
$frame melee_b1 melee_b2 melee_b3 melee_b4 melee_b5 melee_b6 melee_b7 melee_b8 melee_b9 melee_b10 melee_b11 melee_b12 melee_b13

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9 death10 death11 death12 death13

$frame pain1 pain2 pain3 pain4 pain5 pain6 pain7 pain8 pain9

//=============================================================================

void() BruteGrenadeExplode =
{
	T_RadiusDamage (self, self.trueowner, 40, world);
	sound (self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);
	
	BecomeExplosion();
}

void() BruteGrenadeTouch =
{
	if (other == self.owner) return;		// don't explode on owner
	if (CheckProjectilePassthru()) return;

	if (other.takedamage == DAMAGE_AIM)
	{
		if (other.type == "zombie")
			T_Damage (other, self, self.trueowner, other.health + 25);
		BruteGrenadeExplode();
		return;
	}
	sound (self, CHAN_VOICE, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
}

/*
================
BruteAimGrenade

Like OgreAimGrenade but with the option to "spray" the grenade - i.e. deliberately
not aim it directly at the player.
================
*/
vector(vector dest, float speed, float spray_angle) BruteAimGrenade =
{
	float theta, a;
	vector angs;
	
	theta = BallisticTheta(dest,speed,18);		// stock quake ogre firing angle is 18
	if (theta == BAD_THETA) theta = 18;
	
	a = vectoyaw(dest);
	angs = '0 0 0';
	angs_y = a + spray_angle;
	// Similar partially-z-aware aiming as the ogre (see OgreAimGrenade),
	// but we weight the 'ideal' angle more heavily (2:1 rather than 1:1),
	// to give more z-awareness
	if (vlen(dest) < 160)
		theta = clamp(theta, -80, 70);
	else
		theta = clamp(theta, -60, 60);
	theta = (theta * 2 + 18) / 3;

	angs_x = -theta;	
	makevectors(angs);
	
	return v_forward * speed;
}


/*
================
BruteFireGrenade
================
*/

float BRUTE_GRENADE_SEQUENCE_A_LEFT = 1;
float BRUTE_GRENADE_SEQUENCE_A_RIGHT = 2;
float BRUTE_GRENADE_SEQUENCE_B = 3;

void(float sequence, float spray) BruteFireGrenade =
{
	local	entity g;
	vector gorg, gvel;
	float spray_angle;
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, "brute/shoot.wav", 1, ATTN_NORM);

	// If we're spraying the grenade, add some random amount of extra yaw.
	spray_angle = 0;
	if (spray) {
		// -5-25 degrees spray
		spray_angle = -5 + random() * 30;
	}

	makevectors(self.angles);
	switch (sequence) {
	case BRUTE_GRENADE_SEQUENCE_A_LEFT:
		gorg = self.origin + v_forward * 100 + v_up * 40 - v_right * 25;
		break;

	case BRUTE_GRENADE_SEQUENCE_A_RIGHT:
		gorg = self.origin + v_forward * 100 + v_up * 37 + v_right * 21;
		spray_angle = spray_angle * -1;
		break;

	case BRUTE_GRENADE_SEQUENCE_B:
		gorg = self.origin + v_forward * 80 + v_up * 20 - v_right * 25;

		// Spray both left and right
		if (random() < 0.5) {
			spray_angle = spray_angle * -1;
		}
		break;

	default:
		gorg = self.origin;
	}

	gvel = BruteAimGrenade(enemy_vispos() - gorg, 632, spray_angle);
	
	g = launch_grenade(gorg, gvel);
	g.touch = BruteGrenadeTouch;
	g.th_die = BruteGrenadeExplode;
}



void() brute_dropammo =
{
	self.ammo_rockets = 3;
	DropBackpack();
}


//=============================================================================

/*
================
brute_punch

The brute melee attack
================
*/
void() brute_punch =
{
	local vector	delta;
	local float 	ldmg;

	if (!self.enemy)
		return;

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 100)
		return;
	if (!CanDamage (self.enemy, self.origin))
		return;
		
	ldmg = (random() + random() + random()) * 40;
	T_DamageMelee(self.enemy, self, ldmg);
	sound (self, CHAN_VOICE, "shambler/smack.wav", 1, ATTN_NORM);

	SpawnMeatSpray (self.origin + v_forward*16, crandom() * 100 * v_right);
	SpawnMeatSpray (self.origin + v_forward*16, crandom() * 100 * v_right);
}

/* Stand A */
void() brute_standa1 =[ 	$stand_a1, brute_standa2	] {ai_stand();}
void() brute_standa2 =[ 	$stand_a2, brute_standa3	] {ai_stand();}
void() brute_standa3 =[ 	$stand_a3, brute_standa4	] {ai_stand();}
void() brute_standa4 =[ 	$stand_a4, brute_standa5	] {ai_stand();}
void() brute_standa5 =[ 	$stand_a5, brute_standa6	] {
	if (random() < 0.2) {
		sound(self, CHAN_VOICE, "brute/idle1.wav", 1, ATTN_IDLE);
	}
	ai_stand();
}
void() brute_standa6 =[ 	$stand_a6, brute_standa7	] {ai_stand();}
void() brute_standa7 =[ 	$stand_a7, brute_standa8	] {ai_stand();}
void() brute_standa8 =[ 	$stand_a8, brute_stand		] {ai_stand();}

/* Stand B */
void() brute_standb1 =[ 	$stand_b1, brute_standb2	] {ai_stand();}
void() brute_standb2 =[ 	$stand_b2, brute_standb3	] {ai_stand();}
void() brute_standb3 =[ 	$stand_b3, brute_standb4	] {ai_stand();}
void() brute_standb4 =[ 	$stand_b4, brute_standb5	] {ai_stand();}
void() brute_standb5 =[ 	$stand_b5, brute_standb6	] {
	if (random() < 0.2) {
		sound(self, CHAN_VOICE, "brute/idle2.wav", 1, ATTN_IDLE);
	}
	ai_stand();
}
void() brute_standb6 =[ 	$stand_b6, brute_standb7	] {ai_stand();}
void() brute_standb7 =[ 	$stand_b7, brute_standb8	] {ai_stand();}
void() brute_standb8 =[ 	$stand_b8, brute_standb9	] {ai_stand();}
void() brute_standb9 =[ 	$stand_b9, brute_standb10	] {ai_stand();}
void() brute_standb10 =[ 	$stand_b10, brute_standb11	] {ai_stand();}
void() brute_standb11 =[ 	$stand_b11, brute_standb12	] {ai_stand();}
void() brute_standb12 =[ 	$stand_b12, brute_standb13	] {ai_stand();}
void() brute_standb13 =[ 	$stand_b13, brute_standb14	] {ai_stand();}
void() brute_standb14 =[ 	$stand_b14, brute_standb15	] {ai_stand();}
void() brute_standb15 =[ 	$stand_b15, brute_standb16	] {ai_stand();}
void() brute_standb16 =[ 	$stand_b16, brute_standb17	] {ai_stand();}
void() brute_standb17 =[ 	$stand_b17, brute_standb18	] {ai_stand();}
void() brute_standb18 =[ 	$stand_b18, brute_stand	] {ai_stand();}

void() brute_stand {
	if (random() < 0.2) {
		brute_standb1();
	} else {
		brute_standa1();
	}
}

/* Walk */
void() brute_walk1	=[	$walk1,		brute_walk2		] { ai_walk(6); }
void() brute_walk2	=[	$walk2,		brute_walk3		] { ai_walk(6); }
void() brute_walk3	=[	$walk3,		brute_walk4		] { ai_walk(6); }
void() brute_walk4	=[	$walk4,		brute_walk5		] { ai_walk(6); }
void() brute_walk5	=[	$walk5,		brute_walk6		] { ai_walk(6); }
void() brute_walk6	=[	$walk6,		brute_walk7		] { ai_walk(6); }
void() brute_walk7	=[	$walk7,		brute_walk8		] {
	if (random() < 0.5) {
		sound (self, CHAN_VOICE, "brute/walk1.wav", 1, ATTN_IDLE);
	} else {
		sound (self, CHAN_VOICE, "brute/walk2.wav", 1, ATTN_IDLE);
	}
	ai_walk(6); 
}
void() brute_walk8	=[	$walk8,		brute_walk9		] { ai_walk(5); }
void() brute_walk9	=[	$walk9,		brute_walk10 	] { ai_walk(5); }
void() brute_walk10	=[	$walk10,	brute_walk11	] { ai_walk(5); }
void() brute_walk11	=[	$walk11,	brute_walk12	] { ai_walk(5); }
void() brute_walk12	=[	$walk12,	brute_walk13	] { ai_walk(5); }
void() brute_walk13	=[	$walk13,	brute_walk14	] { ai_walk(5); }
void() brute_walk14	=[	$walk14,	brute_walk15	] { ai_walk(5); }
void() brute_walk15	=[	$walk15,	brute_walk16	] { ai_walk(5); }
void() brute_walk16	=[	$walk16,	brute_walk17	] { ai_walk(5); }
void() brute_walk17	=[	$walk17,	brute_walk18	] { ai_walk(5); }
void() brute_walk18	=[	$walk18,	brute_walk19	] {
	if (random() < 0.5) {
		sound (self, CHAN_VOICE, "brute/walk1.wav", 1, ATTN_IDLE);
	} else {
		sound (self, CHAN_VOICE, "brute/walk2.wav", 1, ATTN_IDLE);
	}
	ai_walk(5);
}
void() brute_walk19	=[	$walk19,	brute_walk20	] { ai_walk(6); }
void() brute_walk20	=[	$walk20,	brute_walk21	] { ai_walk(6); }
void() brute_walk21	=[	$walk21,	brute_walk22	] { ai_walk(6); }
void() brute_walk22	=[	$walk22,	brute_walk23	] { ai_walk(6); }
void() brute_walk23	=[	$walk23,	brute_walk1		] { ai_walk(6); }

/* Run */
void() brute_run1	=[	$run1,		brute_run2	] {ai_run(1);}
void() brute_run2	=[	$run2,		brute_run3	] {ai_run(16);}
void() brute_run3	=[	$run3,		brute_run4	] {ai_run(11);}
void() brute_run4	=[	$run4,		brute_run5	] {ai_run(1);}
void() brute_run5	=[	$run5,		brute_run6	] {ai_run(11);}
void() brute_run6	=[	$run6,		brute_run7	] {ai_run(6);}
void() brute_run7	=[	$run7,		brute_run8	] {ai_run(6);}
void() brute_run8	=[	$run8,		brute_run9	] {ai_run(24);}
void() brute_run9	=[	$run8,		brute_run10	] {ai_run(10);}
void() brute_run10	=[	$run8,		brute_run1	] {ai_run(2);}

/* Pain */
void() brute_pain1	=[	$pain1,		brute_pain2	] {}
void() brute_pain2	=[	$pain2,		brute_pain3	] {}
void() brute_pain3	=[	$pain3,		brute_pain4	] {}
void() brute_pain4	=[	$pain4,		brute_pain5	] {}
void() brute_pain5	=[	$pain5,		brute_pain6	] {}
void() brute_pain6	=[	$pain6,		brute_pain7	] {}
void() brute_pain7	=[	$pain7,		brute_pain8	] {}
void() brute_pain8	=[	$pain8,		brute_pain9	] {}
void() brute_pain9	=[	$pain9,		brute_run1	] {}

/* Die */
void()	brute_die1	=[	$death1,	brute_die2	] {}
void()	brute_die2	=[	$death2,	brute_die3	] {}
void()	brute_die3	=[	$death3,	brute_die4	] {
	self.solid = SOLID_NOT;
	brute_dropammo();
}
void()	brute_die4	=[	$death4,	brute_die5	] {}
void()	brute_die5	=[	$death5,	brute_die6	] {}
void()	brute_die6	=[	$death6,	brute_die7	] {}
void()	brute_die7	=[	$death7,	brute_die8	] {}
void()	brute_die8	=[	$death8,	brute_die9	] {}
void()	brute_die9	=[	$death9,	brute_die10	] {}
void()	brute_die10	=[	$death10,	brute_die11	] {}
void()	brute_die11	=[	$death11,	brute_die12	] {}
void()	brute_die12	=[	$death12,	brute_die13	] {}
void()	brute_die13	=[	$death13,	brute_die13	] {PostDeathLogic();}

/* Melee */
void() brute_meleea1	=[	$melee_a1, brute_meleea2 	] {ai_charge(0);}
void() brute_meleea2	=[	$melee_a2, brute_meleea3 	] {ai_charge(0);}
void() brute_meleea3	=[	$melee_a3, brute_meleea4 	] {
	ai_charge(4);
	sound (self, CHAN_VOICE, "brute/meleeswing.wav", 1, ATTN_NORM);
}
void() brute_meleea4	=[	$melee_a4, brute_meleea5 	] {
	ai_charge(2);
	brute_punch();
}
void() brute_meleea5	=[	$melee_a5, brute_meleea6 	] {ai_charge(2);}
void() brute_meleea6	=[	$melee_a6, brute_meleea7 	] {ai_charge(0);}
void() brute_meleea7	=[	$melee_a7, brute_meleea8 	] {ai_charge(0);}
void() brute_meleea8	=[	$melee_a8, brute_meleea9 	] {ai_charge(0);}
void() brute_meleea9	=[	$melee_a9, brute_meleea10 	] {ai_charge(0);}
void() brute_meleea10	=[	$melee_a10, brute_run1	 	] {
	ai_charge(0);
	ai_attack_finished(1 + 2*random());
}

void() brute_meleeb1	=[	$melee_b1, brute_meleeb2 	] {ai_charge(0);}
void() brute_meleeb2	=[	$melee_b2, brute_meleeb3 	] {ai_charge(0);}
void() brute_meleeb3	=[	$melee_b3, brute_meleeb4 	] {ai_charge(0);}
void() brute_meleeb4	=[	$melee_b4, brute_meleeb5 	] {ai_charge(0);}
void() brute_meleeb5	=[	$melee_b5, brute_meleeb6 	] {ai_charge(0);}
void() brute_meleeb6	=[	$melee_b6, brute_meleeb7 	] {
	ai_charge(4);
	sound (self, CHAN_VOICE, "brute/meleeswing.wav", 1, ATTN_NORM);
}
void() brute_meleeb7	=[	$melee_b7, brute_meleeb8 	] {ai_charge(3);}
void() brute_meleeb8	=[	$melee_b8, brute_meleeb9 	] {
	ai_charge(2);
	brute_punch();
}
void() brute_meleeb9	=[	$melee_b9, brute_meleeb10 	] {ai_charge(1);}
void() brute_meleeb10	=[	$melee_b10, brute_meleeb11	] {ai_charge(0);}
void() brute_meleeb11	=[	$melee_b11, brute_meleeb12	] {ai_charge(0);}
void() brute_meleeb12	=[	$melee_b12, brute_meleeb13	] {ai_charge(0);}
void() brute_meleeb13	=[	$melee_b13, brute_run1		] {
	ai_charge(0);
	ai_attack_finished(1 + 2*random());
}

/* Grenades */
void() brute_grena1 	=[	$attack_a1,		brute_grena2	] {ai_face();}
void() brute_grena2		=[	$attack_a2,		brute_grena3	] {ai_face();}
void() brute_grena3		=[	$attack_a3,		brute_grena4	] {ai_face();}
void() brute_grena4		=[	$attack_a4,		brute_grena5	] {ai_face();}
void() brute_grena5		=[	$attack_a5,		brute_grena6	] {ai_face();}
void() brute_grena6		=[	$attack_a6,		brute_grena7	] {ai_face();}
void() brute_grena7		=[	$attack_a7,		brute_grena8	] {ai_face();}
void() brute_grena8		=[	$attack_a8,		brute_grena9	] {ai_face();}
void() brute_grena9		=[	$attack_a9,		brute_grena10	] {ai_face();}
void() brute_grena10	=[	$attack_a10,	brute_grena11	] {ai_face();}
void() brute_grena11	=[	$attack_a11,	brute_grena12	] {ai_face();}
void() brute_grena12	=[	$attack_a12,	brute_grena13	] {
	ai_face();
	BruteFireGrenade(BRUTE_GRENADE_SEQUENCE_A_LEFT, FALSE);
}
void() brute_grena13	=[	$attack_a13,	brute_grena14	] {
	ai_face();
	BruteFireGrenade(BRUTE_GRENADE_SEQUENCE_A_LEFT, TRUE);
}
void() brute_grena14	=[	$attack_a14,	brute_grena15	] {
	ai_face();
	BruteFireGrenade(BRUTE_GRENADE_SEQUENCE_A_LEFT, TRUE);
}
void() brute_grena15	=[	$attack_a15,	brute_grena16	] {ai_face();}
void() brute_grena16	=[	$attack_a16,	brute_grena17	] {ai_face();}
void() brute_grena17	=[	$attack_a17,	brute_grena18	] {ai_face();}
void() brute_grena18	=[	$attack_a18,	brute_grena19	] {ai_face();}
void() brute_grena19	=[	$attack_a19,	brute_grena20	] {ai_face();}
void() brute_grena20	=[	$attack_a20,	brute_grena21	] {ai_face();}
void() brute_grena21	=[	$attack_a21,	brute_grena22	] {ai_face();}
void() brute_grena22	=[	$attack_a22,	brute_grena23	] {ai_face();}
void() brute_grena23	=[	$attack_a23,	brute_grena24	] {
	ai_face();
	BruteFireGrenade(BRUTE_GRENADE_SEQUENCE_A_RIGHT, FALSE);
}
void() brute_grena24	=[	$attack_a24,	brute_grena25	] {
	ai_face();
	BruteFireGrenade(BRUTE_GRENADE_SEQUENCE_A_RIGHT, TRUE);
}
void() brute_grena25	=[	$attack_a25,	brute_grena26	] {
	ai_face();
	BruteFireGrenade(BRUTE_GRENADE_SEQUENCE_A_RIGHT, TRUE);
}
void() brute_grena26	=[	$attack_a26,	brute_grena27	] {ai_face();}
void() brute_grena27	=[	$attack_a27,	brute_grena28	] {ai_face();}
void() brute_grena28	=[	$attack_a28,	brute_grena29	] {ai_face();}
void() brute_grena29	=[	$attack_a29,	brute_grena30	] {ai_face();}
void() brute_grena30	=[	$attack_a30,	brute_grena31	] {ai_face();}
void() brute_grena31	=[	$attack_a31,	brute_grena32	] {ai_face();}
void() brute_grena32	=[	$attack_a32,	brute_run1		] {
	ai_face();
	ai_attack_finished(1 + 2*random());
}

void() brute_grenb1 	=[	$attack_b1,		brute_grenb2	] {ai_face();}
void() brute_grenb2		=[	$attack_b2,		brute_grenb3	] {ai_face();}
void() brute_grenb3		=[	$attack_b3,		brute_grenb4	] {ai_face();}
void() brute_grenb4		=[	$attack_b4,		brute_grenb5	] {ai_face();}
void() brute_grenb5		=[	$attack_b5,		brute_grenb6	] {ai_face();}
void() brute_grenb6		=[	$attack_b6,		brute_grenb7	] {ai_face();}
void() brute_grenb7		=[	$attack_b7,		brute_grenb8	] {ai_face();}
void() brute_grenb8		=[	$attack_b8,		brute_grenb9	] {ai_face();}
void() brute_grenb9		=[	$attack_b9,		brute_grenb10	] {ai_face();}
void() brute_grenb10	=[	$attack_b10,	brute_grenb11	] {ai_face();}
void() brute_grenb11	=[	$attack_b11,	brute_grenb12	] {
	ai_face();
	BruteFireGrenade(BRUTE_GRENADE_SEQUENCE_B, FALSE);
}
void() brute_grenb12	=[	$attack_b12,	brute_grenb13	] {
	ai_face();
	BruteFireGrenade(BRUTE_GRENADE_SEQUENCE_B, TRUE);
}
void() brute_grenb13	=[	$attack_b13,	brute_grenb14	] {
	ai_face();
	BruteFireGrenade(BRUTE_GRENADE_SEQUENCE_B, TRUE);
}
void() brute_grenb14	=[	$attack_b14,	brute_grenb15	] {ai_face();}
void() brute_grenb15	=[	$attack_b15,	brute_grenb16	] {ai_face();}
void() brute_grenb16	=[	$attack_b16,	brute_grenb17	] {ai_face();}
void() brute_grenb17	=[	$attack_b17,	brute_grenb18	] {ai_face();}
void() brute_grenb18	=[	$attack_b18,	brute_grenb19	] {ai_face();}
void() brute_grenb19	=[	$attack_b19,	brute_grenb20	] {ai_face();}
void() brute_grenb20	=[	$attack_b20,	brute_grenb21	] {ai_face();}
void() brute_grenb21	=[	$attack_b21,	brute_grenb22	] {
	ai_face();
	BruteFireGrenade(BRUTE_GRENADE_SEQUENCE_B, FALSE);
}
void() brute_grenb22	=[	$attack_b22,	brute_grenb23	] {
	ai_face();
	BruteFireGrenade(BRUTE_GRENADE_SEQUENCE_B, TRUE);
}
void() brute_grenb23	=[	$attack_b23,	brute_grenb24	] {
	ai_face();
	BruteFireGrenade(BRUTE_GRENADE_SEQUENCE_B, TRUE);
}
void() brute_grenb24	=[	$attack_b24,	brute_grenb25	] {ai_face();}
void() brute_grenb25	=[	$attack_b25,	brute_grenb26	] {ai_face();}
void() brute_grenb26	=[	$attack_b26,	brute_grenb27	] {ai_face();}
void() brute_grenb27	=[	$attack_b27,	brute_grenb28	] {ai_face();}
void() brute_grenb28	=[	$attack_b28,	brute_grenb29	] {ai_face();}
void() brute_grenb29	=[	$attack_b29,	brute_grenb30	] {ai_face();}
void() brute_grenb30	=[	$attack_b30,	brute_grenb31	] {ai_face();}
void() brute_grenb31	=[	$attack_b31,	brute_grenb32	] {ai_face();}
void() brute_grenb32	=[	$attack_b32,	brute_grenb33	] {ai_face();}
void() brute_grenb33	=[	$attack_b33,	brute_grenb34	] {ai_face();}
void() brute_grenb34	=[	$attack_b34,	brute_grenb35	] {ai_face();}
void() brute_grenb35	=[	$attack_b35,	brute_run1		] {
	ai_face();
	ai_attack_finished(1 + 2*random());
}

/*
===========
BruteCheckAttack

The player is in view, so decide to move or launch an attack
Returns FALSE if movement should continue
============
*/
float() BruteCheckAttack =
{
	if (enemy_range == RANGE_MELEE && z_overlap(self.enemy))
	{
		if (CanDamage (self.enemy, self.origin))
		{
			self.attack_state = AS_MELEE;
			return TRUE;
		}
	}

	if (time < self.attack_finished)
		return FALSE;
	
	if (!enemy_vis)
		return FALSE;
	
	// randomly attack with the brute_punch if enemy has the ring of shadows
	if (has_invis(self.enemy))
	{
		if (random() < 0.2)
		{
			self.attack_state = AS_MELEE;
			return TRUE;
		}
	}
		
	if (!CheckClearAttack()) return FALSE;
	
	// missile attack
	if (time < self.attack_finished)
		return FALSE;

	if (enemy_range == RANGE_TOOFAR || enemy_range == RANGE_FAR)
		return FALSE;	// too far for grenades

	self.attack_state = AS_MISSILE;
	return TRUE;
}

void(entity attacker, float damage)	brute_pain =
{	if (self.health <= 0) {
		return;
	}

	// don't make multiple pain sounds right after each other
	if (self.pain_finished > time) {
		return;
	}

	if (random() * 400 > damage) {
		// didn't flinch
		return;
	}	

	if (random() < 0.5) {
		sound(self, CHAN_VOICE, "brute/injure1.wav", 1, ATTN_NORM);
	} else {
		sound(self, CHAN_VOICE, "brute/injure2.wav", 1, ATTN_NORM);
	}
	brute_pain1();
}

void() brute_die =
{
	// check for gib
	if (self.health < -100)
	{
		Gib ("progs/h_brute.mdl", self.health);
		return;
	}

	if (random() < 0.5)	{
		sound(self, CHAN_VOICE, "brute/death1.wav", 1, ATTN_NORM);
	} else {
		sound(self, CHAN_VOICE, "brute/death2.wav", 1, ATTN_NORM);
	}
	brute_die1();
}

void() brute_melee =
{
	if (random() > 0.5) {
		brute_meleea1();
	} else {
		brute_meleeb1();
	}
}

void() brute_gren =
{
	if (random() < 0.1) {
		brute_grenb1();
	} else {
		brute_grena1();
	}
}

//=============================================================================

void() monster_brute_spawn =
{
	self.classname = "monster_brute";
	self.type = "brute";
	
	self.solid = SOLID_SLIDEBOX;

	setmodel (self, "progs/cbrute.mdl");

	self.health = 700;
	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);	

	self.th_stand = brute_standa1;
	self.th_walk = brute_walk1;
	self.th_run = brute_run1;
	self.th_die = brute_die;
	self.th_melee = brute_melee;
	self.th_missile = brute_gren;
	self.th_pain = brute_pain;
	self.th_checkattack = BruteCheckAttack;

	if (self.deathtype == string_null)
		self.deathtype = "was bopped by a Brute";

	walkmonster_start();
}

void() monster_brute_spawner = {mon_spawner_use(monster_brute_spawn);}

/*QUAKED monster_brute (1 0 0) (-32 -32 -24) (32 32 40) AMBUSH ? ? ? TRIGGERED NOTFOG NOTELEFRAG INSTAWAKE
Brute, 700 health points.

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
@PointClass base(Monster) size(-32 -32 -24, 32 32 64) model({ "path": ":progs/ogre.mdl" }) = monster_ogre : "Ogre" []
*/
void() monster_brute =
{
	if (!SUB_ShouldSpawn()) return;
	if (nomonster()) return;
	if (deathmatch)
	{
		remove(self);
		return;
	}

	precache_model ("progs/cbrute.mdl");
	precache_model ("progs/h_brute.mdl");
	precache_model ("progs/grenade.mdl");

	precache_sound ("brute/death1.wav");
	precache_sound ("brute/death2.wav");
	precache_sound ("brute/deaththump.wav");
	precache_sound ("brute/idle1.wav");
	precache_sound ("brute/idle2.wav");
	precache_sound ("brute/injure1.wav");
	precache_sound ("brute/injure2.wav");
	precache_sound ("brute/meleeswing.wav");
	precache_sound ("brute/shoot.wav");
	precache_sound ("brute/sight1.wav");
	precache_sound ("brute/sight2.wav");
	precache_sound ("brute/walk1.wav");
	precache_sound ("brute/walk2.wav");
	precache_sound ("shambler/smack.wav");
	
	self.health = 700;
	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	if (monster_spawnsetup( monster_brute_spawner )) {
        return;
    }
	
	addmonster(1);
	monster_brute_spawn();
}
