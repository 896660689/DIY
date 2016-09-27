(*

File: Smart Accept.applescript

Abstract: This script will smartly accept invitations for text chats, audio chats, video chats, and file transfers when set as the event handler script for those events.
	
Version: 1.0

Copyright 2016 Yonsm.NET, All Rights Reserved

*)

using terms from application "Messages"
	
	on received text invitation theText from theBuddy for theChat
		# accept theChat
		decline theChat
	end received text invitation
	
	on received audio invitation theText from theBuddy for theChat
		# accept theChat
	end received audio invitation
	
	on received video invitation theText from theBuddy for theChat
		# accept theChat
	end received video invitation
	
	on received file transfer invitation theFileTransfer
		# accept theFileTransfer
	end received file transfer invitation
	
	on buddy authorization requested theRequest
		decline theRequest
	end buddy authorization requested
	
	# The following are unused but need to be defined to avoid an error
	
	on message sent theMessage for theChat
		
	end message sent
	
	on message received theMessage from theBuddy for theChat
		set theName to name of theBuddy
		set theChar to character 1 of theName
		if id of theChar < 256 then
			delete theChat
		end if
	end message received
	
	on chat room message received theMessage from theBuddy for theChat
		
	end chat room message received
	
	on active chat message received theMessage
		
	end active chat message received
	
	on addressed chat room message received theMessage from theBuddy for theChat
		
	end addressed chat room message received
	
	on addressed message received theMessage from theBuddy for theChat
		
	end addressed message received
	
	on av chat started
		
	end av chat started
	
	on av chat ended
		
	end av chat ended
	
	on login finished for theService
		
	end login finished
	
	on logout finished for theService
		
	end logout finished
	
	on buddy became available theBuddy
		
	end buddy became available
	
	on buddy became unavailable theBuddy
		
	end buddy became unavailable
	
	on completed file transfer
		
	end completed file transfer
end using terms from
