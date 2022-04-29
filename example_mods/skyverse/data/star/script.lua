function onCreate()

triggerEvent('Intro','Sky','by saruky')


end
inCutscene = true
allowCountdown = false
canSkip = false
function onStartCountdown()


	if not isStoryMode and not allowCountdown then
		setProperty('camHUD.visible',false)
		playMusic('gapicity',0.8)
		characterPlayAnim('boyfriend','kitty')
		characterPlayAnim('dad','kitty')
		runTimer('skylookup',4)
		allowCountdown = true
		return Function_Stop;
	
	end
	setProperty('camHUD.visible',true)
	inCutscene = false
		return Function_Continue;



end

function onEvent(name, value1, value2)
    if name 'camcontrol v' then
        setProperty('camcontrol.visible', true)
	end
	if name 'camcontrol n' then
        setProperty('camcontrol.visible', false)
	end
end

function onBeatHit()
   if curStep == 1184 then
      triggerEvent('camcontrol n', '', '')
   end
   if curStep == 1439 then
	  triggerEvent('camcontrol v', '', '')
   end
end


function onTimerCompleted(t,l,ll)

	if t == 'skylookup' then
		characterPlayAnim('boyfriend','notice')
	end

end
function onUpdatePost()

	
	if getProperty('dad.animation.finished') and not canSkip then
	canSkip = true
	characterPlayAnim('dad','dia')
	end


	if canSkip and inCutscene then
		if keyJustPressed('space') or  keyJustPressed('accept') or mouseClicked('left') then
			startCountdown()
		
		end
	end

end