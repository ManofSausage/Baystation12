/obj/effect/chimera/dormant_chimera
	name = "strange shard"
	desc = "A ridged white shard, roughly the size of someone's hand"
	chimera_icon
	icon = 'icons/mob/simple_animal/chimera.dmi'
	icon_state = "embryo"
	var/last_tick = 0
	var/wait_time = 30 SECONDS
	var/chimera_type = /mob/living/simple_animal/hostile/chimera
	var/removed = /obj/item/implant/chimera
	var/icon_transform = "transform"
	//possibly change these to bold? Kinda like how it looks tho
	var/infected_message_list = list(
		"You are summoned. There is a knock at the door.",
		"It is ready. It is near. It is here.",
		"The chittering is all around you.",
		"Sleep now. Slip into the warm embrace.",
		"It holds you in its arms. It loves you.",
		"Sunlight upon your skin. A kind voice, calling your name.",
		"It awaits you through the doorway, bathed in rays of gold.",
		"You will never be forgotten again.",
		"A drum beats. A thump thump thumping inside you.",
		"It can see you now. It can see all of you.",
		"You hear a chorus of a thousand voices, raised in joyous song.",
		"Close your eyes now. Rest, and awaken fresh.",
		"There is nothing now. Nothing but the endless warmth.",
		"They wait for you, just beyond the veil.",
		"Let them in. Let them in. Let them in.",
		"A great web, all about you. Holding you in loving embrace.",
		"They are close now. So very close.",
		"Something looks through your eyes. It sees."
	)
/obj/effect/chimera/dormant_chimera/Initialize(mapload, atom/parent)
	. = ..()
	get_light_and_color(parent)
	pixel_x = rand(3,-3)
	pixel_y = rand(3,-3)
	START_PROCESSING(SSobj, src)
//add handling for what to do with the unknown body
/obj/effect/chimera/dormant_chimera/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(istype(loc, /obj/item/organ/external))
		var/obj/item/organ/external/O = loc
		O.implants -= src
	. = ..()
	//if(!istype(loc, /obj/item/organ/external))
		//qdel(src)
/obj/effect/chimera/dormant_chimera/on_death()
	visible_message(SPAN_WARNING("\The [src] dies!"))
	qdel(src)
//Rework this to be more impactful and actually hurt the infected, without making it frustrating
//add a "body shifting" thing so it moves through the body and copies organs, and hearing all the other infected speak
//add an effect so if the chimera is removed and just left alone after a while, it turns back into the hostile mob
/obj/effect/chimera/dormant_chimera/Process()
	if(isorgan(src.loc))
		var/obj/item/organ/external/O = src.loc
		var/mob/living/carbon/human/victim = O.owner
		victim.add_chemical_effect(CE_PAINKILLER, 40)
	if (!istype(loc, /obj/item/organ))
		var/turf/temporaryloc = src.loc
		if(temporaryloc.return_air().temperature < 273.15)
			qdel(src)
			var/obj/item/implant/extracted = new removed
			extracted.dropInto(temporaryloc)
		if(temporaryloc.return_air().temperature > 273.15)
			visible_message(SPAN_DANGER("\The [src] shudders and twitches, twisting rapidly with a sickening crunch sound!"))
			var/mob/chimera = new chimera_type
			chimera.dropInto(temporaryloc)
			flick(icon_transform,chimera)
			playsound(src,'sound/effects/borer_hatch.ogg',75,1)
			sleep(10)
			qdel(src)
	if (last_tick == 0)
		last_tick = world.time
	if (last_tick + wait_time > world.time )
		return
	else
		last_tick = world.time
		var/obj/item/organ/external/O = src.loc
		if (isorgan(O))
			var/mob/living/carbon/human/victim = O.owner
			victim.hallucination(30,30)
			to_chat(victim,SPAN_COLOR("maroon", "[pick(infected_message_list)]"))
			if(prob(50))
				victim.druggy = max(victim.druggy, 30)
