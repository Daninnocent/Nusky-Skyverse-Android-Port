package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxTimer;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.5.2h'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var menugraphic:FlxSprite;
	var difficultyselector:FlxSprite;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'skyweek',
		'freeplay',
		'options'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;
	var curDifficulty:Int = 1;
	private static var lastDifficultyName:String = '';
	var selectedskyweek:Bool = false;

	override function create()
	{
		// PlayState.isStoryMode = true;
		
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;


		var bg:FlxSprite = new FlxSprite(-200).loadGraphic(Paths.image('bluebg'));
		bg.setGraphicSize(Std.int(bg.width * 2));
		bg.screenCenter();
		bg.updateHitbox();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		menugraphic = new FlxSprite(750, 230);
		menugraphic.frames = Paths.getSparrowAtlas('menugraphic');
		menugraphic.animation.addByIndices('skyweek', 'menugraphic', [0, 1, 2, 3, 4, 5], "",  24);
		menugraphic.animation.addByIndices('freeplay', 'menugraphic', [6, 7, 8, 9, 10, 11], "", 24);
		menugraphic.animation.addByIndices('options', 'menugraphic', [12, 13, 14, 15, 16, 17], "", 24);
		menugraphic.animation.play('skyweek');
		add(menugraphic);

		var bg2:FlxSprite = new FlxSprite(-50).loadGraphic(Paths.image('overlay'));
		bg2.screenCenter();
		bg2.updateHitbox();
		bg2.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg2);


		// magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		// magenta.scrollFactor.set(0, yScroll);
		// magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		// magenta.updateHitbox();
		// magenta.screenCenter();
		// magenta.visible = false;gb
		// magenta.antialiasing = ClientPrefs.globalAntialiasing;
		// magenta.color = 0xFFfd719b;
		// add(magenta);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));

		difficultyselector = new FlxSprite(1030, 30);
		difficultyselector.frames = Paths.getSparrowAtlas('diff');
		difficultyselector.animation.addByIndices('easy', 'diff', [0], "",  24);
		difficultyselector.animation.addByIndices('normal', 'diff', [1], "", 24);
		difficultyselector.animation.addByIndices('hard', 'diff', [2], "", 24);
		add(difficultyselector);
		

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var offset:Float = 10 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(30, (i * 140)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas(optionShit[i]);
			if (optionShit[i] == "freeplay")
			{
				menuItem.y = menuItem.y + 300;
				menuItem.updateHitbox();
			}
			if (optionShit[i] == "options")
			{
				menuItem.y = menuItem.y + 300;
				menuItem.updateHitbox();
			}
			// what too much lua does to a mf
			menuItem.animation.addByIndices('idle', optionShit[i], [0, 1, 2, 3, 4, 5], "",  24);
			menuItem.animation.addByIndices('selected', optionShit[i], [6, 7, 8, 9, 10, 11], "", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}


		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();
		changeDifficulty();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		#if android
		addVirtualPad(FULL, A_B);
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);

		if (optionShit[curSelected] == 'skyweek')
		{
			menugraphic.animation.play('skyweek');
			selectedskyweek = true;
			difficultyselector.visible = true;
		}
		else if (optionShit[curSelected] == 'freeplay')
		{
			menugraphic.animation.play('freeplay');
			selectedskyweek = false;
			difficultyselector.visible = false;
		}
		else if (optionShit[curSelected] == 'options')
		{
			menugraphic.animation.play('options');
			selectedskyweek = false;
			difficultyselector.visible = false;
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			var upP = controls.UI_UP_P;
			var downP = controls.UI_DOWN_P;

			if (selectedskyweek){
			if (controls.UI_RIGHT_P){
				FlxG.sound.play(Paths.sound('dialogue'));
				changeDifficulty(1);
			}
			else if (controls.UI_LEFT_P){
				FlxG.sound.play(Paths.sound('dialogue'));
				changeDifficulty(-1);
			}
			else if (upP || downP){
				changeDifficulty();
			}
		    }

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					// if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'skyweek':
										selectWeek();
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menugraphic.x = 1150;
		FlxTween.tween(menugraphic, {x: 750}, 0.1, {ease: FlxEase.circInOut});

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				spr.centerOffsets();
			}
		});
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		var diff:String = CoolUtil.difficulties[curDifficulty];
		var newanim = Paths.formatToSongPath(diff);
		//trace(Paths.currentModDirectory + ', menudifficulties/' + Paths.formatToSongPath(diff));

		difficultyselector.animation.play(newanim);

		lastDifficultyName = diff;
	}

	function selectWeek() {
	    // Nevermind that's stupid lmao
		PlayState.storyPlaylist = ['nusky', 'buffer-song', 'chainlock'];

		PlayState.isStoryMode = true;
		
	    var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
		if(diffic == null) diffic = '';
		
		PlayState.storyDifficulty = curDifficulty;
		
		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
		
		LoadingState.loadAndSwitchState(new PlayState(), true);
	}
}
