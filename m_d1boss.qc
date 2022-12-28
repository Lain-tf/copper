/*
==============================================================================

Ep. 1 Boss

==============================================================================
*/

// FRAME MACROSES 
//----------------------------------------------------------------------

$cd id1/models/mon_d1boss
$origin 0 0 24
$base base		
$skin base

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13 stand14 stand15 stand16 stand17
$frame stand18 stand19 stand20 stand21 stand22 stand23

$frame swingr1 swingr2 swingr3 swingr4 swingr5 
$frame swingr6 swingr7 swingr8 swingr9

$frame swingl1 swingl2 swingl3 swingl4 swingl5 
$frame swingl6 swingl7 swingl8 swingl9

$frame big1 big2 big3 big4 big5 
$frame big6 big7 big8 big9 big10
$frame big11 big12 big13 big14 big15 big16
$frame big17 big18 big19 big20 big21 big22
$frame big23 big24

$frame chan1 chan2 chan3 chan4 chan5 
$frame chan6 chan7 chan8 chan9 chan10
$frame chan11 chan12 chan13 chan14 chan15 chan16
$frame chan17 chan18 chan19 chan20 chan21 chan22
$frame chan23 chan24

$frame phase1 phase2 phase3 phase4 phase5 
$frame phase6 phase7 phase8 phase9 phase10
$frame phase11 phase12 phase13 phase14 phase15 phase16
$frame phase17 phase18 phase19 phase20 phase21 phase22
$frame phase23 phase24 phase25 phase26 phase27 phase28
$frame phase29 phase30 phase31 phase32 phase33 phase34 phase35

//----------------------------------------------------------------------

const float D1BOSS_BALL_VEL = 750;
const float D1BOSS_HEALTH = 1400; 
const vector D1BOSS_GIBOFFSET = '0 0 112';
.float	track_finished;
.float	boss_attacksleft;
.float	boss_lastattack;


//offset for gibs
entity(string gibname, float dm, vector offset) ThrowGibBoss =
{
	local entity gib;

	// gibs have to be thinking ballistic projectiles to pass through monsterclip/notrace :(
	gib = toss_projectile(self.origin + offset, GibVelocityForHealth(dm), "gib");
	MakeGib(gib, gibname);
	
	return gib;
};

float() D1BossCheckAttack = 
{
	local vector enemy_org, self_org;

	// Check Melee range without respect to height
	enemy_org = self.enemy.origin;
	self_org = self.origin;
	enemy_org_z = self_org_z;
	
	if ( vlen(self_org - enemy_org) < RANGE_MELEE && self.origin_z >= self.enemy.origin_z )
	{
		self.attack_state = AS_MELEE;
		return TRUE;		
	}

	// Only range attack if cooldown has finished
	if ( time > self.attack_finished ) 
	{
		self.attack_state = AS_MISSILE;
		return TRUE;
	}

	// Maintain distance (strafe)
	if ( (enemy_range >= RANGE_MID) || !enemy_vis ) 
		if ( self.attack_state != AS_STRAIGHT ) //hmmmm?
			self.attack_state = AS_STRAIGHT;
	else 
		self.attack_state = AS_SLIDING;
	
	return FALSE;
};


void() D1BossMissileExplode =
{
	local float skill_damage;
	
	if ( skill > 1 || coop )
		skill_damage = 55;
	else if ( skill == 1)
		skill_damage = 35;
	else 
		skill_damage = 25;
	
	T_RadiusDamage (self, self.trueowner, skill_damage, world);
	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);

	BecomeExplosion();
};


void() D1BossMissileTouch =
{
	if ( CheckProjectilePassthru() ) 
		return;
	
	if ( other == self.owner )
		return;		// don't explode on owner

	if (other.type == "zombie")
		T_Damage (other, self, self.trueowner, other.health + 25);
	
	D1BossMissileExplode();
};


void() D1BossMissileHome =
{
	float rate, dot;
	
	if ( self.lifetime_finished < time )
	{
		D1BossMissileExplode();
		return;
	}
	
	if ( !enemy_alive() )
	{
		remove(self);
		return;
	}
	
	if ( self.track_finished < time )
		return;
		
	self.nextthink = time + SHAL_BALL_THINK_RATE;
	rate = SHAL_BALL_TURN_RATE;
	dot = normalize( self.velocity ) * normalize( self.enemy.origin - self.origin );
	self.owner = self.trueowner;

	if ( dot > 0 )
		rate *= max(1, 1.3 * (1 - dot));
	
	self.velocity = D1BOSS_BALL_VEL * ShalTurnToward( self.enemy, rate * 0.7 ); // 0.7
	self.think = D1BossMissileHome;
	self.oldvelocity = self.velocity;
};


void(float offset_side, float offset_up, float isdash) D1BossMissile =
{
	entity 	missile;
	vector	dir;
	local float toffset_side, toffset_up;
	local vector bossorg,playerorg;
	local float distcheck;
	local float dashmod;
	
	if (isdash)
		dashmod = 0.4;
	else 
		dashmod = 0.1;
	
	//self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors(self.angles);
	
	dir = LeadTarget( self.origin, D1BOSS_BALL_VEL, random() );
	dir = normalize( dir );
	 
	bossorg = self.origin;
	bossorg_z = 0;
	playerorg = self.enemy.origin;
	playerorg_z = 0;
	distcheck = vlen(bossorg - playerorg);
	//dprint3("distance to boss = ",ftos(distcheck),"\n");

	// if player has strafed around behind, don't lob the missile out of our ass
	if ( angledif(self.ideal_yaw, self.angles_y) > 80 )
	{
		dir_x = v_forward_x;
		dir_y = v_forward_y;
		dir = LeadTarget( self.origin, D1BOSS_BALL_VEL, 1 );
		dir = normalize( dir );
	}
	
	if (!offset_side)
	{
		toffset_side = 0;
		toffset_up = 0.3;
	}
	else if (offset_side > 0)
	{
		toffset_side = 1;
		toffset_up = 0;
	}
	else
	{
		toffset_side = -1;
		toffset_up = 0;
	}
	
	if (distcheck > 720) 
		distcheck = 0.5; // delay before we start homing
	else 
	{
		dashmod *= 0.5; // how wide our swing
		if (distcheck > 320) 
			distcheck = 0.25;
		else 
		{
			distcheck = 0.01;
			dashmod = 0;
		}
	}
	
	dir = dir + (v_up * toffset_up) + (v_right * toffset_side * dashmod);
	dir = normalize( dir );
	
	missile = launch_projectile( self.origin + (v_forward * 16) + (v_up * offset_up) + (v_right * offset_side) + '0 0 72', dir * D1BOSS_BALL_VEL, "voreball" );
	//missile = launch_projectile( self.origin + v_forward * 16 + v_up * crandom()*10 + v_right * crandom()*8 + '0 0 72', dir * D1BOSS_BALL_VEL, "voreball" );
	
	SUB_ChangeModel (missile, "progs/proj_d1boss.mdl");

	missile.avelocity = '300 300 300';
	missile.nextthink = time + distcheck;//0.35; // 0.2
	missile.think = D1BossMissileHome;
	missile.enemy = self.enemy;
	missile.touch = D1BossMissileTouch;
	missile.lifetime_finished = time + 5;	 // blow up after a while
	missile.track_finished = time + 1.25; // 1.25
	sound (self, CHAN_WEAPON, "d1boss/proj.wav", 1, ATTN_NORM);
};

/*
void() D1BossGrenade =
{
	entity 	missile;

	//self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors( [70, random() * 360, 0] );
		
	missile = toss_projectile( self.origin + '0 0 80', v_forward * 400 + v_up * 100, "bossgrenade" );
	SUB_ChangeModel (missile, "progs/proj_d1boss.mdl");

	missile.avelocity = '300 300 300';
	missile.nextthink = time + 0.2;
	missile.touch = D1BossMissileTouch;
	missile.lifetime_finished = time + 5;	 // blow up after a while
};
*/


void(float instant) d1boss_changeheight =
{
	if ( self.air_finished < time || instant ) 
	{
		self.height = ( self.distance * 0.25 ) + ( self.distance * 0.75 * random() );
		self.air_finished = time + 3;
	}
};


void(float dist, float toleft) boss_move =
{
	local float	ofs;
	
	self.ideal_yaw = enemy_yaw();
	ChangeYaw ();
	if (toleft)
		ofs = 90;
	else
		ofs = -90;
	
	if (walkmoveplus (self.ideal_yaw + ofs, dist))
		return;

	walkmoveplus (self.ideal_yaw - ofs, dist);
};

void() d1boss_channeling =
{
	self.takedamage = DAMAGE_NO;
};

// ANIMATION CYCLES
void() d1boss_stand1  =[ $stand1,  d1boss_stand2  ] { ai_stand();}
void() d1boss_stand2  =[ $stand2,  d1boss_stand3  ] { ai_stand(); }
void() d1boss_stand3  =[ $stand3,  d1boss_stand4  ] { ai_stand(); }
void() d1boss_stand4  =[ $stand4,  d1boss_stand5  ] { ai_stand(); }
void() d1boss_stand5  =[ $stand5,  d1boss_stand6  ] { ai_stand(); }
void() d1boss_stand6  =[ $stand6,  d1boss_stand7  ] { ai_stand(); }
void() d1boss_stand7  =[ $stand7,  d1boss_stand8  ] { ai_stand(); }
void() d1boss_stand8  =[ $stand8,  d1boss_stand9  ] { ai_stand(); }
void() d1boss_stand9  =[ $stand9,  d1boss_stand10 ] { ai_stand(); }
void() d1boss_stand10 =[ $stand10, d1boss_stand11 ] { ai_stand(); }
void() d1boss_stand11 =[ $stand11, d1boss_stand12 ] { ai_stand(); }
void() d1boss_stand12 =[ $stand12, d1boss_stand13 ] { ai_stand(); }
void() d1boss_stand13 =[ $stand13, d1boss_stand14 ] { ai_stand(); }
void() d1boss_stand14 =[ $stand14, d1boss_stand15 ] { ai_stand(); }
void() d1boss_stand15 =[ $stand15, d1boss_stand16 ] { ai_stand(); }
void() d1boss_stand16 =[ $stand16, d1boss_stand17 ] { ai_stand(); }
void() d1boss_stand17 =[ $stand17, d1boss_stand18 ] { ai_stand(); }
void() d1boss_stand18 =[ $stand18, d1boss_stand19 ] { ai_stand(); }
void() d1boss_stand19 =[ $stand19, d1boss_stand20 ] { ai_stand(); }
void() d1boss_stand20 =[ $stand20, d1boss_stand21 ] { ai_stand(); }
void() d1boss_stand21 =[ $stand21, d1boss_stand22 ] { ai_stand(); }
void() d1boss_stand22 =[ $stand22, d1boss_stand23 ] { ai_stand(); }
void() d1boss_stand23 =[ $stand23, d1boss_stand1  ] { ai_stand(); }

void() d1boss_channelling1  =[ $chan1,  d1boss_channelling2  ] { d1boss_channeling();}
void() d1boss_channelling2  =[ $chan2,  d1boss_channelling3  ] { }
void() d1boss_channelling3  =[ $chan3,  d1boss_channelling4  ] { }
void() d1boss_channelling4  =[ $chan4,  d1boss_channelling5  ] { }
void() d1boss_channelling5  =[ $chan5,  d1boss_channelling6  ] { }
void() d1boss_channelling6  =[ $chan6,  d1boss_channelling7  ] { }
void() d1boss_channelling7  =[ $chan7,  d1boss_channelling8  ] { }
void() d1boss_channelling8  =[ $chan8,  d1boss_channelling9  ] { }
void() d1boss_channelling9  =[ $chan9,  d1boss_channelling10 ] { }
void() d1boss_channelling10 =[ $chan10, d1boss_channelling11 ] { }
void() d1boss_channelling11 =[ $chan11, d1boss_channelling12 ] { }
void() d1boss_channelling12 =[ $chan12, d1boss_channelling13 ] { }
void() d1boss_channelling13 =[ $chan13, d1boss_channelling14 ] { }
void() d1boss_channelling14 =[ $chan14, d1boss_channelling15 ] { }
void() d1boss_channelling15 =[ $chan15, d1boss_channelling16 ] { }
void() d1boss_channelling16 =[ $chan16, d1boss_channelling17 ] { }
void() d1boss_channelling17 =[ $chan17, d1boss_channelling18 ] { }
void() d1boss_channelling18 =[ $chan18, d1boss_channelling19 ] { }
void() d1boss_channelling19 =[ $chan19, d1boss_channelling20 ] { }
void() d1boss_channelling20 =[ $chan20, d1boss_channelling21 ] { }
void() d1boss_channelling21 =[ $chan21, d1boss_channelling22 ] { }
void() d1boss_channelling22 =[ $chan22, d1boss_channelling23 ] { }
void() d1boss_channelling23 =[ $chan23, d1boss_channelling2 ] { }
//void() d1boss_channelling24 =[ $chan24, d1boss_channelling1  ] { }

void() d1boss_walk1  =[ $stand1,  d1boss_walk2  ] { ai_walk(16);}
void() d1boss_walk2  =[ $stand2,  d1boss_walk3  ] { ai_walk(16); }
void() d1boss_walk3  =[ $stand3,  d1boss_walk4  ] { ai_walk(16); }
void() d1boss_walk4  =[ $stand4,  d1boss_walk5  ] { ai_walk(16); }
void() d1boss_walk5  =[ $stand5,  d1boss_walk6  ] { ai_walk(16); }
void() d1boss_walk6  =[ $stand6,  d1boss_walk7  ] { ai_walk(16); }
void() d1boss_walk7  =[ $stand7,  d1boss_walk8  ] { ai_walk(16); }
void() d1boss_walk8  =[ $stand8,  d1boss_walk9  ] { ai_walk(16); }
void() d1boss_walk9  =[ $stand9,  d1boss_walk10 ] { ai_walk(16); }
void() d1boss_walk10 =[ $stand10, d1boss_walk11 ] { ai_walk(16); }
void() d1boss_walk11 =[ $stand11, d1boss_walk12 ] { ai_walk(16); }
void() d1boss_walk12 =[ $stand12, d1boss_walk13 ] { ai_walk(16); }
void() d1boss_walk13 =[ $stand13, d1boss_walk14 ] { ai_walk(16); }
void() d1boss_walk14 =[ $stand14, d1boss_walk15 ] { ai_walk(16); }
void() d1boss_walk15 =[ $stand15, d1boss_walk16 ] { ai_walk(16); }
void() d1boss_walk16 =[ $stand16, d1boss_walk17 ] { ai_walk(16); }
void() d1boss_walk17 =[ $stand17, d1boss_walk18 ] { ai_walk(16); }
void() d1boss_walk18 =[ $stand18, d1boss_walk19 ] { ai_walk(16); }
void() d1boss_walk19 =[ $stand19, d1boss_walk20 ] { ai_walk(16); }
void() d1boss_walk20 =[ $stand20, d1boss_walk21 ] { ai_walk(16); }
void() d1boss_walk21 =[ $stand21, d1boss_walk22 ] { ai_walk(16); }
void() d1boss_walk22 =[ $stand22, d1boss_walk23 ] { ai_walk(16); }
void() d1boss_walk23 =[ $stand23, d1boss_walk1  ] { ai_walk(16); }

void() d1boss_side1  =[ $stand1,  d1boss_side2  ] { ai_face(); ai_run_slide(24); }
void() d1boss_side2  =[ $stand2,  d1boss_side3  ] { }
void() d1boss_side3  =[ $stand3,  d1boss_side4  ] { ai_face(); }
void() d1boss_side4  =[ $stand4,  d1boss_side5  ] { ai_face(); ai_run_slide(24); }
void() d1boss_side5  =[ $stand5,  d1boss_side6  ] { d1boss_changeheight(TRUE); }
void() d1boss_side6  =[ $stand6,  d1boss_side7  ] { }
void() d1boss_side7  =[ $stand7,  d1boss_side8  ] { }
void() d1boss_side8  =[ $stand8,  d1boss_side1  ] { }

void() d1boss_run1  =[ $stand1,  d1boss_run2  ] { if (!self.takedamage) self.takedamage = DAMAGE_AIM; ai_face(); ai_run(24); }
void() d1boss_run2  =[ $stand2,  d1boss_run3  ] { }
void() d1boss_run3  =[ $stand3,  d1boss_run4  ] { ai_face(); }
void() d1boss_run4  =[ $stand4,  d1boss_run5  ] { ai_face(); ai_run(24); }
void() d1boss_run5  =[ $stand5,  d1boss_run6  ] { d1boss_changeheight(TRUE); }
void() d1boss_run6  =[ $stand6,  d1boss_run7  ] { }
void() d1boss_run7  =[ $stand7,  d1boss_run8  ] { }
void() d1boss_run8  =[ $stand8,  d1boss_run1  ] { }

//Long attack
void() d1boss_atkbig1  =[ $big1,  d1boss_atkbig2  ] { sound (self, CHAN_VOICE, "d1boss/atk.wav", 1, ATTN_NORM);  d1boss_changeheight(TRUE); ai_run_slide(10); self.boss_lastattack = 1; }
void() d1boss_atkbig2  =[ $big2,  d1boss_atkbig3  ] { ai_run_slide(6); }
void() d1boss_atkbig3  =[ $big3,  d1boss_atkbig4  ] { ai_run_slide(6); }
void() d1boss_atkbig4  =[ $big4,  d1boss_atkbig5  ] { ai_run_slide(6); }
void() d1boss_atkbig5  =[ $big5,  d1boss_atkbig6  ] { ai_run_slide(6); }
void() d1boss_atkbig6  =[ $big6,  d1boss_atkbig7  ] { ai_run_slide(6); }
void() d1boss_atkbig7  =[ $big7,  d1boss_atkbig8  ] { ai_run_slide(6); }
void() d1boss_atkbig8  =[ $big8,  d1boss_atkbig9  ] { ai_run_slide(6); }
void() d1boss_atkbig9  =[ $big9,  d1boss_atkbig10 ] { ai_run_slide(6); }
void() d1boss_atkbig10 =[ $big10, d1boss_atkbig11 ] { ai_run_slide(6); }
void() d1boss_atkbig11 =[ $big11, d1boss_atkbig12 ] { ai_run_slide(6); }
void() d1boss_atkbig12 =[ $big12, d1boss_atkbig13 ] { ai_run_slide(6); }
void() d1boss_atkbig13 =[ $big13, d1boss_atkbig14 ] { ai_run_slide(6); }
void() d1boss_atkbig14 =[ $big14, d1boss_atkbig15 ] { ai_run_slide(6); }
void() d1boss_atkbig15 =[ $big15, d1boss_atkbig16 ] { ai_run_slide(12); }
void() d1boss_atkbig16 =[ $big16, d1boss_atkbig17 ] { ai_run_slide(16); }
void() d1boss_atkbig17 =[ $big17, d1boss_atkbig18 ] { ai_run_slide(24); }
void() d1boss_atkbig18 =[ $big18, d1boss_atkbig19 ] { ai_run_slide(24); D1BossMissile(-16, 12, 1); }
void() d1boss_atkbig19 =[ $big19, d1boss_atkbig20 ] { ai_run_slide(24); D1BossMissile(0, 12, 0); }
void() d1boss_atkbig20 =[ $big20, d1boss_atkbig21 ] { ai_run_slide(24); D1BossMissile(16, 12, 1); ai_attack_finished(1.5); }
void() d1boss_atkbig21 =[ $big21, d1boss_atkbig22 ] { ai_run_slide(24); }
void() d1boss_atkbig22 =[ $big22, d1boss_atkbig23 ] { ai_run_slide(24); }
void() d1boss_atkbig23 =[ $big23, d1boss_atkbig24 ] { ai_run_slide(24); }
void() d1boss_atkbig24 =[ $big24, d1boss_run1     ] { }

void() d1boss_dashl1 =[ $swingl1, d1boss_dashl2 ] { sound (self, CHAN_VOICE, "d1boss/atk.wav", 1, ATTN_NORM);  ai_nop(); self.boss_attacksleft -= 1; }
void() d1boss_dashl2 =[ $swingl2, d1boss_dashl3 ] { boss_move( 64, 1 ); }
void() d1boss_dashl3 =[ $swingl3, d1boss_dashl4 ] { boss_move( 50, 1 ); }
void() d1boss_dashl4 =[ $swingl4, d1boss_dashl5 ] { boss_move( 48, 1 ); }
void() d1boss_dashl5 =[ $swingl5, d1boss_dashl6 ] { boss_move( 32, 1 ); }
void() d1boss_dashl6 =[ $swingl6, d1boss_dashl7 ] { boss_move( 8 , 1 ); D1BossMissile(-64, 12, 1); }
void() d1boss_dashl7 =[ $swingl7, d1boss_dashl8 ] { boss_move( 8 , 1 ); }
void() d1boss_dashl8 =[ $swingl8, d1boss_dashl9 ] { boss_move( 8 , 1 ); }
void() d1boss_dashl9 =[ $swingl9, d1boss_run1   ] { boss_move( 2 , 1 ); d1boss_atkright1(); }

void() d1boss_dashr1 =[ $swingr1, d1boss_dashr2 ] { sound (self, CHAN_VOICE, "d1boss/atk.wav", 1, ATTN_NORM);  ai_nop(); self.boss_attacksleft -= 1; }
void() d1boss_dashr2 =[ $swingr2, d1boss_dashr3 ] { boss_move( 64, 0 ); }
void() d1boss_dashr3 =[ $swingr3, d1boss_dashr4 ] { boss_move( 50, 0 ); }
void() d1boss_dashr4 =[ $swingr4, d1boss_dashr5 ] { boss_move( 48, 0 ); }
void() d1boss_dashr5 =[ $swingr5, d1boss_dashr6 ] { boss_move( 32, 0 ); }
void() d1boss_dashr6 =[ $swingr6, d1boss_dashr7 ] { boss_move( 8 , 0 ); D1BossMissile(64, 12, 1); }
void() d1boss_dashr7 =[ $swingr7, d1boss_dashr8 ] { boss_move( 8 , 0 ); }
void() d1boss_dashr8 =[ $swingr8, d1boss_dashr9 ] { boss_move( 8 , 0 ); }
void() d1boss_dashr9 =[ $swingr9, d1boss_run1   ] { boss_move( 2 , 0 ); d1boss_atkleft1(); }

void() d1boss_atkleft1 =[ $swingl1, d1boss_atkleft2 ] { sound (self, CHAN_VOICE, "d1boss/atk.wav", 1, ATTN_NORM);  ai_nop(); self.boss_attacksleft -= 1; }
void() d1boss_atkleft2 =[ $swingl2, d1boss_atkleft3 ] { boss_move( 24, 1 ); }
void() d1boss_atkleft3 =[ $swingl3, d1boss_atkleft4 ] { boss_move( 20, 1 ); }
void() d1boss_atkleft4 =[ $swingl4, d1boss_atkleft5 ] { boss_move( 18, 1 ); }
void() d1boss_atkleft5 =[ $swingl5, d1boss_atkleft6 ] { boss_move( 16, 1 ); }
void() d1boss_atkleft6 =[ $swingl6, d1boss_atkleft7 ] { boss_move( 16, 1 ); D1BossMissile(-64, 12, 0); ai_attack_finished(2);}
void() d1boss_atkleft7 =[ $swingl7, d1boss_atkleft8 ] { boss_move( 16, 1 ); }
void() d1boss_atkleft8 =[ $swingl8, d1boss_atkleft9 ] { boss_move( 16, 1 ); }
void() d1boss_atkleft9 =[ $swingl9, d1boss_run1     ] { ai_face(); if ( self.boss_attacksleft > 0 ) d1boss_atkright1(); }

void() d1boss_atkright1 =[ $swingr1, d1boss_atkright2 ] { sound (self, CHAN_VOICE, "d1boss/atk.wav", 1, ATTN_NORM); ai_nop(); self.boss_attacksleft -= 1; }
void() d1boss_atkright2 =[ $swingr2, d1boss_atkright3 ] { boss_move( 24, 0 ); }
void() d1boss_atkright3 =[ $swingr3, d1boss_atkright4 ] { boss_move( 20, 0 ); }
void() d1boss_atkright4 =[ $swingr4, d1boss_atkright5 ] { boss_move( 18, 0 ); }
void() d1boss_atkright5 =[ $swingr5, d1boss_atkright6 ] { boss_move( 16, 0 ); }
void() d1boss_atkright6 =[ $swingr6, d1boss_atkright7 ] { boss_move( 16, 0 ); D1BossMissile(64, 12, 0); ai_attack_finished(2);}
void() d1boss_atkright7 =[ $swingr7, d1boss_atkright8 ] { boss_move( 16, 0 ); }
void() d1boss_atkright8 =[ $swingr8, d1boss_atkright9 ] { boss_move( 16, 0 ); }
void() d1boss_atkright9 =[ $swingr9, d1boss_run1      ] { ai_face(); if ( self.boss_attacksleft > 0 ) d1boss_atkleft1(); }

void() d1boss_phase1  =[ $phase1,  d1boss_phase2  ] { ai_nop(); sound (self, CHAN_VOICE, "d1boss/phasechange.wav", 1, ATTN_NONE); }
void() d1boss_phase2  =[ $phase2,  d1boss_phase3  ] { }
void() d1boss_phase3  =[ $phase3,  d1boss_phase4  ] { }
void() d1boss_phase4  =[ $phase4,  d1boss_phase5  ] { }
void() d1boss_phase5  =[ $phase5,  d1boss_phase6  ] { }
void() d1boss_phase6  =[ $phase6,  d1boss_phase7  ] { }
void() d1boss_phase7  =[ $phase7,  d1boss_phase8  ] { }
void() d1boss_phase8  =[ $phase8,  d1boss_phase9  ] { }
void() d1boss_phase9  =[ $phase9,  d1boss_phase10 ] { }
void() d1boss_phase10 =[ $phase10, d1boss_phase11 ] { }
void() d1boss_phase11 =[ $phase11, d1boss_phase12 ] { }
void() d1boss_phase12 =[ $phase12, d1boss_phase13 ] { }
void() d1boss_phase13 =[ $phase13, d1boss_phase14 ] { }
void() d1boss_phase14 =[ $phase14, d1boss_phase15 ] { ThrowGibBoss ("progs/gib2.mdl", 100, D1BOSS_GIBOFFSET); ThrowGibBoss ("progs/gib1.mdl", 50, D1BOSS_GIBOFFSET); }
void() d1boss_phase15 =[ $phase15, d1boss_phase16 ] { ThrowGibBoss ("progs/gib3.mdl", 100, D1BOSS_GIBOFFSET); ThrowGibBoss ("progs/gib3.mdl", 50, D1BOSS_GIBOFFSET); }
void() d1boss_phase16 =[ $phase16, d1boss_phase17 ] { ThrowGibBoss ("progs/gib2.mdl", 100, D1BOSS_GIBOFFSET); ThrowGibBoss ("progs/gib2.mdl", 50, D1BOSS_GIBOFFSET); }
void() d1boss_phase17 =[ $phase17, d1boss_phase18 ] { ThrowGibBoss ("progs/gib3.mdl", 100, D1BOSS_GIBOFFSET); ThrowGibBoss ("progs/gib2.mdl", 50, D1BOSS_GIBOFFSET); }
void() d1boss_phase18 =[ $phase18, d1boss_phase19 ] { ThrowGibBoss ("progs/gib1.mdl", 100, D1BOSS_GIBOFFSET); ThrowGibBoss ("progs/gib1.mdl", 50, D1BOSS_GIBOFFSET); }
void() d1boss_phase19 =[ $phase19, d1boss_phase20 ] { ThrowGibBoss ("progs/gib2.mdl", 100, D1BOSS_GIBOFFSET); ThrowGibBoss ("progs/gib3.mdl", 50, D1BOSS_GIBOFFSET); }
void() d1boss_phase20 =[ $phase20, d1boss_phase21 ] { ThrowGibBoss ("progs/gib1.mdl", 100, D1BOSS_GIBOFFSET); ThrowGibBoss ("progs/gib3.mdl", 50, D1BOSS_GIBOFFSET); }
void() d1boss_phase21 =[ $phase21, d1boss_phase22 ] { ThrowGibBoss ("progs/gib3.mdl", 100, D1BOSS_GIBOFFSET); ThrowGibBoss ("progs/gib1.mdl", 50, D1BOSS_GIBOFFSET); }
void() d1boss_phase22 =[ $phase22, d1boss_phase23 ] { ThrowGibBoss ("progs/gib3.mdl", 100, D1BOSS_GIBOFFSET); ThrowGibBoss ("progs/gib2.mdl", 50, D1BOSS_GIBOFFSET); }
void() d1boss_phase23 =[ $phase23, d1boss_phase24 ] { ThrowGibBoss ("progs/gib2.mdl", 50,  D1BOSS_GIBOFFSET); ThrowGibBoss ("progs/gib1.mdl", 100,D1BOSS_GIBOFFSET); }
void() d1boss_phase24 =[ $phase24, d1boss_phase25 ] { ThrowGibBoss ("progs/gib1.mdl", 50,  D1BOSS_GIBOFFSET); ThrowGibBoss ("progs/gib1.mdl", 100,D1BOSS_GIBOFFSET); }
void() d1boss_phase25 =[ $phase25, d1boss_phase26 ] { }
void() d1boss_phase26 =[ $phase26, d1boss_phase27 ] { }
void() d1boss_phase27 =[ $phase27, d1boss_phase28 ] { }
void() d1boss_phase28 =[ $phase28, d1boss_phase29 ] { }
void() d1boss_phase29 =[ $phase29, d1boss_phase30 ] { }
void() d1boss_phase30 =[ $phase30, d1boss_phase31 ] { }
void() d1boss_phase31 =[ $phase31, d1boss_phase32 ] { }
void() d1boss_phase32 =[ $phase32, d1boss_phase33 ] { }
void() d1boss_phase33 =[ $phase33, d1boss_phase34 ] { }
void() d1boss_phase34 =[ $phase34, d1boss_phase35 ] { }
void() d1boss_phase35 =[ $phase35, d1boss_sleep_frame] { d1boss_sleepreset(); }


void() d1boss_sleep_frame =                
{                                          
	if ( self.attack_finished < time ) 
	{ 
		self.velocity = '0 0 0';   
		self.avelocity = '0 0 0';                          
	}

	self.think = d1boss_sleep_frame;
	self.nextthink = time + 0.1;
};

void() d1boss_sleepreset =
{
	entity dest;

	self.takedamage = DAMAGE_AIM;
	self.health = D1BOSS_HEALTH;

	dest = find( world, targetname, self.include );
	setorigin( self, dest.origin );
	self.ideal_yaw = vectoyaw(dest.angles); 
	ChangeYaw ();

	d1boss_stand1();
};


void() d1boss_startsleep =
{
	self.takedamage = DAMAGE_NO;
	self.health = 1;
	self.enemy = self.goalentity = world;

	d1boss_phase1();
};


float() d1boss_checkdeath =
{
	if ( self.state ) 
	{
		d1boss_startsleep();
		
		if ( self.state == 3 ) 
		{
			SUB_UseTargetsByField( target );
			self.target = "";
		}
		else if ( self.state == 2 ) 
		{
			SUB_UseTargetsByField( target2 );
			self.target2 = "";
		}
		else if ( self.state == 1 ) 
		{
			SUB_UseTargetsByField( target3 );
			self.target3 = "";
		}
		
		self.state--;
		return TRUE;
	}
	else 
	{
		d1boss_death1();
		//SUB_UseTargetsByField( target4 );
		//self.target4 = "";
		return FALSE;
	}
};


void() d1boss_death1  =[ $phase1,  d1boss_death2  ] { sound (self, CHAN_VOICE, "d1boss/phasechange.wav", 1, ATTN_NONE); self.solid = SOLID_NOT;
							PostDeathLogic(); SUB_UseTargetsByField( target4 ); self.target4 = ""; self.flags = self.flags | FL_FLY; }
void() d1boss_death2  =[ $phase2,  d1boss_death3  ] { }
void() d1boss_death3  =[ $phase3,  d1boss_death4  ] { }
void() d1boss_death4  =[ $phase4,  d1boss_death5  ] { }
void() d1boss_death5  =[ $phase5,  d1boss_death6  ] { }
void() d1boss_death6  =[ $phase6,  d1boss_death7  ] { }
void() d1boss_death7  =[ $phase7,  d1boss_death8  ] { }
void() d1boss_death8  =[ $phase8,  d1boss_death9  ] { }
void() d1boss_death9  =[ $phase9,  d1boss_death10 ] { }
void() d1boss_death10 =[ $phase10, d1boss_death11 ] { }
void() d1boss_death11 =[ $phase11, d1boss_death12 ] { }
void() d1boss_death12 =[ $phase12, d1boss_death13 ] { }
void() d1boss_death13 =[ $phase13, d1boss_death14 ] { }
void() d1boss_death14 =[ $phase14, d1boss_death15 ] { }
void() d1boss_death15 =[ $phase15, d1boss_death16 ] { }
void() d1boss_death16 =[ $phase16, d1boss_death17 ] { }
void() d1boss_death17 =[ $phase17, d1boss_death18 ] { }
void() d1boss_death18 =[ $phase18, d1boss_death19 ] { }
void() d1boss_death19 =[ $phase19, d1boss_death20 ] { }
void() d1boss_death20 =[ $phase20, d1boss_death21 ] { }
void() d1boss_death21 =[ $phase21, d1boss_death22 ] { }
void() d1boss_death22 =[ $phase22, d1boss_death23 ] { }
void() d1boss_death23 =[ $phase23, d1boss_death24 ] { }
void() d1boss_death24 =[ $phase24, d1boss_death25 ] 
{
	local float i, power;
	
	for ( i = 0; i < 12; i++ )
	{ 	
		power = 50;
		
		if ( i < 3 )
			power += ( i - 3 ) * 10;
		
		ThrowGibBoss ("progs/gib1.mdl", 50 + random() * power, D1BOSS_GIBOFFSET);
		ThrowGibBoss ("progs/gib2.mdl", 50 + random() * power, D1BOSS_GIBOFFSET);
		ThrowGibBoss ("progs/gib3.mdl", 50 + random() * power, D1BOSS_GIBOFFSET);
	}
	ThrowHead ("progs/gib1.mdl", -300); 
};
void() d1boss_death25 =[ $phase25, d1boss_death26 ] { }
void() d1boss_death26 =[ $phase26, d1boss_death27 ] { }
void() d1boss_death27 =[ $phase27, d1boss_death28 ] { }
void() d1boss_death28 =[ $phase28, d1boss_death29 ] { }
void() d1boss_death29 =[ $phase29, d1boss_death30 ] { }
void() d1boss_death30 =[ $phase30, d1boss_death31 ] { }
void() d1boss_death31 =[ $phase31, d1boss_death32 ] { }
void() d1boss_death32 =[ $phase32, d1boss_death33 ] { }
void() d1boss_death33 =[ $phase33, d1boss_death34 ] { }
void() d1boss_death34 =[ $phase34, d1boss_death35 ] { }
void() d1boss_death35 =[ $phase35, d1boss_death1  ] { }


void() d1boss_die =
{
	d1boss_death1();
};


void(entity attacker, float damage) d1boss_Pain =
{
	if ( self.health <= 0 ) 
		return;	

	if ( (random() * 70) + 20 > damage )
		return;
	
	if ( random() > 0.5 )
		sound (self, CHAN_AUTO, "d1boss/pain1.wav", 1, ATTN_NORM);
	else if ( random() > 0.75 )
		sound (self, CHAN_AUTO, "d1boss/pain2.wav", 1, ATTN_NORM);		
};


void() d1boss_chooseattack =
{
	if ( random() > 0.8 && !self.boss_lastattack )
		d1boss_atkbig1();
	else 
	{
		self.boss_lastattack = 0; // we can do big attack again
		//self.boss_attacksleft = 2; // limit our attacks to avoid endless loop
		
		if ( random() > 0.5 )
		{
			self.boss_attacksleft = 3;  // three attacks total when dashing, change to 2 if you don't like this
			if ( random() > 0.5 )
				d1boss_dashl1();
			else 
				d1boss_dashr1();
		}
		else
		{	
			self.boss_attacksleft = 2; 
			if ( random() > 0.5 )
				d1boss_atkleft1();
			else 
				d1boss_atkright1();
		}
	}
};


void() monster_d1boss_spawn =
{
	self.classname = "monster_d1boss";
		
	self.solid = SOLID_SLIDEBOX;
	setmodel (self, "progs/mon_d1boss.mdl");
	setsize (self, '-32 -32 -96', '32 32 96');

	self.distance = self.height = 320; 

	self.state = 3;
	self.type = "boss";
	self.th_stand = d1boss_channelling1; //d1boss_stand1;
	self.th_walk = d1boss_walk1;
	self.th_run = d1boss_run1;
	self.th_missile = d1boss_chooseattack;
	self.th_melee = d1boss_run1; //d1boss_dashr1;
	self.th_pain = d1boss_Pain;
	self.th_die = d1boss_die;
	self.th_checkattack = D1BossCheckAttack;
	self.th_checkdeath = d1boss_checkdeath;
	self.yaw_speed = 30;
	
	if ( self.deathtype == string_null )
		self.deathtype = " was put to sleep by The Awoken";
	
	flymonster_start ();
};


void() monster_d1boss_spawner = 
{
	mon_spawner_use(monster_d1boss_spawn);
};

/*QUAKED monster_d1boss (1 0 0) (-32 -32 -96) (32 32 96) AMBUSH ? ? ? TRIGGERED NOTFOG NOTELEFRAG INSTAWAKE
The Awoken One

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
@PointClass base(Monster) size(-32 -32 -96, 32 32 96) model({ "path": ":progs/mon_d1boss.mdl" }) = monster_d1boss : "The Awoken One" []
*/

void() monster_d1boss =
{
	if ( !SUB_ShouldSpawn() ) 
		return;
	
	if ( nomonster() ) 
		return;
	
	if ( deathmatch )
	{
		remove( self );
		return;
	}
	
	precache_model ("progs/mon_d1boss.mdl");
	precache_model ("progs/h_shams.mdl");
	precache_model ("progs/proj_d1boss.mdl");
	
	precache_sound ("d1boss/aggro.wav");
	precache_sound ("d1boss/atk.wav");
	precache_sound ("d1boss/phasechange.wav");
	precache_sound ("d1boss/pain1.wav");
	precache_sound ("d1boss/pain2.wav");
	precache_sound ("d1boss/proj.wav");

	self.health = D1BOSS_HEALTH;
	setsize (self, '-32 -32 -96', '32 32 96');
	//setsize (self, '-16 -16 -24', '16 16 40');
	
	if ( monster_spawnsetup( monster_d1boss_spawner ) )
		return;
	
	addmonster( 1 );
	monster_d1boss_spawn();
};