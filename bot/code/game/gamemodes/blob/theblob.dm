//I will need to recode parts of this but I am way too tired atm
/obj/effect/blob
	name = "blob"
	icon = 'icons/mob/blob.dmi'
	luminosity = 3
	desc = "Some blob creature thingy"
	density = 0
	opacity = 0
	anchored = 1
	var/health = 30
	var/brute_resist = 4
	var/fire_resist = 1


	New(loc)
		blobs += src
		src.dir = pick(1, 2, 4, 8)
		src.update_icon()
		..(loc)
		for(var/atom/A in loc)
			A.blob_act()
		return


	Del()
		blobs -= src
		..()
		return


	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if(air_group || (height==0))	return 1
		if(istype(mover) && mover.checkpass(PASSBLOB))	return 1
		return 0


	process()
		Life()
		return

	fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		..()
		var/damage = Clamp(0.01 * exposed_temperature / fire_resist, 0, 4 - fire_resist)
		if(damage)
			health -= damage
			update_icon()

	proc/Life()
		return


	proc/Pulse(var/pulse = 0, var/origin_dir = 0)//Todo: Fix spaceblob expand

		set background = 1

		if(run_action())//If we can do something here then we dont need to pulse more
			return

		if(pulse > 30)
			return//Inf loop check

		//Looking for another blob to pulse
		var/list/dirs = list(1,2,4,8)
		dirs.Remove(origin_dir)//Dont pulse the guy who pulsed us
		for(var/i = 1 to 4)
			if(!dirs.len)	break
			var/dirn = pick(dirs)
			dirs.Remove(dirn)
			var/turf/T = get_step(src, dirn)
			var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)
			if(!B)
				expand(T)//No blob here so try and expand
				return
			B.Pulse((pulse+1),get_dir(src.loc,T))
			return
		return


	proc/run_action()
		return 0


	proc/expand(var/turf/T = null, var/prob = 1)
		if(prob && !prob(health))	return
		if(istype(T, /turf/space) && prob(75)) 	return
		if(!T)
			var/list/dirs = list(1,2,4,8)
			for(var/i = 1 to 4)
				var/dirn = pick(dirs)
				dirs.Remove(dirn)
				T = get_step(src, dirn)
				if(!(locate(/obj/effect/blob) in T))	break
				else	T = null

		if(!T)	return 0
		var/obj/effect/blob/normal/B = new /obj/effect/blob/normal(src.loc, min(src.health, 30))
		B.density = 1
		if(T.Enter(B,src))//Attempt to move into the tile
			B.density = initial(B.density)
			B.loc = T
		else
			T.blob_act()//If we cant move in hit the turf
			B.Delete()

		for(var/atom/A in T)//Hit everything in the turf
			A.blob_act()
		return 1


	ex_act(severity)
		var/damage = 150
		health -= ((damage/brute_resist) - (severity * 5))
		update_icon()
		return


	bullet_act(var/obj/item/projectile/Proj)
		..()
		switch(Proj.damage_type)
		 if(BRUTE)
			 health -= (Proj.damage/brute_resist)
		 if(BURN)
			 health -= (Proj.damage/fire_resist)

		update_icon()
		return 0


	attackby(var/obj/item/weapon/W, var/mob/user)
		playsound(src.loc, 'sound/effects/attackblob.ogg', 50, 1)
		src.visible_message("\red <B>The [src.name] has been attacked with \the [W][(user ? " by [user]." : ".")]")
		var/damage = 0
		switch(W.damtype)
			if("fire")
				damage = (W.force / max(src.fire_resist,1))
				if(istype(W, /obj/item/weapon/weldingtool))
					playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)
			if("brute")
				damage = (W.force / max(src.brute_resist,1))

		health -= damage
		update_icon()
		return

	proc/change_to(var/type)
		if(!ispath(type))
			error("[type] is an invalid type for the blob.")
		new type(src.loc)
		Delete()
		return

	proc/Delete()
		del(src)

/obj/effect/blob/normal
	icon_state = "blob"
	luminosity = 0
	health = 21

	Delete()
		src.loc = null
		blobs -= src

	update_icon()
		if(health <= 0)
			playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
			Delete()
			return
		if(health <= 15)
			icon_state = "blob_damaged"
			return
