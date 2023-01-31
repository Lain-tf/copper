/*
==============================================================================

Ep. 2 Boss

CODE STRUCTURE

This is a huge fucking complex thing. The boss entity itself (which we'll refer as the main entity)
doesn't have any collision, instead it has 94 small bboxes that follow the overall model shape and
translate/rotate with it.

I've abandoned the idea of making it an actual monster, because we won't be using any AI function
in it, so everything must be handled here - like kill counter, firing targets on death, turning to
non-solid etc.

The main entity has 2 controllers attached:

- Thinker (stored on the .eChildC field): General think loop. Since the main entity's think functions
  are reserved to movement, every other logic is handled here. It decides when it'll fire a volley
  at the player, when it'll go to the center to fire a bullet hell, and also keeps the entity
  turned to the player on phase 2.
  The collision bboxes are attached to the boss .hitbox field in a linked list (each one's
  .buddy points to the next), and this entity also updates their origin relative to the main
  entity's origin/angles through some sick maths.

- Pain controller (stored on the .eChildD field): Controls the damage received on the
  individual bboxes and applies them to the main entity. Necessary because it has to manage
  multi-damage from T_RadiusDamage explosions.

All of the attached entities, including each bbox segment, point back to the main entity through
their .owner field.

All the functions whose names don't with "think" assume that "self" points to the main entity.

HOW TO USE IT

The boss entity moves on path_corners. The .include field must point to the first path_corner in the
room, from which it'll begin its loop. .target2 points to another path_corner at the center of the
room, where it'll move to initiate the bullet hell sequence.

At every few seconds, the boss will fire a project volley at the player. Randomly, it may instead
initiate the bullet hell sequence: it moves to the central path_corner at the center of the room
(pointed by its .target2 field), and that central path_corner will fire its targets. Here, you must
set up relays to manage the whole sequence - show up beams, shake the screen, etc - as well as fire
the target_bullethell entity. While all this happens, the boss entity will sit there waiting, and
will only resume its path after triggered again, so you must include that into the relay sequence
as well.

At the first phase, the boss will have the initial "closed" model, and will always be facing down.
When given enough damage, it'll fire .target3 and turn to phase 2. Then, its model will be changed
to the eye one, and will be constantly facing the player.

When it dies completely, .target4 gets fired.

==============================================================================
*/

const float D2BOSS_BALL_VEL 	= 750;
const float D2BOSS_LOOKDOWN 	= -90;
const float D2BOSS_SHIELDALPHA 	= 0.5;
const float D2BOSS_BHROTATIONMULTIPLIER = -0.5;
const vector D2BOSS_GIBOFFSET = '0 0 -128';
const float D2BOSS_TRANSITION_SPEED = 2; // 0.1-1 or 1+, multiplier for lerp timer
const vector D2BOSS_SWARMOFFSET[7] = {'-1 0 0','1 0 0','0.5 -0.87 0','0.5 0.87 0','-0.5 -0.87 0','-0.5 0.87 0','0 0 0'};
const float D2BOSS_SWARMRADIUS	= 192;

const float	D2BOSS_SLEEPING		 = 0;
const float	D2BOSS_PHASECHANGE	 = 1;
const float D2BOSS_WAITFORSHIELD = 2;
const float	D2BOSS_TELEPORTING   = 3;
const float	D2BOSS_FLYING		 = 4;
const float	D2BOSS_IDLE			 = 5;
const float	D2BOSS_DEATH		 = 14;

.float	track_finished;


void() d2bossMissileExplode =
{
	local float skill_damage;
	
	if ( skill > 1 || coop )
		skill_damage = 80;
	else if ( skill == 1)
		skill_damage = 60;
	else 
		skill_damage = 20;
	
	T_RadiusDamage (self, self.trueowner, skill_damage, world);
	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NONE);

	BecomeExplosion();
};


void() d2bossMissileTouch =
{
	if ( CheckProjectilePassthru() ) 
		return;
	
	if ( other == self.owner || other.owner == self.owner)
	{
		SUB_Remove();
		return;		// don't explode on owner*/
	}

	if ( other.type == "zombie" )
		T_Damage (other, self, self.trueowner, other.health + 25);
	
	d2bossMissileExplode();
};


void() d2bossMissileHome =
{
	local float rate, dot;
	
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
	
	self.velocity = D2BOSS_BALL_VEL * ShalTurnToward( self.enemy, rate * 0.7 ); // 0.7
	self.think = d2bossMissileHome;
	self.oldvelocity = self.velocity;
};


vector(vector source, entity tgt, float misvel, float degree) d2boss_leadtarget =
{
	local vector vel, lead_offset, evel;
	
	vel = tgt.origin - source;
	// don't lead if you can't see the target
	if (has_invis(tgt))
		return vel;
	
	evel = tgt.velocity;
	if( !(tgt.flags & FL_ONGROUND) && fabs(evel_z) < 275 )
		evel_z = 0;	// ignore if the player is jumping around
	
	lead_offset = (vlen(vel) / misvel) * evel * degree;
	
	return vel + lead_offset;
};


void() d2bossMissile =
{
	local entity missile;
	local vector dir;
	local vector bossorg,playerorg;
	local float distcheck;
	local entity tgt;
	
	tgt = checkclient();
	//self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors([-self.angles_x, self.angles_y, self.angles_z]);
	
	dir = d2boss_leadtarget( self.origin, tgt, D2BOSS_BALL_VEL, random() );
	dir = normalize( dir );
	 
	bossorg = self.origin;
	bossorg_z = 0;
	playerorg = self.enemy.origin;
	playerorg_z = 0;
	distcheck = vlen(bossorg - playerorg);

	missile = launch_projectile( self.origin + (v_forward * 160), dir * D2BOSS_BALL_VEL, "voreball" );
	//missile = launch_projectile( self.origin + v_forward * 16 + v_up * crandom()*10 + v_right * crandom()*8 + '0 0 72', dir * D2BOSS_BALL_VEL, "voreball" );
	
	SUB_ChangeModel (missile, "progs/proj_d1boss.mdl");

	missile.avelocity = '300 300 300';
	missile.nextthink = time + distcheck;//0.35; // 0.2
	missile.think = d2bossMissileHome;
	missile.enemy = tgt;
	missile.touch = d2bossMissileTouch;
	missile.lifetime_finished = time + 5;	 // blow up after a while
	missile.track_finished = time + 1.25; // 1.25
	sound (self, CHAN_WEAPON, "d1boss/proj.wav", 1, ATTN_NONE);
};


void() d2bossSwarmFlyUpdate =
{
// self is a swarm rocket
	local vector A,B,C,D,E,F,G,H,I,J;
	local float state, newspeed, deviation;
	local vector dir;
	local vector deviated_velocity;

	A = self.vUtilA; B = self.vUtilB; C = self.vUtilC; D = self.vUtilD;
	
	state = ( time - self.fUtilA ) * 0.25;
	if (state < 1)
	{		
		if ( state < 0.5 )
			deviation = lerp ( 0, 1, state * 2 );
		else 
			deviation = lerp ( 1, 0, (state - 0.5) * 2 );
		deviation = min( 0.7, deviation );
		newspeed = lerp( 400, 800, state );
		
		E = lerpVector( A, B, state );
		F = lerpVector( B, C, state );
		G = lerpVector( C, D, state );
		H = lerpVector( E, F, state );
		I = lerpVector( F, G, state );
		J = lerpVector( H, I, state );
		dir = normalize( J - self.origin );
		
		deviated_velocity_x = self.velocity_x + crandom()*800;
		deviated_velocity_y = self.velocity_y + crandom()*800;
		deviated_velocity_z = self.velocity_z + crandom()*800;
		deviated_velocity = normalize(deviated_velocity);
		
		self.velocity = lerpVector( dir * newspeed, deviated_velocity * newspeed, deviation );	
		self.angles = vectoangles(self.velocity);
		
		self.nextthink = time + 0.025;
		self.think = d2bossSwarmFlyUpdate;
	}
	else 
	{
		self.think = SUB_Remove;
		self.nextthink = time + 5;
	}
};


void() launchSwarm_Loop =
{
// self is a swarm director
	local entity missile;
	
	if (self.fUtilI < 7)
	{
		missile = spawn ();
		missile.vUtilA = self.owner.origin + '0 0 160';
		setmodel (missile, "progs/e2/hell_rocket.mdl");
		setsize (missile, '0 0 0', '0 0 0');
		setorigin (missile, missile.vUtilA );		
		missile.owner = self.owner;
		missile.movetype = MOVETYPE_FLY;
		missile.solid = SOLID_BBOX;
		missile.classname = "missile";
		missile.touch = d2bossMissileTouch;
		missile.enemy = self.enemy;
		missile.fUtilA = time;
		missile.vUtilB = missile.vUtilA + '0 0 320';
		missile.vUtilC = self.vUtilC;
		missile.vUtilD = self.vUtilD + D2BOSS_SWARMOFFSET[self.fUtilI] * D2BOSS_SWARMRADIUS + '0 0 -64';
		missile.velocity = '0 0 400';
		missile.angles = vectoangles(missile.velocity);
		missile.think = d2bossSwarmFlyUpdate;
		missile.nextthink = time + 0.1;
		
		self.fUtilI++;
		self.think = launchSwarm_Loop;
		self.nextthink = time + 0.05;
	}
	else
		SUB_Remove();
};


void() d2bossSwarmAttack =
{
// self is the boss
	local entity director;
	local float rnd;
	local entity marker;
	local float i;
	
	director = spawn();
	director.eUtilA = find(world, targetname, self.target2); // temp
// center of the arena offset
	if (director.eUtilA)
		director.vUtilC = director.eUtilA.origin + '0 0 1024';
// random position around center of the arena
	rnd = rint(random() * 15); // array of 0-15
	director.vUtilD = director.eUtilA.origin + Vector(c16x[rnd], c16y[rnd], 0) * 320 + '0 0 -160';
	
	for ( i = 0; i < 7; i++ ) // array of 0-6
	{
		marker = spawn();
		setmodel (marker, "progs/e2/marker.mdl");
		setsize (marker, '0 0 0', '0 0 0');
		setorigin (marker, director.vUtilD + D2BOSS_SWARMOFFSET[i] * D2BOSS_SWARMRADIUS + '0 0 -116');
		marker.cnt = 3; // required for bh fade
		marker.think = fadeProjectile;
		marker.nextthink = time + 4.5;
	}
// rockets counter
	director.fUtilI = 0;
	director.owner = self;
	director.think = launchSwarm_Loop;
	director.nextthink = time + 0.05;
};

//void() d2boss_idle =[ 0, d2boss_idle ] { };
void () d2boss_idle =
{
	//self.frame = 0; //- intendent way 
	self.frame = 0;
};

void() d2boss_teleport_out	 =[ 1, d2boss_teleport_out02 ] { };
void() d2boss_teleport_out02 =[ 2, d2boss_teleport_out03 ] { };
void() d2boss_teleport_out03 =[ 3, d2boss_teleport_out04 ] { };
void() d2boss_teleport_out04 =[ 4, d2boss_teleport_out05 ] { };
void() d2boss_teleport_out05 =[ 5, d2boss_teleport_out06 ] { };
void() d2boss_teleport_out06 =[ 6, d2boss_teleport_out07 ] { };
void() d2boss_teleport_out07 =[ 7, d2boss_teleport_out08 ] { };
void() d2boss_teleport_out08 =[ 8, d2boss_idle ] 
{
	if ( self.classname == "monster_d2boss" ) 
		d2boss_teleport_in_start();
};

void() d2boss_teleport_in	=[ 9,  d2boss_teleport_in02 ] { };
void() d2boss_teleport_in02 =[ 10, d2boss_teleport_in03 ] { };
void() d2boss_teleport_in03 =[ 11, d2boss_teleport_in04 ] { };
void() d2boss_teleport_in04 =[ 12, d2boss_teleport_in05 ] { };
void() d2boss_teleport_in05 =[ 13, d2boss_teleport_in06 ] { };
void() d2boss_teleport_in06 =[ 14, d2boss_teleport_in07 ] { };
void() d2boss_teleport_in07 =[ 15, d2boss_idle ] 
{
	if ( self.classname == "monster_d2boss" ) 
		d2boss_idle_start();
};

void() d2boss_shield   =[ 16, d2boss_shield02 ] { self.alpha = D2BOSS_SHIELDALPHA - 0.4; };
void() d2boss_shield02 =[ 17, d2boss_shield03 ] { self.alpha = D2BOSS_SHIELDALPHA - 0.3; };
void() d2boss_shield03 =[ 18, d2boss_shield04 ] { self.alpha = D2BOSS_SHIELDALPHA - 0.2; };
void() d2boss_shield04 =[ 19, d2boss_shield05 ] { self.alpha = D2BOSS_SHIELDALPHA - 0.1; };
void() d2boss_shield05 =[ 20, d2boss_shield06 ] { self.alpha = D2BOSS_SHIELDALPHA;};
void() d2boss_shield06 =[ 21, d2boss_idle ] 
{
		self.owner.state = D2BOSS_TELEPORTING;
		self = self.owner;
		d2boss_teleport_out_start();
		self = self.eChildB; //huh? do we really need to set self back to shield?
};


void() d2boss_death   =[ 16, d2boss_death02 ] { d2boss_update_crystals(); };
void() d2boss_death02 =[ 17, d2boss_death03 ] { d2boss_update_crystals(); };
void() d2boss_death03 =[ 18, d2boss_death04 ] { d2boss_update_crystals(); };
void() d2boss_death04 =[ 19, d2boss_death05 ] { d2boss_update_crystals(); };
void() d2boss_death05 =[ 20, d2boss_death06 ] { d2boss_update_crystals(); };
void() d2boss_death06 =[ 21, d2boss_death07 ] { d2boss_update_crystals(); };
void() d2boss_death07 =[ 22, d2boss_death08 ] { d2boss_update_crystals(); };
void() d2boss_death08 =[ 23, d2boss_death09 ] { d2boss_update_crystals(); };
void() d2boss_death09 =[ 24, d2boss_death10 ] { d2boss_update_crystals(); };
void() d2boss_death10 =[ 25, d2boss_death11 ] { d2boss_update_crystals(); };
void() d2boss_death11 =[ 26, d2boss_death12 ] { d2boss_update_crystals(); };
void() d2boss_death12 =[ 27, d2boss_death13 ] { d2boss_update_crystals(); };
void() d2boss_death13 =[ 28, d2boss_death14 ] { d2boss_update_crystals(); };
void() d2boss_death14 =[ 29, d2boss_death15 ] { d2boss_update_crystals(); };
void() d2boss_death15 =[ 30, d2boss_death16 ] { d2boss_update_crystals(); };
void() d2boss_death16 =[ 31, d2boss_death17 ] { d2boss_update_crystals(); };
void() d2boss_death17 =[ 32, d2boss_death18 ] { d2boss_update_crystals(); };
void() d2boss_death18 =[ 33, d2boss_death19 ] { d2boss_update_crystals(); };
void() d2boss_death19 =[ 34, d2boss_death20 ] { d2boss_update_crystals(); };
void() d2boss_death20 =[ 35, d2boss_death21 ] { d2boss_update_crystals(); };
void() d2boss_death21 =[ 36, d2boss_death22 ] { d2boss_update_crystals(); };
void() d2boss_death22 =[ 37, d2boss_death23 ] { d2boss_update_crystals(); };
void() d2boss_death23 =[ 38, d2boss_death24 ] { d2boss_update_crystals(); };
void() d2boss_death24 =[ 39, d2boss_death25 ] { d2boss_update_crystals(); };
void() d2boss_death25 =[ 40, d2boss_death26 ] { d2boss_update_crystals(); };
void() d2boss_death26 =[ 41, d2boss_death27 ] { d2boss_update_crystals(); };
void() d2boss_death27 =[ 42, d2boss_death28 ] { d2boss_update_crystals(); };
void() d2boss_death28 =[ 43, d2boss_death29 ] { d2boss_update_crystals(); };
void() d2boss_death29 =[ 44, d2boss_death30 ] { d2boss_update_crystals(); };
void() d2boss_death30 =[ 45, d2boss_death31 ] { d2boss_update_crystals(); };
void() d2boss_death31 =[ 46, d2boss_death32 ] { d2boss_update_crystals(); };
void() d2boss_death32 =[ 47, d2boss_death33 ] { d2boss_update_crystals(); };
void() d2boss_death33 =[ 48, d2boss_death34 ] { d2boss_update_crystals(); };
void() d2boss_death34 =[ 49, d2boss_death35 ] { d2boss_update_crystals(); };
void() d2boss_death35 =[ 50, d2boss_death36 ] { d2boss_update_crystals(); };
void() d2boss_death36 =[ 51, d2boss_death37 ] { d2boss_update_crystals(); };
void() d2boss_death37 =[ 52, d2boss_death38 ] { d2boss_update_crystals(); };
void() d2boss_death38 =[ 53, d2boss_death39 ] { d2boss_update_crystals(); };
void() d2boss_death39 =[ 54, d2boss_death40 ] { d2boss_update_crystals(); };
void() d2boss_death40 =[ 55, d2boss_death41 ] { d2boss_update_crystals(); };
void() d2boss_death41 =[ 56, d2boss_death42 ] { d2boss_update_crystals(); };
void() d2boss_death42 =[ 57, d2boss_death43 ] { d2boss_update_crystals(); };
void() d2boss_death43 =[ 58, d2boss_death44 ] { d2boss_update_crystals(); };
void() d2boss_death44 =[ 59, d2boss_death45 ] { d2boss_update_crystals(); };
void() d2boss_death45 =[ 60, d2boss_death46 ] { d2boss_update_crystals(); };
void() d2boss_death46 =[ 61, d2boss_death47 ] { d2boss_update_crystals(); 
for (self.fUtilH = 0; self.fUtilH < 4; self.fUtilH++) ThrowGibBoss ("progs/gib1.mdl", 125, '0 0 0', crandom() * 300); };
void() d2boss_death47 =[ 62, d2boss_death48 ] { d2boss_update_crystals(); 
for (self.fUtilH = 0; self.fUtilH < 4; self.fUtilH++) ThrowGibBoss ("progs/gib2.mdl", 165, '0 0 0', crandom() * 300); };
void() d2boss_death48 =[ 63, d2boss_death49 ] { d2boss_update_crystals(); 
for (self.fUtilH = 0; self.fUtilH < 4; self.fUtilH++) ThrowGibBoss ("progs/gib3.mdl", 75, '0 0 0', crandom() * 300); };
void() d2boss_death49 =[ 64, d2boss_death50 ] { d2boss_update_crystals(); };
void() d2boss_death50 =[ 65, d2boss_death51 ] { d2boss_update_crystals(); };
void() d2boss_death51 =[ 66, d2boss_death52 ] { d2boss_update_crystals(); };
void() d2boss_death52 =[ 67, d2boss_death53 ] {	d2boss_update_crystals(); };
void() d2boss_death53 =[ 68, d2boss_death54 ] {	d2boss_update_crystals(); };
void() d2boss_death54 =[ 69, d2boss_death55 ] {	d2boss_update_crystals(); };
void() d2boss_death55 =[ 70, d2boss_death56 ] {	d2boss_update_crystals(); };
void() d2boss_death56 =[ 71, d2boss_death57 ] {	d2boss_update_crystals(); };
void() d2boss_death57 =[ 72, d2boss_death58 ] {	d2boss_update_crystals(); };
void() d2boss_death58 =[ 73, d2boss_death59 ] {	d2boss_update_crystals(); };
void() d2boss_death59 =[ 74, d2boss_death60 ] {	d2boss_update_crystals(); d2boss_randomexplosion(); };
void() d2boss_death60 =[ 75, d2boss_death61 ] {	d2boss_update_crystals(); d2boss_randomexplosion(); };
void() d2boss_death61 =[ 76, d2boss_death62 ] { d2boss_update_crystals(); d2boss_randomexplosion(); };
void() d2boss_death62 =[ 77, d2boss_death63 ] { d2boss_update_crystals(); d2boss_randomexplosion(); };
void() d2boss_death63 =[ 78, d2boss_death64 ] { d2boss_update_crystals(); d2boss_randomexplosion(); };
void() d2boss_death64 =[ 79, d2boss_death65 ] { d2boss_update_crystals(); d2boss_randomexplosion(); };
void() d2boss_death65 =[ 80, d2boss_death_final ] 
{ 
// final gibbage
	for (self.fUtilH = 0; self.fUtilH < 6; self.fUtilH++) ThrowGibBoss ( "progs/gib_d2bosscrystala.mdl", 225, [0,0, crandom() * 128], crandom() * 200 );
	for (self.fUtilH = 0; self.fUtilH < 6; self.fUtilH++) ThrowGibBoss ( "progs/gib_d2bosscrystalb.mdl", 225, [0,0, crandom() * 128], crandom() * 200 );
	for (self.fUtilH = 0; self.fUtilH < 6; self.fUtilH++) ThrowGibBoss ( "progs/gib_d2bosscrystalc.mdl", 225, [0,0, crandom() * 128], crandom() * 200 );
	for (self.fUtilH = 0; self.fUtilH < 5; self.fUtilH++) ThrowGibBoss ( "progs/gib_d2bossstonea.mdl",   175, [0,0, crandom() * 128], crandom() * 200 );
	for (self.fUtilH = 0; self.fUtilH < 5; self.fUtilH++) ThrowGibBoss ( "progs/gib_d2bossstoneb.mdl",   175, [0,0, crandom() * 128], crandom() * 200 );
	for (self.fUtilH = 0; self.fUtilH < 5; self.fUtilH++) ThrowGibBoss ( "progs/gib_d2bossstonec.mdl",   175, [0,0, crandom() * 128], crandom() * 200 );
	for (self.fUtilH = 0; self.fUtilH < 5; self.fUtilH++) ThrowGibBoss ( "progs/gib_d2bossstoned.mdl",   175, [0,0, crandom() * 128], crandom() * 200 );
	for (self.fUtilH = 0; self.fUtilH < 5; self.fUtilH++) ThrowGibBoss ( "progs/gib_d2bossstonee.mdl",   175, [0,0, crandom() * 128], crandom() * 200 );
	for (self.fUtilH = 0; self.fUtilH < 8; self.fUtilH++) ThrowGibBoss ( "progs/gib1.mdl", 				 75,  [0,0, crandom() * 128], crandom() * 200 );
	for (self.fUtilH = 0; self.fUtilH < 8; self.fUtilH++) ThrowGibBoss ( "progs/gib2.mdl", 				 75,  [0,0, crandom() * 128], crandom() * 200 );
	for (self.fUtilH = 0; self.fUtilH < 8; self.fUtilH++) ThrowGibBoss ( "progs/gib3.mdl", 				 75,  [0,0, crandom() * 128], crandom() * 200 );
// explosion effect (sound + particles)
	d2boss_randomexplosion();
};


void() d2boss_randomexplosion =
{
	local entity sprite;
	local vector offset;
	sprite = spawn();
	offset = self.origin;
	offset_x += crandom() * 128;
	offset_y += crandom() * 128;
	offset_z += crandom() * 128;
	setorigin(sprite, offset);
	sprite.think = s_explode1;
	sprite.nextthink = time + 0.1;
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, offset_x);
	WriteCoord (MSG_BROADCAST, offset_y);
	WriteCoord (MSG_BROADCAST, offset_z);
};


void() d2boss_death_final =
{ 	
	d2boss_cleanup();
	remove(self);
};


void() d2boss_cleanup = 
{
	local entity next, e;

	if (self.hitbox) 
	{
		e = self.hitbox;
		while (e)
		{
			next = e.buddy;
			remove(e);
			e = next;
		}
	}
	
//remove bullethell entity
	if (self.eChildA) 
		remove(self.eChildA);
//remove shield model
	if (self.eChildB) 
		remove(self.eChildB);
//remove thinker
	if (self.eChildC) 
		remove(self.eChildC);
//remove pain_controller
	if (self.eChildD) 
		remove(self.eChildD);
//remove crystals
	if (self.eUtilA)
		remove(self.eUtilA);
	killed_monster();
	activator = self.enemy;
	SUB_UseTargetsByField(target4);
};


void() d2boss_update_crystals =
{
	self.eUtilA.frame = self.frame;
	self.eUtilA.angles = self.angles;
	setorigin ( self.eUtilA, self.origin ); 
};


void() d2boss_predeath_loop =
{
	if ( self.frame < 39 )
	{
	// look at player
		self.avelocity_z = lerp( self.yaw_speed, 0, ( time - self.fUtilB ) * 0.5 ); 
	// stop movement
		self.velocity = lerpVector( self.oldvelocity, '0 0 0', ( time - self.fUtilB ) * 4 ); 
		
		self.frame++;
		d2boss_update_crystals();
		self.think = d2boss_predeath_loop;
		self.nextthink = time + 0.1;
	}
	else
	{
		self.think = d2boss_death25;
		self.nextthink = time + 0.1;
	}
};


void() d2boss_die =
{
	local entity crystals;
	
	crystals = d2boss_spawn_childs( self, 0 );
	self.eUtilA = crystals;
	sound (self, CHAN_AUTO, "d2boss/death.wav", 1, ATTN_NONE);
	
	self.frame = 16; //first death frame
	self.state = D2BOSS_DEATH;
// set lerp timer
	self.fUtilB = time;
// become invulnerable
	d2boss_bbox_setfield(takedamage, DAMAGE_NO); 
	self.oldvelocity = self.velocity;
	//self.velocity = 0;
	self.think = d2boss_predeath_loop;
	self.nextthink = time + 0.1;	
};


void(entity attacker, float damage) d2boss_Pain =
{
//dprint("Pain!\n");
	if ( self.health <= 0 ) 
		return;	

	if ( random() > 0.5 )
		sound (self, CHAN_AUTO, "d2boss/pain1.wav", 1, ATTN_NONE);
	else if ( random() > 0.75 )
		sound (self, CHAN_AUTO, "d2boss/pain2.wav", 1, ATTN_NONE);		
};


// ------------------------------------------------------------------------------
// 			BOSS CHILD ENTITIES
// ------------------------------------------------------------------------------
// spawns all the child entities for the boss, starts thinker loop
void() d2boss_createentities =
{
// pain controller, to add up hits on simultaneous bbox entities at the same frame
	local vector ofs, org;
	local entity e, next;
// 94 bbox entities
	vector coords[] = 
	{
		'0 96 -96',		'0 -96 -96',	'0 96 96',		'0 -96 96',		'112 0 0',
		'-112 0 0',		'16 0 96',		'-16 0 -96',	'16 32 96',		'16 -32 96',
		'-16 32 -96',	'-16 -32 -96',	'16 64 96',		'16 -64 96',	'-16 64 -96',
		'-16 -64 -96',	'16 96 64',		'16 -96 64',	'-16 96 -64',	'-16 -96 -64',
		'16 96 32',		'16 -96 32',	'-16 96 -32',	'-16 -96 -32',	'16 96 0',
		'16 -96 0',		'-16 96 0',		'-16 -96 0',	'16 96 -32',	'16 -96 -32',
		'-16 96 32',	'-16 -96 32',	'16 96 -64',	'16 -96 -64',	'-16 96 64',
		'-16 -96 64',	'16 0 -96',		'-16 0 96',		'16 32 -96',	'16 -32 -96',
		'-16 32 96',	'-16 -32 96',	'16 64 -96',	'16 -64 -96',	'-16 64 96',
		'-16 -64 96',	'48 0 64',		'-48 0 -64',	'48 32 64',		'48 -32 64',
		'-48 32 -64',	'-48 -32 -64',	'48 64 64',		'48 -64 64',	'-48 64 -64',
		'-48 -64 -64',	'48 64 0',		'48 -64 0',		'-48 64 0',		'-48 -64 0',
		'48 64 -32',	'48 -64 -32',	'-48 64 32',	'-48 -64 32',	'48 64 32',
		'48 -64 32',	'-48 64 -32',	'-48 -64 -32',	'48 0 -64',		'-48 0 64',
		'48 32 -64',	'48 -32 -64',	'-48 32 64',	'-48 -32 64',	'48 64 -64',
		'48 -64 -64',	'-48 64 64',	'-48 -64 64',	'80 0 -32',		'-80 0 32',
		'80 0 32',		'-80 0 -32',	'80 32 0',		'80 -32 0',		'-80 32 0',	
		'-80 -32 0',	'80 32 -32',	'80 -32 -32',	'-80 32 32',	'-80 -32 32',
		'80 32 32',		'80 -32 32',	'-80 32 -32',	'-80 -32 -32'
	};

//spanw pain controller, assign it to eChildD	
	e = spawn();
	e.owner = self;
	e.classname = "d2boss_paincontroller";
	e.think = d2boss_paincontroller_think;
	self.eChildD = e;
	
//spawn thinker entity, assign it to eChildC
	e = spawn();
	e.owner = self;
	e.classname = "d2boss_thinker";
	e.think = d2boss_thinker_loop;
	e.nextthink = time + 0.025;
	self.eChildC = e;

	makevectors (self.angles);
	
	for (float i = 0; i < 94; i++) 
	{
		next = spawn();
		next.classname = "d2boss_bbox";
		next.movetype = MOVETYPE_FLY;
		next.solid = SOLID_BBOX;
		next.th_pain = d2boss_bbox_pain;
		next.takedamage = DAMAGE_NO;
		next.health = 500000;
		next.owner = self;
		
		ofs = coords[i];
		next.view_ofs = ofs;
		org = self.origin + v_forward * ofs_x + v_right * ofs_y + v_up * ofs_z;
		setorigin(next, org);
		setsize(next, '-24 -24 -24', '24 24 24');
		
		if (!i)
			self.hitbox = next;
		else
			e.buddy = next;
		
		e = next;
	}
};


// ------------------------------------------------------------------------------
// 			HITBOXES
// ------------------------------------------------------------------------------
// refresh hitboxes positions according to boss origin and angles
void() d2boss_updatebboxes = 
{
// self is boss
	local entity e;
	local vector org, ofs;
	
	e = self.hitbox;
	makevectors([-self.angles_x, self.angles_y, self.angles_z]);
	
	while (e) 
	{
	// reset health
		e.health = 500000; 
		ofs = e.view_ofs;

		org = self.origin + v_forward * ofs_x + v_right * ofs_y + v_up * ofs_z;
		setorigin(e, org);
		
		e = e.buddy;
	}
};


// sets the specified float field on all bbox entities
void(.float fld, float value) d2boss_bbox_setfield = 
{
// self is boss
	local entity e;
	
	e = self.hitbox;
	while (e) 
	{
		e.fld = value;
		e = e.buddy;
	}
};


// handles damage that is done to hitboxes, stores it to .dmg and .multi_dmg of pain controller
void(entity attacker, float damage) d2boss_bbox_pain = 
{
// self is hitbox entity
// "state" field set in T_RadiusDamageCheck() function if it was a radius damage
// In this case, don't add up damage from multiple bbox entities or else the damage would be multiplied
	if (self.state == 1 )
	{
		if (damage > self.owner.eChildD.multi_dmg) 
			self.owner.eChildD.multi_dmg = damage;
	}
	else
		self.owner.eChildD.dmg += damage;

	self.state = 0;
	self.owner.eChildD.enemy = attacker;
	self.owner.eChildD.think = d2boss_paincontroller_think;
	self.owner.eChildD.nextthink = time + 0.01;
};

// ------------------------------------------------------------------------------
// 			PAIN CONTROL
// ------------------------------------------------------------------------------
// applies damage, triggers phase change (boss_reset) if we run out of hp
void(entity tgt, entity attacker, float dmg) d2boss_damage = 
{
// self is pain control entity
	tgt.health -= dmg;

	if (attacker.flags & FL_CLIENT) 
		tgt.enemy = attacker;

	if (tgt.health <= 0) 
	{
		if (tgt.fUtilF)
			SUB_CallAsSelf( d2boss_die, tgt );
		else
			SUB_CallAsSelf( d2boss_reset, tgt );
	}
};


// analyzes damage income and call for damage application, resets the damage income
void() d2boss_paincontroller_think = 
{
// self is pain control entity
	local float totaldmg;
	
	totaldmg = max( self.dmg, self.multi_dmg );
	d2boss_damage( self.owner, self.enemy, totaldmg );

//	dprint4("Damage: ", ftos(self.dmg), ", multi-damage: ", ftos(self.multi_dmg));
//	dprint2(", total dmg: ", ftos(totaldmg));
//	dprint3(", health: ", ftos(self.owner.health), "\n");
	
	self.dmg = self.multi_dmg = 0;
	self.enemy = world;
};


// ------------------------------------------------------------------------------
// 			BOSS LOGIC
// ------------------------------------------------------------------------------
// resets everything that we need before shield and teleportation sequences, fires .target
void() d2boss_reset =
{
// fire targets immediately
	activator = self.enemy;
	SUB_UseTargetsByField( target );
// become invulnerable
	d2boss_bbox_setfield(takedamage, DAMAGE_NO); 
// reset hp
	self.health = self.max_health;
// stop rotating, stop moving
	self.avelocity = 0;
	self.velocity = 0;
// stop doing stuff
	self.nextthink = 0;
// set the wished angles vector to looking down
	self.vUtilA_x = D2BOSS_LOOKDOWN;
// we do the lerping only when v_angle is specified
	self.v_angle = normalizeAngles180(self.angles);
// lerp starts now
	self.fUtilA = time;	
// initiat phase change	
	self.state = D2BOSS_PHASECHANGE;
};

// move along path corners
void() d2boss_reachpath = 
{
	local entity pathcorner;
	
	pathcorner = find(world, targetname, self.goalentity.target);
	self.goalentity = pathcorner;
	SUB_CalcMove(pathcorner.origin, self.speed, d2boss_reachpath);
};


// delay after being triggered
void() d2boss_intro =
{
	// blow open it's eye
	local entity gib;
	local vector offset;

	setmodel(self, "progs/mon_d2bossb.mdl");
	setsize ( self, '0 0 0', '0 0 0' );
	
	gib = ThrowGibBoss ( "progs/gib_d2bosscrystala.mdl", 0, D2BOSS_GIBOFFSET, -50 );
	gib.avelocity *= 0.1;
	gib = ThrowGibBoss ( "progs/gib_d2bosscrystalb.mdl", 0, D2BOSS_GIBOFFSET, -65 );
	gib.avelocity *= 0.1;
	gib = ThrowGibBoss ( "progs/gib_d2bosscrystalc.mdl", 0, D2BOSS_GIBOFFSET, -55 );
	gib.avelocity *= 0.1;
	gib = ThrowGibBoss ( "progs/gib_d2bossstonec.mdl",   0, D2BOSS_GIBOFFSET, -25 );
	gib.avelocity *= 0.1;
	gib = ThrowGibBoss ( "progs/gib_d2bossstoned.mdl",   0, D2BOSS_GIBOFFSET, -25 );
	gib.avelocity *= 0.1;
	
// explosion effect (sound + particles)
	offset = self.origin + D2BOSS_GIBOFFSET;
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, offset_x);
	WriteCoord (MSG_BROADCAST, offset_y);
	WriteCoord (MSG_BROADCAST, offset_z);
	
	self.nextthink = time + 2;
	self.think = d2boss_wake;
};


void() d2boss_wake =
{
// don't start firing right away, wait for three seconds
	self.attack_finished = time + 3;
	
	d2boss_flying_start();
};


void() d2boss_idle_start =
{
	self.frame = 0;
	self.state = D2BOSS_IDLE;
	self.think = d2boss_flying_start;
	self.nextthink = time + self.wait;
// start spinning
	self.eChildB.avelocity_z = self.yaw_speed * D2BOSS_BHROTATIONMULTIPLIER; //slowdown a bit
	self.avelocity_z = self.yaw_speed * D2BOSS_BHROTATIONMULTIPLIER; //slowdown a bit
};


void() d2boss_flying_start =
{
	d2boss_shield_down();
	d2boss_bbox_setfield(takedamage, DAMAGE_AIM); 
// flying state	
	self.state = D2BOSS_FLYING;
// start spinning
	self.avelocity_z = self.yaw_speed;
	self.goalentity = find(world, targetname, self.include);
	SUB_CalcMove( self.goalentity.origin, self.speed, d2boss_reachpath );

// force angles lerping
// we do the lerping only when v_angle is specified
	self.v_angle = normalizeAngles180(self.angles);
// lerp starts now
	self.fUtilA = time;	
};


void() d2boss_teleport_out_start =
{
	d2boss_teleport_out();
// shield
	self.eChildB.think = d2boss_teleport_out; 
	self.eChildB.nextthink = time;
};


void() d2boss_teleport_in_start =
{
	local entity destination;
	
	destination = find( world, targetname, self.target2 );
	if ( destination )
	{
	//d2boss_telefrag(); ???
		setorigin( self, destination.origin);
		setorigin( self.eChildB, destination.origin);
	}
// start of animation sequence
	d2boss_teleport_in();
// shield
	self.eChildB.think = d2boss_teleport_in; 
	self.eChildB.nextthink = time;
};


void() d2boss_shield_up =
{
// this is mostly about the shield
// reset position and angles so it matches the boss model
	self.avelocity = 0;
	
	setorigin(self.eChildB, self.origin);
	//self.frame = 16; // first frame of shield up sequence
	self.eChildB.alpha = 0;
	self.eChildB.angles = self.angles;
	self.state = D2BOSS_WAITFORSHIELD;
	self.eChildB.think = d2boss_shield;
	self.eChildB.nextthink = time;
	sound (self, CHAN_AUTO, "d2boss/shield_up.wav", 1, ATTN_NONE);	
};


void() d2boss_shield_down =
{
	self.eChildB.alpha = -1;
	self.eChildB.avelocity_z = 0;
	self.eChildB.frame = 16;
	sound (self, CHAN_AUTO, "d2boss/shield_down.wav", 1, ATTN_NONE);
};


// ------------------------------------------------------------------------------
// 			THINKER
// ------------------------------------------------------------------------------
void( entity peWho ) d2boss_trackplayer =
{
//self is thinker
	local vector ang;
	local entity targ;
	
	targ = checkclient();

	if ( targ )
	{
		ang = vectoangles(peWho.enemy.origin - peWho.origin);
		ang = normalizeAngles180(ang);
		peWho.vUtilA_x = ang_x;
		peWho.vUtilA_y = ang_y;
	}
	
	if (!peWho.enemy && targ)
		peWho.enemy = targ;
};


void() d2boss_thinker_loop = 
{
// self is thinker entity
	local entity boss, thinker;
// better readability
	boss = self.owner; 
	thinker = self;
	self = boss;

// boss tracks the player when in flying phase
	if ( boss.state == D2BOSS_FLYING ) 
	{
		d2boss_trackplayer(boss);
	// fire rocket
		if ( self.attack_finished < time )
		{
			//d2bossMissile();
			d2bossSwarmAttack();
			self.attack_finished = time + 2 + ( 2 * random()); // how often
		}
	}
	
	if ( boss.v_angle )
	{
		boss.angles_x = lerp( boss.v_angle_x, boss.vUtilA_x, (time - boss.fUtilA) * D2BOSS_TRANSITION_SPEED ); 
		boss.angles_y = lerp( boss.v_angle_y, boss.vUtilA_y, (time - boss.fUtilA) * D2BOSS_TRANSITION_SPEED );
	
	// lerp is done, boss angles is matching wished angles
		if ( (boss.angles_x == boss.vUtilA_x) && (boss.angles_y == boss.vUtilA_y))
		{
			boss.v_angle = 0;
			boss.vUtilA = 0;
			
			if ( boss.state == D2BOSS_PHASECHANGE ) 
				d2boss_shield_up();
		}
	}
	else if ( boss.state == D2BOSS_FLYING ) 
	{
	// no need to lerp anything, set wished angles directly
		boss.angles_x = boss.vUtilA_x;
		boss.angles_y = boss.vUtilA_y;
	}
	
// update bboxes position
	SUB_CallAsSelf(d2boss_updatebboxes, boss);
	
// loop
	thinker.think = d2boss_thinker_loop;
	thinker.nextthink = time + 0.01;
};


// ------------------------------------------------------------------------------
// 			SPAWN
// ------------------------------------------------------------------------------
entity(entity peWho, float isShield) d2boss_spawn_childs =
{
	local entity e;
	
	e = spawn();
	e.solid = SOLID_NOT;
	e.takedamage = DAMAGE_NO;
	e.movetype = MOVETYPE_FLY;
	if (isShield)
	{
		setmodel ( e, "progs/mon_d2bossf.mdl" );
		e.classname = "d2boss_shield";
		e.alpha = D2BOSS_SHIELDALPHA;
		e.angles = peWho.angles;
		e.angles_x = D2BOSS_LOOKDOWN;
	}
	else 
	{
		setmodel ( e, "progs/mon_d2bossc.mdl" );
		e.classname = "d2boss_crystals";
		e.angles = peWho.angles;
	}
	setsize ( e, '0 0 0', '0 0 0' );
	setorigin ( e, peWho.origin );
	e.frame = 0; 
	e.owner = peWho;
	
	return e;
};


// child A - bullet hell
// child B - shield model
// child C - think entity
// child D - pain control entity
// eUtil A - death crystals
// fUtilA - lerp timer for transition between staring at player and looking directly down
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
	precache_model ("progs/mon_d2bossb.mdl"); // broken model (eye)
	precache_model ("progs/mon_d2bossc.mdl"); // death crystals
	precache_model ("progs/mon_d2bossf.mdl"); // forcefield
	precache_model ("progs/gib_d2bosscrystala.mdl");
	precache_model ("progs/gib_d2bosscrystalb.mdl");
	precache_model ("progs/gib_d2bosscrystalc.mdl");
	precache_model ("progs/gib_d2bossstonea.mdl");
	precache_model ("progs/gib_d2bossstoneb.mdl");
	precache_model ("progs/gib_d2bossstonec.mdl");
	precache_model ("progs/gib_d2bossstoned.mdl"); // :)
	precache_model ("progs/gib_d2bossstonee.mdl");
	precache_model ("progs/e2/marker.mdl");
	precache_model ("progs/h_shams.mdl");
	precache_model ("progs/proj_d1boss.mdl");
	precache_sound ("d2boss/shield_down.wav");
	precache_sound ("d2boss/shield_up.wav");
	precache_sound ("d2boss/death.wav");
	precache_sound ("d2boss/pain1.wav");
	precache_sound ("d2boss/pain2.wav");

	if (self.strength > 0)
		self.health = self.strength;
	else 
		self.health = 1000;
	self.max_health = self.health;
// movement speed
	if ( !self.speed ) 
		self.speed = 300;
	if ( !self.wait )
		self.wait = 40;
// spin velocity
	self.fixangle = zeroconvertdefault(self.fixangle, 180);
	
	addmonster(1);
		
	self.solid = SOLID_NOT;
	self.takedamage = DAMAGE_NO;
	self.movetype = MOVETYPE_FLY;
	setmodel ( self, "progs/mon_d2boss.mdl" );
	setsize ( self, '0 0 0', '0 0 0' );
	self.angles_x = D2BOSS_LOOKDOWN;
	self.frame = 0; //idle
	self.state = D2BOSS_SLEEPING;
	self.type = "boss";
	self.th_die = d2boss_die;
	self.use = d2boss_intro;
	self.yaw_speed = self.fixangle;
// death marker
	self.fUtilF = 0;
	
	if ( self.deathtype == string_null )
		self.deathtype = " was killed by the Sculptor";
	
// spawn hitboxes, pain control, thinker
	d2boss_createentities(); 
// spawn shield
	self.eChildB = d2boss_spawn_childs( self, 1 ); 
};

/*QUAKED monster_d2boss (1 0 0) (-16 -16 -24) (16 16 40) AMBUSH ? ? ? TRIGGERED NOTFOG NOTELEFRAG INSTAWAKE
Scrag (the SCULPTOR), ??? health points.

Keys:
"target" entity to trigger when killed
"targetname" entity name
*/
/*FGD
@PointClass base(Angle, Appearflags, Target, Targetname) color(220 0 0) size(32 32 32) model({ "path": ":progs/mon_d2boss_rot.mdl" }) = monster_d2boss : "The Sculptor"
[
	strength(integer) : "Health per phase" : 1000
	speed(integer) : "Movement speed" : 300
	wait(integer) : "Wait for bullethell to happen" : 40
	fixangle(integer) : "Spin velocity (-1 for no spin)" : 180
]
*/


void() d2boss_trigger_death =
{
	local entity boss;
	
	boss = find(world, targetname, self.target);
	if (boss)
	{
		boss.fUtilF = 1;
		boss.health = 666;
	}
};

//please write FGD script for this, i have no time to do it
void() trigger_killboss =
{
	self.use = d2boss_trigger_death;
};

/*QUAKED trigger_killboss (0 0 0) (-4 -4 -4) (4 4 4) 
Kills the Sculptor

Keys:
"target" boss to kill
"targetname" entity name
*/
/*FGD
@PointClass base(Target, Targetname) color(220 0 0) size(8 8 8) = trigger_killboss : "The Sculptor's killer"
[
]
*/
	//
	//	E = lerpVector( A, B, state );
	//	F = lerpVector( B, C, state );
	//	G = lerpVector( C, D, state );
	//	H = lerpVector( E, F, state );
	//	I = lerpVector( F, G, state );
	//	J = lerpVector( H, I, state );