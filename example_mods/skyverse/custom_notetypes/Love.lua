function goodNoteHit(id,d,t,s)

	if t == 'Love' then
	anim = {'LEFT','DOWN','UP','RIGHT'}
		characterPlayAnim('bf','sing'..anim[d+1]..'-love')
	end

end
function opponentNoteHit(id,d,t,s)

	if t == 'Love' then
	anim = {'LEFT','DOWN','UP','RIGHT'}
		characterPlayAnim('dad','sing'..anim[d+1]..'-love')
	end

end