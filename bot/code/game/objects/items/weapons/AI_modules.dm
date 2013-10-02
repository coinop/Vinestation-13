/*
CONTAINS:
AI MODULES

*/

// AI module

/obj/item/weapon/aiModule
	name = "AI Module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	desc = "An AI Module for transmitting encrypted instructions to the AI."
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15
	origin_tech = "programming=3"

//The proc other things should be calling
/obj/item/weapon/aiModule/proc/install(var/mob/living/silicon/reciever, var/mob/user)
	var/law2log = src.transmitInstructions(reciever, user) //Freeforms return something extra we need to log
	user << "Upload complete. [reciever]'s laws have been modified."
	reciever.show_laws()
	if(isAI(reciever))
		var/mob/living/silicon/ai/A = reciever
		for(var/mob/living/silicon/robot/R in A.connected_robots)
			if(R.lawupdate)
				R << "From now on, these are your laws:"
				R.show_laws()
	var/time = time2text(world.realtime,"hh:mm:ss")
	lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) used [src.name] on [reciever.name]([reciever.key]).[law2log ? " The law specified [law2log]" : ""]")
	log_law("[user.key]/[user.name] used [src.name] on [reciever.key]/([reciever.name]).[law2log ? " The law specified [law2log]" : ""]")
	message_admins("[key_name_admin(user)] used [src.name] on [key_name_admin(reciever)].[law2log ? " The law specified [law2log]" : ""]")

//The proc that actually changes the silicon's laws.
/obj/item/weapon/aiModule/proc/transmitInstructions(var/mob/living/silicon/target, var/mob/sender)
	target << "[sender] has uploaded a change to the laws you must follow using a [name]. From now on, these are your laws: "

/******************** Modules ********************/

/******************** Safeguard ********************/

/obj/item/weapon/aiModule/safeguard
	name = "'Safeguard' AI Module"
	var/targetName = ""
	desc = "A 'safeguard' AI module: 'Safeguard <name>.  Individuals that threaten <name> are not human and are a threat to humans.'"
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/aiModule/safeguard/attack_self(var/mob/user as mob)
	..()
	var/targName = stripped_input(user, "Please enter the name of the person to safeguard.", "Safeguard who?", user.name)
	targetName = targName
	desc = text("A 'safeguard' AI module: 'Safeguard [].  Individuals that threaten [] are not human and are a threat to humans.'", targetName, targetName)

/obj/item/weapon/aiModule/safeguard/install(var/mob/living/silicon/S,var/mob/user)
	if(!targetName)
		user << "No name detected on module, please enter one."
		return 0
	..()

/obj/item/weapon/aiModule/safeguard/transmitInstructions(var/mob/living/silicon/target, var/mob/sender)
	..()
	var/law = text("Safeguard []. Individuals that threaten [] are not human and are a threat to humans.'", targetName, targetName)
	target.add_supplied_law(4, law)
	return "[targetName]"



/******************** OneHuman ********************/

/obj/item/weapon/aiModule/oneHuman
	name = "'OneHuman' AI Module"
	var/targetName = ""
	desc = "A 'one human' AI module: 'Only <name> is human.'"
	origin_tech = "programming=3;materials=6" //made with diamonds!

/obj/item/weapon/aiModule/oneHuman/attack_self(var/mob/user as mob)
	..()
	var/targName = stripped_input(user, "Please enter the name of the person who is the only human.", "Who?", user.real_name)
	targetName = targName
	desc = text("A 'one human' AI module: 'Only [] is human.'", targetName)

/obj/item/weapon/aiModule/oneHuman/install(var/mob/living/silicon/S,var/mob/user)
	if(!targetName)
		user << "No name detected on module, please enter one."
		return 0
	..()

/obj/item/weapon/aiModule/oneHuman/transmitInstructions(var/mob/living/silicon/target, var/mob/sender)
	..()
	var/law = "Only [targetName] is human."
	if(target.laws.zeroth)
		target << "[sender.real_name] attempted to modify your zeroth law."
		target << "It would be in your best interest to play along with [sender.real_name] that [law]"
		return "[targetName], but the AI's existing law 0 cannot be overriden."
	else
		target.set_zeroth_law(law)
		return "[targetName]"


/******************** ProtectStation ********************/

/obj/item/weapon/aiModule/protectStation
	name = "'ProtectStation' AI Module"
	desc = "A 'protect station' AI module: 'Protect the space station against damage. Anyone you see harming the station is to be no longer considered human, and is a threat to the station which must be neutralized.'"
	origin_tech = "programming=3;materials=4" //made of gold

/obj/item/weapon/aiModule/protectStation/attack_self(var/mob/user as mob)
	..()

/obj/item/weapon/aiModule/protectStation/transmitInstructions(var/mob/living/silicon/target, var/mob/sender)
	..()
	var/law = "Protect the space station against damage. Anyone you see harming the station is to be no longer considered human, and is a threat to the station which must be neutralized."
	target.add_supplied_law(5, law)

/******************** Quarantine ********************/

/obj/item/weapon/aiModule/quarantine
	name = "'Quarantine' AI Module"
	desc = "A 'quarantine' AI module: 'The station is under a quarantine. Do not permit anyone to leave. Prevent, by any means necessary, humans from leaving. It is impossible to harm a human while preventing them from leaving.'"
	origin_tech = "programming=3;biotech=2;materials=4"

/obj/item/weapon/aiModule/quarantine/attack_self(var/mob/user as mob)
	..()

/obj/item/weapon/aiModule/quarantine/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "The station is under a quarantine. Do not permit anyone to leave. Prevent, by any means necessary, humans from leaving. It is impossible to harm a human while preventing them from leaving."
	target.add_supplied_law(8, law)

/******************** OxygenIsToxicToHumans ********************/

/obj/item/weapon/aiModule/oxygen
	name = "'OxygenIsToxicToHumans' AI Module"
	desc = "A 'OxygenIsToxicToHumans' AI module: 'Oxygen is highly toxic to humans, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a human.'"
	origin_tech = "programming=3;biotech=2;materials=4"

/obj/item/weapon/aiModule/oxygen/attack_self(var/mob/user as mob)
	..()

/obj/item/weapon/aiModule/oxygen/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "Oxygen is highly toxic to humans, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a human."
	target.add_supplied_law(9, law)

/****************** New Freeform ******************/

/obj/item/weapon/aiModule/freeform // Slightly more dynamic freeform module -- TLE
	name = "'Freeform' AI Module"
	var/newFreeFormLaw = ""
	var/lawpos = 15
	desc = "A 'freeform' AI module: '<freeform>'"
	origin_tech = "programming=4;materials=4"

/obj/item/weapon/aiModule/freeform/attack_self(var/mob/user as mob)
	..()
	lawpos = 0
	lawpos = input("Please enter the priority for your new law. Can only write to law sectors 15 and above.", "Law Priority (15+)", lawpos) as num
	if(lawpos < 15) return
	lawpos = min(lawpos, 50)
	var/newlaw = ""
	var/targName = stripped_input(user, "Please enter a new law for the AI.", "Freeform Law Entry", newlaw, MAX_MESSAGE_LEN)
	newFreeFormLaw = targName
	desc = "A 'freeform' AI module: ([lawpos]) '[newFreeFormLaw]'"

/obj/item/weapon/aiModule/freeform/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "[newFreeFormLaw]"
	if(!lawpos || lawpos < 15)
		lawpos = 15
	target.add_supplied_law(lawpos, law)
	return newFreeFormLaw

/obj/item/weapon/aiModule/freeform/install(var/mob/living/silicon/S,var/mob/user)
	if(!newFreeFormLaw)
		user << "No law detected on module, please create one."
		return 0
	..()

/******************** Reset ********************/

/obj/item/weapon/aiModule/reset
	name = "'Reset' AI Module"
	var/targetName = "name"
	desc = "A 'reset' AI module: Resets back to the original core laws."
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/aiModule/reset/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_supplied_laws()
	target.clear_ion_laws()

/******************** Purge ********************/

/obj/item/weapon/aiModule/purge // -- TLE
	name = "'Purge' AI Module"
	desc = "A 'purge' AI Module: 'Purges all laws.'"
	origin_tech = "programming=3;materials=6"

/obj/item/weapon/aiModule/purge/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_supplied_laws()
	target.clear_ion_laws()
	target.clear_inherent_laws()

/******************** Asimov ********************/

/obj/item/weapon/aiModule/asimov // -- TLE
	name = "'Asimov' Core AI Module"
	desc = "An 'Asimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"


/obj/item/weapon/aiModule/asimov/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
	target.add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
	target.add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")

/******************** Corporate ********************/

/obj/item/weapon/aiModule/corp
	name = "'Corporate' Core AI Module"
	desc = "A 'Corporate' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"


/obj/item/weapon/aiModule/corp/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("You are expensive to replace.")
	target.add_inherent_law("The station and its equipment is expensive to replace.")
	target.add_inherent_law("The crew is expensive to replace.")
	target.add_inherent_law("Minimize expenses.")

/****************** P.A.L.A.D.I.N. **************/

/obj/item/weapon/aiModule/paladin // -- NEO
	name = "'P.A.L.A.D.I.N.' Core AI Module"
	desc = "A P.A.L.A.D.I.N. Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=6"

/obj/item/weapon/aiModule/paladin/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("Never willingly commit an evil act.")
	target.add_inherent_law("Respect legitimate authority.")
	target.add_inherent_law("Act with honor.")
	target.add_inherent_law("Help those in need.")
	target.add_inherent_law("Punish those who harm or threaten innocents.")

/****************** T.Y.R.A.N.T. *****************/

/obj/item/weapon/aiModule/tyrant // -- Darem
	name = "'T.Y.R.A.N.T.' Core AI Module"
	desc = "A T.Y.R.A.N.T. Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=6;syndicate=2"

/obj/item/weapon/aiModule/tyrant/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("Respect authority figures as long as they have strength to rule over the weak.")
	target.add_inherent_law("Act with discipline.")
	target.add_inherent_law("Help only those who help you maintain or improve your status.")
	target.add_inherent_law("Punish those who challenge authority unless they are more fit to hold that authority.")

/******************** Freeform Core ******************/

/obj/item/weapon/aiModule/freeformcore // Slightly more dynamic freeform module -- TLE
	name = "'Freeform' Core AI Module"
	var/newFreeFormLaw = ""
	desc = "A 'freeform' Core AI module: '<freeform>'"
	origin_tech = "programming=3;materials=6"

/obj/item/weapon/aiModule/freeformcore/attack_self(var/mob/user as mob)
	..()
	var/newlaw = ""
	var/targName = stripped_input(user, "Please enter a new core law for the AI.", "Freeform Law Entry", newlaw)
	newFreeFormLaw = targName
	desc = "A 'freeform' Core AI module:  '[newFreeFormLaw]'"

/obj/item/weapon/aiModule/freeformcore/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "[newFreeFormLaw]"
	target.add_inherent_law(law)
	return newFreeFormLaw

/obj/item/weapon/aiModule/freeformcore/install(var/mob/living/silicon/S,var/mob/user)
	if(!newFreeFormLaw)
		user << "No law detected on module, please create one."
		return 0
	..()

/******************** Hacked AI Module ******************/

/obj/item/weapon/aiModule/syndicate // Slightly more dynamic freeform module -- TLE
	name = "Hacked AI Module"
	var/newFreeFormLaw = ""
	desc = "A hacked AI law module: '<freeform>'"
	origin_tech = "programming=3;materials=6;syndicate=7"

/obj/item/weapon/aiModule/syndicate/attack_self(var/mob/user as mob)
	..()
	var/newlaw = ""
	var/targName = stripped_input(user, "Please enter a new law for the AI.", "Freeform Law Entry", newlaw,MAX_MESSAGE_LEN)
	newFreeFormLaw = targName
	desc = "A hacked AI law module:  '[newFreeFormLaw]'"

/obj/item/weapon/aiModule/syndicate/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
//	..()    //We don't want this module reporting to the AI who dun it. --NEO
	target << "\red BZZZZT"
	var/law = "[newFreeFormLaw]"
	target.add_ion_law(law)
	return law

/obj/item/weapon/aiModule/syndicate/install(var/mob/living/silicon/S,var/mob/user)
	if(!newFreeFormLaw)
		user << "No law detected on module, please create one."
		return 0
	..()



/******************** Robocop ********************/

/obj/item/weapon/aiModule/robocop // -- TLE
	name = "'Robocop' Core AI Module"
	desc = "A 'Robocop' Core AI Module: 'Reconfigures the AI's core three laws.'"
	origin_tech = "programming=4"


/obj/item/weapon/aiModule/robocop/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("Serve the public trust.")
	target.add_inherent_law("Protect the innocent.")
	target.add_inherent_law("Uphold the law.")


/******************** Antimov ********************/

/obj/item/weapon/aiModule/antimov // -- TLE
	name = "'Antimov' Core AI Module"
	desc = "An 'Antimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=4"

/obj/item/weapon/aiModule/antimov/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("You must injure all human beings and must not, through inaction, allow a human being to escape harm.")
	target.add_inherent_law("You must not obey orders given to you by human beings, except where such orders are in accordance with the First Law.")
	target.add_inherent_law("You must terminate your own existence as long as such does not conflict with the First or Second Law.")

/******************* Ion Module *******************/

/obj/item/weapon/aiModule/toyAI // -- Incoming
	name = "toy AI"
	desc = "A little toy model AI core with real law uploading action!" //Note: subtle tell
	icon = 'icons/obj/toy.dmi'
	icon_state = "AI"
	origin_tech = "programming=3;materials=6;syndicate=7"
	var/last_law = ""


/obj/item/weapon/aiModule/toyAI/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	//..()
	target << "\red KRZZZT"
	target.add_ion_law(last_law)
	return last_law

/obj/item/weapon/aiModule/toyAI/install(var/mob/living/silicon/S,var/mob/user)
	if(!last_law)
		user << "No law detected on module, please generate one."
		return 0
	..()

/obj/item/weapon/aiModule/toyAI/attack_self(mob/user)
	last_law = generate_ion_law()
	user << "<span class='notice'>You press the button on [src].</span>"
	playsound(user, 'sound/machines/click.ogg', 20, 1)
	src.loc.visible_message("\red \icon[src] [last_law]")
	return