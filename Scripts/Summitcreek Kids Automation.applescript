-- ************************************************
-- MIDI Note Mappings:
--
--  0    fade music to 0
--
--  1    play pre-service music at medium level
--  2    play small group music at low level
--  3    play game music at high level
--  4    play pre-service music at low level
--  5    play worship pre-roll at high level
--  6   play salvation call music at low level
--
--  11   fade spotify to low volume
--  12   fade spotify to medium volume
--  13   fade spotify to high volume
--
--  21   increase spotify by 10%
--  22   increase spotify by 20%
--  23   increase spotify by 30%
--
--  31   decrease spotify by 10%
--  32   decrease spotify by 20%
--  33   decrease spotify by 30%
--
on handleMidi(message)
	if (item 1 of message = 144) then
		set note_in to item 2 of message
		
		if note_in = 0 then
			spotifyFadeOut()
		else if note_in = 1 then
			playPreserviceMusic(getSetting("spotifyMediumVolume"))
		else if note_in = 2 then
			playSmallGroupMusic(getSetting("spotifyLowVolume"))
		else if note_in = 3 then
			playGameMusic(getSetting("spotifyHighVolume"))
		else if note_in = 4 then
			playPreserviceMusic(getSetting("spotifyLowVolume"))
		else if note_in = 5 then
			playWorshipPreroll(getSetting("spotifyHighVolume"))
		else if note_in = 6 then
			playSalvationCallMusic(getSetting("spotifyLowVolume"))
		else if note_in = 11 then
			changeSpotifyVolume(getSetting("spotifyLowVolume"))
		else if note_in = 12 then
			changeSpotifyVolume(getSetting("spotifyMediumVolume"))
		else if note_in = 13 then
			changeSpotifyVolume(getSetting("spotifyHighVolume"))
		else if note_in = 21 then
			changeSpotifyVolumeBy(10)
		else if note_in = 22 then
			changeSpotifyVolumeBy(20)
		else if note_in = 23 then
			changeSpotifyVolumeBy(30)
		else if note_in = 31 then
			changeSpotifyVolumeBy(-10)
		else if note_in = 32 then
			changeSpotifyVolumeBy(-20)
		else if note_in = 33 then
			changeSpotifyVolumeBy(-30)
		end if
	end if
end handleMidi

on getSetting(name)
	set thePropertyListFilePath to "~/Automation/Settings.plist"
	tell application "System Events"
		tell property list file thePropertyListFilePath to return value of property list item name
	end tell
end getSetting

on getPathSetting(name)
	return ((path to home folder as string) & "Automation:" & getSetting("midiPipeFile"))
end getPathSetting

on getMidiPipeFile()
	return getPathSetting("midiPipeFile")
end getMidiPipeFile

on spotifyFadeOut()
	if application "Spotify" is running then
		changeSpotifyVolume(0)
		spotifyStop()
	end if
end spotifyFadeOut

on playPreserviceMusic(vol)
	startPlaylist("spotify:user:highlandskids:playlist:6btfekjxDpgvUHDOXzml30", vol)
end playPreserviceMusic

on playSmallGroupMusic(vol)
	startPlaylist("spotify:user:highlandskids:playlist:6QleaTfjnXXSCiQSs4rUOu", vol)
end playSmallGroupMusic

on playGameMusic(vol)
	startPlaylist("spotify:user:highlandskids:playlist:3X9xdEomsh4MQnPH9FMOqp", vol)
end playGameMusic

on playWorshipPreroll(vol)
	startPlaylistAtPosition("spotify:track:6wyl6TzMdUBqRZZ5QIdwpJ", 30, vol)
end playWorshipPreroll

on playSalvationCallMusic(vol)
	startPlaylist("spotify:user:summitcreekkids:playlist:7p61LuwVUyglyjqWzimovo", vol)
end playSalvationCallMusic

# Fade the master volume up/down to new_vol.
on changeMasterVolume(new_vol)
	set cur_vol to output volume of (get volume settings)
	
	if cur_vol > new_vol then
		# Fade down
		repeat while cur_vol > new_vol
			set cur_vol to cur_vol - 1
			set volume output volume cur_vol --100%
			delay 0.1
		end repeat
	else if cur_vol < new_vol then
		# Fade up
		repeat while cur_vol < new_vol
			set cur_vol to cur_vol + 1
			set volume output volume cur_vol --100%
			delay 0.1
		end repeat
	end if
end changeMasterVolume

on changeSpotifyVolumeBy(changeBy)
	set newVolume to spotifyVolume() + changeBy
	changeSpotifyVolume(newVolume)
end changeSpotifyVolumeBy

on spotifyVolume()
	tell application "Spotify" to return sound volume
end spotifyVolume

on fadeSpotifyUp(new_vol)
	tell application "Spotify"
		set cur_vol to sound volume
		
		if cur_vol < new_vol then
			repeat while cur_vol ² new_vol
				set cur_vol to cur_vol + 1
				set sound volume to cur_vol
				delay 0.1
			end repeat
		end if
	end tell
end fadeSpotifyUp

on fadeSpotifyDown(new_vol)
	tell application "Spotify"
		set cur_vol to sound volume
		
		if cur_vol > new_vol then
			# Fade down
			repeat while cur_vol > new_vol + 1
				set cur_vol to cur_vol - 1
				set sound volume to cur_vol
				delay 0.1
			end repeat
		end if
	end tell
end fadeSpotifyDown

on changeSpotifyVolume(new_vol)
	-- This will handle fading in either direction
	fadeSpotifyUp(new_vol)
	fadeSpotifyDown(new_vol)
end changeSpotifyVolume

on startPlaylist(playlist, vol)
	startPlaylistAtPosition(playlist, 60, vol)
end startPlaylist

on startPlaylistAtPosition(playlist, pos, vol)
	fadeSpotifyDown(vol)
	delay 1
	tell application "Spotify"
		set shuffling to true
		play track playlist
		delay 0.1
		set player position to pos
	end tell
	fadeSpotifyUp(vol)
end startPlaylistAtPosition

on spotifyStop()
	tell application "Spotify" to pause {}
end spotifyStop

on anyRunning()
	set apps to {"Spotify", "ProPresenter 6", "MidiPipe"}
	
	tell application "System Events" to set ProcessList to name of every process
	
	repeat with currentApp in apps
		if currentApp is in ProcessList then return true
	end repeat
	
	return false
end anyRunning

on closeAllApps()
	if not anyRunning() then return
	
	display dialog "Closing all open applications.  Click Continue to proceed." buttons {"Continue"} default button "Continue"
	
	tell application "System Events"
		set ProcessList to name of every process
		if "Spotify" is in ProcessList then tell application "Spotify" to quit
		if "ProPresenter 6" is in ProcessList then tell application "ProPresenter 6" to quit
		if "midiPipe" is in ProcessList then tell application "MidiPipe" to quit
	end tell
	
	delay 2
end closeAllApps

on openAllApps()
	display dialog "Opening all required applications. Click Continue to proceed." buttons {"Continue"} default button "Continue"
	
	tell application "Finder" to set {screen_left, screen_top, screen_width, screen_height} to bounds of window of desktop
	
	# Need to configure midiPipe to open minimized
	set filename to getMidiPipeFile()
	tell application "Finder" to open file filename
	
	tell application "Spotify" to activate
	delay 2
	#setPosition("Spotify", 0, 0, screen_width * 0.8, screen_height)
	
	tell application "ProPresenter 6" to activate
	delay 2
	#setPosition("ProPresenter 6", screen_width * 0.1, 0, screen_width * 0.9, screen_height * 0.85)
	#try
	#    tell application "System Events" to keystroke "i" using {shift down, command down}
	#end try
end openAllApps

on setPosition(name, x, y, width, height)
	tell application "System Events"
		tell process name
			tell window 1
				set position to {x, y}
				set size to {width, height}
			end tell
		end tell
	end tell
end setPosition

on runPreSetup()
	closeAllApps()
	display dialog "Connect the TV and audio cables. Then click Continue." buttons {"Continue"} default button "Continue"
end runPreSetup

on runPostSetup()
	changeMasterVolume(getSetting("mainVolume"))
	changeSpotifyVolume(10)
end runPostSetup

on setup()
	runPreSetup()
	openAllApps()
	runPostSetup()
end setup

