//turn these into a single proc with a mobtype parameter, can't use get_mobs_or_objs because the recursion there chucks an error if overused

/proc/get_chimeras_near(R, atom/source, include_mobs = 1, include_objects = 1)
	RETURN_TYPE(/list)

	var/turf/T = get_turf(source)
	var/list/hear = list()

	if(!T)
		return hear

	var/list/range = hear(R, T)

	for(var/I in range)
		if(ismob(I))
			if(include_mobs)
				var/mob/M = I
				if(istype(M,/mob/living/simple_animal/hostile/chimera))
					hear += M
		else if(isobj(I))
			if(include_objects)
				hear += I

	return hear

/proc/get_humans_near(R, atom/source, include_mobs = 1, include_objects = 1)
	RETURN_TYPE(/list)

	var/turf/T = get_turf(source)
	var/list/hear = list()

	if(!T)
		return hear

	var/list/range = hear(R, T)

	for(var/I in range)
		if(ismob(I))
			if(include_mobs)
				var/mob/M = I
				if(istype(M,/mob/living/carbon/human))
					hear += M
	return hear

//If you see it disguising as anything else it shouldn't (like wall mounted shit) add it to the exceptions here
GLOBAL_LIST_INIT(chimera_protected, list(
	/obj/machinery,
	/obj/structure/table,
	/obj/structure,
	/obj/structure/cable,
	/obj/decal/cleanable,
	/obj/structure/window,
	/obj/structure/lattice,
	/obj/structure/wall_frame,
	/obj/structure/grille,
	/obj/item/device/radio/intercom,
	/obj/structure/catwalk,
	/obj/structure/ladder,
	/obj/structure/disposalpipe,
	/obj/structure/stairs,
	/obj/structure/sign,
	/obj/airlock_filler_object,
	/obj/structure/railing,
	/obj/item/modular_computer,
	/obj/item/projectile/animate,
	/obj/item/organ,
	/obj/item/organ/internal,
	/obj/item/stool,
	/obj/dummy/chimera
))

/obj/dummy/chimera
	name = ""
	desc = ""
	density = FALSE
	anchored = TRUE
	var/can_move = 1
	//anchored = TRUE
	var/mob/living/simple_animal/hostile/chimera/master = null


/obj/dummy/chimera/attack_hand(mob/living/user)
	var/mob/living/simple_animal/hostile/chimera/master = src.master
	master.uncloak()
	user.Stun(3)
	user.Weaken(3)
	sleep(30)
	master.infest(user)
	//if(master.Adjacent(user))
		//master.forceMove(user)
		//var/mob/living/carbon/human/H = user
		//master.infest(H)
/obj/dummy/chimera/use_tool(obj/item/tool, mob/user, list/click_params)
	var/mob/living/simple_animal/hostile/chimera/master = src.master
	master.uncloak()

	return ..()
/obj/dummy/chimera/bullet_act(mob/living/user)
	var/mob/living/simple_animal/hostile/chimera/master = src.master
	master.uncloak()
//use layer = to set layers
/mob/living/simple_animal/hostile/chimera
	name = "???"
	desc = "A bizarre, twitching creature roughly the size of a cat. It's limbs twitch with alarming speed."
	icon = 'icons/mob/simple_animal/chimera.dmi'
	icon_state = "chimera"
	icon_living = "chimera"
	icon_dead = "chimera_dead"

	meat_type = /obj/item/reagent_containers/food/snacks/fish/unknown
	response_help = "touches"
	bleed_colour = "#37274b"
	response_disarm = "pushes"
	response_harm = "hits"
	color = null
	density = 1
	movement_cooldown = 2
	maxHealth = 125
	health = 125
	harm_intent_damage = 5
	natural_weapon = /obj/item/natural_weapon/chimera_blade
	does_spin = FALSE
	min_gas = null
	max_gas = null
	layer = OBJ_LAYER
	minbodytemp = 0
	faction = "REDACTED"
	move_to_delay = 2
	special_attack_min_range = 2
	special_attack_max_range = 4
	special_attack_cooldown = 10 SECONDS
	var/icon_transform = "transform"
	var/icon_injecting = "injecting"
	var/icon_lunge = "chimera_lunge1"
	var/true_form = 'icons/mob/simple_animal/chimera.dmi'
	var/true_form_state = "chimera"
	var/leap_warmup = 1 SECOND // How long the leap telegraphing is.
	var/dummy = null
	var/leap_sound = 'sound/weapons/spiderlunge.ogg'
	var/cloaked = FALSE
	var/egg_type = /obj/effect/chimera/dormant_chimera
	var/destroy_objects = 0
	var/knockdown_people = 0
	var/last_uncloak = 0
	var/revealed = 0
	pass_flags = PASS_FLAG_TABLE

/mob/living/simple_animal/hostile/chimera/examine_damage_state(mob/user)
	return

/mob/living/simple_animal/hostile/chimera/proc/cloak()
	var/obj/dummy/chimera/C = new /obj/dummy/chimera(src.loc)
	src.dummy = C
	C.master = src
	if (!src.cloaked && can_cloak())
		var/list/objects = get_chimeras_near(3,src,0,1)
		if (length(objects) == 0)
			src.cloaked = FALSE
			return
		//src.cloaked = TRUE
		var/list/shuffled_objects = shuffle(objects)
		for (var/obj/T in shuffled_objects)
			if (!is_type_in_list(T, GLOB.chimera_protected))
				C.icon = T.icon
				C.icon_state = T.icon_state
				C.name = T.name
				C.color = T.color
				C.desc = T.desc

				src.icon = null
				src.icon_state = null
				src.icon_living = null
				src.name = null
				src.color = null
				src.desc = null
				src.cloaked = TRUE
				src.revealed = FALSE
				set_AI_busy(TRUE)
				return


/mob/living/simple_animal/hostile/chimera/proc/uncloak()
	qdel(dummy)
	src.icon = 'icons/mob/simple_animal/chimera.dmi'
	src.icon_state = "chimera"
	src.icon_living = "chimera"
	src.name = "???"
	src.color = null
	src.set_density(1)
	src.desc = "A bizarre pallid twitching creature roughly the size of a large dog. Its many limbs vibrate with alarming speed."
	src.cloaked = FALSE
	visible_message(SPAN_DANGER("\The [src] shudders and twitches, twisting rapidly with a sickening crunch sound!"))
	playsound(src,'sound/effects/borer_hatch.ogg',75,1)

	flick(icon_transform,src)
	set_AI_busy(FALSE)

	return

/mob/living/simple_animal/hostile/chimera/Initialize()
	. = ..()
	if(can_cloak())
		cloak()


/mob/living/simple_animal/hostile/chimera/proc/break_cloak()
	src.revealed = TRUE
	visible_message(SPAN_DANGER("\The [src] reels under the impact, stunned!"))
	set_AI_busy(TRUE)
	sleep(20)
	set_AI_busy(FALSE)
	uncloak()
//looks for other people around, should add a client/alive check to this so it only does living people
/mob/living/simple_animal/hostile/chimera/proc/can_cloak()
	var/list/people_around = get_humans_near(7,src,1,0)
	if ((locate(/mob/living/carbon) in people_around) != null)
		for (var/mob/M in people_around)
			if (M.stat == CONSCIOUS)
				return FALSE
		//return FALSE
	return TRUE
//infection proc, based off of voxslug code and nurse spider code
/mob/living/simple_animal/hostile/chimera/proc/infest(mob/living/carbon/human/H)
	src.layer = FLY_LAYER
	H.anchored= TRUE
	//flick(icon_injecting,src)
	if (H.isSynthetic())
		return
	var/obj/item/clothing/suit/space/S = H.get_covering_equipped_item_by_zone(BP_CHEST)
	if(istype(S) && !length(S.breaches))
		S.create_breaches(DAMAGE_BRUTE, 40)
		src.visible_message("\The [src] rips open the suit, tearing viciously!")
		playsound(src,'sound/effects/bonesetter.ogg',75,1)
		if(!length(S.breaches)) //unable to make a hole
			return
	//add check to make sure this is only done when it actually infests
	sleep(15)
	//gets the organ to infect, checks the victim is on the same tile
	var/obj/item/organ/external/O = H.get_organ(BP_CHEST)
	//make sure it's not just the EXACT same tile. Adjacent is fine too
	if(!src.Adjacent(H))
		return
	src.forceMove(H.loc)
	src.layer = FLY_LAYER
	flick(icon_injecting,src)
	sleep(15)
	if(O && (src.loc == H.loc) && (health > 0))
		var/eggs = new egg_type(O, src)
		var/eggcount = 0
		for(var/obj/effect/chimera/E in O.implants)
			eggcount++
		//checks the victim is not already infected and exits if it is
		if (eggcount > 0)
			H.anchored = FALSE
			return
		O.implants += eggs
		src.visible_message(SPAN_DANGER("\The [src] transforms into thin strands that make their way up [H]'s ear canal!"))
		playsound(src,'sound/effects/bonegel.ogg',75,1)
		qdel(src)
	H.anchored = FALSE
//handles when to cloak and uncloak, hunting behaviour for chimeras
/mob/living/simple_animal/hostile/chimera/handle_special()
	SSradiation.radiate(src,3)
	if (src.cloaked)
		src.set_density(0)
	var/list/targets_around = (get_humans_near(7,src,1,0))
	var/list/chimeras_around = (get_chimeras_near(7,src,1,0))
	if (can_cloak() && !src.cloaked)
		cloak()
	if (src.cloaked && (    ( length(targets_around) < 2 ) || ( length(targets_around) < length(chimeras_around) )        ) && (length(targets_around) != 0))
		sleep(rand(100,150))
		if (!src.revealed && (  ( length(targets_around) < 2 ) || ( length(targets_around) < length(chimeras_around) )  ) )
			uncloak()

//Leap attack, triggers once awakened/every so often afterwards
//Change this to have a windup and use Adjacent instead
/mob/living/simple_animal/hostile/chimera/do_special_attack(atom/A)
	set waitfor = FALSE
	set_AI_busy(TRUE)
	var/turf/target_turf = get_turf(A)
	status_flags |= LEAPING // Lets us pass over everything.
	do_windup_animation(A, leap_warmup)
	sleep(leap_warmup)
	flick(icon_lunge,src)
	visible_message(SPAN_DANGER("\The [src] lunges at \the [A]!"))
	throw_at(get_step(get_turf(A), get_turf(src)), special_attack_max_range+1, 1, src)
	playsound(src, leap_sound, 75, 1)
	sleep(3) // For the throw to complete. It won't hold up the AI ticker due to waitfor being false.
	var/mob/living/victim = null

	/*
	var/turf/struck_turf = get_step(src, dir)
	if ( (A.loc == struck_turf))
		. = FALSE
		//sleep(10)
		for(var/mob/living/M in get_turf(A))
			if(ishuman(M))
				M.Weaken(3)
				var/mob/living/carbon/human/H = M
				if(H.check_shields(damage = 0, damage_source = src, attacker = src, def_zone = null, attack_text = "the leap"))
					break
				src.forceMove(A.loc)
				if ( (health > 0) && (M.Adjacent(src)))
					infest(M)
					. = TRUE
	*/
	if(status_flags & LEAPING)
		status_flags &= ~LEAPING // Revert special passage ability.

	set_AI_busy(FALSE)

/mob/living/simple_animal/hostile/chimera/throw_impact(atom/hit_atom, datum/thrownthing/TT)
	if(istype(hit_atom,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = hit_atom

		if(H.check_shields(damage = 0, damage_source = src, attacker = src, def_zone = null, attack_text = "the leap"))
			return
		H.Weaken(3)
		TT.thrownthing.forceMove(H.loc)
		if ( (health > 0) && (src.loc == H.loc))
			infest(H)
	if(isobj(hit_atom))
		var/obj/O = hit_atom
		if(!O.anchored)
			step(O, src.last_move)
		O.hitby(src,TT)

	if(isturf(hit_atom))
		var/turf/T = hit_atom
		T.hitby(src,TT)
//I might literally just make this so it uncloaks after briefly stunning you. Maybe no stun altogether and it literally just reveals itself
/mob/living/simple_animal/hostile/chimera/attack_hand(mob/living/carbon/human/M as mob)
	..()

	switch(M.a_intent)

		if(I_HELP)
			set_AI_busy(TRUE)
			if ( (health > 0) && src.cloaked)
				M.visible_message(SPAN_NOTICE("[M]'s hand pushes into \the [src] with a vile squelch sound."))
				playsound(src, 'sound/effects/attackblob.ogg', 100, 1)
				M.Weaken(10)
				M.visible_message(M, SPAN_DANGER("You feel a jolt run through your body, paralyzing you!"))

				uncloak()


				if (health > 0 && (M.Adjacent(src)))
					src.forceMove(M.loc)
					infest(M)
			set_AI_busy(FALSE)
			M.anchored = FALSE
		if(I_DISARM)
			set_AI_busy(TRUE)
			if (src.cloaked)
				M.visible_message(SPAN_NOTICE("[M]'s hand pushes into \the [src] with a vile squelch sound."))
				playsound(src, 'sound/effects/attackblob.ogg', 100, 1)
				M.Weaken(10)
				M.visible_message(M, SPAN_DANGER("You feel a jolt run through your body, paralyzing you!"))
				uncloak()

				if ( (health > 0) && (M.Adjacent(src)))
					src.forceMove(M.loc)
					infest(M)
			set_AI_busy(FALSE)
			M.anchored = FALSE

		if(I_HURT)
			if (health > 0 && src.cloaked)
				uncloak()

	return

/mob/living/simple_animal/hostile/chimera/bullet_act(obj/item/projectile/P)
	if (status_flags & GODMODE)
		return PROJECTILE_FORCE_MISS
	. = ..()
	if (src.cloaked)
		break_cloak()

/mob/living/simple_animal/hostile/chimera/hit_with_weapon(obj/item/O, mob/living/user, effective_force, hit_zone)
	. = ..()
	if (src.cloaked)
		break_cloak()
