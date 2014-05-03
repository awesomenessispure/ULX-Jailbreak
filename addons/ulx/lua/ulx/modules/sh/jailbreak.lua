-- Script made by Classified
-- Gamemode by Chessnut.
print("ULX Jailbreak is loading")

local versioncheck = "";
local CurrentVersion = "1.2b"

http.Fetch( "https://raw.githubusercontent.com/TheClassified/ULX-Jailbreak/master/versioncheck.txt",
	function( body, len, headers, code )
		versioncheck = body;
		if versioncheck == CurrentVersion then
			
		else
			if CLIENT then return end
				print("You have an outdated version of ULX Jailbreak: https://github.com/TheClassified/ULX-Jailbreak")
		end
	end,
	function( error )
		print("COULD NOT FETCH VERSION OF JAILBREAK ULX")
	end
 );


local CATEGORY_NAME = "Jailbreak"

local WardenModel = Model("models/player/combine_super_soldier.mdl");
local GuardModels = {
	Model("models/player/police.mdl"),
	Model("models/player/combine_soldier.mdl"),
	Model("models/player/combine_soldier_prisonguard.mdl")
};


--------------------------- Vote Demote -------------------------

local function voteDemoteDone2( t, target, time, ply, reason )

	local shouldDemote = false

	if t.results[ 1 ] and t.results[ 1 ] > 0 then
	
		ulx.logUserAct( ply, target, "#A approved the votedemote against #T (" .. (reason or "") .. ")" )
		
		shouldDemote = true
		
	else
	
		ulx.logUserAct( ply, target, "#A denied the vote demote against #T" )
		
	end

	if shouldDemote then
			target:Kill()
			target:SetTeam(3)
	end
	
end

local function voteDemoteDone( t, target, time, ply, reason )

	local results = t.results
	
	local winner
	
	local winnernum = 0
	
	for id, numvotes in pairs( results ) do
	
		if numvotes > winnernum then
		
			winner = id
			
			winnernum = numvotes
			
		end
		
	end

	local ratioNeeded = GetConVarNumber( "ulx_votedemoteSuccessratio" )
	
	local minVotes = GetConVarNumber( "ulx_votedemoteMinvotes" )
	
	local str
	
	if winner ~= 1 or winnernum < minVotes or winnernum / t.voters < ratioNeeded then
	
		str = "Vote results: User will not be demoted. (" .. (results[ 1 ] or "0") .. "/" .. t.voters .. ")"
		
	else
	
		str = "Vote results: User will now be demoted for, pending approval. (" .. winnernum .. "/" .. t.voters .. ")"
		
		ulx.doVote( "Accept result and demote " .. target:Nick() .. "?", { "Yes", "No" }, voteDemoteDone2, 30000, { ply }, true, target, time, ply, reason )
		
	end

	ULib.tsay( _, str )
	
	ulx.logString( str )
	
	Msg( str .. "\n" )
	
end


function ulx.votedemote( calling_ply, target_ply, reason )
	if target_ply:Team() == 1 or target_ply:Team() == 3 then ULib.tsayError( calling_ply, "The target player has to be on the guards team.", true ) return end

	if voteInProgress then
	
		ULib.tsayError( calling_ply, "There is already a vote in progress. Please wait for the current one to end.", true )
		
		return
		
	end

	local msg = "Demote " .. target_ply:Nick().."?"
	if reason and reason ~= "" then
		msg = msg .. " (" .. reason .. ")"
	end

	ulx.doVote( msg, { "Yes", "No" }, voteDemoteDone, _, _, _, target_ply, time, calling_ply, reason )
	
	ulx.fancyLogAdmin( calling_ply, "#A started a vote demote against #T", target_ply )
	
end
local votedemote = ulx.command( "Jailbreak", "ulx votedemote", ulx.votedemote, "!votedemote" )
votedemote:addParam{ type=ULib.cmds.PlayerArg }
votedemote:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
votedemote:defaultAccess( ULib.ACCESS_ALL )
votedemote:help( "Starts a public vote demote against target." )
if SERVER then ulx.convar( "votedemoteSuccessratio", "0.7", _, ULib.ACCESS_ADMIN ) ulx.convar( "votedemoteMinvotes", "3", _, ULib.ACCESS_ADMIN ) end

------------------------------ Make Prisoner------------------------------
function ulx.makeprisoner( calling_ply, target_plys )
	local affected_plys = {}

	for i=1, #target_plys do
		local v = target_plys[ i ]

		if ulx.getExclusive( v, calling_ply ) then
			ULib.tsayError( calling_ply, ulx.getExclusive( v, calling_ply ), true )
		//elseif not v:Alive() then
		//	ULib.tsayError( calling_ply, v:Nick() .. " is already dead!", true )
		elseif v:IsFrozen() then
			ULib.tsayError( calling_ply, v:Nick() .. " is frozen!", true )
		else
			v:Kill()
			v:SetTeam(3)
			table.insert( affected_plys, v )			
		end
	end

	ulx.fancyLogAdmin( calling_ply, "#A changed the team of #T", affected_plys )
end
local makeprisoner = ulx.command( CATEGORY_NAME, "ulx makeprisoner", ulx.makeprisoner, "!makeprisoner" )
makeprisoner:addParam{ type=ULib.cmds.PlayersArg }
makeprisoner:defaultAccess( ULib.ACCESS_ADMIN )
makeprisoner:help( "Changes the team of the target(s) to prisoner." )

------------------------------ Make Guard ------------------------------
function ulx.makeguard( calling_ply, target_plys )
	local affected_plys = {}

	for i=1, #target_plys do
		local v = target_plys[ i ]

		if ulx.getExclusive( v, calling_ply ) then
			ULib.tsayError( calling_ply, ulx.getExclusive( v, calling_ply ), true )
		//elseif not v:Alive() then
		//	ULib.tsayError( calling_ply, v:Nick() .. " is already dead!", true )
		elseif v:IsFrozen() then
			ULib.tsayError( calling_ply, v:Nick() .. " is frozen!", true )
		else
			v:Kill()
			v:SetTeam(4)
			table.insert( affected_plys, v )			
		end
	end

	ulx.fancyLogAdmin( calling_ply, "#A changed the team of #T", affected_plys )
end
local makeguard = ulx.command( CATEGORY_NAME, "ulx makeguard", ulx.makeguard, "!makeguard" )
makeguard:addParam{ type=ULib.cmds.PlayersArg }
makeguard:defaultAccess( ULib.ACCESS_ADMIN )
makeguard:help( "Changes the team of the target(s) to prisoner." )

------------------------------ Make Warden ------------------------------
function ulx.makewarden( calling_ply, target_plys )
	local affected_plys = {}

	for i=1, #target_plys do
		local v = target_plys[ i ]

		if ulx.getExclusive( v, calling_ply ) then
			ULib.tsayError( calling_ply, ulx.getExclusive( v, calling_ply ), true )
		elseif not v:Alive() then
			ULib.tsayError( calling_ply, v:Nick() .. " is already dead!", true )
		elseif v:IsFrozen() then
			ULib.tsayError( calling_ply, v:Nick() .. " is frozen!", true )
		else
			GAMEMODE:SetGlobalVar("warden", v)
			v:SetModel(WardenModel)
			v:SetArmor(50);
			table.insert( affected_plys, v )
		end
	end

	ulx.fancyLogAdmin( calling_ply, "#A forced warden #T", affected_plys )
end
local makewarden = ulx.command( CATEGORY_NAME, "ulx makewarden", ulx.makewarden, "!makewarden" )
makewarden:addParam{ type=ULib.cmds.PlayersArg }
makewarden:defaultAccess( ULib.ACCESS_ADMIN )
makewarden:help( "Force warden of the target(s)." )

------------------------------ Demote Warden ------------------------------
function ulx.demotewarden( calling_ply, target_plys )
	local affected_plys = {}

	for i=1, #target_plys do
		local v = target_plys[ i ]

		if ulx.getExclusive( v, calling_ply ) then
			ULib.tsayError( calling_ply, ulx.getExclusive( v, calling_ply ), true )
		elseif not v:Alive() then
			ULib.tsayError( calling_ply, v:Nick() .. " is already dead!", true )
		elseif v:IsFrozen() then
			ULib.tsayError( calling_ply, v:Nick() .. " is frozen!", true )
		elseif v:Team() == 1 or v:Team() == 3 then
			ULib.tsayError( calling_ply, v:Nick() .. " is a prisoner!", true )
		else
			GAMEMODE:SetGlobalVar("warden", NULL)
			v:SetModel(table.Random(GuardModels))
			v:SetArmor(25);
			table.insert( affected_plys, v )
		end
	end

	ulx.fancyLogAdmin( calling_ply, "#A demoted warden #T", affected_plys )
end
local demotewarden = ulx.command( CATEGORY_NAME, "ulx demotewarden", ulx.demotewarden, "!demotewarden" )
demotewarden:addParam{ type=ULib.cmds.PlayersArg }
demotewarden:defaultAccess( ULib.ACCESS_ADMIN )
demotewarden:help( "Demote warden of the target(s)." )

------------------------------ ROUND END ------------------------------
local number = 5
function ulx.roundend( calling_ply )
	timer.Create( "RoundEndTimer", 1, 5, function()
		number = number - 1
		if number == 0 then
			number = "NOW!"
		end
		ULib.csay( _, "ROUND ENDS ".. tostring(number) )
		print(tostring(number))
	end)
			GAMEMODE:EndRound()

	ulx.fancyLogAdmin( calling_ply, "#A ended the round.", affected_plys )
end
local roundend = ulx.command( CATEGORY_NAME, "ulx roundend", ulx.roundend, "!roundend" )
roundend:defaultAccess( ULib.ACCESS_ADMIN )
roundend:help( "Restart the round/End the current round." )



print("ULX Jailbreak has finished loading")
