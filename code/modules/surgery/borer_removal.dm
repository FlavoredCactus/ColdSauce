/datum/surgery/borer_removal
	name = "borer removal"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/saw, /datum/surgery_step/borer_removal, /datum/surgery_step/close)
	species = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	location = "head"

/datum/surgery_step/borer_removal
	implements = list(/obj/item/weapon/hemostat = 100, /obj/item/weapon/shovel/spade = 65, /obj/item/weapon/minihoe = 50, /obj/item/weapon/crowbar = 35)
	time = 64

/datum/surgery_step/borer_removal/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to search in [target]'s head for a cortical borer.</span>")

/datum/surgery_step/borer_removal/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(remove_borer(user, target))
		user.visible_message("<span class='notice'>[user] successfully extracts the cortical borer from [target]!</span>")
	else
		user.visible_message("<span class='notice'>[user] can't find anything in [target]'s head!</span>")
	return 1

/datum/surgery_step/borer_removal/proc/remove_borer(mob/user, mob/living/carbon/target)
	var/mob/living/simple_animal/borer/B = locate() in target.contents
	if(B)
		user << "<span class='notice'>You found a cortical borer in [target]'s head!</span>"
		B.detach()
		return 1


/datum/surgery_step/borer_removal/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/simple_animal/borer/B = locate() in target.contents
	if(B)
		user.visible_message("<span class='warning'>[user] accidentally pokes the cortical borer in [target]!</span>")
	else
		target.adjustBrainLoss(30)
		user.visible_message("<span class='warning'>[user] accidentally pokes [target] in the brain!</span>")
	return 0