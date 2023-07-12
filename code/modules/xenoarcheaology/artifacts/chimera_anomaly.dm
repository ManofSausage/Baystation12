/obj/machinery/artifact/chimera_anomaly
	name="strange pillar"
	icon_height = 64
	desc = "A towering, bone white pillar composed of smaller pillars fused together, made of a vaguely glistening material"
	icon = 'icons/obj/chimera_anomaly.dmi'
	icon_state = "ano190"
	anchored = TRUE
	layer = FLY_LAYER
	can_damage = FALSE
	damage_type = FALSE

/obj/machinery/artifact/chimera_anomaly/New()
	..()

	var/effecttype = pick(typesof(/datum/artifact_effect/cold) - /datum/artifact_effect)
	my_effect = new effecttype(src)
	var/triggertype = /datum/artifact_trigger/energy
	my_effect.trigger = new triggertype
	effecttype = pick(typesof(/datum/artifact_effect/scrying) - /datum/artifact_effect)
	secondary_effect = new effecttype(src)
	triggertype = /datum/artifact_trigger/touch/organic
	secondary_effect.trigger = new triggertype
	secondary_effect.ToggleActivate(0)
	src.desc = "A towering, bone white pillar composed of smaller pillars fused together, made of a vaguely glistening material"
	src.name = "strange pillar"
	icon_num = 19
	icon_state = "ano[icon_num]0"


	setup_destructibility()
