tell application "System Events"
	set thePropertyListFilePath to "~/Automation/Settings.plist"
	
	if exists file thePropertyListFilePath then
		display dialog "Settings file already exists!" buttons {"OK"} default button "OK"
	else
		set theParentDictionary to make new property list item with properties {kind:record}
		
		set thePropertyListFile to make new property list file with properties {contents:theParentDictionary, name:thePropertyListFilePath}
		
		tell property list items of thePropertyListFile
			#make new property list item at end with properties:
			# {kind:boolean, name:"booleanKey", value:true}
			# {kind:date, name:"dateKey", value:current date}
			# {kind:list, name:"listKey"}
			# {kind:number, name:"numberKey", value:5}
			# {kind:record, name:"recordKey"}
			# {kind:string, name:"stringKey", value:"string value"}
			
			make new property list item at end with properties {kind:number, name:"mainVolume", value:50}
			
			make new property list item at end with properties {kind:number, name:"spotifyVolume", value:50}
			make new property list item at end with properties {kind:number, name:"spotifySuperLowVolume", value:15}
			make new property list item at end with properties {kind:number, name:"spotifyLowVolume", value:20}
			make new property list item at end with properties {kind:number, name:"spotifyMediumVolume", value:60}
			make new property list item at end with properties {kind:number, name:"spotifyHighVolume", value:70}
			
			make new property list item at end with properties {kind:string, name:"midiPipeFile", value:"summitcreek_kids_automation.mipi"}
		end tell
		
		display dialog "Settings file created!" buttons {"OK"} default button "OK"
	end if
end tell


