--[[

	
		db   dD  .d8b.  d888888b  .d8b.  d8888b. d888888b d8b   db  .d8b.  
		88 ,8P' d8' `8b `~~88~~' d8' `8b 88  `8D   `88'   888o  88 d8' `8b 
		88,8P   88ooo88    88    88ooo88 88oobY'    88    88V8o 88 88ooo88 
		88`8b   88~~~88    88    88~~~88 88`8b      88    88 V8o88 88~~~88 
		88 `88. 88   88    88    88   88 88 `88.   .88.   88  V888 88   88 
		YP   YD YP   YP    YP    YP   YP 88   YD Y888888P VP   V8P YP   YP 
                                                                   

	Script - Katarina - The Sinister Blase 2.0 by Skeem

	Changelog :
   1.0 - Initial Release
   1.1 - Fixed Damage Calculation
	   - Fixed Auto Ignite
	   - Hopefully Fixed BugSplat
   1.2 - Really fixed BugSplat Now
	   - More Damage Calculation Adjustments
	   - More checks for when to ult
	   - More checks to not use W when enemy not in range
   1.2.1 - Fixed the problem with channelling ultimate
   1.3 - Fixed the problem with ult AGAIN
       - Added Auto Pots
	   - Added Auto Zhonyas
	   - Added Draw Circles of targets that can die
   1.3.1 - Lul another Ult fix wtfux
         - Added move to mouse to harass mode
   1.4 - Recoded most of the script
       - Added toggle to use items with KS
	   - Jungle Clearing
	   - New method to stop ult from not channeling
	   - New Menu
	   - Lane Clear
   1.4.1 - Added packet block ult movement
   1.4.2 - Some draw text fixes
		 - ult range fixes so it doesn't keep spinning if no enemies are around
		 - Added some permashows
   1.5   - No longer AutoCarry Script
         - Requires iSAC library for orbwalking
		 - Revamped code a little
		 - Deleted ult usage from auto KS for now
   1.5.2 - Fixed Skills not casting ult
         - Fixed enemy chasing bug
		 - Added delay W to both harass & full combo with toggle in menu
   1.6   - Fixed Jungle Clear
		 - Added Toggle to Stop ult if enemies can die from other spells
		 - Fixed Ward Jump
		 - Improved Farm a bit
   1.6.1 - Added Blackfire Tourch in combo
         - Fixed ult stop when enemies can die
   1.6.2 - Fixed Blackfire torch error
   1.7   - Updated ward jump, won't use more than 1 item
         - Beta KS with wards if E not ready
		 - Beta ward save when in danger
		 - Doesn't require iSAC anymore
   1.7.1 - Fixed ward jump (doesn't jump to wards that are in oposite way of mouse)
         - Fixed Combo
		 - some fixes for auto ward save
   1.8   - Added Trinkets for Ward Jump
         - Improved KS a little, removed unnecessary code
   1.8.3 - Attempt to fix some errors
         - Reworked combo a little should be smoother now
         - Added togge for orbwalking in combo as requested
         - Casting wards should work a little better as well
   1.8.4 - Fixed bugsplat
   1.8.5 - Fixed Draw Errors
   1.8.7 - Fixed W Delay changed name to Proc Q Mark
         - Fixed text errors added Q mark to calculations
   1.9   - Fixed ult issues recoded a couple of things
   2.0   - Big update rewrote everything!
         - Combo Reworked should be a lot smoother now
         - Harass Reworked as well, should work better and detonate marks
         - Farm reworked / Uses mixed skill damages to maximize farm
         - Ward Jump Improved / Now Can ward to minions & allies that are in range
         - Lane Clear & Jungle Clear Improved / Uses new jungle table with all mobs in 5v5 / 3v3
         - New Overkill Protection
         - New Option to OrbWalk Minions In Lane During Lane Clear
         - New Option to Orbwalk Jungle during jungle clear
         - New Option to block packets while channeling (Won't block ultimate if Target is killable (Option for this too))
         - New Option to KS with Ult
         - New Option to KS with Items
         - New Option to KS with Wards / Minions / Allies
         - Added Priority Arranger to Target Selector
         - New Draw which shows exactly which skills need to be used to kill
         - New Option to Draw Who is being targetted by text
         - New Option to Draw a circle around target

  	]] --		

-- / Hero Name Check / --
if myHero.charName ~= "Katarina" then return end
-- / Hero Name Check / --

-- / Loading Function / --
function OnLoad()
	--->
		Variables()
		KatarinaMenu()
		PrintChat("<font color='#FF0000'> >> Katarina - The Sinister Blade 2.0 Loaded!! <<</font>")
	---<
end
-- / Loading Function / --

-- / Tick Function / --
function OnTick()
	--->
		Checks()
		DamageCalculation()
		UseConsumables()

		if Target then
			if KatarinaMenu.harass.wharass then CastW(Target) end
			if KatarinaMenu.killsteal.Ignite then AutoIgnite(Target) end
		end
	---<
	-- Menu Variables --
	--->
		ComboKey =     KatarinaMenu.combo.comboKey
		FarmingKey =   KatarinaMenu.farming.farmKey
		HarassKey =    KatarinaMenu.harass.harassKey
		ClearKey =     KatarinaMenu.clear.clearKey
		WardJumpKey =  KatarinaMenu.misc.wardJumpKey
	---<
	-- Menu Variables --
	--->
		if ComboKey then
			FullCombo()
		end
		if HarassKey then
			HarassCombo()
		end
		if FarmingKey and not ComboKey then
			Farm()
		end
		if ClearKey then
			MixedClear()
		end	
		if WardJumpKey then
			moveToCursor()
			local WardPos = GetDistance(mousePos) <= 600 and mousePos or getMousePos()
			wardJump(WardPos.x, WardPos.z)
		end
		if KatarinaMenu.killsteal.smartKS then KillSteal() end
		if KatarinaMenu.misc.AutoLevelSkills then autoLevelSetSequence(levelSequence) end
	---<
end
-- / Tick Function / --

-- / Variables Function / --
function Variables()
	--- Skills Vars --
	--->
		SkillQ = {range = 675, name = "Bouncing Blades", ready = false}
		SkillW = {range = 375, name = "Sinister Steel", ready = false}
		SkillE = {range = 700, name = "Shunpo", ready = false}
		SkillR = {range = 550, name = "Death Lotus", ready = false}
	---<
	--- Skills Vars ---
	--- Items Vars ---
	--->
		Items = {
					HealthPot      = {ready = false},
					ManaPot        = {ready = false},
					FlaskPot       = {ready = false},
					TrinketWard    = {ready = false},
		            RubySightStone = {ready = false},
				    SightStone     = {ready = false},
				    SightWard      = {ready = false},
				    VisionWard     = {ready = false}
         }
	---<
	--- Items Vars ---
	--- Orbwalking Vars ---
	--->
		lastAnimation = "Run"
		lastAttack = 0
		lastAttackCD = 0
		lastWindUpTime = 0
	---<
	--- Orbwalking Vars --
	--- Drawing Vars ---
	--->
		TextList = {"Harass him!!", "Q Kill!", "W Kill!", "E Kill!", "Q+W Kill!", "Q+E Kill!", "W+E Kill!", "Q+W+E Kill!", "Full Combo Kill!", "Need CDs"}
		KillText = {}
		colorText = ARGB(255,0,255,0)
	---<
	--- Drawing Vars ---
	--- Misc Vars ---
	--->
		lastwardused = 0
		levelSequence = { 1,3,2,2,2,4,2,1,2,1,4,1,1,3,3,4,3,3 }
		UsingHPot = false
		castDelay, castingUlt = 0, false
		gameState = GetGame()
		if gameState.map.shortName == "twistedTreeline" then
			TTMAP = true
		else
			TTMAP = false
		end
	---<
	--- Misc Vars ---
	--- Tables ---
	--->
		Wards = {}
		allyHeroes = GetAllyHeroes()
		enemyHeroes = GetEnemyHeroes()
		enemyMinions = minionManager(MINION_ENEMY, 1000, player, MINION_SORT_HEALTH_ASC)
		allyMinions = minionManager(MINION_ALLY, 1000, player, MINION_SORT_HEALTH_DES)
		JungleMobs = {}
		JungleFocusMobs = {}
		priorityTable = {
	    	AP = {
	        	"Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
	        	"Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
	        	"Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra",
	        },
	    	Support = {
	        	"Alistar", "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean",
	        },
	    	Tank = {
	        	"Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Nautilus", "Shen", "Singed", "Skarner", "Volibear",
	        	"Warwick", "Yorick", "Zac",
	        },
	    	AD_Carry = {
	        	"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "Jinx", "KogMaw", "Lucian", "MasterYi", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
	        	"Talon","Tryndamere", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Yasuo","Zed", 
	        },
	    	Bruiser = {
	        	"Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nocturne", "Olaf", "Poppy",
	        	"Renekton", "Rengar", "Riven", "Rumble", "Shyvana", "Trundle", "Udyr", "Vi", "MonkeyKing", "XinZhao",
	        },
        }
		if TTMAP then --
			FocusJungleNames = {
				["TT_NWraith1.1.1"] = true,
				["TT_NGolem2.1.1"] = true,
				["TT_NWolf3.1.1"] = true,
				["TT_NWraith4.1.1"] = true,
				["TT_NGolem5.1.1"] = true,
				["TT_NWolf6.1.1"] = true,
				["TT_Spiderboss8.1.1"] = true,
			}		
			JungleMobNames = {
        		["TT_NWraith21.1.2"] = true,
        		["TT_NWraith21.1.3"] = true,
        		["TT_NGolem22.1.2"] = true,
        		["TT_NWolf23.1.2"] = true,
        		["TT_NWolf23.1.3"] = true,
        		["TT_NWraith24.1.2"] = true,
        		["TT_NWraith24.1.3"] = true,
        		["TT_NGolem25.1.1"] = true,
        		["TT_NWolf26.1.2"] = true,
        		["TT_NWolf26.1.3"] = true,
			}
		else 
			JungleMobNames = { 
        		["Wolf8.1.2"] = true,
        		["Wolf8.1.3"] = true,
        		["YoungLizard7.1.2"] = true,
        		["YoungLizard7.1.3"] = true,
        		["LesserWraith9.1.3"] = true,
        		["LesserWraith9.1.2"] = true,
        		["LesserWraith9.1.4"] = true,
        		["YoungLizard10.1.2"] = true,
        		["YoungLizard10.1.3"] = true,
        		["SmallGolem11.1.1"] = true,
        		["Wolf2.1.2"] = true,
        		["Wolf2.1.3"] = true,
        		["YoungLizard1.1.2"] = true,
        		["YoungLizard1.1.3"] = true,
        		["LesserWraith3.1.3"] = true,
        		["LesserWraith3.1.2"] = true,
        		["LesserWraith3.1.4"] = true,
        		["YoungLizard4.1.2"] = true,
        		["YoungLizard4.1.3"] = true,
        		["SmallGolem5.1.1"] = true,
			}
			FocusJungleNames = {
        		["Dragon6.1.1"] = true,
        		["Worm12.1.1"] = true,
        		["GiantWolf8.1.1"] = true,
        		["AncientGolem7.1.1"] = true,
        		["Wraith9.1.1"] = true,
        		["LizardElder10.1.1"] = true,
        		["Golem11.1.2"] = true,
        		["GiantWolf2.1.1"] = true,
        		["AncientGolem1.1.1"] = true,
        		["Wraith3.1.1"] = true,
        		["LizardElder4.1.1"] = true,
        		["Golem5.1.2"] = true,
				["GreatWraith13.1.1"] = true,
				["GreatWraith14.1.1"] = true,
			}
		end
		for i = 0, objManager.maxObjects do
			local object = objManager:getObject(i)
			if object ~= nil then
				if FocusJungleNames[object.name] then
					table.insert(JungleFocusMobs, object)
				elseif JungleMobNames[object.name] then
					table.insert(JungleMobs, object)
				end
			end
		end
	---<
	--- Tables ---
end
-- / Variables Function / --

-- / Menu Function / --
function KatarinaMenu()
	--- Main Menu ---
	--->
		KatarinaMenu = scriptConfig("Katarina - The Sinister Blade", "Katarina")
		---> Combo Menu
		KatarinaMenu:addSubMenu("["..myHero.charName.." - Combo Settings]", "combo")
			KatarinaMenu.combo:addParam("comboKey", "Full Combo Key (X)", SCRIPT_PARAM_ONKEYDOWN, false, 88)
			KatarinaMenu.combo:addParam("stopUlt", "Stop "..SkillR.name.." (R) If Target Can Die", SCRIPT_PARAM_ONOFF, false)
			KatarinaMenu.combo:addParam("detonateQ", "Try to Proc "..SkillQ.name.." (Q) Mark", SCRIPT_PARAM_ONOFF, false)
			KatarinaMenu.combo:addParam("comboItems", "Use Items with Burst", SCRIPT_PARAM_ONOFF, true)
			KatarinaMenu.combo:addParam("comboOrbwalk", "Orbwalk in Combo", SCRIPT_PARAM_ONOFF, true)
			KatarinaMenu.combo:permaShow("comboKey")
		---<
		---> Harass Menu
		KatarinaMenu:addSubMenu("["..myHero.charName.." - Harass Settings]", "harass")
			KatarinaMenu.harass:addParam("detonateQ", "Proc Q Mark", SCRIPT_PARAM_ONOFF, true)
			KatarinaMenu.harass:addParam("hMode", "Harass Mode",SCRIPT_PARAM_SLICE, 1, 1, 2, 0)
			KatarinaMenu.harass:addParam("harassKey", "Harass Hotkey (T)", SCRIPT_PARAM_ONKEYDOWN, false, 84)
			KatarinaMenu.harass:addParam("wharass", "Always Sinister Steel (W)", SCRIPT_PARAM_ONOFF, true)
			KatarinaMenu.harass:addParam("mTmH", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
			KatarinaMenu.harass:permaShow("harassKey")
		---<
		---> Farming Menu
		KatarinaMenu:addSubMenu("["..myHero.charName.." - Farming Settings]", "farming")
			KatarinaMenu.farming:addParam("farmKey", "Farming ON/Off (Z)", SCRIPT_PARAM_ONKEYTOGGLE, true, 90)
			KatarinaMenu.farming:addParam("qFarm", "Farm with Bouncing Blades (Q)", SCRIPT_PARAM_ONOFF, true)
			KatarinaMenu.farming:addParam("wFarm", "Sinister Steel (W)", SCRIPT_PARAM_ONOFF, true)
			KatarinaMenu.farming:addParam("eFarm", "Farm with Shunpo (E)", SCRIPT_PARAM_ONOFF, false)
			KatarinaMenu.farming:permaShow("farmKey")
		---<
		---> Clear Menu		
		KatarinaMenu:addSubMenu("["..myHero.charName.." - Clear Settings]", "clear")
			KatarinaMenu.clear:addParam("clearKey", "Jungle/Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, 86)
			KatarinaMenu.clear:addParam("JungleFarm", "Use Skills to Farm Jungle", SCRIPT_PARAM_ONOFF, true)
			KatarinaMenu.clear:addParam("ClearLane", "Use Skills to Clear Lane", SCRIPT_PARAM_ONOFF, true)
			KatarinaMenu.clear:addParam("clearQ", "Clear with "..SkillQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
			KatarinaMenu.clear:addParam("clearW", "Clear with "..SkillW.name.." (W)", SCRIPT_PARAM_ONOFF, true)
			KatarinaMenu.clear:addParam("clearE", "Clear with "..SkillE.name.." (E)", SCRIPT_PARAM_ONOFF, true)
			KatarinaMenu.clear:addParam("clearOrbM", "OrbWalk Minions", SCRIPT_PARAM_ONOFF, true)
			KatarinaMenu.clear:addParam("clearOrbJ", "OrbWalk Jungle", SCRIPT_PARAM_ONOFF, true)
		---<
		---> KillSteal Menu
		KatarinaMenu:addSubMenu("["..myHero.charName.." - KillSteal Settings]", "killsteal")
			KatarinaMenu.killsteal:addParam("smartKS", "Use Smart Kill Steal", SCRIPT_PARAM_ONOFF, true)
			KatarinaMenu.killsteal:addParam("wardKS", "Use Wards to KS", SCRIPT_PARAM_ONOFF, true)
			KatarinaMenu.killsteal:addParam("ultKS", "Use "..SkillR.name.." (R) to KS", SCRIPT_PARAM_ONOFF, true)
			KatarinaMenu.killsteal:addParam("itemsKS", "Use Items to KS", SCRIPT_PARAM_ONOFF, true)
			KatarinaMenu.killsteal:addParam("Ignite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
			KatarinaMenu.killsteal:permaShow("KillSteal")
		---<
		---> Drawing Menu			
		KatarinaMenu:addSubMenu("["..myHero.charName.." - Drawing Settings]", "drawing")	
			KatarinaMenu.drawing:addParam("disableAll", "Disable All Ranges Drawing", SCRIPT_PARAM_ONOFF, false)
			KatarinaMenu.drawing:addParam("drawText", "Draw Enemy Text", SCRIPT_PARAM_ONOFF, true)
			KatarinaMenu.drawing:addParam("drawTargetText", "Draw Who I'm Targetting", SCRIPT_PARAM_ONOFF, true)
			KatarinaMenu.drawing:addParam("drawTargetCircle", "Draw Circle Around Target", SCRIPT_PARAM_ONOFF, false)
			KatarinaMenu.drawing:addParam("drawQ", "Draw Bouncing Blades (Q) Range", SCRIPT_PARAM_ONOFF, true)
			KatarinaMenu.drawing:addParam("drawW", "Draw Sinister Steel (W) Range", SCRIPT_PARAM_ONOFF, false)
			KatarinaMenu.drawing:addParam("drawE", "Draw Shunpo (E) Range", SCRIPT_PARAM_ONOFF, false)
		---<
		---> Misc Menu	
		KatarinaMenu:addSubMenu("["..myHero.charName.." - Misc Settings]", "misc")
			KatarinaMenu.misc:addParam("wardJumpKey", "Ward Jump Hotkey (G)", SCRIPT_PARAM_ONKEYDOWN, false, 71)
			KatarinaMenu.misc:addParam("wardSave", "Beta Ward Save", SCRIPT_PARAM_ONKEYDOWN, false, 71)
			KatarinaMenu.misc:addParam("ZWItems", "Auto Zhonyas/Wooglets", SCRIPT_PARAM_ONOFF, true)
			KatarinaMenu.misc:addParam("ZWHealth", "Min Health % for Zhonyas/Wooglets", SCRIPT_PARAM_SLICE, 15, 0, 100, -1)
			KatarinaMenu.misc:addParam("aHP", "Auto Health Pots", SCRIPT_PARAM_ONOFF, true)
			KatarinaMenu.misc:addParam("HPHealth", "Min % for Health Pots", SCRIPT_PARAM_SLICE, 50, 0, 100, -1)
			KatarinaMenu.misc:addParam("AutoLevelSkills", "Auto Level Skills (Requires Reload)", SCRIPT_PARAM_ONOFF, true)
			KatarinaMenu.misc:permaShow("WardJump")
		---<
		---> Target Slector		
			TargetSelector = TargetSelector(TARGET_LESS_CAST, SkillE.range, DAMAGE_MAGIC)
			TargetSelector.name = "Katarina"
			KatarinaMenu:addTS(TargetSelector)
		---<
		---> Arrange Priorities
			if heroManager.iCount < 10 then -- borrowed from Sidas Auto Carry, modified to 3v3
       			PrintChat(" >> Too few champions to arrange priority")
			elseif heroManager.iCount == 6 and TTMAP then
				ArrangeTTPrioritys()
    		else
        		ArrangePrioritys()
    		end
    	---<
	---<
	--- Main Menu ---
end
-- / Menu Function / --

-- / Full Combo Function / --
function FullCombo()
	--- Combo While Not Channeling --
	--->
		if castDelay == 0 then
			castingUlt = false
		end
		if not isChanneling("Spell4") and not castingUlt then
			if Target then
				if KatarinaMenu.combo.comboOrbwalk then
					OrbWalking(Target)
				end
				if KatarinaMenu.combo.bItems then
					UseItems(Target)
				end
				CastQ(Target)
				if KatarinaMenu.combo.detonateQ then
					if not SkillQ.ready then CastE(Target) end
					if not SkillE.ready then CastW(Target) end
				else
					CastE(Target)
					CastW(Target)
				end
				CastR(Target)
			else
				if KatarinaMenu.combo.comboOrbwalk then
					moveToCursor()
				end
			end
		end
	---<
	--- Combo While Not Channeling --
end
-- / Full Combo Function / --

-- / Harass Combo Function / --
function HarassCombo()
	--- Smart Harass --
	--->
		if KatarinaMenu.harass.mTmH then
			moveToCursor()
		end
		if Target then
			--- Harass Mode 1 Q+W+E ---
			if KatarinaMenu.harass.hMode == 1 then
				CastQ(Target)
				if KatarinaMenu.harass.detonateQ then
					if not SkillQ.ready then CastE(Target) end
					if not SkillW.ready then CastW(Target) end
				else
					CastE(Target)
					CastW(Target)
				end
			end
			--- Harass Mode 1 ---
			--- Harass Mode 2 Q+W ---
			if KatarinaMenu.harass.hMode == 2 then
				CastQ(Target)
				CastW(Target)
			end
			--- Harass Mode 2 ---
		end
	---<
	--- Smart Harass ---
end
-- / Harass Combo Function / --

-- / Farm Function / --
function Farm()
	--->
		for _, minion in pairs(enemyMinions.objects) do
			--- Minion Damages ---
			local qMinionDmg = getDmg("Q", minion, myHero)
        	local wMinionDmg = getDmg("W", minion, myHero)
			local eMinionDmg = getDmg("E", minion, myHero)
			--- Minion Damages ---
			--- Minion Keys ---
			local qFarmKey = KatarinaMenu.farming.qFarm
			local wFarmKey = KatarinaMenu.farming.wFarm
			local eFarmKey = KatarinaMenu.farming.eFarm
			--- Minion Keys ---
			--- Farming Minions ---
			if ValidTarget(minion) then
				if GetDistance(minion) <= SkillW.range then
					if qFarmKey and wFarmKey then
						if SkillQ.ready and SkillW.ready then
							if minion.health <= (qMinionDmg + wMinionDmg) and minion.health > wMinionDmg then
								CastSpell(_Q, minion)
								CastSpell(_W)
							end
						elseif SkillW.ready then
							if minion.health <= (wMinionDmg) then
								CastSpell(_W)
							end
						elseif SkillQ.ready and not SkillW.ready then
							if minion.health <= (qMinionDmg) then
								CastSpell(_Q, minion)
							end
						end
					elseif qFarmKey and not wFarmKey then
						if SkillQ.ready then
							if minion.health <= (qMinionDmg) then
								CastSpell(_Q, minion)
							end
						end
					end
				elseif (GetDistance(minion) > SkillW.range) and (GetDistance(minion) <= SkillQ.range) then
					if qFarmKey then
						if minion.health <= qMinionDmg then
							CastSpell(_Q, minion)
						end
					elseif eFarmKey then
						if minion.health <= eMinionDmg then
							CastSpell(_E, minion)
						end
					end
				end
			end
			break									
		end
		--- Farming Minions ---
	---<
end
-- / Farm Function / --

-- / Clear Function / --
function MixedClear()
	--- Jungle Clear ---
	--->
		if KatarinaMenu.clear.JungleFarm then
			local JungleMob = GetJungleMob()
			if JungleMob ~= nil then
				if KatarinaMenu.clear.clearOrbJ then
					OrbWalking(JungleMob)
				end
				if KatarinaMenu.clear.clearQ and SkillQ.ready and GetDistance(JungleMob) <= SkillQ.range then
					CastSpell(_Q, JungleMob)
				end
				if KatarinaMenu.clear.clearW and SkillW.ready and GetDistance(JungleMob) <= SkillW.range then
					CastSpell(_W)
				end
				if KatarinaMenu.clear.clearE and SkillE.ready and GetDistance(JungleMob) <= SkillE.range then
					CastSpell(_E, JungleMob) 
				end
			else
				if KatarinaMenu.clear.clearOrbJ then
					moveToCursor()
				end
			end
		end
	---<
	--- Jungle Clear ---
	--- Lane Clear ---
	--->
		if KatarinaMenu.clear.ClearLane then
			for _, minion in pairs(enemyMinions.objects) do
				if  ValidTarget(minion) then
					if KatarinaMenu.clear.clearOrbM then
						OrbWalking(minion)
					end
					if KatarinaMenu.clear.clearQ and SkillQ.ready and GetDistance(minion) <= SkillQ.range then
						CastSpell(_Q, minion)
					end
					if KatarinaMenu.clear.clearW and SkillW.ready and GetDistance(minion) <= SkillW.range then
						CastSpell(_W)
					end
					if KatarinaMenu.clear.clearE and SkillE.ready and GetDistance(minion) <= SkillE.range then 
						CastSpell(_E, minion)
					end
				else
					if KatarinaMenu.clear.clearOrbM then
						moveToCursor()
					end
				end
			end
		end
	---<
	--- Lane Clear ---
end
-- / Clear Function / --

-- / Casting Q Function / --
function CastQ(enemy)
	--- Dynamic Q Cast ---
	--->
		if not SkillQ.ready or (GetDistance(enemy) > SkillQ.range) then
			return false
		end
		if ValidTarget(enemy) then 
			if VIP_USER then
				Packet("S_CAST", {spellId = _Q, targetNetworkId = enemy.networkID}):send()
				return true
			else
				CastSpell(_Q, enemy)
				return true
			end
		end
		return false
	---<
	--- Dynamic Q Cast ---
end
-- / Casting Q Function / --

-- / Casting E Function / --
function CastE(enemy)
	--- Dynamic E Cast ---
	--->
		if not SkillE.ready or (GetDistance(enemy) > SkillE.range) then
			return false
		end
		if ValidTarget(enemy) then 
			if VIP_USER then
				Packet("S_CAST", {spellId = _E, targetNetworkId = enemy.networkID}):send()
				return true
			else
				CastSpell(_E, enemy)
				return true
			end
		end
		return false
	---<
	--- Dynamic E Cast ---
end
-- / Casting E Function / --

-- / Casting W Function / --
function CastW(enemy)
	--- Dynamic W Cast ---
	--->
		if not SkillW.ready or (GetDistance(enemy) > SkillW.range) then
			return false
		end
		if ValidTarget(enemy) then
			CastSpell(_W)
			return true
		end
		return false
	---<
	--- Dynamic W Cast ---
end
-- / Casting W Function / --

-- / Casting R Function / --
function CastR(enemy)
	--- Dynamic R Cast ---
	--->
		if (SkillQ.ready or SkillW.ready or SkillE.ready or (GetDistance(enemy) > SkillR.range)) or not SkillR.ready then
			return false
		end
		if ValidTarget(enemy) and not isChanneling("Spell4") then
			CastSpell(_R) 
			castDelay = GetTickCount()+250
		end
	---<
	--- Dymanic R Cast --
end
-- / Casting R Function / --

-- / Ward Jumping Function / --
function wardJump(x, y)
	--->
		if SkillE.ready then
			if next(Wards) ~= nil then
				for i, obj in pairs(Wards) do 
					if obj.valid then
						if GetDistance(obj, mousePos) <= 400 then
							CastSpell(_E, obj)
						else
							if GetTickCount()-lastwardused >= 2000 then
								if Items.TrinketWard.ready then
									CastSpell(ITEM_7, x, y)
									lastwardused = GetTickCount()
								elseif Items.RubySightStone.ready then
									CastSpell(rstSlot, x, y)
									lastwardused = GetTickCount()
								elseif Items.SightStone.ready then 
									CastSpell(ssSlot, x, y)
									lastwardused = GetTickCount()
								elseif Items.SightWard.ready then 
									CastSpell(swSlot, x, y)
									lastwardused = GetTickCount()
								elseif Items.VisionWard.ready then
									CastSpell(vwSlot, x, y)
									lastwardused = GetTickCount()
								end
							end
						end
					end
				end
			else
				if GetTickCount()-lastwardused >= 2000 then
					if Items.TrinketWard.ready then
						CastSpell(ITEM_7, x, y)
						lastwardused = GetTickCount()
					elseif Items.RubySightStone.ready then
						CastSpell(rstSlot, x, y)
						lastwardused = GetTickCount()
					elseif Items.SightStone.ready then 
						CastSpell(ssSlot, x, y)
						lastwardused = GetTickCount()
					elseif Items.SightWard.ready then 
						CastSpell(swSlot, x, y)
						lastwardused = GetTickCount()
					elseif Items.VisionWard.ready then
						CastSpell(vwSlot, x, y)
						lastwardused = GetTickCount()
					end
				end
			end
		end
	---<
end
-- / Ward Jumping Function / --

-- / Use Items Function / --
function UseItems(enemy)
	--- Use Items (Will Improve Soon) ---
	--->
		if ValidTarget(enemy) then
			if dfgReady and GetDistance(enemy) <= 600 then CastSpell(dfgSlot, enemy) end
			if hxgReady and GetDistance(enemy) <= 600 then CastSpell(hxgSlot, enemy) end
			if bwcReady and GetDistance(enemy) <= 450 then CastSpell(bwcSlot, enemy) end
			if brkReady and GetDistance(enemy) <= 450 then CastSpell(brkSlot, enemy) end
			if tmtReady and GetDistance(enemy) <= 185 then CastSpell(tmtSlot) end
			if hdrReady and GetDistance(enemy) <= 185 then CastSpell(hdrSlot) end
		end
	---<
	--- Use Items ---
end
-- / Use Items Function / --

function UseConsumables()

end	

-- / Auto Ignite Function / --
function AutoIgnite(enemy)
	--- Simple Auto Ignite ---
	--->
		if enemy.health <= iDmg and GetDistance(enemy) <= 600 then
			if iReady then CastSpell(ignite, enemy) end
		end
	---<
	--- Simple Auto Ignite ---
end
-- / Auto Ignite Function / --

-- / Damage Calculation Function / --
function DamageCalculation()
	--- Calculate our Damage On Enemies ---
	--->
 		for i=1, heroManager.iCount do
		local enemy = heroManager:GetHero(i)
			if ValidTarget(enemy) then
				dfgDmg, hxgDmg, bwcDmg, iDmg, bftDmg = 0, 0, 0, 0, 0
				pDmg = (SkillQ.ready and getDmg("Q", enemy, myHero, 2) or 0)
				qDmg = (SkillQ.ready and getDmg("Q",enemy,myHero) or 0)
    	        wDmg = (SkillW.ready and getDmg("W",enemy,myHero) or 0)
				eDmg = (SkillE.ready and getDmg("E",enemy,myHero) or 0)
            	rDmg = getDmg("R",enemy,myHero)*12
				if DFGREADY then dfgDmg = (dfgSlot and getDmg("DFG",enemy,myHero) or 0)	end
				if BFTREADY then bftdmg = (bftSlot and getDmg("BLACKFIRE",enemy,myHero) or 0) end
        	    if HXGREADY then hxgDmg = (hxgSlot and getDmg("HXG",enemy,myHero) or 0) end
            	if BWCREADY then bwcDmg = (bwcSlot and getDmg("BWC",enemy,myHero) or 0) end
            	if iReady then iDmg = (ignite and getDmg("IGNITE",enemy,myHero) or 0) end
            	onspellDmg = (liandrysSlot and getDmg("LIANDRYS",enemy,myHero) or 0)+(blackfireSlot and getDmg("BLACKFIRE",enemy,myHero) or 0)
            	itemsDmg = dfgDmg + bftDmg + hxgDmg + bwcDmg + iDmg + onspellDmg
    ---<
    --- Calculate our Damage On Enemies ---
    --- Setting KillText Color & Text ---
    --->
    			if enemy.health > (pDmg + qDmg + eDmg + wDmg + rDmg + itemsDmg) then
    				KillText[i] = 1
				elseif enemy.health <= qDmg then
					if SkillQ.ready then
						KillText[i] = 2
						colorText = ARGB(255,255,0,0)
					else
						KillText[i] = 10
						colorText = ARGB(255,0,0,255)
					end
				elseif enemy.health <= wDmg then
					if SkillW.ready then
						KillText[i] = 3
						colorText = ARGB(255,255,0,0)
					else
						KillText[i] = 10
						colorText = ARGB(255,0,0,255)
					end
				elseif enemy.health <= eDmg then
					if SkillE.ready then
						KillText[i] = 4
						colorText = ARGB(255,255,0,0)
					else
						KillText[i] = 10
						colorText = ARGB(255,0,0,255)
					end
				elseif enemy.health <= (qDmg + wDmg) and SkillQ.ready and SkillW.ready then
					if SkillQ.ready and SkillW.ready then
						KillText[i] = 5
						colorText = ARGB(255,255,0,0)
					else
						KillText[i] = 10
						colorText = ARGB(255,0,0,255)
					end
				elseif enemy.health <= (qDmg + eDmg) and SkillQ.ready and SkillE.ready then
					if SkillQ.ready and SkillE.ready then
						KillText[i] = 6
						colorText = ARGB(255,255,0,0)
					else
						KillText[i] = 10
						colorText = ARGB(255,0,0,255)
					end
				elseif enemy.health <= (wDmg + eDmg) and SkillW.ready and SkillE.ready then
					if SkillW.ready and SkillE.ready then
						KillText[i] = 7
						colorText = ARGB(255,255,0,0)
					else
						KillText[i] = 10
						colorText = ARGB(255,0,0,255)
					end
				elseif enemy.health <= (qDmg + wDmg + eDmg) and SkillQ.ready and SkillW.ready and SkillE.ready then
					if SkillQ.ready and SkillW.ready and SkillE.ready then
						KillText[i] = 8
						colorText = ARGB(255,255,0,0)
					else
						KillText[i] = 10
						colorText = ARGB(255,0,0,255)
					end
				elseif enemy.health <= (qDmg + pDmg + wDmg + eDmg + rDmg + itemsDmg) then
					if SkillQ.ready and SkillW.ready and SkillE.ready then
						KillText[i] = 9
						colorText = ARGB(255,255,0,0)
					else
						KillText[i] = 10
						colorText = ARGB(255,0,0,255)
					end
				end
			end
		end
	---<
	--- Setting KillText Color & Text ---
end
-- / Damage Calculation Function / --

-- / KillSteal Function / --
function KillSteal()
	--- KillSteal No Wards ---
	--->
		if Target then
			local distance = GetDistance(Target)
			local health = Target.health
			if health <= qDmg and SkillQ.ready and (distance < SkillQ.range) then
				CastQ(Target)
			elseif health <= wDmg and SkillW.ready and (distance < SkillW.range) then
				CastW(Target)
			elseif health <= eDmg and SkillE.ready and (distance < SkillE.range) then
				CastE(Target)
			elseif health <= (qDmg + wDmg) and SkillQ.ready and SkillW.ready and (distance < SkillW.range) then
				CastW(Target)
			elseif health <= (qDmg + eDmg) and SkillQ.ready and SkillE.ready and (distance < SkillE.range) then
				CastE(Target)
			elseif health <= (wDmg + eDmg) and SkillW.ready and SkillE.ready and (distance < SkillW.range) then
				CastW(Target)
			elseif health <= (qDmg + wDmg + eDmg) and SkillQ.ready and SkillW.ready and SkillE.ready and (distance < SkillE.range) then
				CastE(Target)
			elseif KatarinaMenu.killsteal.ultKS then
				if health <= (qDmg + pDmg + wDmg + eDmg + rDmg) and SkillQ.ready and SkillW.ready and SkillE.ready and SkillR.ready and (distance < SkillE.range) then
					CastE(Target)
					CastQ(Target)
					CastW(Target)
					CastR(Target)
				end
				if health <= rDmg and distance < (SkillR.range - 100) then
					CastR(Target)
				end
			elseif KatarinaMenu.killsteal.itemsKS then
				if health <= (qDmg + wDmg + eDmg + itemsDmg) then
					UseItems(Target)
				end
			end
		end
	---<
	--- KillSteal No Wards ---
end
-- / KillSteal Function / --

-- / Misc Functions / --
--- Get Mouse Pos Function by Klokje ---
--->
	function getMousePos(range)
    	local temprange = range or 600
    	local MyPos = Vector(myHero.x, myHero.y, myHero.z)
    	local MousePos = Vector(mousePos.x, mousePos.y, mousePos.z)

    	return MyPos - (MyPos - MousePos):normalized() * 600
	end
---<
--- Get Mouse Pos Function by Klokje ---
--- On Animation (Setting our last Animation) ---
--->
	function OnAnimation(unit, animationName)
    	if unit.isMe and lastAnimation ~= animationName then lastAnimation = animationName end
	end
---<
--- On Animation (Setting our last Animation) ---
--- isChanneling Function (Checks if Animation is Channeling) ---
--->
	function isChanneling(animationName)
    	if lastAnimation == animationName then
        	return true
    	else
        	return false
    	end
	end
---<
--- isChanneling Function (Checks if Animation is Channeling) ---
--- Checking if Hero in Danger ---
--->
	function isInDanger(hero)
		nEnemiesClose, nEnemiesFar = 0, 0
		hpPercent = hero.health / hero.maxHealth
		for _, enemy in pairs(enemies) do
			if not enemy.dead and hero:GetDistance(enemy) <= 500 then 
				nEnemiesClose = nEnemiesClose + 1 
				if hpPercent < 0.5 and hpPercent < enemy.health / enemy.maxHealth then return true end
			elseif not enemy.dead and hero:GetDistance(enemy) <= 1000 then
				nEnemiesFar = nEnemiesFar + 1 
			end
		end
		if nEnemiesClose > 1 then return true end
		if nEnemiesClose == 1 and nEnemiesFar > 1 then return true end
		return false
	end
---<
--- Checking if Hero in Danger ---
--- Get Jungle Mob Function by Apple ---
--->
	function GetJungleMob()
		for _, Mob in pairs(JungleFocusMobs) do
			if ValidTarget(Mob, q1Range) then return Mob end
		end
		for _, Mob in pairs(JungleMobs) do
			if ValidTarget(Mob, q1Range) then return Mob end
		end
	end
---<
--- Get Jungle Mob Function by Apple ---
--- Arrange Priorities 5v5 ---
--->
	function ArrangePrioritys()
    	for i, enemy in pairs(enemyHeroes) do
        	SetPriority(priorityTable.AD_Carry, enemy, 1)
        	SetPriority(priorityTable.AP, enemy, 2)
        	SetPriority(priorityTable.Support, enemy, 3)
        	SetPriority(priorityTable.Bruiser, enemy, 4)
        	SetPriority(priorityTable.Tank, enemy, 5)
    	end
	end
---<
--- Arrange Priorities 5v5 ---
--- Arrange Priorities 3v3 ---
--->
	function ArrangeTTPrioritys()
		for i, enemy in pairs(enemyHeroes) do
			SetPriority(priorityTable.AD_Carry, enemy, 1)
        	SetPriority(priorityTable.AP, enemy, 1)
        	SetPriority(priorityTable.Support, enemy, 2)
        	SetPriority(priorityTable.Bruiser, enemy, 2)
        	SetPriority(priorityTable.Tank, enemy, 3)
		end
	end
---<
--- Arrange Priorities 3v3 ---
--- Set Priorities ---
--->
	function SetPriority(table, hero, priority)
    	for i=1, #table, 1 do
        	if hero.charName:find(table[i]) ~= nil then
            	TS_SetHeroPriority(priority, hero.charName)
        	end
    	end
	end
---<
--- Set Priorities ---
-- / Misc Functions / --

-- / On Send Packet Function / --
function OnSendPacket(packet)
	-- Block Packets if Channeling --
	--->
		if isChanneling("Spell4") then
			local packet = Packet(packet)
			if packet:get('name') == 'S_MOVE' or packet:get('name') == 'S_CAST' and packet:get('sourceNetworkId') == myHero.networkID then
				if KatarinaMenu.combo.stopUlt then
					if Target and GetDistance(Target) < SkillR.range then
						if not SkillQ.ready and SkillW.ready and SkillE.ready and Target.health > (qDmg + wDmg + eDmg) then
							packet:block()
						end
					end
				else
					if Target and GetDistance(Target) < SkillR.range then
						packet:block()
					end
				end
			end
		end
	---<
	--- Block Packets if Channeling --
end
-- / On Send Packet Function / --

-- / On Create Obj Function / --
function OnCreateObj(obj)
	--- All of Our Objects (CREATE) --
	-->
		if obj ~= nil then
			if (obj.name:find("katarina_deathLotus_mis.troy") or obj.name:find("katarina_deathLotus_tar.troy")) then
				if GetDistance(obj, myHero) <= 70 then
					castDelay = GetTickCount()+250
				end
			end
			if (obj.name:find("katarina_deathlotus_success.troy") or obj.name:find("Katarina_deathLotus_empty.troy")) then
				if GetDistance(obj, myHero) <= 70 then
					castDelay = 0
					castingUlt = false
				end
			end
			if obj.name:find("Global_Item_HealthPotion.troy") then
				if GetDistance(obj, myHero) <= 70 then
					UsingHPot = true
				end
			end
			if obj.valid and (string.find(obj.name, "Ward") ~= nil or string.find(obj.name, "Wriggle") ~= nil or string.find(obj.name, "Trinket")) then 
				table.insert(Wards, obj)
			end
			if FocusJungleNames[obj.name] then
				table.insert(JungleFocusMobs, obj)
			elseif JungleMobNames[obj.name] then
        		table.insert(JungleMobs, obj)
			end
		end
	---<
	--- All of Our Objects (CREATE) --
end
-- / On Create Obj Function / --

-- / On Delete Obj Function / --
function OnDeleteObj(obj)
	--- All of Our Objects (CLEAR) --
	--->
		if obj ~= nil then
			if (obj.name:find("katarina_deathlotus_success.troy") or obj.name:find("Katarina_deathLotus_empty.troy")) then
				castingUlt = false
			end
			if (obj.name:find("katarina_deathLotus_mis.troy") or obj.name:find("katarina_deathLotus_tar.troy")) then
				castingUlt = false
			end
			if obj.name:find("TeleportHome.troy") then
				Recall = false
			end
			if obj.name:find("Global_Item_HealthPotion.troy") then
				UsingHPot = false
			end
			for i, Mob in pairs(JungleMobs) do
				if obj.name == Mob.name then
					table.remove(JungleMobs, i)
				end
			end
			for i, Mob in pairs(JungleFocusMobs) do
				if obj.name == Mob.name then
					table.remove(JungleFocusMobs, i)
				end
			end
		end
	--- All of Our Objects (CLEAR) --
	---<
end
--- All The Objects in The World Literally ---
-- / On Delete Obj Function / --

-- / Plugin On Draw / --
function OnDraw()
	--- Drawing Our Ranges ---
	--->
		if not myHero.dead then
			if not KatarinaMenu.drawing.disableAll then
				if SkillQ.ready and KatarinaMenu.drawing.drawQ then 
					DrawCircle(myHero.x, myHero.y, myHero.z, SkillQ.range, 0xB20000)
				end
				if SkillW.ready and KatarinaMenu.drawing.drawW then
					DrawCircle(myHero.x, myHero.y, myHero.z, SkillW.range, 0x20B2AA)
				end
				if SkillE.ready and KatarinaMenu.drawing.DrawE then
					DrawCircle(myHero.x, myHero.y, myHero.z, SkillE.range, 0x800080)
				end
			end
		end
	---<
	--- Drawing Our Ranges ---
	--- Draw Enemy Damage Text ---
	--->
		if KatarinaMenu.drawing.drawText then
			for i = 1, heroManager.iCount do
        		local Unit = heroManager:GetHero(i)
        		if ValidTarget(Unit) then
        			local barPos = WorldToScreen(D3DXVECTOR3(Unit.x, Unit.y, Unit.z)) --(Credit to Zikkah)
					local PosX = barPos.x - 35
					local PosY = barPos.y - 10        
        	 		DrawText(TextList[KillText[i]], 16, PosX, PosY, colorText)
				end
			end
		end
	---<
	--- Draw Enemy Damage Text ---
		if Target then
			if KatarinaMenu.drawing.drawTargetText then
				DrawText("Targetting: " .. Target.charName, 12, 100, 100, colorText)
			end
			if KatarinaMenu.drawing.drawTargetCircle then
				DrawCircle(Target.x, Target.y, Target.z, 100, colorText)
			end
		end
end
-- / Plugin On Draw / --

-- / OrbWalking Functions / --
--- Orbwalking Target ---
--->
	function OrbWalking(Target)
		if TimeToAttack() and GetDistance(Target) <= myHero.range + GetDistance(myHero.minBBox) then
			myHero:Attack(Target)
    	elseif heroCanMove() then
        	moveToCursor()
    	end
	end
---<
--- Orbwalking Target ---
--- Check When Its Time To Attack ---
--->
	function TimeToAttack()
    	return (GetTickCount() + GetLatency()/2 > lastAttack + lastAttackCD)
	end
---<
--- Check When Its Time To Attack ---
--- Prevent AA Canceling ---
--->
	function heroCanMove()
		return (GetTickCount() + GetLatency()/2 > lastAttack + lastWindUpTime + 20)
	end
---<
--- Prevent AA Canceling ---
--- Move to Mouse ---
--->
	function moveToCursor()
		if GetDistance(mousePos) then
			local moveToPos = myHero + (Vector(mousePos) - myHero):normalized()*300
			myHero:MoveTo(moveToPos.x, moveToPos.z)
    	end        
	end
---<
--- Move to Mouse ---
--- On Process Spell ---
--->
	function OnProcessSpell(object,spell)
		if object == myHero then
			if spell.name:lower():find("attack") then
				lastAttack = GetTickCount() - GetLatency()/2
				lastWindUpTime = spell.windUpTime*1000
				lastAttackCD = spell.animationTime*1000
        	end
    	end
	end
---<
--- On Process Spell ---
-- / OrbWalking Functions / --

-- / Checks Function / --
function Checks()
	--- Updates & Checks if Target is Valid ---
	--->
		TargetSelector:update()
		tsTarget = TargetSelector.target
		if tsTarget and tsTarget.type == "obj_AI_Hero" then
			Target = tsTarget
		else
			Target = nil
		end
	---<
	--- Updates & Checks if Target is Valid ---	
	--- Checks and finds Ignite ---
	--->
		if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
			ignite = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
			ignite = SUMMONER_2
		end
	---<
	--- Checks and finds Ignite ---
	--- Slots for Items ---
	--->
		rstSlot, ssSlot, swSlot, vwSlot =    GetInventorySlotItem(2045),
										     GetInventorySlotItem(2049),
										     GetInventorySlotItem(2044),
										     GetInventorySlotItem(2043)
		dfgSlot, hxgSlot, bwcSlot, brkSlot = GetInventorySlotItem(3128),
											 GetInventorySlotItem(3146),
											 GetInventorySlotItem(3144),
											 GetInventorySlotItem(3153)
		hpSlot, mpSlot, fskSlot =            GetInventorySlotItem(2003),
								             GetInventorySlotItem(2004),
								             GetInventorySlotItem(2041)
		znaSlot, wgtSlot, bftSlot =          GetInventorySlotItem(3157),
	    	                                 GetInventorySlotItem(3090),
											 GetInventorySlotItem(3188)
	---<
	--- Slots for Items ---
	--- Checks if Spells are Ready ---
	--->
		SkillQ.ready = (myHero:CanUseSpell(_Q) == READY)
		SkillW.ready = (myHero:CanUseSpell(_W) == READY)
		SkillE.ready = (myHero:CanUseSpell(_E) == READY)
		SkillR.ready = (myHero:CanUseSpell(_R) == READY)
		iReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	---<
	--- Checks if Active Items are Ready ---
	--->
		dfgReady = (dfgSlot ~= nil and myHero:CanUseSpell(dfgSlot) == READY)
		hxgReady = (hxgSlot ~= nil and myHero:CanUseSpell(hxgSlot) == READY)
		bwcReady = (bwcSlot ~= nil and myHero:CanUseSpell(bwcSlot) == READY)
		brkReady = (brkSlot ~= nil and myHero:CanUseSpell(brkSlot) == READY)
		znaReady = (znaSlot ~= nil and myHero:CanUseSpell(znaSlot) == READY)
		wgtReady = (wgtSlot ~= nil and myHero:CanUseSpell(wgtSlot) == READY)
		bftReady = (bftSlot ~= nil and myHero:CanUseSpell(bftSlot) == READY)
	---<
	--- Checks if Items are Ready ---
	--- Checks if Health Pots / Mana Pots are Ready ---
	--->
		Items.HealthPot.ready = (hpSlot ~= nil and myHero:CanUseSpell(hpSlot) == READY)
		Items.ManaPot.ready =(mpSlot ~= nil and myHero:CanUseSpell(mpSlot) == READY)
		Items.FlaskPot.ready = (fskSlot ~= nil and myHero:CanUseSpell(fskSlot) == READY)
	---<
	--- Checks if Health Pots / Mana Pots are Ready ---	
	--- Checks if Wards are Ready ---
	--->
		Items.TrinketWard.ready      = (myHero:CanUseSpell(ITEM_7) == READY and myHero:getItem(ITEM_7).id == 3340) or (myHero:CanUseSpell(ITEM_7) == READY and myHero:getItem(ITEM_7).id == 3350) or (myHero:CanUseSpell(ITEM_7) == READY and myHero:getItem(ITEM_7).id == 3361) or (myHero:CanUseSpell(ITEM_7) == READY and myHero:getItem(ITEM_7).id == 3362)
		Items.RubySightStone.ready   = (rstSlot ~= nil and myHero:CanUseSpell(rstSlot) == READY)
		Items.SightStone.ready       = (ssSlot ~= nil and myHero:CanUseSpell(ssSlot) == READY)
		Items.SightWard.ready        = (swSlot ~= nil and myHero:CanUseSpell(swSlot) == READY)
		Items.VisionWard.ready       = (vwSlot ~= nil and myHero:CanUseSpell(vwSlot) == READY)
	---<
	--- Checks if Wards are Ready ---	
	--- Updates Wards that Die ---
	--->
		if next(Wards)~=nil then
			for i, obj in pairs(Wards) do
				if not obj.valid then
					table.remove(Wards, i)
				end
			end
		end
	---<
	--- Updates Wards that Die ---
	--- Inserts Allies into Ward Table ---
	--->
		for _, ally in pairs(allyHeroes) do
			if GetDistance(ally) < SkillE.range and ValidTarget(minion) then
				table.insert(Wards, ally)
			end
		end
	---<
	--- Inserts Allies into Ward Table ---
	--- Inserts Minions into Ward Table ---
		for _, EnemyMinion in pairs(enemyMinions.objects) do
			if GetDistance(EnemyMinion) < (SkillE.range + 200) and ValidTarget(EnemyMinion) then
				table.insert(Wards, EnemyMinion)
			end
		end
		for _, AllyMinion in pairs(allyMinions.objects) do
			if GetDistance(AllyMinion) < (SkillE.range + 200) then
				table.insert(Wards, AllyMinion)
			end
		end
	---<
	--- Inserts Minions Into Ward Table ---
	--- Updates Minions ---
	--->
		enemyMinions:update()
		allyMinions:update()
	---<
	--- Updates Minions ---
	--- Setting Cast of Ult ---
	--->
		if GetTickCount() <= castDelay then castingUlt = true end
		if SkillQ.ready and SkillW.ready and SkillE.ready and not Target then castingUlt = false end
	---<
	--- Setting Cast of Ult ---
end
-- / Checks Function / --