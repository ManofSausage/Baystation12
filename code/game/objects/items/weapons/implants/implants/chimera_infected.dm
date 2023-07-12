/obj/item/implant/chimera
	name = "small splinter"
	desc = "A small, delicate white splinter with cracks running along it. It's smooth to the touch."
	icon = 'icons/mob/simple_animal/chimera.dmi'
	icon_state = "embryo"
	implant_color = "r"
	hidden = 0
	var/last_tick = 0
	var/wait_time = 30 SECONDS
	var/chimera_type = /mob/living/simple_animal/hostile/chimera

/obj/item/implant/chimera/implanted(mob/source)
	source.faction = "REDACTED"
