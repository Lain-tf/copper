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

};


void() d2boss_startsleep =
{
	d2boss_bbox_setfield(takedamage, DAMAGE_NO);
	self.health = 1;
	self.enemy = self.goalentity = world;

};


float() d2boss_checkdeath =
{
	if ( self.state ) 
	{
		d2boss_startsleep();
		
		if ( self.state == 3 ) 
		{
			//SUB_UseTargetsByField( target );
			//self.target = "";
		}
		else if ( self.state == 2 ) 
		{
			//SUB_UseTargetsByField( target2 );
			//self.target2 = "";
		}
		else if ( self.state == 1 ) 
		{
			//SUB_UseTargetsByField( target3 );
			//self.target3 = "";
		}
		
		self.state--;
		return TRUE;
	}
	else 
	{
		d2boss_death22();
		//SUB_UseTargetsByField( target4 );
		//self.target4 = "";
		return FALSE;
	}
};


void() d2boss_death22 =[ 7, d2boss_death23 ] { ThrowGibBoss ("progs/gib1.mdl", 100 + random() * 50); }
void() d2boss_death23 =[ 7, d2boss_death24 ] { ThrowGibBoss ("progs/gib2.mdl", 100 + random() * 50); }
void() d2boss_death24 =[ 7, d2boss_death25 ] { ThrowGibBoss ("progs/gib3.mdl", 100 + random() * 50);	ThrowGibBoss ("progs/gib2.mdl", 100 + random() * 50); }
void() d2boss_death25 =[ 7, d2boss_death26 ] { ThrowGibBoss ("progs/gib2.mdl", 100 + random() * 50);	ThrowGibBoss ("progs/gib3.mdl", 100 + random() * 50); }
void() d2boss_death26 =[ 7, d2boss_death27 ] { ThrowGibBoss ("progs/gib2.mdl", 100 + random() * 50);	ThrowGibBoss ("progs/gib2.mdl", 100 + random() * 50); }
void() d2boss_death27 =[ 7, d2boss_death28 ] { ThrowGibBoss ("progs/gib3.mdl", 100 + random() * 50);	ThrowGibBoss ("progs/gib3.mdl", 100 + random() * 50); }
void() d2boss_death28 =[ 7, d2boss_death29 ] { ThrowHead ("progs/gib1.mdl", -300); }
void() d2boss_death29 =[ 7, d2boss_death30 ] { ThrowGibBoss ("progs/gib1.mdl", 100 + random() * 50);	ThrowGibBoss ("progs/gib2.mdl", 100 + random() * 50); }
void() d2boss_death30 =[ 7, d2boss_death31 ] { ThrowGibBoss ("progs/gib3.mdl", 100 + random() * 50);	ThrowGibBoss ("progs/gib2.mdl", 100 + random() * 50); }
void() d2boss_death31 =[ 7, d2boss_death32 ] { }
void() d2boss_death32 =[ 7, d2boss_death33 ] { }
void() d2boss_death33 =[ 7, d2boss_death34 ] { }
void() d2boss_death34 =[ 7, d2boss_death35 ] { }
void() d2boss_death35 =[ 7, d2boss_death22 ] { PostDeathLogic(); SUB_UseTargetsByField( target4 ); self.target4 = ""; }


void() d2boss_die =
{
	d2boss_death22();
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

void() d2boss_wake =
{

}



void() d2boss_createentities =
{
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

// sets the specified float field on all bbox entities
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


/*QUAKED monster_d2boss (1 0 0) (-16 -16 -24) (16 16 40) AMBUSH ? ? ? TRIGGERED NOTFOG NOTELEFRAG INSTAWAKE
Scrag (the SCULPTOR), ??? health points.

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
@PointClass base(Monster) size(-16 -16 -24, 16 16 40) model({ "path": ":progs/mon_d2boss.mdl" }) = monster_d2boss : "The Sculptor" []
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
	
	precache_model ("progs/mon_d2boss_rot.mdl");
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
	//setsize (self, '-16 -16 -24', '16 16 40');
	
	addmonster(1);
		
	self.solid = SOLID_NOT;
	self.takedamage = DAMAGE_NO;
	self.movetype = MOVETYPE_FLY;
	setmodel (self, "progs/mon_d2boss_rot.mdl");
	setsize (self, '0 0 0', '0 0 0');
	
	self.frame = 7;

	self.state = 3;
	self.type = "boss";
	//self.th_stand = d2boss_channelling1; //d2boss_stand1;
	self.th_pain = d2boss_Pain;
	self.th_die = d2boss_die;
	self.th_checkdeath = d2boss_checkdeath;
	self.use = d2boss_wake;
	self.yaw_speed = 30;
	
	if ( self.deathtype == string_null )
		self.deathtype = " was killed by the Sculptor";

	//flymonster_start();
	d2boss_createentities();
};