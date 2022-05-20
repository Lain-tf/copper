/*
==============================================================================

Ep. 1 Boss

==============================================================================
*/


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

$frame smash1 smash2 smash3 smash4 smash5 
$frame smash6 smash7 smash8 smash9 smash10
$frame smash11 smash12 smash13 smash14 smash15 smash16
$frame smash17 smash18 smash19 smash20 smash21 smash22
$frame smash23 smash24

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


float D1BOSS_BALL_VEL = 750;
float D1BOSS_HEALTH = 1400; 
.float	track_finished;

float() D1BossCheckAttack = {
	//----------------------------------------------------------------------
	// Check Melee range and constantly fire
	//----------------------------------------------------------------------
	if (enemy_range < RANGE_MELEE) {
		self.attack_state = AS_MELEE;
		dprint("Melee\n");
		return TRUE;
	}
	
	
	//----------------------------------------------------------------------
	// Check Melee range without respect to height
	//----------------------------------------------------------------------
	local vector enemy_org, self_org;
	
	enemy_org = self.enemy.origin;
	self_org = self.origin;
	enemy_org_z = self_org_z;
	if (vlen(self_org - enemy_org) < 120 && (self.origin_z >= self.enemy.origin_z))
		{
		self.attack_state = AS_MELEE;
		return TRUE;		
		}
	
	
	//----------------------------------------------------------------------
	// Range attacks (Spit and Bomb)
	// Attack_chance override (percentage 0-1 chance)
	//----------------------------------------------------------------------
	// Only range attack if cooldown has finished
	if (time > self.attack_finished) {
		// Fast/intense nail/spit attack
		if (enemy_range < RANGE_NEAR) { 
			// Skill 0=3s, 1=2.25s, 2=1.5s, 3=0.75s
			//self.attack_speed = (4 - skill) * 0.75;
			//self.attack_finished = time + self.attack_speed + random();
			//self.attack_finished = time + 2 + random();
			self.attack_state = AS_MISSILE; //AS_MELEE;
			return TRUE;
		}
		// Large rocket bomb attack with floor damage
		else {
			// Skill 0=4s, 1=3s, 2=2s, 3=1s
			//self.attack_speed = (4 - skill) * 1;
			//self.attack_finished = time + self.attack_speed + random();
			//self.attack_finished = time + 3 + random();
			self.attack_state = AS_MISSILE;
			return TRUE;
		}
	}

	//----------------------------------------------------------------------
	// Maintain distance (strafe)
	//----------------------------------------------------------------------
	if (enemy_range >= RANGE_MID || !enemy_vis) {
		if (self.attack_state != AS_STRAIGHT) self.attack_state = AS_STRAIGHT;
	}
	else self.attack_state = AS_SLIDING;
	return FALSE;
};

/*
=================
WizardAttackFinished
=================
*/
void()	D1BossAttackFinished =
{
	if (enemy_range >= RANGE_MID || !enemy_vis)
	{
		self.attack_state = AS_STRAIGHT;
		self.think = d1boss_run1;
	}
	else
	{
		self.attack_state = AS_SLIDING;
		self.think = d1boss_side1;
	}
}

/*
==============================================================================

FAST ATTACKS

==============================================================================
*/
void() D1BossMissileExplode =
{
	T_RadiusDamage (self, self.trueowner, 55, world);
	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);

	BecomeExplosion();
}

void() D1BossMissileTouch =
{
	if (CheckProjectilePassthru()) return;
	if (other == self.owner)
		return;		// don't explode on owner

	if (other.type == "zombie")
		T_Damage (other, self, self.trueowner, other.health + 25);
	
	D1BossMissileExplode();
}

void() D1BossMissileHome =
{
	// a voreball with perfect homing causes combat to effectively stop, forcing the player
	// to run around around trying to shake it, often backpedaling through lots of empty map.
	// limiting the voreball's turn rate so they can be dodged and forgotten about makes vores
	// a more flexible enemy and more useful to the mapper
	float rate, dot;
	
	if (self.lifetime_finished < time)
	{
		D1BossMissileExplode();
		return;
	}		
	if (self.track_finished < time)
	{
		return;
	}
	
	if (!enemy_alive())
	{
		remove(self);
		return;
	}
	
	self.nextthink = time + SHAL_BALL_THINK_RATE;
	rate = SHAL_BALL_TURN_RATE;
	dot = normalize(self.velocity) * normalize(self.enemy.origin - self.origin);
	
	// reset our owner regularly, or else a voreball that passes through a notrace-invisible
	// player will become owned by the player and remain nonsolid to them after the ring ends
	self.owner = self.trueowner;
	// if the projectile is inside a notrace entity at this time, it'll touch again this frame
	// and reset anyway, so this state will pingpong until it passes out the other side
	
	// 'poor' homing (half turn rate):
	
	if (dot > 0)
	{
		rate *= max(1, 1.3 * (1 - dot));
	}
	self.velocity = D1BOSS_BALL_VEL * ShalTurnToward(self.enemy, rate * 0.7);
	
	
	// go faster at long distance to close the gap, so snipey vores have a better presence
	//dist = vlen(self.enemy.origin - self.origin);
	//dist = saturate( (dist-120) / 512 );
	//self.velocity *= 1 + dist;
	
	self.think = D1BossMissileHome;
	self.oldvelocity = self.velocity;
}

void() D1BossMissile =
{
	entity 	missile;
	vector	dir;


	//self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors(self.angles);
	
	dir = (enemy_vispos() + '0 0 -16') - self.origin + enemy_aim_vertical();
	dir = LeadTarget(self.origin, D1BOSS_BALL_VEL, random());
	dir = normalize(dir);
	
	// if player has strafed around behind, don't lob the missile out of our ass
	if (angledif(self.ideal_yaw, self.angles_y) > 80)
	{
		dir_x = v_forward_x;
		dir_y = v_forward_y;
		dir = LeadTarget(self.origin, D1BOSS_BALL_VEL, 1);
		dir = normalize(dir);
	}
	
	missile = launch_projectile(self.origin + v_forward * 16 + v_up * crandom()*10 + v_right * crandom()*8 + '0 0 72', dir * D1BOSS_BALL_VEL, "voreball");

	SUB_ChangeModel (missile, "progs/proj_d1boss.mdl");

	missile.avelocity = '300 300 300';
	missile.nextthink = time + 0.2;
	missile.think = D1BossMissileHome;
	missile.enemy = self.enemy;
	missile.touch = D1BossMissileTouch;
	missile.lifetime_finished = time + 5;	 // blow up after a while
	missile.track_finished = time + 1.25;
	sound (self, CHAN_WEAPON, "d1boss/proj.wav", 1, ATTN_NORM);

}



//============================================================================================



void() D1BossGrenade =
{
	entity 	missile;

	//self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors([70, random() * 360, 0]);
		
	missile = toss_projectile(self.origin + '0 0 80', v_forward * 400 + v_up * 100, "bossgrenade");
	SUB_ChangeModel (missile, "progs/proj_d1boss.mdl");

	missile.avelocity = '300 300 300';
	missile.nextthink = time + 0.2;
	missile.touch = D1BossMissileTouch;
	missile.lifetime_finished = time + 5;	 // blow up after a while

}


void() d1boss_idlesound =
{
	if (self.show_hostile > time) return;

	local float wr;
	wr = random() * 5;

	if (self.wait < time)
	{
	 	self.wait = time + 2;
	 	if (wr > 4.5) 
	 		sound (self, CHAN_VOICE, "d1boss/idle.wav", 1,  ATTN_IDLE);
	}
	return;
}

void(float instant) d1boss_changeheight =
{
	if (self.air_finished < time || instant) {
		self.height = (self.distance * 0.25) + (self.distance * 0.75 * random());
		self.air_finished = time + 3;
	}
}

void()	d1boss_stand1	=[	$stand1,		d1boss_stand2	] {ai_stand();}
void()	d1boss_stand2	=[	$stand2,		d1boss_stand3	] {ai_stand();}
void()	d1boss_stand3	=[	$stand3,		d1boss_stand4	] {ai_stand();}
void()	d1boss_stand4	=[	$stand4,		d1boss_stand5	] {ai_stand();}
void()	d1boss_stand5	=[	$stand5,		d1boss_stand6	] {ai_stand();}
void()	d1boss_stand6	=[	$stand6,		d1boss_stand7	] {ai_stand();}
void()	d1boss_stand7	=[	$stand7,		d1boss_stand8	] {ai_stand();}
void()	d1boss_stand8	=[	$stand8,		d1boss_stand9	] {ai_stand();}
void()	d1boss_stand9	=[	$stand9,		d1boss_stand10	] {ai_stand();}
void()	d1boss_stand10	=[	$stand10,		d1boss_stand11	] {ai_stand();}
void()	d1boss_stand11	=[	$stand11,		d1boss_stand12	] {ai_stand();}
void()	d1boss_stand12	=[	$stand12,		d1boss_stand13	] {ai_stand();}
void()	d1boss_stand13	=[	$stand13,		d1boss_stand14	] {ai_stand();}
void()	d1boss_stand14	=[	$stand14,		d1boss_stand15	] {ai_stand();}
void()	d1boss_stand15	=[	$stand15,		d1boss_stand16	] {ai_stand();}
void()	d1boss_stand16	=[	$stand16,		d1boss_stand17	] {ai_stand();}
void()	d1boss_stand17	=[	$stand17,		d1boss_stand18	] {ai_stand();}
void()	d1boss_stand18	=[	$stand18,		d1boss_stand19	] {ai_stand();}
void()	d1boss_stand19	=[	$stand19,		d1boss_stand20	] {ai_stand();}
void()	d1boss_stand20	=[	$stand20,		d1boss_stand21	] {ai_stand();}
void()	d1boss_stand21	=[	$stand21,		d1boss_stand22	] {ai_stand();}
void()	d1boss_stand22	=[	$stand22,		d1boss_stand23	] {ai_stand();}
void()	d1boss_stand23	=[	$stand23,		d1boss_stand1	] {ai_stand();}

void()	d1boss_walk1	=[	$stand1,		d1boss_walk2	] {ai_walk(24);d1boss_idlesound();}
void()	d1boss_walk2	=[	$stand2,		d1boss_walk3	] {ai_walk(24);}
void()	d1boss_walk3	=[	$stand3,		d1boss_walk4	] {ai_walk(24);}
void()	d1boss_walk4	=[	$stand4,		d1boss_walk5	] {ai_walk(24);}
void()	d1boss_walk5	=[	$stand5,		d1boss_walk6	] {ai_walk(24);}
void()	d1boss_walk6	=[	$stand6,		d1boss_walk7	] {ai_walk(24);}
void()	d1boss_walk7	=[	$stand7,		d1boss_walk8	] {ai_walk(24);}
void()	d1boss_walk8	=[	$stand8,		d1boss_walk9	] {ai_walk(24);}
void()	d1boss_walk9	=[	$stand9,		d1boss_walk10	] {ai_walk(24);}
void()	d1boss_walk10	=[	$stand10,		d1boss_walk11	] {ai_walk(24);}
void()	d1boss_walk11	=[	$stand11,		d1boss_walk12	] {ai_walk(24);}
void()	d1boss_walk12	=[	$stand12,		d1boss_walk13	] {ai_walk(24);}
void()	d1boss_walk13	=[	$stand13,		d1boss_walk14	] {ai_walk(24);}
void()	d1boss_walk14	=[	$stand14,		d1boss_walk15	] {ai_walk(24);}
void()	d1boss_walk15	=[	$stand15,		d1boss_walk16	] {ai_walk(24);}
void()	d1boss_walk16	=[	$stand16,		d1boss_walk17	] {ai_walk(24);}
void()	d1boss_walk17	=[	$stand17,		d1boss_walk18	] {ai_walk(24);}
void()	d1boss_walk18	=[	$stand18,		d1boss_walk19	] {ai_walk(24);}
void()	d1boss_walk19	=[	$stand19,		d1boss_walk20	] {ai_walk(24);}
void()	d1boss_walk20	=[	$stand20,		d1boss_walk21	] {ai_walk(24);}
void()	d1boss_walk21	=[	$stand21,		d1boss_walk22	] {ai_walk(24);}
void()	d1boss_walk22	=[	$stand22,		d1boss_walk23	] {ai_walk(24);}
void()	d1boss_walk23	=[	$stand23,		d1boss_walk1	] {ai_walk(24);}

void()	d1boss_side1	=[	$stand1,		d1boss_side2	] {d1boss_changeheight(TRUE); ai_run(24);d1boss_idlesound();}
void()	d1boss_side2	=[	$stand2,		d1boss_side3	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_side3	=[	$stand3,		d1boss_side4	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_side4	=[	$stand4,		d1boss_side5	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_side5	=[	$stand5,		d1boss_side6	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_side6	=[	$stand6,		d1boss_side7	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_side7	=[	$stand7,		d1boss_side8	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_side8	=[	$stand8,		d1boss_side9	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_side9	=[	$stand9,		d1boss_side10	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_side10	=[	$stand10,		d1boss_side11	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_side11	=[	$stand11,		d1boss_side12	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_side12	=[	$stand12,		d1boss_side13	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_side13	=[	$stand13,		d1boss_side14	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_side14	=[	$stand14,		d1boss_side15	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_side15	=[	$stand15,		d1boss_side16	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_side16	=[	$stand16,		d1boss_side17	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_side17	=[	$stand17,		d1boss_side18	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_side18	=[	$stand18,		d1boss_side19	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_side19	=[	$stand19,		d1boss_side20	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_side20	=[	$stand20,		d1boss_side21	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_side21	=[	$stand21,		d1boss_side22	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_side22	=[	$stand22,		d1boss_side23	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_side23	=[	$stand23,		d1boss_side1	] {d1boss_changeheight(TRUE); ai_run(24);}

void()	d1boss_run1	=[	$stand1,		d1boss_run2	] {self.takedamage = DAMAGE_AIM; d1boss_changeheight(FALSE); ai_run(16);d1boss_idlesound();}
void()	d1boss_run2	=[	$stand2,		d1boss_run3	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_run3	=[	$stand3,		d1boss_run4	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_run4	=[	$stand4,		d1boss_run5	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_run5	=[	$stand5,		d1boss_run6	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_run6	=[	$stand6,		d1boss_run7	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_run7	=[	$stand7,		d1boss_run8	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_run8	=[	$stand8,		d1boss_run9	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_run9	=[	$stand9,		d1boss_run10	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_run10	=[	$stand10,		d1boss_run11	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_run11	=[	$stand11,		d1boss_run12	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_run12	=[	$stand12,		d1boss_run13	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_run13	=[	$stand13,		d1boss_run14	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_run14	=[	$stand14,		d1boss_run15	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_run15	=[	$stand15,		d1boss_run16	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_run16	=[	$stand16,		d1boss_run17	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_run17	=[	$stand17,		d1boss_run18	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_run18	=[	$stand18,		d1boss_run19	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_run19	=[	$stand19,		d1boss_run20	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_run20	=[	$stand20,		d1boss_run21	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_run21	=[	$stand21,		d1boss_run22	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_run22	=[	$stand22,		d1boss_run23	] {d1boss_changeheight(TRUE); ai_run(24);}
void()	d1boss_run23	=[	$stand23,		d1boss_run1	] {d1boss_changeheight(TRUE); ai_run(24);}

//Long attack
void()	d1boss_fast1	=[	$smash1,		d1boss_fast2	] {d1boss_changeheight(TRUE); ai_run_slide(10);sound (self, CHAN_VOICE, "d1boss/bigattack.wav", 1, ATTN_NORM);}
void()	d1boss_fast2	=[	$smash2,		d1boss_fast3	] {ai_run_slide(6);}
void()	d1boss_fast3	=[	$smash3,		d1boss_fast4	] {ai_run_slide(6);}
void()	d1boss_fast4	=[	$smash4,		d1boss_fast5	] {ai_run_slide(6);}
void()	d1boss_fast5	=[	$smash5,		d1boss_fast6	] {ai_run_slide(6);}
void()	d1boss_fast6	=[	$smash6,		d1boss_fast7	] {ai_run_slide(6);}
void()	d1boss_fast7	=[	$smash7,		d1boss_fast8	] {ai_run_slide(6);}
void()	d1boss_fast8	=[	$smash8,		d1boss_fast9	] {ai_run_slide(6);}
void()	d1boss_fast9	=[	$smash9,		d1boss_fast10	] {ai_run_slide(6);}
void()	d1boss_fast10	=[	$smash10,		d1boss_fast11	] {ai_run_slide(6);}
void()	d1boss_fast11	=[	$smash11,		d1boss_fast12	] {ai_run_slide(6);}
void()	d1boss_fast12	=[	$smash12,		d1boss_fast13	] {ai_run_slide(6);}
void()	d1boss_fast13	=[	$smash13,		d1boss_fast14	] {ai_run_slide(6);}
void()	d1boss_fast14	=[	$smash14,		d1boss_fast15	] {ai_run_slide(6);}
void()	d1boss_fast15	=[	$smash15,		d1boss_fast16	] {ai_run_slide(12);}
void()	d1boss_fast16	=[	$smash16,		d1boss_fast17	] {ai_run_slide(16);}
void()	d1boss_fast17	=[	$smash17,		d1boss_fast18	] {ai_run_slide(24);}
void()	d1boss_fast18	=[	$smash18,		d1boss_fast19	] {ai_run_slide(24);D1BossMissile();}
void()	d1boss_fast19	=[	$smash19,		d1boss_fast20	] {ai_run_slide(24);D1BossMissile();}
void()	d1boss_fast20	=[	$smash20,		d1boss_fast21	] {ai_run_slide(24);D1BossMissile();}
void()	d1boss_fast21	=[	$smash21,		d1boss_fast22	] {ai_run_slide(24);}
void()	d1boss_fast22	=[	$smash22,		d1boss_fast23	] {ai_run_slide(24);}
void()	d1boss_fast23	=[	$smash23,		d1boss_fast24	] {ai_run_slide(24);}
void()	d1boss_fast24	=[	$smash24,		d1boss_run1	] {ai_attack_finished(2);}

void()	d1boss_melee1	=[	$smash1,		d1boss_melee2	] {sound (self, CHAN_VOICE, "d1boss/atk.wav", 1, ATTN_NORM);}
void()	d1boss_melee2	=[	$smash2,		d1boss_melee3	] {D1BossGrenade();}
void()	d1boss_melee3	=[	$smash3,		d1boss_melee4	] {D1BossGrenade();}
void()	d1boss_melee4	=[	$smash4,		d1boss_melee5	] {D1BossGrenade();}
void()	d1boss_melee5	=[	$smash5,		d1boss_melee6	] {D1BossGrenade();}
void()	d1boss_melee6	=[	$smash6,		d1boss_melee7	] {D1BossGrenade();}
void()	d1boss_melee7	=[	$smash7,		d1boss_run1	] {ai_attack_finished(2);}

void() d1boss_swingl1	=[      $swingl1,      d1boss_swingl2   ] {
	sound (self, CHAN_VOICE, "d1boss/dash.wav", 1, ATTN_NORM);
	ai_nop();
}
void() d1boss_swingl2 =[      $swingl2,      d1boss_swingl3   ] {ai_run_slide(64);}
void() d1boss_swingl3 =[      $swingl3,      d1boss_swingl4   ] {ai_run_slide(50);}
void() d1boss_swingl4 =[      $swingl4,      d1boss_swingl5   ] {ai_run_slide(48);}
void() d1boss_swingl5 =[      $swingl5,      d1boss_swingl6   ] {ai_run_slide(32);}
void() d1boss_swingl6 =[      $swingl6,      d1boss_swingl7   ] {ai_run_slide(8);D1BossMissile();}
void() d1boss_swingl7 =[      $swingl7,      d1boss_swingl8   ] {ai_run_slide(8);}
void() d1boss_swingl8 =[      $swingl8,      d1boss_swingl9   ] {ai_run_slide(8);}
void() d1boss_swingl9 =[      $swingl9,      d1boss_run1  ] {ai_run_slide(2); d1boss_swinogr1();}

void() d1boss_swingr1	=[      $swingr1,      d1boss_swingr2   ] {
	sound (self, CHAN_VOICE, "d1boss/dash.wav", 1, ATTN_NORM);
	ai_nop();
}
void() d1boss_swingr2 =[      $swingr2,      d1boss_swingr3   ] {ai_run_slide(64);}
void() d1boss_swingr3 =[      $swingr3,      d1boss_swingr4   ] {ai_run_slide(50);}
void() d1boss_swingr4 =[      $swingr4,      d1boss_swingr5   ] {ai_run_slide(48);}
void() d1boss_swingr5 =[      $swingr5,      d1boss_swingr6   ] {ai_run_slide(32);}
void() d1boss_swingr6 =[      $swingr6,      d1boss_swingr7   ] {ai_run_slide(8);D1BossMissile();}
void() d1boss_swingr7 =[      $swingr7,      d1boss_swingr8   ] {ai_run_slide(8);}
void() d1boss_swingr8 =[      $swingr8,      d1boss_swingr9   ] {ai_run_slide(8);}
void() d1boss_swingr9 =[      $swingr9,      d1boss_run1  ] {ai_run_slide(2); d1boss_swinogr1();}

void() d1boss_swinogl1	=[      $swingl1,      d1boss_swinogl2   ] {
	sound (self, CHAN_VOICE, "d1boss/atk.wav", 1, ATTN_NORM);
	ai_nop();
}
void() d1boss_swinogl2 =[      $swingl2,      d1boss_swinogl3   ] {ai_run_slide(16);}
void() d1boss_swinogl3 =[      $swingl3,      d1boss_swinogl4   ] {ai_run_slide(16);}
void() d1boss_swinogl4 =[      $swingl4,      d1boss_swinogl5   ] {ai_run_slide(16);}
void() d1boss_swinogl5 =[      $swingl5,      d1boss_swinogl6   ] {ai_run_slide(16);}
void() d1boss_swinogl6 =[      $swingl6,      d1boss_swinogl7   ] {ai_run_slide(16); D1BossMissile();}
void() d1boss_swinogl7 =[      $swingl7,      d1boss_swinogl8   ] {ai_run_slide(16);}
void() d1boss_swinogl8 =[      $swingl8,      d1boss_swinogl9   ] {ai_run_slide(16);}
void() d1boss_swinogl9 =[      $swingl9,      d1boss_run1  ] {ai_face(); d1boss_swinogr1();}

void() d1boss_swinogr1	=[      $swingr1,      d1boss_swinogr2   ] {
	sound (self, CHAN_VOICE, "d1boss/atk.wav", 1, ATTN_NORM);
	ai_nop();
}
void() d1boss_swinogr2 =[      $swingr2,      d1boss_swinogr3   ] {ai_run_slide(16);}
void() d1boss_swinogr3 =[      $swingr3,      d1boss_swinogr4   ] {ai_run_slide(16);}
void() d1boss_swinogr4 =[      $swingr4,      d1boss_swinogr5   ] {ai_run_slide(16);}
void() d1boss_swinogr5 =[      $swingr5,      d1boss_swinogr6   ] {ai_run_slide(16);}
void() d1boss_swinogr6 =[      $swingr6,      d1boss_swinogr7   ] {ai_run_slide(16); D1BossMissile();}
void() d1boss_swinogr7 =[      $swingr7,      d1boss_swinogr8   ] {ai_run_slide(16);}
void() d1boss_swinogr8 =[      $swingr8,      d1boss_swinogr9   ] {ai_run_slide(16);}
void() d1boss_swinogr9 =[      $swingr9,      d1boss_run1  ] {ai_face(); ai_attack_finished(1);}

void()	d1boss_phase1	=[	$phase1,	d1boss_phase2	] {ai_face();
	sound (self, CHAN_VOICE, "d1boss/phasechange.wav", 1, ATTN_NONE);
}
void()	d1boss_phase2	=[	$phase2,	d1boss_phase3	] {ai_face();}
void()	d1boss_phase3	=[	$phase3,	d1boss_phase4	] {ai_face();}
void()	d1boss_phase4	=[	$phase4,	d1boss_phase5	] {ai_face();}
void()	d1boss_phase5	=[	$phase5,	d1boss_phase6	] {ai_face();}
void()	d1boss_phase6	=[	$phase6,	d1boss_phase7	] {ai_face();}
void()	d1boss_phase7	=[	$phase7,	d1boss_phase8	] {ai_face();}
void()	d1boss_phase8	=[	$phase8,	d1boss_phase9	] {ai_face();}
void()	d1boss_phase9	=[	$phase9,	d1boss_phase10	] {ai_face();}
void()	d1boss_phase10	=[	$phase10,	d1boss_phase11	] {ai_face();}
void()	d1boss_phase11	=[	$phase11,	d1boss_phase12	] {ai_face();}
void()	d1boss_phase12	=[	$phase12,	d1boss_phase13	] {ai_face();}
void()	d1boss_phase13	=[	$phase13,	d1boss_phase14	] {ai_face();}
void()	d1boss_phase14	=[	$phase14,	d1boss_phase15	] {ai_face();}
void()	d1boss_phase15	=[	$phase15,	d1boss_phase16	] {ai_face();}
void()	d1boss_phase16	=[	$phase16,	d1boss_phase17	] {ai_face();
	ThrowGib ("progs/gib3.mdl", 100); //TODO: Figure out how the fuck to raise these from self.origin
	ThrowGib ("progs/gib2.mdl", 50);
}
void()	d1boss_phase17	=[	$phase17,	d1boss_phase18	] {ai_face();
	ThrowGib ("progs/gib3.mdl", 50);
	ThrowGib ("progs/gib1.mdl", 100);
	ThrowGib ("progs/gib1.mdl", 50);
	ThrowGib ("progs/gib1.mdl", 100);
}
void()	d1boss_phase18	=[	$phase18,	d1boss_phase19	] {ai_face();}
void()	d1boss_phase19	=[	$phase19,	d1boss_phase20	] {ai_face();}
void()	d1boss_phase20	=[	$phase20,	d1boss_phase21	] {ai_face();}
void()	d1boss_phase21	=[	$phase21,	d1boss_phase22	] {ai_face();}
void()	d1boss_phase22	=[	$phase22,	d1boss_phase23	] {ai_face();}
void()	d1boss_phase23	=[	$phase23,	d1boss_phase24	] {ai_face();}
void()	d1boss_phase24	=[	$phase24,	d1boss_phase25	] {ai_face();}
void()	d1boss_phase25	=[	$phase25,	d1boss_phase26	] {ai_face();}
void()	d1boss_phase26	=[	$phase26,	d1boss_phase27	] {ai_face();}
void()	d1boss_phase27	=[	$phase27,	d1boss_phase28	] {ai_face();}
void()	d1boss_phase28	=[	$phase28,	d1boss_phase29	] {ai_face();}
void()	d1boss_phase29	=[	$phase29,	d1boss_phase30	] {ai_face();}
void()	d1boss_phase30	=[	$phase30,	d1boss_phase31	] {ai_face();}
void()	d1boss_phase31	=[	$phase31,	d1boss_phase32	] {ai_face();}
void()	d1boss_phase32	=[	$phase32,	d1boss_phase33	] {ai_face();}
void()	d1boss_phase33	=[	$phase33,	d1boss_phase34	] {ai_face();}
void()	d1boss_phase34	=[	$phase34,	d1boss_phase35	] {ai_face();}
void()	d1boss_phase35	=[	$phase35,	d1boss_sleep_frame] {}
                                                                   
                                           
void() d1boss_sleep_frame =                
{                                          
	if (self.attack_finished < time) { 
		self.velocity = '0 0 0';   
		self.avelocity = '0 0 0';                          
	}

	self.think = d1boss_sleep_frame;
	self.nextthink = time + 0.1;
};

void() d1boss_startsleep =
{
	entity dest;
	vector vdestdelta;
	float traveltime, len;
	float yawdelta;

	self.takedamage = DAMAGE_NO;
	self.health = D1BOSS_HEALTH;
	self.enemy = self.goalentity = world;
	dest = find(world, targetname, self.include);
	

	vdestdelta = dest.origin - self.origin;
	len = vlen (vdestdelta);
	traveltime = len / 150;
	self.velocity = vdestdelta * (1/traveltime);
	self.attack_finished = time + traveltime;

	yawdelta = dest.angles_y - self.angles_y;
	self.avelocity_y = yawdelta/traveltime;

	d1boss_phase1();
}

float() d1boss_checkdeath =
{
	if (self.state) {
		d1boss_startsleep();
		
		if (self.state == 3) {
			SUB_UseTargetsByField(target);
			self.target = "";
		}
		else if (self.state == 2) {
			SUB_UseTargetsByField(target2);
			self.target2 = "";
		}
		else if (self.state == 1) {
			SUB_UseTargetsByField(target3);
			self.target3 = "";
		}
		self.state--;
		return TRUE;
	}
	else {
		SUB_UseTargetsByField(target4);
		self.target4 = "";
		return FALSE;
	}

}

void()	d1boss_death1	=[	$phase1,		d1boss_death2	] {
	sound (self, CHAN_VOICE, "d1boss/death.wav", 1, ATTN_NORM);
	self.solid = SOLID_NOT;
}
void()	d1boss_death2	=[	$phase2,		d1boss_death3	] {}
void()	d1boss_death3	=[	$phase3,		d1boss_death4	] {}
void()	d1boss_death4	=[	$phase4,		d1boss_death5	] {}
void()	d1boss_death5	=[	$phase5,		d1boss_death6	] {}
void()	d1boss_death6	=[	$phase6,		d1boss_death7	] {}
void()	d1boss_death7	=[	$phase7,		d1boss_death8	] {}
void()	d1boss_death8	=[	$phase8,		d1boss_death9	] {}
void()	d1boss_death9	=[	$phase9,		d1boss_death10	] {}
void()	d1boss_death10	=[	$phase10,		d1boss_death11	] {}
void()	d1boss_death11	=[	$phase11,		d1boss_death12	] {}
void()	d1boss_death12	=[	$phase12,		d1boss_death13	] {}
void()	d1boss_death13	=[	$phase13,		d1boss_death14	] {}
void()	d1boss_death14	=[	$phase14,		d1boss_death15	] {}
void()	d1boss_death15	=[	$phase15,		d1boss_death16	] {}
void()	d1boss_death16	=[	$phase16,		d1boss_death17	] {}
void()	d1boss_death17	=[	$phase17,		d1boss_death18	] {}
void()	d1boss_death18	=[	$phase18,		d1boss_death19	] {}
void()	d1boss_death19	=[	$phase19,		d1boss_death20	] {}
void()	d1boss_death20	=[	$phase20,		d1boss_death21	] {}
void()	d1boss_death21	=[	$phase21,		d1boss_death22	] {}
void()	d1boss_death22	=[	$phase22,		d1boss_death1	] {PostDeathLogic();}


void() d1boss_die =
{
	d1boss_death1 ();
}

void(entity attacker, float damage) d1boss_Pain =
{
	if (self.health <= 0) return;	

	if ((random() * 70) + 20 > damage)
	{
		return;
	}
	
	if ((random() > 0.5))
	{
	sound (self, CHAN_VOICE, "d1boss/pain1.wav", 1, ATTN_NORM);
	}
	else if ((random() > .75))
	{
	sound (self, CHAN_VOICE, "d1boss/pain2.wav", 1, ATTN_NORM);		
	}
	else
	{
		return;
	}
};

void() d1boss_chooseattack =
{
	if (random() > 0.8)
		d1boss_fast1();
	else if (random() > .5)
		d1boss_swingl1();
	else
		d1boss_swinogl1();
}



void() monster_d1boss_spawn =
{
	self.classname = "monster_d1boss";
		
	self.solid = SOLID_SLIDEBOX;
	//self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/mon_d1boss.mdl");

	setsize (self, '-32 -32 -96', '32 32 96');

	self.health = D1BOSS_HEALTH;
	self.distance = self.height = 192;
	//self.customflags = self.customflags | CFL_CHECKDEATH;

	self.state = 3;
	self.type = "boss";
	
	self.th_stand = d1boss_stand1;
	self.th_walk = d1boss_walk1;
	self.th_run = d1boss_run1;
	self.th_missile = d1boss_chooseattack;
	self.th_melee = d1boss_melee1;
	self.th_pain = d1boss_Pain;
	self.th_die = d1boss_die;
	self.th_checkattack = D1BossCheckAttack;
	self.th_checkdeath = d1boss_checkdeath;
	self.yaw_speed = 30;

	if (self.deathtype == string_null)
		self.deathtype = "was obliterated by Ryan";

	flymonster_start ();
}

void() monster_d1boss_spawner = {mon_spawner_use(monster_d1boss_spawn);}

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
@PointClass base(Monster) size(-16 -16 -24, 16 16 40) model({ "path": ":progs/mon_d1boss.mdl" }) = monster_wizard : "Scrag" []
*/
void() monster_d1boss =
{
	if (!SUB_ShouldSpawn()) return;
	if (nomonster()) return;
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/mon_d1boss.mdl");
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

	self.health = D1BOSS_HEALTH;
	//setsize (self, '-16 -16 -24', '16 16 40');
	setsize (self, '-32 -32 -96', '32 32 96');
	if ( monster_spawnsetup( monster_d1boss_spawner ) ) return;
	
	addmonster(1);
	monster_d1boss_spawn();
}




