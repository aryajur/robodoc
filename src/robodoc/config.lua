-- Robodoc Configuration setup

-- Structure of configuration file:
--[=[
items = {
	"FILE",
	"MODULE",
	"FUNCTION",
	"CLASS",
	"METHOD",
	"STRUCTURE",
	"TYPE",
	"ENUM",
	"VARIABLE",
	"VARIABLES",
	"CONSTANT",
	"CONSTANTS",
	"ARRAY",
	"INPUTS",
	"INPUT",
	"ARGUMENTS",
	"ARGUMENT",
	"PARAMETERS",
	"PARAMETER",
	"AUTHOR",
	"SYNOPSYS",
	"SOURCE",
	"RETURN VALUE",
	"RETURNS",
	"SEE ALSO",
	"ALGORITHM",
	"ALGO",
	"KNOWN ISSUES",
	"WARNINGS",
	"ERRORS",
	"BUGS",
	"NOTE",
	"NOTES",
	"COMMENT",
	"COMMENTS",
	"EXAMPLE",
	"EXAMPLES",
	"DERIVED FROM",
	"DERIVED BY",
	"REUSED FROM",
	"TAGS",
	"KEYWORDS",
	"TODO",
	"IDEAS",
	"PORTABILITY",
	"CREATION DATE",
	"HISTORY",
	"ASSUMPTION",
	"ASSUMPTIONS"
}
source_items = {
	"SYNOPSYS"
}
header_markers = {
  [[--****]],
  [[--[[****]]
}

header_types = {
	{
		typeCharacter = "a",	-- Letter that indicates the header
		indexName = "Arrays",
		fileName = "arrays",
		priority = 0, 	-- Optional (default = 0 same as predefined header types)
	}
}

keywords = {
	"for",
	"if",
	"else",
	"then",
}
options = [[
    --index
    --tabsize 8
    --documenttitle "Code Documentation"
    --tell
]]
]=]

local globals = require("robodoc.globals")
local logger = globals.logger
local parser = globals.parser
local tu = require("tableUtils")

local pairs = pairs
local type = type
local tonumber = tonumber
local string = string
local arg = arg		-- Command line arguments

-- Note this file is Lua 5.3 compatible only because the way the load function is used in readConfigFile FUnction
local M = {}
package.loaded[...] = M
if setfenv and type(setfenv) == "function" then
	setfenv(1,M)	-- Lua 5.1
else
	_ENV = M		-- Lua 5.2
end
--[[
configuration = {
	items=nil,-- = {},
	ignore_items=nil,-- = {},
	source_items=nil,-- = {},
	preformatted_items=nil,-- = {},
	format_items=nil,-- = {},
	--item_order=nil,-- = {},  -- Combined to items. The order they appear in items is the order as well
	ignore_files=nil,-- = {},
	accept_files=nil,-- = {},
	headertypes=nil,-- = {},
	header_markers=nil,-- = {},
	remark_markers=nil,-- = {},
	end_markers=nil,-- = {},
	remark_begin_markers=nil,-- = {},
	remark_end_markers=nil,-- = {},
	keywords=nil,-- = {},
	source_line_comments=nil,-- = {},
	header_ignore_chars=nil,-- = {},
	header_separate_chars=nil,-- = {}	
	tab_stops = nil,		-- Tab stops array. Each array location has a number which tells how many spaces for that tab
	dot_name = "dot",		-- Path of the DOT tool
	header_breaks = 2,		-- Insert a linebreak after every NUMBER header names (default value: 2, set to zero to disable)	
}
]]

local defaultItems = {
    "SOURCE",                   -- source code inclusion 
    "NAME",                     -- Item Name + short description 
    "COPYRIGHT",                -- who own the copyright : "(c) <year>-<year> by <company/person>" 
    "SYNOPSIS", "USAGE",        -- how to use it 
    "FUNCTION", "DESCRIPTION", "PURPOSE",       -- what does it 
    "AUTHOR",                   -- who wrote it 
    "CREATION DATE",            -- when did the work start 
    "MODIFICATION HISTORY", "HISTORY",  -- who done what changes when 
    "INPUTS", "ARGUMENTS", "OPTIONS", "PARAMETERS", "SWITCHES", -- what can we feed into it 
    "OUTPUT", "SIDE EFFECTS",   -- what output will be made 
    "RESULT", "RETURN VALUE",   -- what do we get returned 
    "EXAMPLE",                  -- a clear example of the items use 
    "NOTES",                    -- any annotations 
    "DIAGNOSTICS",              -- diagnostical output 
    "WARNINGS", "ERRORS",       -- warning & error-messages 
    "BUGS",                     -- known bugs 
    "TODO", "IDEAS",            -- what to implement next & ideas 
    "PORTABILITY",              -- where does it come from, where will it work 
    "SEE ALSO",                 -- references 
    "METHODS", "NEW METHODS",   -- oop methods 
    "ATTRIBUTES", "NEW ATTRIBUTES",     -- oop attributes 
    "TAGS",                     -- tagitem description 
    "COMMANDS",                 -- command description 
    "DERIVED FROM",             -- oop super class 
    "DERIVED BY",               -- oop sub class 
    "USES", "CHILDREN",         -- what modules are used by this one 
    "USED BY", "PARENTS",       -- which modules do use this 	
}

local defaultHeader_markers = {
    "/****",                    -- 0   C, C++ 
    "//!****",                  -- 1   C++, ACM 
    "//****",                   -- 2   C++ 
    "(****",                    -- 3   Pascal, Modula-2, B52 
    "{****",                    -- 4   Pascal 
    ";;!****",                  -- 5   Aspen Plus 
    ";****",                    -- 6   M68K assembler 
    "****",                     -- 7   M68K assembler 
    "C     ****",               -- 8   Fortran 
    "REM ****",                 -- 9   BASIC 
    "%****",                    -- 10  LaTeX, TeX, Postscript 
    "#****",                    -- 11  Tcl/Tk 
    "      ****",               -- 12  COBOL 
    "--****",                   -- 13  Occam 
    "<!--****",                 -- 14  HTML Code 
    "<!---****",                -- 15  HTML Code,  the three-dashed comment
                                 -- tells the [server] pre-processor not
                                 -- to send that comment with the HTML 
                                 
    "|****",                    -- 16  GNU Assembler 
    "!****",                    -- 17  FORTRAN 90 
    "!!****",                   -- 18  FORTRAN 90 
    "$!****",                   -- 19  DCL 
    "'****",                    -- 20  VB, LotusScript 
    ".****",                    -- 21  DB/C 
    "\\ ****",                  -- 22  Forth 
    "<!-- ****",                -- 23  XML 
}

local defaultRemark_markers = {
    " *",                       -- 0  C, C++, Pascal, Modula-2 
    "//!",                      -- 1  C++, ACM -- MUST CHECK BEFORE C++ 
    "//",                       -- 2  C++ 
    "*",                        -- 3  C, C++, M68K assembler, Pascal,  Modula-2 
    ";;!",                      -- 4  Aspen Plus -- MUST CHECK BEFORE M68K 
    ";*",                       -- 5  M68K assembler 
    ";",                        -- 6  M68K assembler 
    "C",                        -- 7  Fortran 
    "REM",                      -- 8  BASIC 
    "%",                        -- 9  LaTeX, TeX, Postscript 
    "#",                        -- 10 Tcl/Tk 
    "      *",                  -- 11 COBOL 
    "--",                       -- 12 Occam 
    "|",                        -- 13 GNU Assembler 
    "!!",                       -- 14 FORTRAN 90 
    "!",                        -- 15 FORTRAN 90 
    "$!",                       -- 16 DCL 
    "'*",                       -- 17 VB 
    ".*",                       -- 18 DB/C 
    "\\",                       -- 19 Forth 
}

local defaultEnd_markers = {
    "/***",                     -- 0  C, C++ 
    "//!***",                   -- 1  C++, ACM -- Must check before C++ 
    "//***",                    -- 2  C++ 
    " ***",                     -- 3  C, C++, Pascal, Modula-2 
    "{***",                     -- 4  Pascal 
    "(***",                     -- 5  Pascal, Modula-2, B52 
    ";;!***",                   -- 6  Aspen Plus -- Must check before M68K 
    ";***",                     -- 7  M68K assembler 
    "***",                      -- 8  M68K assembler 
    "C     ***",                -- 9  Fortran 
    "REM ***",                  -- 10 BASIC 
    "%***",                     -- 11 LaTeX, TeX, Postscript 
    "#***",                     -- 12 Tcl/Tk 
    "      ***",                -- 13 COBOL 
    "--***",                    -- 14 Occam 
    "<!--***",                  -- 15 HTML 
    "<!---***",                 -- 16 HTML 
    "|***",                     -- 17 GNU Assembler 
    "!!***",                    -- 18 FORTRAN 90 
    "!***",                     -- 19 FORTRAN 90 
    "$!***",                    -- 20 DCL 
    "'***",                     -- 21 VB, LotusScript 
    ".***",                     -- 22 DB/C 
    "\\ ***",                   -- 23 Forth 
    "<!-- ***",                 -- 24 XML 
}

local defaultHeader_separate_chars = {	-- Delimiter in the names which will separate the names. 
										-- These characters before the end of line will signal the name continues on the next line
										-- Every entry should be 1 character only
	","
}

local defaultHeader_ignore_chars = {	-- Any patterns that will be replaced by empty string in the extracted names
    "%[.-%]",	-- Anything surrounded by square brackets is removed
}

local defaultRemark_begin_markers = {
    "/*",
    "(*",
    "<!--",
    "{*",
}

local defaultRemark_end_markers = {
    "*/",
    "*)",
    "-->",
    "*}",	
}

local defaultTabSize = 8

-- Characters allowed to be used as headertype typeCharacters
-- Note in the C code these were assigned so as to lookup directly using the ASCII code
-- ASCII codes that lie on typeCharacter = '\0' are therefore not allowed
local headerTypeDirectory = {
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
    {typeCharacter=string.char(1), indexName="Sourcefiles", fileName="robo_sourcefiles", priority=0},
    {typeCharacter=string.char(0), indexName="Index", fileName="masterindex", priority=0},    -- no robo_ prefix for backwards compatibility 
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
    {typeCharacter=' ', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='!', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='"', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='#', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='$', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='%', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='&', indexName=nil, fileName=nil, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
    {typeCharacter='(', indexName=nil, fileName=nil, priority=0},
    {typeCharacter=')', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='*', indexName="Generics", fileName="robo_generics", priority=0},
    {typeCharacter='+', indexName=nil, fileName=nil, priority=0},
    {typeCharacter=',', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='-', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='.', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='/', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='0', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='1', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='2', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='3', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='4', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='5', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='6', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='7', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='8', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='9', indexName=nil, fileName=nil, priority=0},
    {typeCharacter=':', indexName=nil, fileName=nil, priority=0},
    {typeCharacter=';', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='<', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='=', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='>', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='?', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='@', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='A', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='B', indexName="Businessrules", fileName="robo_businessrules", priority=0},
    {typeCharacter='C', indexName="Contracts", fileName="robo_contracts", priority=0},
    {typeCharacter='D', indexName="Datasources", fileName="robo_datasources", priority=0},
    {typeCharacter='E', indexName="Ensure contracts", fileName="robo_ensure_contracts", priority=0},
    {typeCharacter='F', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='G', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='H', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='I', indexName="Invariants", fileName="robo_invariants", priority=0},
    {typeCharacter='J', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='K', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='L', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='M', indexName="Metadata", fileName="robo_metadata", priority=0},
    {typeCharacter='N', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='O', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='P', indexName="Process", fileName="robo_processes", priority=0},
    {typeCharacter='Q', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='R', indexName="Require contracts", fileName="robo_require_contracts", priority=0},
    {typeCharacter='S', indexName="Subjects", fileName="robo_subjects", priority=0},
    {typeCharacter='T', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='U', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='V', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='W', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='X', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='Y', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='Z', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='[', indexName=nil, fileName=nil, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},	-- Separator
    {typeCharacter=']', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='^', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='_', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='`', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='a', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='b', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='c', indexName="Classes", fileName="robo_classes", priority=0},
    {typeCharacter='d', indexName="Definitions", fileName="robo_definitions", priority=0},
    {typeCharacter='e', indexName="Exceptions", fileName="robo_exceptions", priority=0},
    {typeCharacter='f', indexName="Functions", fileName="robo_functions", priority=0},
    {typeCharacter='g', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='h', indexName="Modules", fileName="robo_modules", 1},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},	-- Internal header flag
    {typeCharacter='j', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='k', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='l', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='m', indexName="Methods", fileName="robo_methods", priority=0},
    {typeCharacter='n', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='o', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='p', indexName="Procedures", fileName="robo_procedures", priority=0},
    {typeCharacter='q', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='r', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='s', indexName="Structures", fileName="robo_strutures", priority=0},
    {typeCharacter='t', indexName="Types", fileName="robo_types", priority=0},
    {typeCharacter='u', indexName="Unittest", fileName="robo_unittests", priority=0},
    {typeCharacter='v', indexName="Variables", fileName="robo_variables", priority=0},
    {typeCharacter='w', indexName="Warehouses", fileName="robo_warehouses", priority=0},
    {typeCharacter='x', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='y', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='z', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='{', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='|', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='}', indexName=nil, fileName=nil, priority=0},
    {typeCharacter='~', indexName=nil, fileName=nil, priority=0},
--    {typeCharacter='\0', indexName=NULL, fileName=NULL, priority=0},
}

-- Function to validate the configuration file data
local function validateConfigFile(config)
	local arrStrings = {
		"items",
		"ignore_items",
		"source_items",
		"header_markers",
		"remark_markers",
		"end_markers",
		"header_separate_chars",
		"header_ignore_chars",
		"remark_begin_markers",
		"remark_end_markers",
		"keywords",
		"ignore_files",
		"accept_files",
		"source_line_comments",
		"preformatted_items",
		"format_items",
	}
	local function checkArrayType(arr,Name,typ)
		local len = #arr
		for k,v in pairs(arr) do
			if type(k) ~= "number" or k > len then
				return nil,Name.." should be an array of strings."
			end
			if type(v) ~= typ then
				return nil,"All "..Name.." should be strings."
			end
		end		
	end
	for i = 1,#arrStrings do
		if config[arrStrings[i]] and type(config[arrStrings[i]]) ~= "table" then
			return nil,arrStrings[i].." must be a table with list of items"
		end
		if config[arrStrings[i]] then
			local stat,msg = checkArrayType(config[arrStrings[i]],arrStrings[i],"string")
			if not stat then
				return nil,msg
			end
		end		
	end
	if config.header_separate_chars then
		for i = 1,#config.header_separate_chars do
			if #config.header_separate_chars[i] ~= 1 then
				return nil,"header_separate_chars should be 1 character entries only: "..config.header_separate_chars[i]
			end
		end
	end
	if config.headertypes then
		local len = #config.headertypes
		for k,v in pairs(config.headertypes) do
			if type(k) ~= "number" or k > len then
				return nil,"headertypes should be an array of headertype definitions."
			end
			if type(v) ~= "table" then
				return nil,"headertype definition should be a table."
			end
			if not v.typeCharacter or type(v.typeCharacter) ~= "string" or #v.typeCharacter ~= 1 then
				return nil,"headertype definition should have a single letter typeCharacter."
			end
			if not tu.inArray(headerTypeDirectory,v.typeCharacter,function(one,two) return one.typeCharacter == two end) then
				return nil,"headertype typeCharacter: "..v.typeCharacter.." not allowed."
			end
			if not v.indexName or type(v.indexName) ~= "string" then
				return nil,"headertype indexName should be a string to indicate the name of heading under which all the headers are placed."
			end
			if not v.fileName or type(v.fileName) ~= "string" then
				return nil,"headertype fileName should be a string to indicate the fileName where all the headers are placed."
			end
			if v.priority and not tonumber(v.priority) then
				return nil,"headertype priority should be a number"
			end
		end
	end
	return true
end

function readConfigFile(fileName)
	if not fileName then
		return
	end
	local f,msg = io.open(fileName)
	if not f then
		logger:error("Cannot open specified configuration file: "..fileName)
		os.exit()
	end
	local cdat = f:read("*a")
	f:close()
	-- Load the configuration
	local safeenv = {}
	local func,stat
	func,msg = load(cdat,"Configuration","t",safeenv)
	if not func then
		logger:error("Cannot load configuration file: "..msg)
		os.exit()
	end
	stat,msg = pcall(func)
	if not stat then
		logger:error("Error loading configuration file: "..msg)
		os.exit()
	end
	stat,msg = validateConfigFile(safeenv)
	if not stat then
		logger:error("Invalid configuration file: "..msg)
		os.exit()
	end
	return safeenv
end

-- Function to validate the command line arguments
local function validateArgs(args)
	if not args.singledoc and not args.multidoc and not args.singlefile then
		return nil,"One of the flags: --singledoc, --multidoc or --singlefile is needed on the command line or configuration file."
	end
	if args.singledoc or args.singlefile then
		-- doc option should be a file
		local stat,msg = globals.fileCreatable(args.doc)
		if not stat then
			return nil,msg
		end
	end
	if args.singlefile then
		-- src option should be a file
		local stat,msg = globals.fileExists(args.src)
		if not stat then
			return nil,msg
		end
	end
	return true
end

-- Function to setup the configuration from the given configuration
-- The function also parses any command line arguments, validates them and includes them in the configuration
-- The command line configuration parameters take precedence over any similar options defined in the configuration file
function setupConfig(config)
	local configuration = {
		items = defaultItems,
		header_markers = defaultHeader_markers,
		remark_markers = defaultRemark_markers,
		end_markers = defaultEnd_markers,
		header_separate_chars = defaultHeader_separate_chars,
		header_ignore_chars = defaultHeader_ignore_chars,
		remark_begin_markers = defaultRemark_begin_markers,
		remark_end_markers = defaultRemark_end_markers,
		dot_name = "dot",		-- Path of the DOT tool
		header_breaks = 2,		-- Insert a linebreak after every NUMBER header names (default value: 2, set to zero to disable)
	}
	globals.configuration = configuration
	-- Read the options from the configuration file
	local opts = {}
	if config and config.options then
		local options = " "..config.options
		for o in options:gmatch("%s%s*([^%s]+)") do
			opts[#opts + 1] = o
		end
	end
	-- Parse all the arguments given in the command line
	for i = 1,#arg do
		opts[#opts + 1] = arg[i]
	end
	local args = parser:parse(opts)
	local stat,msg = validateArgs(args)
	if not stat then return nil,msg end
	if config and config.items then
		configuration.items = config.items
		local stat = tu.inArray(configuration.items,"SOURCE")
		if not stat then
			table.insert(configuration.items,1,"SOURCE")
		elseif stat ~= 1 then
			table.remove(configuration.items,stat)
			table.insert(configuration.items,1,"SOURCE")
		end	
	end
	local arrStrings = {
		-- The following have defaults
		"header_markers",
		"remark_markers",
		"end_markers",
		"header_separate_chars",
		"header_ignore_chars",
		"remark_begin_markers",
		"remark_end_markers",
		
		-- The following do not have defaults
		"keywords",
		"ignore_items",
		"source_items",
		"ignore_files",
		"accept_files",
		"source_line_comments",
		"preformatted_items",
		"format_items",
	}
	for i = 1,#arrStrings do
		if config and config[arrStrings[i]] then
			configuration[arrStrings[i]] = config[arrStrings[i]]
		end
	end
	configuration.headertypes = tu.copyTable(headerTypeDirectory,{},true)
	if config and config.headertypes then
		for i =1,#config.headertypes do
			local index = tu.inArray(configuration.headertypes,config.headertypes[i],function(one,two) 
					return one.typeCharacter == two.typeCharacter 
				end)
			-- validate Config should have already checked the existence of the headertype
			configuration.headertypes[index] = config.headertypes[i]
		end
	end
	--configuration.dot_name = args.dotname

	configuration.header_breaks = args.header_breaks==0 and 255 or args.header_breaks
	
	-- setup tab_stops
	local tab_stops = {}
	local tabsize = args.tabsize or defaultTabSize
	if not args.tabstops then
		for i = 1,256 do
			tab_stops[i] = tabsize*i
		end	
	else
		for i = 1,#args.tabstops do
			tab_stops[i] = args.tabstops[i]
		end
	end
	configuration.tab_stops = tab_stops
	
	-- Setup masterindex and sourceindex options
	if args.masterindex then
		local index = tu.inArray(configuration.headertypes,string.char(2),function(one,two) 
				return one.typeCharacter == two 
			end)
		configuration.headertypes[index] = {
			typeCharacter = string.char(2),
			indexName = args.masterindex[1],
			fileName = args.masterindex[2],
			priority = 0
		}
	end

	if args.sourceindex then
		local index = tu.inArray(configuration.headertypes,string.char(1),function(one,two) 
				return one.typeCharacter == two 
			end)
		configuration.headertypes[index] = {
			typeCharacter = string.char(1),
			indexName = args.sourceindex[1],
			fileName = args.sourceindex[2],
			priority = 0
		}
	end
	return args
end

-- To populate the list of actions to do
--[[
-- Actions
actions = {
	do_nosort = true,
	do_nodesc = true,
    do_toc= true,
    do_internal= true,
    do_internal_only= true,
    do_tell= true,
    do_index= true,
    do_nosource= true,
    do_sections= true,
    do_lockheader= true,
    do_footless= true,
    do_headless= true,
    do_nopre= true,
    do_ignore_case_when_linking= true,
    do_nogenwith= true,
    do_sectionnameonly= true,
    do_verbal= true,
    do_source_line_numbers= true,

    -- Document modes
    do_singledoc= true,
    do_multidoc= true,
    do_singlefile= true,
    do_one_file_per_header= true,
    do_no_subdirectories= true,

    -- Latex options
    do_altlatex= true,
    do_latexparts= true,

    -- Syntax coloring
    do_quotes= true,
    do_squotes= true,
    do_line_comments= true,
    do_block_comments= true,
    do_keywords= true,
    do_non_alpha= true,
}
]]
function findActions()
	local actions = {}
	local flags = {
		-- Document modes
		"singledoc",
		"singlefile",
		"multidoc",
		"no_subdirectories",
		"one_file_per_header",
		"sections",
		"internal",
		"ignore_case_when_linking",
		"internalonly",
		"toc",
		"index",
		"nosource",
		"tell",
		"debug",
		"nodesc",
		"nogeneratedwith",
		"lockheader",
		"footless",
		"verbal",
		"headless",
		"nosort",
		"nopre",
		"sectionnameonly",
		"source_line_numbers",
	}
	local args = globals.args	-- Get all command line arguments
	for i = 1,#flags do
		if args[flags[i]] then
			actions["do_"..flags[i]] = true
		end
	end
	if args.syntaxcolors then
		actions.do_quotes = true
		actions.do_squotes = true
		actions.do_line_comments = true
		actions.do_block_comments = true
		actions.do_keywords = true
		actions.do_non_alpha = true
	elseif args.syntaxcolors_enable then
		for i = 1,#args.syntaxcolors_enable do
			actions["do_"..args.syntaxcolors_enable[i]] = true
		end
	end
	return actions
end
