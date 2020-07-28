-- Module to generate the documentation
-- Given the document structure

local lfs = require("lfs")
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

-- Function to return the first header found in the file data from the position start
local function findHeader(fDat,start)
	local hm = config.header_markers
	local strt,tstrt,index,stp,tstp
	for i = 1,#hm do
		tstrt,tstp = fDat:find("\n%s*"..hm[i],start,true)	-- Do a plain match
		if tstrt then
			if not strt then
				strt = tstrt
				stp = tstp
				index = i
			else
				if tstrt < strt then
					strt = tstrt
					stp = tstp
					index = i
				end
			end
		end
	end
	local _,lineNum = fDat:sub(1,strt-1):gsub("\n","")
	lineNum = tonumber(lineNum) + 2
	return strt,stp,index,lineNum
end

local function findHeaderNames(fDat,start)
	local sstr = fDat:sub(start,-1).."\n"
	local hsep = "%"..table.concat(config.header_separate_chars,"%")
	local hi = config.header_ignore_chars
	local function removeHeader_ignore_chars(name)
		for i = 1,#hi do
			name = name:gsub(hi[i],"")
		end
		return name
	end
	local names = {}
	local stp = start-1
	for name in sstr:gmatch("(.-["..hsep.."\n])") do
		-- Check if end character it header separate char or \n
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
 * INPUTS
 *    o document -- the document for which the parts are generated.
 * SYNOPSYS
 ]]
local function createDocParts(document)
--@@END@@
	local dir = document.dir
	local hm = config.header_markers
	local parts = {}
	document.parts = parts
	for i = 1,#dir do
		local headers = {}	-- Data structure to store all header information
		parts[#parts + 1] = {
			file = dir[i],
			headers = headers
		}
		logger:debug("Analysing "..dir[i].path..dir[i].file)
		local f,msg = io.open(dir[i].path..dir[i].file)
		if f then
			local fDat = f:read("*a")
			f:close()
			-- Collect all the headers
			local strt,stp,index,lineNum = findHeader(fDat,1)
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
						headers[#headers + 1] = {
							htype = hti,		-- index pointing to configuration.headertypes
							internal = internal,
							line_number = lineNum,
							names = names
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
								logger:warn("A header with the name "..dupname.." already exist. See file: "..parts[j].file.path..parts[j].file.file.." line number "..parts[j].headers[ind].line_number)
							end
						end		-- for j = 1,#parts do ends to check if duplicate header exists
					end
				end
				else
					logger:warn("File: "..dir[i].path..dir[i].file.." unknown header type: "..htype)
				end
				strt,stp,index = findHeader(fDat,stp+1)		-- Find the next header
			end
		else
			logger:debug("Could not open file "..dir[i].path..dir[i].file..": "..msg)
		end		
	end
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
	end
end