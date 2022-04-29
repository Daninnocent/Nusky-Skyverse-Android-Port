local daBeats = {0,0,0,0,0,0,0}
local speedfactor = 4;
local startedGame = false
local curbs = 0
local canHit = false;
local perfectStrum = 0;
local hitted = false
local doctorEnabled = false
local yoffset = 300
local winw = 1280
local winh = 720
local lastbeatms = 0
local curst = 0
local oldStep= 0
local daACTUALBEAT = 0
local alreadyDoctored = false
function onUpdatePost()

	if doctorEnabled then


	lerpProperty('dadheart.scale.x',1,0.01)
	lerpProperty('dadheart.scale.y',1,0.01)
	lerpProperty('bfheart.scale.x',1,0.01)
	lerpProperty('bfheart.scale.y',1,0.01)


	lerpProperty('bfheart.offset.y',yoffset,0.1)
	lerpProperty('dadheart.offset.y',yoffset,0.1)
	lerpProperty('dochud.offset.y',yoffset,0.1)
	lerpProperty('dadheart.offset.y',yoffset,0.1)


	for i=0,5 do
		lerpProperty('beat'.. i ..'.offset.y',yoffset,0.1)
		if daBeats[i+1] == '1' then 
			objectPlayAnimation('beat'..i,'silent')
		end
	end


	if mouseClicked('left') and canHit then
		goodHit(math.abs(getSongPosition()-perfectStrum))
	end
	end
curst = math.floor((getSongPosition()-lastbeatms+noteOffset)/stepCrochet)
 if  oldStep < curst then
 onStep()
 end
oldStep = curst
	--lerpPropertyClass('openfl.Lib','application.window.width',winw,0.1)
	--lerpPropertyClass('openfl.Lib','application.window.height',winh,0.1)


end
function goodHit(dif)
	
	debugPrint(dif)
	hitted = true
	if dif < 100 then
		setProperty('health',getProperty('health')+0.1)
	else
		setProperty('health',getProperty('health')-0.2)
	end

end
function onBeatHit()
	if doctorEnabled then
	setProperty('bfheart.scale.x',1.2)
	setProperty('bfheart.scale.y',1.2)

	setProperty('dadheart.scale.x',1.2)
	setProperty('dadheart.scale.y',1.2)
	--setPropertyFromClass('openfl.Lib','application.window.width',970)
	--setPropertyFromClass('openfl.Lib','application.window.height',545)

	else
	
	--setPropertyFromClass('openfl.Lib','application.window.width',1290)
	--setPropertyFromClass('openfl.Lib','application.window.height',725)
	end

end
function onTimerCompleted(t,l,ll)

	if t == 'www' then
		playSound('ChartingTick',0.4)
	end

end
function onStep()
--debugPrint(curst)
--if curst % 4 == 0 then playSound('ChartingTick',0.4) end
if doctorEnabled and not alreadyDoctored then
doDaHit()
end
--curst = curst + 1

end
function doDaHit()

		dabeat = (curst % (speedfactor*8))/speedfactor
		canHit = dabeat >= 5 and dabeat <7
		--debugPrint(dabeat)
		if dabeat == 0 then hitted = false end
		if dabeat == 5 then
			perfectStrum = getSongPosition() + (stepCrochet*speedfactor)+noteOffset-- (stepCrochet*(curst+speedfactor))+noteOffset
		end
		if dabeat == math.floor(dabeat) then 
			setProperty('camGame.zoom',1.1)
		--	doTweenZoom('aaa','camGame',1,0.1,'linear')
			if daBeats[dabeat+1] == '0' then playSound('ChartingTick',0.2) end
			if dabeat < 7 and  daBeats[dabeat+1] == '0' then objectPlayAnimation('beat'..dabeat,'beat',true) end
		end

	if dabeat == 7  then 
		alreadyDoctored = true
		if not hitted then 	setProperty('health',getProperty('health')-0.6) end
	end

end
function onEvent(n,v1,v2)

	if n == 'doctorHandler' then
	speedfactor = v1
	daBeats = split(v2,',')
	removeLuaSprite('dochud')
	removeLuaSprite('dadheart')
	removeLuaSprite('bfheart')
	doctorEnabled = true
	doTweenAlpha('ee','camGame',1,0.1,'linear')
	for u=0,3 do
		setPropertyFromGroup('playerStrums',u,'visible',true)
		setPropertyFromGroup('opponentStrums',u,'visible',true)
	end
	if v2 == '' then
	winw = 1280
	winh = 720
	doctorEnabled = false
	
	end
		if doctorEnabled then
--	winw = 960
--	winh = 540
curst = 0
lastbeatms = getSongPosition()
alreadyDoctored = false
--doDaHit()
	doTweenAlpha('ee','camGame',0.5,0.1,'linear')
	for u=0,3 do
		setPropertyFromGroup('playerStrums',u,'visible',false)
		setPropertyFromGroup('opponentStrums',u,'visible',false)
	end
	makeLuaSprite('dochud','doctor/docgui',13,490)
	addLuaSprite('dochud',true)
	setObjectCamera('dochud','hud')
		
	makeLuaSprite('dadheart','doctor/keithna heart',44,550)
	addLuaSprite('dadheart',true)
	setObjectCamera('dadheart','hud')

	makeLuaSprite('bfheart','doctor/kitheart',1092,544)
	addLuaSprite('bfheart',true)
	setObjectCamera('bfheart','hud')
	end
	doDaHit()
	for i=0,5 do
		
	removeLuaSprite('beat'..i)
		if doctorEnabled then
		makeAnimatedLuaSprite('beat'..i,'doctor/beat',222+(106*i),538)
		addAnimationByIndices('beat'..i,'idle','beat','3',24)
		addAnimationByIndices('beat'..i,'beat','beat','0,1,2,3',24)
		addAnimationByIndices('beat'..i,'silent','beat','4,5,6',24)
		objectPlayAnimation('beat'..i,'idle',true)
		if daBeats[i+1] == '1' then
			objectPlayAnimation('beat'..i,'silent',true)
		end
		addLuaSprite('beat'..i,true)
		setObjectCamera('beat'..i,'hud')
		end

	end


	end

	if n == 'startDoc' then
	startGame()
	end


end

function lerpProperty(property,value,factor)

	setProperty(property,lerp(getProperty(property),value,factor))


end
function lerpPropertyClass(class,property,value,factor)

	setPropertyFromClass(class,property,lerp(getPropertyFromClass(class,property),value,factor))

end
function lerpPropertyGroup(group,index,property,value,factor)

	setPropertyFromGroup(group,index,property,lerp(getPropertyFromGroup(group,index,property),value,factor))

end

function lerp(a,b,t) return a * (1-t) + b * t end


function split(pString, pPattern)
   local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pPattern
   local last_end = 1
   local s, e, cap = pString:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
     table.insert(Table,cap)
      end
      last_end = e+1
      s, e, cap = pString:find(fpat, last_end)
   end
   if last_end <= #pString then
      cap = pString:sub(last_end)
      table.insert(Table, cap)
   end
   return Table
end
