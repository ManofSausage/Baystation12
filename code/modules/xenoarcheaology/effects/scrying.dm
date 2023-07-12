var/obj/effect/chimera/dormant_chimera/chimera

/datum/artifact_effect/scrying
	name = "artifact_chimera"
	effect_type = EFFECT_PSIONIC
	var/captive = /mob/living/captive_brain


/datum/artifact_effect/scrying/DoEffectTouch(mob/user)

	//prisoner.client = user.client
	//playsound(get_turf(holder),'sound/magic/disable_tech.ogg', 50)
	if (istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/U = user
		var/obj/item/organ/external/user_chest = U.get_organ(BP_CHEST)
		for(var/obj/effect/chimera/E in user_chest.implants)
			var/purged = E
			U.vomit()
			user_chest.implants -= E
			U.visible_message(SPAN_DANGER("\The [U] bends over in pain, vomiting up a strange white shard!"))
			U.Stun(2)
			E.forceMove(get_turf(U))
			return
	var/list/activeclients = list()
	for(var/mob/living/carbon/human/M in SSmobs.mob_list)
		var/obj/item/organ/external/target_chest = M.get_organ(BP_CHEST)
		for(var/obj/effect/chimera/E in target_chest.implants)
			activeclients.Add(M)
	for (var/mob/living/simple_animal/hostile/chimera/C in SSmobs.mob_list)
		activeclients.Add(C)
	for (var/obj/item/implant/chimera/implanted in user)
		var/mob/victim = input(user,"You see a number of threads in your mind's eye, floating before you... ", "Grasp One") as null|anything in activeclients
		if (istype(victim,/mob/living/carbon/human) && !victim.is_dead())

			var/mob/living/carbon/human/H = victim
			var/obj/item/organ/external/O = H.get_organ(BP_CHEST)
			var/is_infected = O.implants

			seize_control(victim,user)
		if (istype(victim,/mob/living/simple_animal/hostile/chimera))
			var/mob/living/simple_animal/hostile/chimera/targeted_chimera = victim
			targeted_chimera.uncloak()
		return
	//write code for if not chimera infected here
/datum/artifact_effect/scrying/proc/seize_control(mob/living/carbon/human/victim,mob/living/carbon/human/user)
	var/mob/living/carbon/human/originaluser = user
	var/mob/living/carbon/human/originalvictim = victim
	var/mob/living/captive_brain/prisoner = new captive
	var/mob/living/carbon/human/H = victim
	var/obj/item/organ/external/O = H.get_organ(BP_CHEST)
	//var/is_infected = O.implants
	prisoner.dropInto(get_turf(H))
	prisoner.forceMove(O)
	to_chat(victim,SPAN_OCCULT("There is a presence behind you, placing its hand upon your shoulder. It sees from behind your eyes. Your body is not your own."))
	var/h2b_id = originalvictim.computer_id
	var/h2b_ip=  originalvictim.lastKnownIP
	originalvictim.computer_id = null
	originalvictim.lastKnownIP = null
	prisoner.ckey = victim.ckey
	victim.ckey = null
	victim.ckey = user.ckey
	//victim.client = null
	//victim.client = user.client
	sleep(300)
	if (!victim.is_dead())
		originaluser.ckey = victim.ckey
		victim.ckey = prisoner.ckey
		qdel(prisoner)
		//prisoner.ckey = null

	else
		originaluser.setBrainLoss(200)
		//prisoner.ckey = null
		qdel(prisoner)
