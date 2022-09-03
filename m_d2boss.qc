/*
==============================================================================

Ep. 1 Boss

==============================================================================
*/

// FRAME MACROSES 
//----------------------------------------------------------------------

$cd id1/models/mon_d2boss
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

float d2boss_BALL_VEL = 750;
float d2boss_HEALTH = 600; 
.float	track_finished;
.float	boss_attacksleft;
.float	boss_lastattack;


//offset for gibs
/*entity(string gibname, float dm) ThrowGibBoss =
{
	local entity gib;

	// gibs have to be thinking ballistic projectiles to pass through monsterclip/notrace :(
	gib = toss_projectile(self.origin + '0 0 112', GibVelocityForHealth(dm), "gib");
	MakeGib(gib, gibname);
	
	return gib;
};*/

void(vector org, float dist, float amount) bullethell = {
	float step = 360/amount;
	float yaw;
	entity newmis;
	vector angs;

	for (yaw = 0; yaw < 360; yaw += step) {
		angs = [0, yaw, 0];
		makevectors(angs);

		/*newmis = spawn();
		newmis.angles = angs;
		newmis.velocity = v_forward * 600;

		newmis.owner = self;
		newmis.movetype = MOVETYPE_FLYMISSILE;
		newmis.solid = SOLID_BBOX;
		
		newmis.nextthink = time + 5;
		newmis.think = SUB_Remove;
		newmis.touch = Laser_Touch;
		
		setmodel (newmis, "progs/laser.mdl");
		setsize (newmis, '0 0 0', '0 0 0');
		setorigin (newmis, org + v_forward * dist);
		*/
		newmis = launch_laser(org + v_forward * dist, v_forward * 600);
	}
}

float() d2bossCheckAttack = 
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


void() d2bossMissileExplode =
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


void() d2bossMissileTouch =
{
	if ( CheckProjectilePassthru() ) 
		return;
	
	if ( other == self.owner )
		return;		// don't explode on owner

	if (other.type == "zombie")
		T_Damage (other, self, self.trueowner, other.health + 25);
	
	d2bossMissileExplode();
};


void() d2bossMissileHome =
{
	float rate, dot;
	
	if ( self.lifetime_finished < time )
	{
		d2bossMissileExplode();
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
	
	self.velocity = d2boss_BALL_VEL * ShalTurnToward( self.enemy, rate * 0.7 ); // 0.7
	self.think = d2bossMissileHome;
	self.oldvelocity = self.velocity;
};


void(float offset_side, float offset_up, float isdash) d2bossMissile =
{
	entity missile;
	vector dir;
	float toffset_side, toffset_up;
	vector bossorg,playerorg;
	float distcheck;
	float dashmod;
	
	if (isdash)
		dashmod = 0.4;
	else 
		dashmod = 0.1;
	
	//self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors(self.angles);
	
	dir = LeadTarget( self.origin, d2boss_BALL_VEL, random() );
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
		dir = LeadTarget( self.origin, d2boss_BALL_VEL, 1 );
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
	
	missile = launch_projectile( self.origin + (v_forward * 16) + (v_up * offset_up) + (v_right * offset_side) + '0 0 72', dir * d2boss_BALL_VEL, "voreball" );
	//missile = launch_projectile( self.origin + v_forward * 16 + v_up * crandom()*10 + v_right * crandom()*8 + '0 0 72', dir * d2boss_BALL_VEL, "voreball" );
	
	SUB_ChangeModel (missile, "progs/proj_d1boss.mdl");

	missile.avelocity = '300 300 300';
	missile.nextthink = time + distcheck;//0.35; // 0.2
	missile.think = d2bossMissileHome;
	missile.enemy = self.enemy;
	missile.touch = d2bossMissileTouch;
	missile.lifetime_finished = time + 5;	 // blow up after a while
	missile.track_finished = time + 1.25; // 1.25
	sound (self, CHAN_WEAPON, "d1boss/proj.wav", 1, ATTN_NORM);
};

/*
void() d2bossGrenade =
{
	entity 	missile;

	//self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors( [70, random() * 360, 0] );
		
	missile = toss_projectile( self.origin + '0 0 80', v_forward * 400 + v_up * 100, "bossgrenade" );
	SUB_ChangeModel (missile, "progs/proj_d2boss.mdl");

	missile.avelocity = '300 300 300';
	missile.nextthink = time + 0.2;
	missile.touch = d2bossMissileTouch;
	missile.lifetime_finished = time + 5;	 // blow up after a while
};
*/

void() d2boss_idlesound =
{
	if (self.show_hostile > time) 
		return;

	local float wr;
	
	wr = random() * 5;

	if ( self.wait < time )
	{
	 	self.wait = time + 2;
		
	 	if ( wr > 4.5 ) 
	 		sound (self, CHAN_VOICE, "d1boss/idle.wav", 1,  ATTN_IDLE);
	}
	
	return;
};


void(float instant) d2boss_changeheight =
{
	if ( self.air_finished < time || instant ) 
	{
		self.height = ( self.distance * 0.25 ) + ( self.distance * 0.75 * random() );
		self.air_finished = time + 3;
	}
};


void(float dist, float toleft) d2bossmove =
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

void() d2boss_channeling =
{
	d2boss_bbox_setfield(takedamage, DAMAGE_NO);
};

// ANIMATION CYCLES
void() d2boss_stand1  =[ $stand1,  d2boss_stand2  ] { ai_stand(); d2boss_idlesound(); }
void() d2boss_stand2  =[ $stand2,  d2boss_stand3  ] { ai_stand(); }
void() d2boss_stand3  =[ $stand3,  d2boss_stand4  ] { ai_stand(); }
void() d2boss_stand4  =[ $stand4,  d2boss_stand5  ] { ai_stand(); }
void() d2boss_stand5  =[ $stand5,  d2boss_stand6  ] { ai_stand(); }
void() d2boss_stand6  =[ $stand6,  d2boss_stand7  ] { ai_stand(); }
void() d2boss_stand7  =[ $stand7,  d2boss_stand8  ] { ai_stand(); }
void() d2boss_stand8  =[ $stand8,  d2boss_stand9  ] { ai_stand(); }
void() d2boss_stand9  =[ $stand9,  d2boss_stand10 ] { ai_stand(); }
void() d2boss_stand10 =[ $stand10, d2boss_stand11 ] { ai_stand(); }
void() d2boss_stand11 =[ $stand11, d2boss_stand12 ] { ai_stand(); }
void() d2boss_stand12 =[ $stand12, d2boss_stand13 ] { ai_stand(); }
void() d2boss_stand13 =[ $stand13, d2boss_stand14 ] { ai_stand(); }
void() d2boss_stand14 =[ $stand14, d2boss_stand15 ] { ai_stand(); }
void() d2boss_stand15 =[ $stand15, d2boss_stand16 ] { ai_stand(); }
void() d2boss_stand16 =[ $stand16, d2boss_stand17 ] { ai_stand(); }
void() d2boss_stand17 =[ $stand17, d2boss_stand18 ] { ai_stand(); }
void() d2boss_stand18 =[ $stand18, d2boss_stand19 ] { ai_stand(); }
void() d2boss_stand19 =[ $stand19, d2boss_stand20 ] { ai_stand(); }
void() d2boss_stand20 =[ $stand20, d2boss_stand21 ] { ai_stand(); }
void() d2boss_stand21 =[ $stand21, d2boss_stand22 ] { ai_stand(); }
void() d2boss_stand22 =[ $stand22, d2boss_stand23 ] { ai_stand(); }
void() d2boss_stand23 =[ $stand23, d2boss_stand1  ] { ai_stand(); }

void() d2boss_channelling1  =[ $chan1,  d2boss_channelling2  ] { d2boss_channeling(); d2boss_idlesound(); }
void() d2boss_channelling2  =[ $chan2,  d2boss_channelling3  ] { }
void() d2boss_channelling3  =[ $chan3,  d2boss_channelling4  ] { }
void() d2boss_channelling4  =[ $chan4,  d2boss_channelling5  ] { }
void() d2boss_channelling5  =[ $chan5,  d2boss_channelling6  ] { }
void() d2boss_channelling6  =[ $chan6,  d2boss_channelling7  ] { }
void() d2boss_channelling7  =[ $chan7,  d2boss_channelling8  ] { }
void() d2boss_channelling8  =[ $chan8,  d2boss_channelling9  ] { }
void() d2boss_channelling9  =[ $chan9,  d2boss_channelling10 ] { }
void() d2boss_channelling10 =[ $chan10, d2boss_channelling11 ] { }
void() d2boss_channelling11 =[ $chan11, d2boss_channelling12 ] { }
void() d2boss_channelling12 =[ $chan12, d2boss_channelling13 ] { }
void() d2boss_channelling13 =[ $chan13, d2boss_channelling14 ] { }
void() d2boss_channelling14 =[ $chan14, d2boss_channelling15 ] { }
void() d2boss_channelling15 =[ $chan15, d2boss_channelling16 ] { }
void() d2boss_channelling16 =[ $chan16, d2boss_channelling17 ] { }
void() d2boss_channelling17 =[ $chan17, d2boss_channelling18 ] { }
void() d2boss_channelling18 =[ $chan18, d2boss_channelling19 ] { }
void() d2boss_channelling19 =[ $chan19, d2boss_channelling20 ] { }
void() d2boss_channelling20 =[ $chan20, d2boss_channelling21 ] { }
void() d2boss_channelling21 =[ $chan21, d2boss_channelling22 ] { }
void() d2boss_channelling22 =[ $chan22, d2boss_channelling23 ] { }
void() d2boss_channelling23 =[ $chan23, d2boss_channelling2 ] { }
//void() d2boss_channelling24 =[ $chan24, d2boss_channelling1  ] { }

void() d2boss_walk1  =[ $stand1,  d2boss_walk2  ] { ai_walk(16); d2boss_idlesound(); }
void() d2boss_walk2  =[ $stand2,  d2boss_walk3  ] { ai_walk(16); }
void() d2boss_walk3  =[ $stand3,  d2boss_walk4  ] { ai_walk(16); }
void() d2boss_walk4  =[ $stand4,  d2boss_walk5  ] { ai_walk(16); }
void() d2boss_walk5  =[ $stand5,  d2boss_walk6  ] { ai_walk(16); }
void() d2boss_walk6  =[ $stand6,  d2boss_walk7  ] { ai_walk(16); }
void() d2boss_walk7  =[ $stand7,  d2boss_walk8  ] { ai_walk(16); }
void() d2boss_walk8  =[ $stand8,  d2boss_walk9  ] { ai_walk(16); }
void() d2boss_walk9  =[ $stand9,  d2boss_walk10 ] { ai_walk(16); }
void() d2boss_walk10 =[ $stand10, d2boss_walk11 ] { ai_walk(16); }
void() d2boss_walk11 =[ $stand11, d2boss_walk12 ] { ai_walk(16); }
void() d2boss_walk12 =[ $stand12, d2boss_walk13 ] { ai_walk(16); }
void() d2boss_walk13 =[ $stand13, d2boss_walk14 ] { ai_walk(16); }
void() d2boss_walk14 =[ $stand14, d2boss_walk15 ] { ai_walk(16); }
void() d2boss_walk15 =[ $stand15, d2boss_walk16 ] { ai_walk(16); }
void() d2boss_walk16 =[ $stand16, d2boss_walk17 ] { ai_walk(16); }
void() d2boss_walk17 =[ $stand17, d2boss_walk18 ] { ai_walk(16); }
void() d2boss_walk18 =[ $stand18, d2boss_walk19 ] { ai_walk(16); }
void() d2boss_walk19 =[ $stand19, d2boss_walk20 ] { ai_walk(16); }
void() d2boss_walk20 =[ $stand20, d2boss_walk21 ] { ai_walk(16); }
void() d2boss_walk21 =[ $stand21, d2boss_walk22 ] { ai_walk(16); }
void() d2boss_walk22 =[ $stand22, d2boss_walk23 ] { ai_walk(16); }
void() d2boss_walk23 =[ $stand23, d2boss_walk1  ] { ai_walk(16); }

void() d2boss_side1  =[ $stand1,  d2boss_side2  ] { ai_face(); ai_run_slide(24); }
void() d2boss_side2  =[ $stand2,  d2boss_side3  ] { }
void() d2boss_side3  =[ $stand3,  d2boss_side4  ] { ai_face(); }
void() d2boss_side4  =[ $stand4,  d2boss_side5  ] { ai_face(); ai_run_slide(24); }
void() d2boss_side5  =[ $stand5,  d2boss_side6  ] { d2boss_changeheight(TRUE); }
void() d2boss_side6  =[ $stand6,  d2boss_side7  ] { }
void() d2boss_side7  =[ $stand7,  d2boss_side8  ] { }
void() d2boss_side8  =[ $stand8,  d2boss_side1  ] { }

void() d2boss_run1  =[ $stand1,  d2boss_run2  ] { d2boss_bbox_setfield(takedamage, DAMAGE_AIM); ai_face(); ai_run(24); }
void() d2boss_run2  =[ $stand2,  d2boss_run3  ] { }
void() d2boss_run3  =[ $stand3,  d2boss_run4  ] { ai_face(); }
void() d2boss_run4  =[ $stand4,  d2boss_run5  ] { ai_face(); ai_run(24); }
void() d2boss_run5  =[ $stand5,  d2boss_run6  ] { d2boss_changeheight(TRUE); }
void() d2boss_run6  =[ $stand6,  d2boss_run7  ] { }
void() d2boss_run7  =[ $stand7,  d2boss_run8  ] { }
void() d2boss_run8  =[ $stand8,  d2boss_run1  ] { }

//Long attack
void() d2boss_atkbig1  =[ $big1,  d2boss_atkbig2  ] { d2boss_changeheight(TRUE); ai_run_slide(10); sound(self, CHAN_VOICE, "d1boss/bigattack.wav", 1, ATTN_NORM); self.boss_lastattack = 1; }
void() d2boss_atkbig2  =[ $big2,  d2boss_atkbig3  ] { ai_run_slide(6); }
void() d2boss_atkbig3  =[ $big3,  d2boss_atkbig4  ] { ai_run_slide(6); }
void() d2boss_atkbig4  =[ $big4,  d2boss_atkbig5  ] { ai_run_slide(6); }
void() d2boss_atkbig5  =[ $big5,  d2boss_atkbig6  ] { ai_run_slide(6); }
void() d2boss_atkbig6  =[ $big6,  d2boss_atkbig7  ] { ai_run_slide(6); }
void() d2boss_atkbig7  =[ $big7,  d2boss_atkbig8  ] { ai_run_slide(6); }
void() d2boss_atkbig8  =[ $big8,  d2boss_atkbig9  ] { ai_run_slide(6); }
void() d2boss_atkbig9  =[ $big9,  d2boss_atkbig10 ] { ai_run_slide(6); }
void() d2boss_atkbig10 =[ $big10, d2boss_atkbig11 ] { ai_run_slide(6); }
void() d2boss_atkbig11 =[ $big11, d2boss_atkbig12 ] { ai_run_slide(6); }
void() d2boss_atkbig12 =[ $big12, d2boss_atkbig13 ] { ai_run_slide(6); }
void() d2boss_atkbig13 =[ $big13, d2boss_atkbig14 ] { ai_run_slide(6); }
void() d2boss_atkbig14 =[ $big14, d2boss_atkbig15 ] { ai_run_slide(6); }
void() d2boss_atkbig15 =[ $big15, d2boss_atkbig16 ] { ai_run_slide(12); }
void() d2boss_atkbig16 =[ $big16, d2boss_atkbig17 ] { ai_run_slide(16); }
void() d2boss_atkbig17 =[ $big17, d2boss_atkbig18 ] { ai_run_slide(24); }
void() d2boss_atkbig18 =[ $big18, d2boss_atkbig19 ] { ai_run_slide(24); d2bossMissile(-16, 12, 1); }
void() d2boss_atkbig19 =[ $big19, d2boss_atkbig20 ] { ai_run_slide(24); d2bossMissile(0, 12, 0); }
void() d2boss_atkbig20 =[ $big20, d2boss_atkbig21 ] { ai_run_slide(24); d2bossMissile(16, 12, 1); ai_attack_finished(1.5); }
void() d2boss_atkbig21 =[ $big21, d2boss_atkbig22 ] { ai_run_slide(24); }
void() d2boss_atkbig22 =[ $big22, d2boss_atkbig23 ] { ai_run_slide(24); }
void() d2boss_atkbig23 =[ $big23, d2boss_atkbig24 ] { ai_run_slide(24); }
void() d2boss_atkbig24 =[ $big24, d2boss_run1     ] { }

void() d2boss_dashl1 =[ $swingl1, d2boss_dashl2 ] { sound(self, CHAN_VOICE, "d1boss/dash.wav", 1, ATTN_NORM); ai_nop(); self.boss_attacksleft -= 1; }
void() d2boss_dashl2 =[ $swingl2, d2boss_dashl3 ] { d2bossmove( 64, 1 ); }
void() d2boss_dashl3 =[ $swingl3, d2boss_dashl4 ] { d2bossmove( 50, 1 ); }
void() d2boss_dashl4 =[ $swingl4, d2boss_dashl5 ] { d2bossmove( 48, 1 ); }
void() d2boss_dashl5 =[ $swingl5, d2boss_dashl6 ] { d2bossmove( 32, 1 ); }
void() d2boss_dashl6 =[ $swingl6, d2boss_dashl7 ] { d2bossmove( 8 , 1 ); d2bossMissile(-64, 12, 1); }
void() d2boss_dashl7 =[ $swingl7, d2boss_dashl8 ] { d2bossmove( 8 , 1 ); }
void() d2boss_dashl8 =[ $swingl8, d2boss_dashl9 ] { d2bossmove( 8 , 1 ); }
void() d2boss_dashl9 =[ $swingl9, d2boss_run1   ] { d2bossmove( 2 , 1 ); d2boss_atkright1(); }

void() d2boss_dashr1 =[ $swingr1, d2boss_dashr2 ] { sound(self, CHAN_VOICE, "d1boss/dash.wav", 1, ATTN_NORM); ai_nop(); self.boss_attacksleft -= 1; }
void() d2boss_dashr2 =[ $swingr2, d2boss_dashr3 ] { d2bossmove( 64, 0 ); }
void() d2boss_dashr3 =[ $swingr3, d2boss_dashr4 ] { d2bossmove( 50, 0 ); }
void() d2boss_dashr4 =[ $swingr4, d2boss_dashr5 ] { d2bossmove( 48, 0 ); }
void() d2boss_dashr5 =[ $swingr5, d2boss_dashr6 ] { d2bossmove( 32, 0 ); }
void() d2boss_dashr6 =[ $swingr6, d2boss_dashr7 ] { d2bossmove( 8 , 0 ); d2bossMissile(64, 12, 1); }
void() d2boss_dashr7 =[ $swingr7, d2boss_dashr8 ] { d2bossmove( 8 , 0 ); }
void() d2boss_dashr8 =[ $swingr8, d2boss_dashr9 ] { d2bossmove( 8 , 0 ); }
void() d2boss_dashr9 =[ $swingr9, d2boss_run1   ] { d2bossmove( 2 , 0 ); d2boss_atkleft1(); }

void() d2boss_atkleft1 =[ $swingl1, d2boss_atkleft2 ] { sound(self, CHAN_VOICE, "d1boss/atk.wav", 1, ATTN_NORM); ai_nop(); self.boss_attacksleft -= 1; }
void() d2boss_atkleft2 =[ $swingl2, d2boss_atkleft3 ] { d2bossmove( 24, 1 ); }
void() d2boss_atkleft3 =[ $swingl3, d2boss_atkleft4 ] { d2bossmove( 20, 1 ); }
void() d2boss_atkleft4 =[ $swingl4, d2boss_atkleft5 ] { d2bossmove( 18, 1 ); }
void() d2boss_atkleft5 =[ $swingl5, d2boss_atkleft6 ] { d2bossmove( 16, 1 ); }
void() d2boss_atkleft6 =[ $swingl6, d2boss_atkleft7 ] { d2bossmove( 16, 1 ); d2bossMissile(-64, 12, 0); ai_attack_finished(2);}
void() d2boss_atkleft7 =[ $swingl7, d2boss_atkleft8 ] { d2bossmove( 16, 1 ); }
void() d2boss_atkleft8 =[ $swingl8, d2boss_atkleft9 ] { d2bossmove( 16, 1 ); }
void() d2boss_atkleft9 =[ $swingl9, d2boss_run1     ] { ai_face(); if ( self.boss_attacksleft > 0 ) d2boss_atkright1(); }

void() d2boss_atkright1 =[ $swingr1, d2boss_atkright2 ] { sound (self, CHAN_VOICE, "d1boss/atk.wav", 1, ATTN_NORM); ai_nop(); self.boss_attacksleft -= 1; }
void() d2boss_atkright2 =[ $swingr2, d2boss_atkright3 ] { d2bossmove( 24, 0 ); }
void() d2boss_atkright3 =[ $swingr3, d2boss_atkright4 ] { d2bossmove( 20, 0 ); }
void() d2boss_atkright4 =[ $swingr4, d2boss_atkright5 ] { d2bossmove( 18, 0 ); }
void() d2boss_atkright5 =[ $swingr5, d2boss_atkright6 ] { d2bossmove( 16, 0 ); }
void() d2boss_atkright6 =[ $swingr6, d2boss_atkright7 ] { d2bossmove( 16, 0 ); d2bossMissile(64, 12, 0); ai_attack_finished(2);}
void() d2boss_atkright7 =[ $swingr7, d2boss_atkright8 ] { d2bossmove( 16, 0 ); }
void() d2boss_atkright8 =[ $swingr8, d2boss_atkright9 ] { d2bossmove( 16, 0 ); }
void() d2boss_atkright9 =[ $swingr9, d2boss_run1      ] { ai_face(); if ( self.boss_attacksleft > 0 ) d2boss_atkleft1(); }

void() d2boss_phase1  =[ $phase1,  d2boss_phase2  ] { ai_nop(); sound (self, CHAN_VOICE, "d1boss/phasechange.wav", 1, ATTN_NONE); }
void() d2boss_phase2  =[ $phase2,  d2boss_phase3  ] { }
void() d2boss_phase3  =[ $phase3,  d2boss_phase4  ] { }
void() d2boss_phase4  =[ $phase4,  d2boss_phase5  ] { }
void() d2boss_phase5  =[ $phase5,  d2boss_phase6  ] { }
void() d2boss_phase6  =[ $phase6,  d2boss_phase7  ] { }
void() d2boss_phase7  =[ $phase7,  d2boss_phase8  ] { }
void() d2boss_phase8  =[ $phase8,  d2boss_phase9  ] { }
void() d2boss_phase9  =[ $phase9,  d2boss_phase10 ] { }
void() d2boss_phase10 =[ $phase10, d2boss_phase11 ] { }
void() d2boss_phase11 =[ $phase11, d2boss_phase12 ] { }
void() d2boss_phase12 =[ $phase12, d2boss_phase13 ] { }
void() d2boss_phase13 =[ $phase13, d2boss_phase14 ] { }
void() d2boss_phase14 =[ $phase14, d2boss_phase15 ] { }
void() d2boss_phase15 =[ $phase15, d2boss_phase16 ] { }
void() d2boss_phase16 =[ $phase16, d2boss_phase17 ] { }
void() d2boss_phase17 =[ $phase17, d2boss_phase18 ] { }
void() d2boss_phase18 =[ $phase18, d2boss_phase19 ] { }
void() d2boss_phase19 =[ $phase19, d2boss_phase20 ] { }
void() d2boss_phase20 =[ $phase20, d2boss_phase21 ] { }
void() d2boss_phase21 =[ $phase21, d2boss_phase22 ] { }
void() d2boss_phase22 =[ $phase22, d2boss_phase23 ] { ThrowGibBoss ("progs/gib3.mdl", 100); ThrowGibBoss ("progs/gib2.mdl", 50); }
void() d2boss_phase23 =[ $phase23, d2boss_phase24 ] { ThrowGibBoss ("progs/gib3.mdl", 50); ThrowGibBoss ("progs/gib1.mdl", 100); }
void() d2boss_phase24 =[ $phase24, d2boss_phase25 ] { ThrowGibBoss ("progs/gib1.mdl", 50); ThrowGibBoss ("progs/gib1.mdl", 100); }
void() d2boss_phase25 =[ $phase25, d2boss_phase26 ] { }
void() d2boss_phase26 =[ $phase26, d2boss_phase27 ] { }
void() d2boss_phase27 =[ $phase27, d2boss_phase28 ] { }
void() d2boss_phase28 =[ $phase28, d2boss_phase29 ] { }
void() d2boss_phase29 =[ $phase29, d2boss_phase30 ] { }
void() d2boss_phase30 =[ $phase30, d2boss_phase31 ] { }
void() d2boss_phase31 =[ $phase31, d2boss_phase32 ] { }
void() d2boss_phase32 =[ $phase32, d2boss_phase33 ] { }
void() d2boss_phase33 =[ $phase33, d2boss_phase34 ] { }
void() d2boss_phase34 =[ $phase34, d2boss_phase35 ] { }
void() d2boss_phase35 =[ $phase35, d2boss_sleep_frame] { d2boss_sleepreset(); }


void() d2boss_sleep_frame =                
{                                          
	if ( self.attack_finished < time ) 
	{ 
		self.velocity = '0 0 0';   
		self.avelocity = '0 0 0';                          
	}

	self.think = d2boss_sleep_frame;
	self.nextthink = time + 0.1;
};

void() d2boss_sleepreset =
{
	entity dest;

	d2boss_bbox_setfield(takedamage, DAMAGE_AIM);
	self.health = d2boss_HEALTH;

	dest = find( world, targetname, self.include );
	setorigin( self, dest.origin );
	self.ideal_yaw = vectoyaw(dest.angles); 
	ChangeYaw ();

	d2boss_stand1();
};


void() d2boss_startsleep =
{
	d2boss_bbox_setfield(takedamage, DAMAGE_NO);
	self.health = 1;
	self.enemy = self.goalentity = world;

	d2boss_phase1();
};


float() d2boss_checkdeath =
{
	if ( self.state ) 
	{
		d2boss_startsleep();
		
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
		d2boss_death1();
		//SUB_UseTargetsByField( target4 );
		//self.target4 = "";
		return FALSE;
	}
};


void() d2boss_death1  =[ $phase1,  d2boss_death2  ] { sound (self, CHAN_VOICE, "d1boss/death.wav", 1, ATTN_NORM); self.solid = SOLID_NOT; }
void() d2boss_death2  =[ $phase2,  d2boss_death3  ] { }
void() d2boss_death3  =[ $phase3,  d2boss_death4  ] { }
void() d2boss_death4  =[ $phase4,  d2boss_death5  ] { }
void() d2boss_death5  =[ $phase5,  d2boss_death6  ] { }
void() d2boss_death6  =[ $phase6,  d2boss_death7  ] { }
void() d2boss_death7  =[ $phase7,  d2boss_death8  ] { }
void() d2boss_death8  =[ $phase8,  d2boss_death9  ] { }
void() d2boss_death9  =[ $phase9,  d2boss_death10 ] { }
void() d2boss_death10 =[ $phase10, d2boss_death11 ] { }
void() d2boss_death11 =[ $phase11, d2boss_death12 ] { }
void() d2boss_death12 =[ $phase12, d2boss_death13 ] { }
void() d2boss_death13 =[ $phase13, d2boss_death14 ] { }
void() d2boss_death14 =[ $phase14, d2boss_death15 ] { }
void() d2boss_death15 =[ $phase15, d2boss_death16 ] { }
void() d2boss_death16 =[ $phase16, d2boss_death17 ] { }
void() d2boss_death17 =[ $phase17, d2boss_death18 ] { }
void() d2boss_death18 =[ $phase18, d2boss_death19 ] { }
void() d2boss_death19 =[ $phase19, d2boss_death20 ] { }
void() d2boss_death20 =[ $phase20, d2boss_death21 ] { }
void() d2boss_death21 =[ $phase21, d2boss_death22 ] { }
void() d2boss_death22 =[ $phase22, d2boss_death23 ] { ThrowGibBoss ("progs/gib1.mdl", 100 + random() * 50); }
void() d2boss_death23 =[ $phase23, d2boss_death24 ] { ThrowGibBoss ("progs/gib2.mdl", 100 + random() * 50); }
void() d2boss_death24 =[ $phase24, d2boss_death25 ] { ThrowGibBoss ("progs/gib3.mdl", 100 + random() * 50);	ThrowGibBoss ("progs/gib2.mdl", 100 + random() * 50); }
void() d2boss_death25 =[ $phase25, d2boss_death26 ] { ThrowGibBoss ("progs/gib2.mdl", 100 + random() * 50);	ThrowGibBoss ("progs/gib3.mdl", 100 + random() * 50); }
void() d2boss_death26 =[ $phase26, d2boss_death27 ] { ThrowGibBoss ("progs/gib2.mdl", 100 + random() * 50);	ThrowGibBoss ("progs/gib2.mdl", 100 + random() * 50); }
void() d2boss_death27 =[ $phase27, d2boss_death28 ] { ThrowGibBoss ("progs/gib3.mdl", 100 + random() * 50);	ThrowGibBoss ("progs/gib3.mdl", 100 + random() * 50); }
void() d2boss_death28 =[ $phase28, d2boss_death29 ] { ThrowHead ("progs/gib1.mdl", -300); }
void() d2boss_death29 =[ $phase29, d2boss_death30 ] { ThrowGibBoss ("progs/gib1.mdl", 100 + random() * 50);	ThrowGibBoss ("progs/gib2.mdl", 100 + random() * 50); }
void() d2boss_death30 =[ $phase30, d2boss_death31 ] { ThrowGibBoss ("progs/gib3.mdl", 100 + random() * 50);	ThrowGibBoss ("progs/gib2.mdl", 100 + random() * 50); }
void() d2boss_death31 =[ $phase31, d2boss_death32 ] { }
void() d2boss_death32 =[ $phase32, d2boss_death33 ] { }
void() d2boss_death33 =[ $phase33, d2boss_death34 ] { }
void() d2boss_death34 =[ $phase34, d2boss_death35 ] { }
void() d2boss_death35 =[ $phase35, d2boss_death1  ] { PostDeathLogic(); SUB_UseTargetsByField( target4 ); self.target4 = ""; }


void() d2boss_die =
{

	d2boss_death1();
};


void(entity attacker, float damage) d2boss_Pain =
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


void() d2boss_chooseattack =
{
	if ( random() > 0.8 && !self.boss_lastattack )
		d2boss_atkbig1();
	else 
	{
		self.boss_lastattack = 0; // we can do big attack again
		//self.boss_attacksleft = 2; // limit our attacks to avoid endless loop
		
		if ( random() > 0.5 )
		{
			self.boss_attacksleft = 3;  // three attacks total when dashing, change to 2 if you don't like this
			if ( random() > 0.5 )
				d2boss_dashl1();
			else 
				d2boss_dashr1();
		}
		else
		{	
			self.boss_attacksleft = 2; 
			if ( random() > 0.5 )
				d2boss_atkleft1();
			else 
				d2boss_atkright1();
		}
	}
};


void() d2boss_createentities = {
	// pain controller, to add up hits on simultaneous bbox entities at the same frame
	entity pc = spawn();
	self.trigger_field = pc;
	pc.owner = self;
	pc.classname = "d2boss_paincontroller";
	pc.think = d2boss_paincontroller_think;

	vector coords[] = {
		'0 0 112',
		'0 0 -112',
		'0 32 80',
		'0 32 -80',
		'0 -32 80',
		'0 -32 -80',
		'0 64 48',
		'0 64 -48',
		'0 -64 48',
		'0 -64 -48',
		'0 96 16',
		'0 96 -16',
		'0 -96 16',
		'0 -96 -16',
		'32 0 80',
		'32 0 -80',
		'-32 0 80',
		'-32 0 -80',
		'32 32 80',
		'32 32 -80',
		'32 -32 80',
		'32 -32 -80',
		'-32 32 80',
		'-32 32 -80',
		'-32 -32 80',
		'-32 -32 -80',
		'32 64 48',
		'32 64 -48',
		'32 -64 48',
		'32 -64 -48',
		'-32 64 48',
		'-32 64 -48',
		'-32 -64 48',
		'-32 -64 -48',
		'32 96 16',
		'32 96 -16',
		'32 -96 16',
		'32 -96 -16',
		'-32 96 16',
		'-32 96 -16',
		'-32 -96 16',
		'-32 -96 -16',
		'64 0 48',
		'64 0 -48',
		'-64 0 48',
		'-64 0 -48',
		'64 32 48',
		'64 32 -48',
		'64 -32 48',
		'64 -32 -48',
		'-64 32 48',
		'-64 32 -48',
		'-64 -32 48',
		'-64 -32 -48',
		'64 64 48',
		'64 64 -48',
		'64 -64 48',
		'64 -64 -48',
		'-64 64 48',
		'-64 64 -48',
		'-64 -64 48',
		'-64 -64 -48',
		'64 96 16',
		'64 96 -16',
		'64 -96 16',
		'64 -96 -16',
		'-64 96 16',
		'-64 96 -16',
		'-64 -96 16',
		'-64 -96 -16',
		'96 0 16',
		'96 0 -16',
		'-96 0 16',
		'-96 0 -16',
		'96 32 16',
		'96 32 -16',
		'96 -32 16',
		'96 -32 -16',
		'-96 32 16',
		'-96 32 -16',
		'-96 -32 16',
		'-96 -32 -16',
		'96 64 16',
		'96 64 -16',
		'96 -64 16',
		'96 -64 -16',
		'-96 64 16',
		'-96 64 -16',
		'-96 -64 16',
		'-96 -64 -16',
		'96 96 0',
		'96 -96 0',
		'-96 96 0',
		'-96 -96 0'
	};
	vector ofs, org;

	entity e, next;
	e = spawn();
	self.buddy = e;
	e.owner = self;
	e.classname = "d2boss_bboxcontroller";
	e.think = d2boss_bboxcontroller_think;
	e.nextthink = time + 0.05;

	//makevectors([-self.angles_x, self.angles_y, self.angles_z]);
	makevectors (self.angles);

	for (float i = 0; i < 94; i++) {
		next = spawn();
		next.classname = "d2boss_bbox";
		next.movetype = MOVETYPE_FLY;
		next.solid = SOLID_BBOX;
		next.th_pain = d2boss_bbox_pain;
		next.takedamage = DAMAGE_AIM;
		next.health = 10000000000;
		
		ofs = coords[i];
		next.view_ofs = ofs;

		org = self.origin + v_forward * ofs_x + v_right * ofs_y + v_up * ofs_z;
		setorigin(next, org);

		setsize(next, '-24 -24 -24', '24 24 24');
		
		next.owner = self;

		e.buddy = next;
		e = next;
	}

}


void(.float fld, float value) d2boss_bbox_setfield = {
	entity e = self.buddy.buddy; // first bbox

	while (e) {
		if (e.classname == "d2boss_bbox") {
			e.fld = value;
			e = e.buddy;
		}
	}
}

void(entity attacker, float damage) d2boss_bbox_pain = {
	entity pc = self.owner.trigger_field;

	// "state" field set in T_RadiusDamageCheck() function if it was a radius damage
	// In this case, don't add up damage from multiple bbox entities or else the damage would be multiplied
	if (self.state){
		if (damage > pc.multi_dmg) pc.multi_dmg = damage;
	}
	else
		pc.dmg += damage;

	self.state = 0;
	pc.enemy = attacker;
	pc.nextthink = time + 0.01;
}

void() d2boss_paincontroller_think = {
	float totaldmg = max(self.dmg, self.multi_dmg);

	T_Damage(self.owner, self.enemy, self.enemy, totaldmg);

	dprint4("Damage: ", ftos(self.dmg), ", multi-damage: ", ftos(self.multi_dmg));
	dprint3(", total dmg: ", ftos(totaldmg), "\n");
	self.dmg = self.multi_dmg = 0;
	self.enemy = world;
}

void() d2boss_bboxcontroller_think = {
	makevectors(self.owner.angles);

	entity e = self.buddy;
	vector org, ofs;

	while (e) {
		ofs = e.view_ofs;

		org = self.owner.origin + v_forward * ofs_x + v_right * ofs_y + v_up * ofs_z;
		setorigin(e, org);
		
		e = e.buddy;
	}

	self.nextthink = time + 0.05;
}

void() monster_d2boss_spawn =
{
	self.classname = "monster_d2boss";
		
	self.solid = SOLID_NOT;
	self.takedamage = DAMAGE_NO;
	setmodel (self, "progs/mon_d2boss.mdl");
	setsize (self, '0 0 0', '0 0 0');

	self.distance = self.height = 320; 

	self.state = 3;
	self.type = "boss";
	self.th_stand = d2boss_channelling1; //d2boss_stand1;
	self.th_walk = d2boss_walk1;
	self.th_run = d2boss_run1;
	self.th_missile = d2boss_chooseattack;
	self.th_melee = d2boss_run1; //d2boss_dashr1;
	self.th_pain = d2boss_Pain;
	self.th_die = d2boss_die;
	self.th_checkattack = d2bossCheckAttack;
	self.th_checkdeath = d2boss_checkdeath;
	self.yaw_speed = 30;
	
	if ( self.deathtype == string_null )
		self.deathtype = " was killed by the Huge Fucking Octohedron";
	
	flymonster_start ();
	d2boss_createentities();
};


void() monster_d2boss_spawner = 
{
	mon_spawner_use(monster_d2boss_spawn);
};

/*QUAKED monster_wizard (1 0 0) (-16 -16 -24) (16 16 40) AMBUSH ? ? ? TRIGGERED NOTFOG NOTELEFRAG INSTAWAKE
Scrag (the WIZARD), 80 health points.

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
@PointClass base(Monster) size(-16 -16 -24, 16 16 40) model({ "path": ":progs/mon_d2boss.mdl" }) = monster_wizard : "Scrag" []
*/

void() monster_d2boss =
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
	
	precache_model ("progs/mon_d2boss.mdl");
	precache_model ("progs/h_shams.mdl");
	precache_model ("progs/proj_d1boss.mdl");
	
	precache_sound ("d1boss/dash.wav");
	precache_sound ("d1boss/atk.wav");
	precache_sound ("d1boss/death.wav");
	precache_sound ("d1boss/bigattack.wav");
	precache_sound ("d1boss/pain1.wav");
	precache_sound ("d1boss/pain2.wav");
	precache_sound ("d1boss/phasechange.wav");
	precache_sound ("d1boss/aggro.wav");
	precache_sound ("d1boss/return.wav");
	precache_sound ("d1boss/idle.wav");
	precache_sound ("d1boss/proj.wav");

	self.health = d2boss_HEALTH;
	setsize (self, '0 0 0', '0 0 0');
	//setsize (self, '-16 -16 -24', '16 16 40');
	
	if ( monster_spawnsetup( monster_d2boss_spawner ) )
		return;
	
	addmonster( 1 );
	monster_d2boss_spawn();
};