local APIKey = "" --https://steamcommunity.com/dev/apikey

local function HandleAltAccount( SteamIDAlt, SteamID64Main )
	if not ( ULib and ULib.bans ) then return end  -- This requies ULX
	local SteamIDMain = util.SteamIDFrom64( SteamID64 ) -- Get SteamID for easy reading

	if ULib.bans[ SteamIDMain ] then -- If steamid of main account is in table then user is banned.
		game.KickID( SteamIDAlt, "You have been banned from this server" ) -- So we kick the alt

		ULib.addBan( SteamIDAlt, ULib.bans[ SteamIDMain ].unban > 0 and math.ceil(( ULib.bans[ SteamIDMain ].unban - os.time() ) / 60) or 0, string.format( "Alt account %s", SteamIDMain ), plyname, NULL ) -- And then we ban the alt
		
		-- Get more info about the main
		http.Fetch(	string.format( "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=%s&format=json&steamids=%s", APIKey, SteamID64Main ), function( body )
			body = util.JSONToTable( body )
			if (not body) or (not body.response) or (not body.response.players) or (not body.response.players[ 1 ]) then
				return
			end
			ULib.addBan( SteamIDAlt, ULib.bans[ SteamIDMain ].unban > 0 and math.ceil(( ULib.bans[ SteamIDMain ].unban - os.time() ) / 60) or 0, string.format( "Alt account %s [%s]", body.response.players[ 1 ].personaname, SteamIDMain ), plyname, NULL ) -- Add alt account name.
		end, print )
	end
	
end

hook.Add( "CheckPassword", "CheckFamilySharing", function( SteamID64, ipAddress, svPassword, clPassword, name )
	http.Fetch( string.format( "http://api.steampowered.com/IPlayerService/IsPlayingSharedGame/v0001/?key=%s&format=json&steamid=%s&appid_playing=4000", APIKey, SteamID64 ), function( body )
		body = util.JSONToTable( body )

		local SteamID = util.SteamIDFrom64( SteamID64 )
		if (not body) or (not body.response) or (not body.response.lender_steamid) then
			error( string.format( "FamilySharing: Invalid Steam API response for %s | %s\n", name, SteamID ) )
		end

		if lender ~= "0" then
			
			HandleAltAccount( SteamID, body.response.lender_steamid )
		
		end
	end, function( code )
		error( string.format( "FamilySharing: Failed API call for %s | %s ( Error: %s )\n", name, SteamID, code ) )
	end )
end )