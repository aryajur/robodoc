-- Module to generate the documentation
-- Given the document structure

local tu = require("tableUtils")
local globals = require("robodoc.globals")
local logger = globals.logger
local config = globals.configuration
local table = table

local tonumber = tonumber

local M = {}
package.loaded[...] = M
if setfenv and type(setfenv) == "function" then
	setfenv(1,M)	-- Lua 5.1
else
	_ENV = M		-- Lua 5.2
end

local sourceExt

--[[****f* docgen/isSourceFile
* FUNCTION
To check whether a file is a source file. It checks the file extension which must be one from sourceExt (document.srcextension)
* INPUTS
	o file			-- file name to check
* SYNOPSYS
]]
local function isSourceFile(file)
--@@END@@
	local filext = file:match("%.(.-)$")
	if not tu.inArray(sourceExt,filext,function(one,two) return one:upper() == two:upper() end) then
		return false
	end
	return true
end

--[[****f* docgen/getSourceFileList
 * FUNCTION
 *   Walks through all the files in the directory pointed to
 *   by srcPath and adds all the files to array part of dir.
 * INPUTS
 *   o srcPath			-- Source files root path
 *   o nodesc			-- boolean if true then only files in srcPath directory are extracted
 * RESULT
 *   a dir structure filled with all sourcefiles and 
 *   subdirectories in paths key.
 * SYNOPSIS
 ]]
local function getSourceFileList(srcPath,nodesc)
--@@END@@
	local dir = {paths={srcPath}}
	local di = globals.dirIter(srcPath,1,nodesc)
	local item,path = di:next()
	while item do
		local skip
		if config.ignore_files then
			local fullname = path..item
			for i = 1,#config.ignore_files do
				if item:match(config.ignore_files[i]) or path:match(config.ignore_files[i]) or fullname:match(config.ignore_files[i]) then
					skip = true
					logger:info("Skipping file: "..fullname.." because match to "..config.ignore_files[i])
					break
				end
			end
		end
		if not skip then
			dir[#dir + 1] = {file=item,path=path}
			dir.paths[#dir.paths + 1] = path
		end
		item,path = di:next()
	end
	return dir
end

local function findMarker(fDat,start,markers,mi)
	local strt,tstrt,index,stp,tstp
	local function fH(ind)
		tstrt,tstp = fDat:find("\n%s*"..markers[ind],start,true)	-- Do a plain match
		if tstrt then
			if not strt then
				strt = tstrt
				stp = tstp
				index = ind
			else
				if tstrt < strt then	-- To store location of the header that occurs first 
					strt = tstrt
					stp = tstp
					index = ind
				end
			end
		end		
	end
	if mi then
		fH(mi)
	else
		for i = 1,#markers do
			fH(i)
		end
	end
	local _,lineNum = fDat:sub(1,strt-1):gsub("\n","")
	lineNum = tonumber(lineNum) + 2
	return strt,stp,index,lineNum
end

-- Function to return the first header found in the file data from the position start
-- If hi is specified then only that header is searched
local function findHeader(fDat,start,hi)
	return findMarker(fDat,start,config.header_markers,hi)
end

local function findHeaderEnd(fDat,start,ei)
	return findMarker(fDat,start,config.end_markers,ei)
end

local function findHeaderNames(fDat,start)
	local sstr = fDat:sub(start,-1).."\n"	-- adding a \n in the end to allow gmatch to run
	local hsep = "%"..table.concat(config.header_separate_chars,"%")	-- Header separator characters ',' by default
	local hi = config.header_ignore_chars		-- header ignore characters "%[.-%]" by default
	local function removeHeader_ignore_chars(name)
		for i = 1,#hi do
			name = name:gsub(hi[i],"")
		end
		return name
	end
	local names = {}
	local stp = start-1
	for name in sstr:gmatch("(.-["..hsep.."\n])") do
		-- Check if end character is header separate char or \n
		local nm = name:gsub("^%s*",""):gsub("%s*$","")	-- Trim leading and traling spaces
		if nm ~= "" then
			if nm:sub(-1,-1):match(hsep) then
				names[#names + 1] = removeHeader_ignore_chars(nm:sub(1,-2))
				stp = stp+#name
			else
				names[#names + 1] = removeHeader_ignore_chars(nm:sub(1,-1))
				stp = stp+#nm
				break
			end
		end
	end
	return names,stp
end

--[[****f* docgen/createDocParts
 * FUNCTION
 *   Create all the parts of a document based on the sourcefiles in
 *   the source tree.  This creates a new part for each file in
 *   the source tree.
 *	 This function does not ignore any headers (based on options internal and internalonly). Those options
 * 	 should be considered later when compiling the documentation
 * INPUTS
 *    o document -- the document for which the parts are generated.
 * SYNOPSYS
 ]]
local function createDocParts(document)
--@@END@@
	local dir = document.dir
	local actions = document.actions
	local hm = config.header_markers
	local parts = {}	-- part as defined in original C code is:
	--[[ (Double dash means equivalent or functionality in Lua present)
		struct RB_Part
		{
	--		struct RB_Part     *next;
	--		struct RB_Filename *filename;
	--		struct RB_header   *headers;
	--		struct RB_header   *last_header;
		};
	]]
	document.parts = parts
	for i = 1,#dir do
		local headers = {}	-- Data structure to store all header information
		--- Header structure in original C code is:
		--[[ (Double dash means equivalent or functionality in Lua present)
			struct RB_header
			{
		--		struct RB_header   *next;
		--		struct RB_header   *parent;
		--		struct RB_Part     *owner;
		--		struct RB_HeaderType *htype;
				struct RB_Item     *items;
		--		int                 is_internal;
		--		char               *name;
		--		char              **names;
		--		int                 no_names;
				char               *version;
		--		char               *function_name;
		--		char               *module_name;
				char               *unique_name;
				char               *file_name;
				struct RB_header_lines *lines;
				int                 no_lines;
		--		int                 line_number;
			};	
		]]
		parts[#parts + 1] = {
			srcfile = dir[i],
			headers = headers
		}
		logger:debug("Analysing "..dir[i].path..dir[i].file)
		local f,msg = io.open(dir[i].path..dir[i].file)
		if f then
			local fDat = f:read("*a")
			f:close()
			-- Collect all the headers
			local strt,stp,index,lineNum = findHeader(fDat,1)	-- hi is the header index in config.header_markers
			local hi = actions.do_lockheader and index
			local ei
			while strt do
				-- Header found
				local internal = fDat:sub(stp+1)=="i"
				local names
				local htype = internal and fDat:sub(stp+2,stp+2) or fDat:sub(stp+1,stp+1)	-- Get the single character for the header type
				-- lookup the character in config.headertypes
				local hti = tu.inArray(config.headertypes,htype,function(one,two) return one.typeCharacter == two and one.indexName end)
				if hti then
					stp = fDat:find(" ",stp+1,true)	-- After the header type find the space to start the name search after that
					if not stp then
						logger:warn("File: "..dir[i].path..dir[i].file.." header incomplete: "..htype)
					else
						names,stp = findHeaderNames(fDat,stp+1)
						if not names[1] then
							logger:warn("No names found for the header at line "..lineNum.." in file "..dir[i].path..dir[i].file)
						else
							headers[#headers + 1] = {
								htype = hti,		-- index pointing to configuration.headertypes
								internal = internal,
								line_number = lineNum,
								start = strt,
								names = names,
								part = parts[#parts]
							}
							-- Check if there is a duplicate header
							for j = 1,#parts do
								local ind = tu.inArray(parts[j].headers,headers[#headers],function(one,two) 
										for i = 1,#one.names do
											if tu.inArray(two.names,one.names[i]) then
												return true
											end
										end
										return false
									end)
								if ind then
									local dupname
									for k = 1,#names do
										if tu.inArray(parts[j].headers[ind].names,names[k]) then
											dupname = names[k]
											break
										end
									end
									logger:warn("A header with the name "..dupname.." already exist. See file: "..parts[j].srcfile.path..parts[j].srcfile.file.." line number "..parts[j].headers[ind].line_number)
								end
							end		-- for j = 1,#parts do ends to check if duplicate header exists
							local modName,fName = names[1]:match("(.+)[%/%.](.-)$")
							modName = modName or ""			-- Made adding the module name optional
							fName = fName or names[1]
							headers[#headers].function_name = fName
							headers[#headers].module_name = modName
							logger:debug("Found header "..names[1].." at line "..lineNum)
							-- Now find the end marker of the header
							local pstp = stp
							strt,stp,index,lineNum = findHeaderEnd(fDat,stp+1,ei)
							ei = actions.do_lockheader and index
							if findHeader(fDat,pstp+1,hi) < strt then
								logger:warn("Header "..names[1].." in file "..dir[i].path..dir[i].file.." at line "..headers[#headers].line_number.." does not have an end marker. Ignoring.")
								strt,stp,index,lineNum = findHeader(fDat,pstp+1,hi)
								headers[#headers] = nil
							else
								logger:debug("Found header end at line "..lineNum)
								headers[#headers].data = fDat:sub(headers[#headers].start,stp).."\n"
							end
						end		-- if not names[1] then ends
					end		-- if not stp then ends -- for finding a space after the header marker
				else
					logger:warn("File: "..dir[i].path..dir[i].file.." unknown header type: "..htype)
				end		-- if hti then ends here
				strt,stp,index,lineNum = findHeader(fDat,stp+1,hi)		-- Find the next header
			end		-- while strt do ends strt contains the next header starting position
		else
			logger:debug("Could not open file "..dir[i].path..dir[i].file..": "..msg)
		end		-- if f then ends (f contains the handle for the file being analyzed)
	end		-- for i = 1,#dir do ends
end

-- Function to generate the file paths for all documentation file paths. 
-- This is in the multidoc option where the source file hierarchy is replicated in the documentation file hierarchy
--[[
 * EXAMPLE
 *   srcpath = ./test/mysrc/sub1/sub2
 *   srcroot = ./test/mysrc/
 *   docroot = ./test/mydoc/
 *     ==>
 *   docpath = ./test/mydoc/sub1/sub2
]]
local function getDocFileList(document)
	local srcroot = document.srcroot
	local docroot = document.docroot
	local parts = document.parts	-- Contains the path and file names of all the soruce files
	for i = 1,#parts do
		local sFile = parts[i].srcfile
		local dFile = {file = sFile.file}
		if document.actions.do_no_subdirectories then
			-- documentation files should all be in 1 directory
			dFile.path = docroot
		else
			-- Documentation files follow the hierarchy of the source files
			dFile.path = docroot..sFile.path:sub(#srcroot+1,-1)
		end
		parts[i].docfile = dFile
	end
end

-- Function to create the directory tree for all the paths where the documentation files will be placed
local function createDocFilePaths(document)
	-- First get the list of all documentation files
	local docfiles = {}
	for i = 1,#document.parts do
		docfiles[i] = parts[i].docfile
	end
	-- Sort the file list according to the path so that hierarchy is created from the top most path first
	table.sort(docfiles,function(one,two) return one.path < two.path end)
	-- Now create the paths
	for i = 1,#docfiles do
		globals.createPath(docfiles[i].path)
	end
end

-- Function to generate the documentation from the info available in the document structure and config structure
local function genDocumentation(document)
	
	
end

function docgen(document)
	sourceExt = document.srcextension
	if document.actions.do_multidoc then
		logger:info("Scan source directory: "..document.srcroot)
		document.dir = getSourceFileList(document.srcroot,document.actions.do_nodesc)
		logger:info("Found "..#document.dir.." files.")
		if #document.dir == 0 then
			return
		end
		createDocParts(document)
		
	elseif document.actions.do_singledoc then
		
	elseif document.actions.do_singlefile then
		
	end
end