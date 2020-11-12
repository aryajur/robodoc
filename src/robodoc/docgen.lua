-- Module to generate the documentation
-- Given the document structure

local tu = require("tableUtils")
local globals = require("robodoc.globals")
local logger = globals.logger
local config
local html = globals.html
local generator = require("robodoc.generator")

local table = table
local tonumber = tonumber
local pairs = pairs
local string = string
local next = next
local io = io

MIN_HEADER_TYPE = 1
MAX_HEADER_TYPE = 127

local M = {}
package.loaded[...] = M
if setfenv and type(setfenv) == "function" then
	setfenv(1,M)	-- Lua 5.1
else
	_ENV = M		-- Lua 5.2
end

--[[
	* getLenExtention(extention)

]]
local sourceExt


--[[***f* HeaderTypes/RB_FindHeaderType
 * FUNCTION
 *   Return the header type that corresponds to the type character.
 * RESULT
 *   * 0  -- there is no such header type
 *   * pointer to the header type otherwise.
 * SOURCE
]]
function FindHeaderType(typeCharacter)
	--------TODO-------------
	return HeaderTypeLookTable[typeCharacter]

end

--[[***f* Filename/Get_Fullname
 * NAME
 *   Get_Fullname --
 * SYNOPSIS
 ]]
function GetSubIndexFileName(docroot, extension, headertype)
--[[
 * INPUTS
 *   * docroot      -- the path to the documentation directory.
 *   * extension    -- the extension for the file
 *   * header_type  -- the header type
 * RESULT
 *   a pointer to a freshly allocated string.
 * NOTES
 *   Has too many parameters.
 * SOURCE
 ]]
	assert(docroot)
	local filename = ""
	filename = filename..docroot
	filename = filename..headertype.filename
	filename = filename..extension
	return filename
end

--[[****f* docgen/getFullDocname
* FUNCTION
	Return FullDocname
* INPUTS
	o file			-- file name to get full docname
* SYNOPSYS
]]
function getFullDocname(filename)
	if filename.fulldocname ~= nil then
		return filename.fulldocname
	else
		local result = ""
		result = result..filename.path.docname
		result = result..filename.docname
		return result
	end
end

--[[***f* Filename/Get_Fullname
 * NAME
 *   Get_Fullname --
 * SYNOPSIS
 ]]
function getFullName(filename)
--[[
 * FUNCTION
 *   Give the full name of the file, that is the name of
 *   the file including the extension and the path.
 *   The path can be relative or absolute.
 * NOTE
 *   The string returned is owned by this function
 *   so don't change it.
 * SOURCE
 ]]
	if filename.fulldocname ~= nil then
		return filename.fullname
	else
		local result = ""
		result = result..filename.path.name
		result = result..filename.name
		return result
	end
end

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
		if not skip and isSourceFile(item) then
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
	if not strt then
		return nil
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


-- Get the items information from the captured header content
-- If ri is specified then only that remark marker is searched
local function analyse_items(header,actions,ri)
	local function checkItem(line)
		line = line:gsub("^%s*","")
		-- Now check if there is a remark marker here
		local found
		if ri then
			if line:sub(1,#config.remark_markers[ri]) == config.remark_markers[ri] then
				found = true
				line = line:sub(#config.remark_markers[ri]+1,-1)
			end
		else
			for i = 1,#config.remark_markers do
				if line:sub(1,#config.remark_markers[i]) == config.remark_markers[i] then
					found = true
					line = line:sub(#config.remark_markers[i]+1,-1):gsub("%s*$","")
					ri = i
					break
				end
			end
		end		-- if ri then ends
		if found then
			-- Look for the Item type
			found = nil
			for i = 1,#config.items do
				if line == config.items[i] then
					found = i
					break
				end
			end
			return found
		end		-- if found then ends
	end
	-- Function to trim the empty lines at the beginning of the item chunk
	local function trimItemEmptyBeginLines(itemType,lines)
		if tu.inArray(config.source_items,config.items[itemType]) then
			-- Skip the next line if it is remark end marker
			for i = 1,#config.remark_begin_markers do
				if lines[1]:sub(1,#config.remark_begin_markers[i]) == config.remark_begin_markers[i] then
					if lines[1]:sub(#config.remark_begin_markers[i]+1,-1):gsub("%s","") ~= "" then
						logger:warn("In file "..header.part.srcFile.path..header.part.srcFile.file.." in header at line "..header.lineNum.." text follows remark end marker "..config.remark_begin_markers[i])
					end
					table.remove(lines,1)
					break
				end
			end
		end
		local done,ln
		while not done do
			ln = lines[1]:gsub("^%s*","")
			local found
			for i = 1,#config.remark_markers do
				if ln:sub(1,#config.remark_markers[i]) == config.remark_markers[i] and ln:sub(#config.remark_markers[i]+1,-1):gsub("%s","") == "" then
					found = true
					break
				end
			end
			if found then
				table.remove(lines,1)
			else
				done = true
			end
		end
	end
	-- Function to trim the empty lines in the end of the item chunk
	local function trimItemEmptyEndLines(itemType,lines)
		if tu.inArray(config.source_items,config.items[itemType]) then
			-- Skip the last line if it is a remark begin marker
			for i = 1,#config.remark_begin_markers do
				if lines[#lines]:sub(1,#config.remark_begin_markers[i]) == config.remark_begin_markers[i] then
					if lines[#lines]:sub(#config.remark_begin_markers[i]+1,-1):gsub("%s","") ~= "" then
						logger:warn("In file "..header.part.srcFile.path..header.part.srcFile.file.." in header at line "..header.lineNum.." text follows remark begin marker "..config.remark_begin_markers[i])
					end
					table.remove(lines,#lines)
					break
				end
			end
		end
		local done,ln
		while not done do
			ln = lines[#lines]:gsub("^%s*","")
			local found
			for i = 1,#config.remark_markers do
				if ln:sub(1,#config.remark_markers[i]) == config.remark_markers[i] and ln:sub(#config.remark_markers[i]+1,-1):gsub("%s","") == "" then
					found = true
					break
				end
			end
			if found then
				table.remove(lines,#lines)
			else
				done = true
			end
		end
	end

	local function ExpandTab(line)
		local newLine = {}
		local actual_tab = 1
		for i = 1,#line do
			if line:sub(i,i) == "\t" then
				while config.tab_stops[actual_tab] <= #newLine do
					actual_tab = actual_tab + 1
				end
				local jump = config.tab_stops[actual_tab] - #newLine
				if jump <= 0 then
					jump = 1
				end
				for j = 1,jump do
					table.insert(newLine," ")
				end
			else
				newLine = table.insert(newLine,line:sub(i,i))
			end
		end
		return table.concat(newLine)
	end

	local function addItemLines(item,lines)
		-- Trim the empty lines in the beginning
		trimItemEmptyBeginLines(item.itemType,lines)
		trimItemEmptyEndLines(item.itemType,lines)
		local ln, lnEX, lineKind
		local sourceItem = tu.inArray(config.source_items,config.items[item.itemType])
		local itemLines = {}
		for i = 1,#lines do
			lnEX = ExpandTab(lines[i])
			ln = lnEX:gsub("^%s*","")

			local remarkMarker = tu.inArray(config.remark_markers,ln,function(one,two) return two:sub(1,#one) == one end)
			if not sourceItem and remarkMarker then
				ln = lb:sub(#config.remark_markers[remarkMarker] + 1,-1)
				lineKind = "PLAIN"
			else
				ln = lnEX	-- This is a code line so maintain spaces in the beginning
				lineKind = "RAW"
			end

			if (not sourceItem and remarkMarker) or sourceItem then
				itemLines[#itemLines + 1] = {
					line = ln,
					kind = lineKind,
					line_number = item.start + i,
					format = {
						BEGINPRE = nil,
						BEGINSOURCE = nil,
						ENDPRE = nil,
						ENDSOURCE = nil,
						BEGIN_LIST = nil,
						BEGIN_LIST_ITEM = nil,
						END_LIST_ITEM = nil,
						END_LIST = nil,
						BEGIN_PRE = nil,
						END_PRE = nil,
						BEGIN_PARAGRAPH = nil,
						END_PARAGRAPH = nil
					}
				}
			end
		end
		item.lines = itemLines
	end
--[[
 - FUNCTION
 -   Try to determine the formatting of an item.
 -   An empty line generates a new paragraph
 -   Things that are indented more that the rest of the text
 -   are preformatted.
 -   Things that start with a '*' or '-' create list items
 -   unless they are indented more that the rest of the text.
]]
	local function analyseItemFormat(item)
		local source = tu.inArray(config.source_items,config.items[item.itemType])
		local function Analyse_Indentation()
			for i = 1,#item.lines do
				if item.lines[i].kind == "PLAIN" then
					if item.lines[i].line:gsub("%s","") ~= "" then
						return #item.lines[i].line:match("^(%s*)")
					end
				end
			end
			return 0
		end
		-- Analyse List
		--[[
			 *   Parse the item text to see if there are any lists.
			 *   A list is either case I:
			 *      ITEMNAME
			 *         o bla bla
			 *         o bla bla
			 *   or case II:
			 *      some text:     <-- begin of a list
			 *      o bla bla      <-- list item
			 *        bla bla bla  <-- continuation of list item.
			 *      o bla bla      <-- list item
			 *                     <-- end of a list
			 *      bla bla        <-- this can also be the end of a list.
		]]
		local function Analyse_List(indent)
			local function Is_ListItem_Start(line,indent)
				local curIndent = #line:match("^(%s*)")
				if curIndent == indent and #line:match("^%s*([%*%-o]%s.+)") >=3 then
					-- List item start
					return true
				end
			end
			local function Analyse_ListBody(startLn,indent)
				for i = startLn,#item.lines do
					if item.lines[i].kind == "PLAIN" or i == #item.lines then
						if Is_ListItem_Start(item.lines[i],indent) then
							item.lines[i].format.END_LIST_ITEM = true
							item.lines[i].format.BEGIN_LIST_ITEM = true
							-- Remove the list character
							item.lines[i].line = item.lines[i].line:match("^%s*[%*%-o]%s(.+)")
						elseif #item.lines[i].line:match("^(%s*)") <= indent then	-- Check whther the list item continuation like:
																				--  *   Is it like the second line in something like:
																				--		* this is a list item
																				--		  that continues
							-- This is not the continuation of the list item
							item.lines[i].format.END_LIST_ITEM = true
							item.lines[i].format.END_LIST = true
							return i
						end		-- if Is_ListItem_Start(item.lines[i],indent) then ends
					end		-- if item.lines[i].kind == "PLAIN" or i == #item.lines then ends
				end		-- for i = startLn,#item.lines do ends
				return #item.lines + 1
			end
			-- Case I
			local i = 1
			if item.lines[i].kind == "PLAIN" and Is_ListItem_Start(item.lines[i],indent) then
				item.lines[i].format.BEGIN_LIST = true
				item.lines[i].format.BEGIN_LIST_ITEM = true
				-- Remove the list character
				item.lines[i].line = item.lines[i].line:match("^%s*[%*%-o]%s(.+)")
				-- Analyse list body
				i = Analyse_ListBody(i + 1,indent)
			end
			-- Case II
			while i <= #item.lines do
				if item.lines[i].kind  == "PLAIN" and item.lines[i].line:match("^.+:%s*$") then	-- A list can start with a line ending with :
					-- go to the next line where the list content starts
					i = i + 1
					if i <= #item.lines and item.lines[i].kind == "PLAIN" and Is_ListItem_Start(item.lines[i],indent) then
						item.lines[i].format.BEGIN_LIST = true
						item.lines[i].format.BEGIN_LIST_ITEM = true
						-- Remove the list character
						item.lines[i].line = item.lines[i].line:match("^%s*[%*%-o]%s(.+)")
						-- Analyse list body
						i = Analyse_ListBody(i+1,indent)
						--[[ One list might be immediately followed
						 * by another. In this case we have to
						 * analyse the last line again. ]]
						if item.lines[i].kind  == "PLAIN" and item.lines[i].line:match("^.+:%s*$") then
							i = i - 1
						end
						i = i + 1
					end
				end
			end
		end
		-- To analyse preformatted text
		local function Analyse_Preformatted(indent)
			local inList, ln, newIndent, preformatted
			for i = 1,#item.lines do
				ln = item.lines[i].line
				newIndent = #line:match("^(%s*)")
				if not inList and item.lines[i].format.BEGIN_LIST then
					inList = true
				end
				if inList and item.lines[i].format.END_LIST then
					inList = false
				end
				if not inList then
					if newIndent > indent and not preformatted then
						preformatted = true
						item.lines[i].format.BEGIN_PRE = true
					elseif newIndent <= indent and preformatted then
						preformatted = false
						item.lines[i].format.END_PRE = true
					end
				end
			end
		end
		local function Analyse_Paragraphs()
			local inPara,inList,inPre,isEmpty,prevIsEmpty,ln
			if not next(item.lines[1].format) then
				item.lines[1].format.BEGIN_PARAGRAPH = true
				inPara = true
			end
			for i = 1,#item.lines do
				ln = item.lines[i].line
				prevIsEmpty = isEmpty
				isEmpty = ln:match("^%s*$")
				if item.lines[i].format.BEGIN_LIST then
					inList = true
				end
				if item.lines[i].format.BEGIN_PRE then
					inPre = true
				end
				if item.lines[i].format.END_LIST then
					inList = false
				end
				if item.lines[i].format.END_PRE then
					inPre = false
				end
				if inPara then
					if item.lines[i].format.BEGIN_LIST or item.lines[i].format.BEGIN_PRE or isEmpty then
						inPara = false
						item.lines[i].format.END_PARAGRAPH = true
					end
				else
					if item.lines[i].format.END_LIST or item.lines[i].format.END_PRE or (not isEmpty and prevIsEmpty and not inList and not inPre) then
						inPara = trye
						item.lines[i].format.BEGIN_PARAGRAPH = true
					end
				end
			end
			if inPara then
				item.lines[#item.lines].format.END_PARAGRAPH = true
			end
		end
		if #item.lines > 0 then
			if not source and (actions.do_nopre or tu.inArray(config.format_items or {},config.items[item.itemType])) and
			  not tu.inArray(config.preformatted_items or {},config.items[item.itemtype]) then
				-- Analyse indentation
				local indent = Analyse_Indentation()
				Analyse_List(indent)
				Analyse_Preformatted(indent)
				Analyse_Paragraphs()
			else
				-- Preformat_All
				local ln
				ln = item.lines[1]
				ln.format.BEGINSOURCE = source and true
				if #item.lines > 1 then
					ln.format.BEGINPRE = true
					ln = item.lines[#item.lines]
					ln.format.ENDPRE = true
					ln.format.ENDSOURCE = source and true
				end
			end
		end		-- if #item.lines > 0 then ends
	end		-- local function analyseItemFormat(item) ends

	header.items = {}
	--[[
	-- Item structure defined in the C program
struct RB_Item
{
    struct RB_Item     *next;
    enum ItemType       type;
    int                 no_lines;
    struct RB_Item_Line **lines;
    int                 begin_index;
    int                 end_index;
    int                 max_line_number;
};
	]]
	local lnCt = 0
	local start,stp,line = header.data:find("(.-)\n")	-- header.data always ends with \n
	local lines = {}
	while line do
		lnCt = lnCt + 1
		local itemType = checkItem(line)
		if itemType then
			if #header.items > 0 then
				header.items[#header.items].last = lnCt-1
				addItemLines(header.items[#header.items],lines)
				analyseItemFormat(header.items[#header.items])
			end
			header.items[#header.items + 1] = {
				itemType = itemType,
				start = lnCt,
			}
			lines = {}
		else
			lines[#lines + 1] = line
		end
		start,stp,line = header.data:find("(.-)\n",stp+1)
	end		-- for line in header.data:gmatch("(.-)\n") do ends
	if #header.items > 0 then
		header.items[#header.items].last = lnCt-1
		addItemLines(header.items[#header.items],lines)
		analyseItemFormat(header.items[#header.items])
	end
	return ri
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
	-- Also store all the headers in the document
	document.headers = {}
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
		--		char               *unique_name;
		--		char               *file_name;
				struct RB_header_lines *lines;
				int                 no_lines;
		--		int                 line_number;
			};
		]]
		parts[#parts + 1] = {
			srcfile = dir[i],
			headers = headers,
			docfile = nil
		}
		logger:debug("Analysing "..dir[i].path..dir[i].file)
		local f,msg = io.open(dir[i].path..dir[i].file)
		if f then
			local fDat = f:read("*a")
			f:close()
			-- Collect all the headers
			local strt,stp,index,lineNum = findHeader(fDat,1)	-- hi is the header index in config.header_markers
			local hi = actions.do_lockheader and index
			local ei,ri		-- ei - end marker index found, ri - remark marker index found
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
								part = parts[#parts],
								file_name = nil,
								unique_name = nil,
								items = nil
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
								local RI = analyse_items(headers[#headers],actions,ri)
								ri = actions.do_lockheader and (not ri and RI or ri)
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
		-- Add all the collected headers to document.headers
		for j = 1,#headers do
			document.headers[#document.headers + 1] = headers[j]
		end
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
	local ext = document.extension
	if ext:sub(1,1) ~= "." then
		ext = "."..ext
	end
	for i = 1,#parts do
		local sFile = parts[i].srcfile
		local dFile = {file = sFile.file:gsub("%..-$","")..ext}
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
		docfiles[i] = document.parts[i].docfile
	end
	-- Sort the file list according to the path so that hierarchy is created from the top most path first
	table.sort(docfiles,function(one,two) return one.path < two.path end)
	-- Now create the paths
	local stat,msg
	for i = 1,#docfiles do
		stat,msg = globals.createPath(docfiles[i].path)
		if not stat then
			logger:error("Cannot create directory: "..docfiles[i].path)
			return nil,msg
		end
	end
	return true
end

-- Function to split the parts so that one part only has 1 header
local function splitParts(document)
	local parts = document.parts
	local sparts = {}
	local function fillPartKeys(p,sp)
		for k,v in pairs(p) do
			if k ~= "headers" then
				sp[k] = v
			end
		end
	end
	for i = 1,#parts do
		for j = 1,#parts[i].headers do
			sparts[#sparts + 1] = {}
			fillPartKeys(parts[i],sparts[#sparts])
			sparts[#sparts].headers = {parts[i].headers[j]}
			sparts[#sparts].headers[1].part = sparts[#sparts]
		end
	end		-- for i ends here
	document.parts = sparts
	return true
end

-- Sanitize a name by making sure all characters are either alphanumeric or hex codes if any other encoding characters are present
local function sanitizeName(name)
	local newName = ""
	for i = 1,#name do
		local c = name:sub(i,i)
		if c:byte() < 128 and c:match("%w") then
			newName = newName..c
		else
			newName = newName..string.format("%2X",c:byte())
		end
	end
	return newName
end

-- Function to interlink the headers
-- Every header table gets a parent entry and a array of children
local function interlinkHeaders(headers)
	for i = 1,#headers do
		local name = headers[i].names[1]
		headers[i].children = headers[i].children or {}
		for j = 1,#headers do
			if j ~= i then
				if headers[j].module_name == name then
					headers[j].parent = headers[i]
					headers[i].children[#headers[i].children + 1] = headers[j]
				end
			end
		end		-- for j = 1,#headers do ends
	end		-- for i = 1,#headers do ends
end

local function OpenDocumentation(part)

end


-- Function to generate the documentation from the info available in the document structure and config structure
-- RB_Generate_MultiDoc function from C file
local function genMultiDoc(document)
	local stat,msg
	local document_file
	-- Get the list of document path and names that need to be created
	getDocFileList(document)
	-- Create all the document paths
	stat,msg = createDocFilePaths(document)
	if not stat then
		return nil,msg
	end
	if document.actions.do_one_file_per_header then
		logger:info("Generating file names for storing each header in a separate file.")
		splitParts(document)
		-- Add the header name to the docfile name
		local parts = document.parts
		for i = 1,#parts do
			local name,ext = parts[i].docfile.file:match("^(.+)(%..-)$")
			parts[i].docfile.file = name..sanitizeName(parts[i].headers[1].names[1])..ext
		end
	end
	if not document.actions.do_nosort then
		local function compareHeaders(one,two)
			if config.headertypes[one.htype].priority > config.headertypes[two.htype].priority then
				return true
			end
			if config.headertypes[one.htype].priority < config.headertypes[two.htype].priority then
				return false
			end
			-- priorities are equal
			if document.actions.do_sectionnameonly then
				-- Do not include parent name in sorting it they are not displayed
				return one.function_name < two.function_name
			else
				return one.names[1] < two.names[1]
			end
		end
		-- Sort the headers
		local parts = document.parts
		for i = 1,#parts do
			table.sort(parts[i].headers,compareHeaders)
		end
		-- Sort all the headers in the document.headers table as well
		table.sort(document.headers,compareHeaders)
	end
	-- Interlink the headers by creating parent child relationships
	interlinkHeaders(document.headers)
	-- Create structure for links
	document.links = {}
	-- Populate the filename where each header is stored
	for i = 1,#document.headers do
		if document.actions.do_singledoc or document.actions.do_singlefile then
			document.headers[i].file_name = document.srcroot
		else
			document.headers[i].file_name = document.headers[i].part.docfile.path..document.headers[i].part.docfile.file
		end
		-- Give each header a unique name
		document.headers[i].unique_name = "robo"..string.format("%07u",i)
		-- Sort the items in the header
		table.sort(document.headers[i].items,function(one,two)
				return one.itemType and two.itemType and one.itemType < two.itemType
			end)
		for j = 1,#document.headers[i].names do
			local name = document.headers[i].names[j]
			document.links[#document.links + 1] = {
				htype = docment.headers[i].htype,
				internal = document.headers[i].internal,
				file_name = document.headers[i].file_name,
				object_name = name:find("%/") and name:match("%/(.-)$") or name,
				label_name = document.headers[i].unique_name
			}
		end
	end
	-- Add links for all the source files only if not do one file per header
	if not document.actions.do_one_file_per_header then
		for i = 1,#document.parts do
			document.links[#document.links + 1] = {
				label_name = "robo_top_of doc",
				object_name = document.parts[i].srcfile.file,
				file_name = document.parts[i].srcfile.path..document.parts[i].srcfile.file,
				htype = tu.inArray(config.headertypes,string.char(1),function(one,two) return one.typeCharacter == two end)
			}
			document.parts[i].link = document.links[#document.links]
		end
	end
	-- Sort all the links
	table.sort(document.links,function(one,two) return one.object_name < two.object_name end)

    logger:info("Creating CSS file..")
	if(globals.docformats.name == "html") then
		html.createCSS(document)
	end

	for i=1, #document.parts do
		local srcname = document.parts[i].srcfile.file
		local docname = document.parts[i].srcfile.path..document.parts[i].srcfile.file

		if #document.headers == 0 then
			goto skip
		end
		if globals.docformats.name == "HTML" then

			document_file, msg = io.Open(document.parts[i].srcfile.file)
			if not document_file then
				logger:error("Cannot open file"..document.parts[i].srcfile.file)
			end

			generator.GenerateDocStart(document, document_file, srcname, srcname, 1, docname, document.charset)
			generator.GenerateBeginNavigation(document_file)

			if(document.actions.do_one_file_per_header) then
				html.GenerateNavBarOneFilePerHeader(document,document_file,document.parts[i].headers)
			else
				generator.GenerateIndexMenu(document_file,docname,document)
			end

			generator.GenerateEndNavigation(document_file)
			generator.GenerateBeginContent(document_file)

			if((document.actions.do_toc) and (document.no_headers)) then
				generator.GenerateTOC2(document_file,document.headers,document.no_headers,document.parts[i],docname)
			end

			generator.GeneratePart(document_file, document, i_part)
			generator.GenerateEndContent(document_file)
			generator.GenerateDocEnd(document_file,docname,srcname)
			document_file:close()
		else
			generator.GeneratePart(document_file, document, i_part)
		end
		::skip::
	end
	if(document.actions.do_index) then
		generator.GenerateIndex(document)
	end
end

function docgen(document)
	config = globals.configuration
	sourceExt = document.srcextension
	if document.actions.do_multidoc then
		logger:info("Scan source directory: "..document.srcroot)
		document.dir = getSourceFileList(document.srcroot,document.actions.do_nodesc)
		logger:info("Found "..#document.dir.." files.")
		if #document.dir == 0 then
			return
		end
		createDocParts(document)
		genMultiDoc(document)
	elseif document.actions.do_singledoc then

	elseif document.actions.do_singlefile then

	end
end

