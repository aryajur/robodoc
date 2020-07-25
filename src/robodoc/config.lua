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


]=]
configuration = {
	items,--,-- = {},
	ignore_items,-- = {},
	source_items,-- = {},
	preformatted_items,-- = {},
	format_items,-- = {},
	--item_order,-- = {},  -- Combined to items. The order they appear in items is the order as well
	options,-- = {},
	ignore_files,-- = {},
	accept_files,-- = {},
	custom_headertypes,-- = {},
	header_markers,-- = {},
	remark_markers,-- = {},
	end_markers,-- = {},
	remark_begin_markers,-- = {},
	remark_end_markers,-- = {},
	keywords,-- = {},
	source_line_comments,-- = {},
	header_ignore_chars,-- = {},
	header_separate_chars-- = {}	
}

local logger = logger
local tu = require("tableUtils")

local pairs = pairs
local type = type

-- Note this file is Lua 5.3 compatible only because the way the load function is used in readConfigFile FUnction
local M = {}
package.loaded[...] = M
if setfenv and type(setfenv) == "function" then
	setfenv(1,M)	-- Lua 5.1
else
	_ENV = M		-- Lua 5.2
end

local defaultItems = {
    "SOURCE",                   -- source code inclusion 
    "NAME",                     -- Item name + short description 
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
    "--***",                    -- 0   C, C++ 
    "//!****",                  -- 1   C++, ACM 
    "/--***",                   -- 2   C++ 
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
    "--**",                     -- 0  C, C++ 
    "//!***",                   -- 1  C++, ACM -- Must check before C++ 
    "/--**",                    -- 2  C++ 
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

local defaultHeader_separate_chars = {
	","
}

local defaultHeader_ignore_chars = {
    "[",
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

-- Function to validate the configuration file data
local function validateConfigFile(config)
	local arrStrings = {
		"items",
		"header_markers",
		"remark_markers",
		"end_markers",
		"header_separate_chars",
		"header_ignore_chars",
		"remark_begin_markers",
		"remark_end_markers"		
	}
	local function checkArrayType(arr,name,typ)
		local len = #arr
		for k,v in pairs(arr) do
			if type(k) ~= "number" or k > len then
				return nil,name.." should be an array of items."
			end
			if type(v) ~= typ then
				return nil,"All "..name.." should be strings."
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
	return true
end

function readConfigFile(filename)
	if not filename then
		return
	end
	local f,msg = io.open(filename)
	if not f then
		logger:error("Cannot open specified configuration file: "..filename)
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

-- Function to setup the configuration from the given configuration
function setupConfig(config)
	configuration = {}
	if not config.items then
		configuration.items = defaultItems
	else
		configuration.items = config.items
		stat = tu.inArray(configuration.items,"SOURCE")
		if not stat then
			table.insert(configuration.items,1,"SOURCE")
		elseif stat ~= 1 then
			table.remove(configuration.items,stat)
			table.insert(configuration.items,1,"SOURCE")
		end	
	end
	if config.header_markers then
		configuration.header_markers = config.header_markers
	else
		configuration.header_markers = defaultHeader_markers
	end
	if config.remark_markers then
		configuration.remark_markers = config.remark_markers
	else
		configuration.remark_markers = defaultRemark_markers
	end
	if config.end_markers then
		configuration.end_markers = config.end_markers
	else
		configuration.end_markers = defaultEnd_markers
	end
	if config.header_separate_chars then
		configuration.header_separate_chars = config.header_separate_chars
	else
		configuration.header_separate_chars = defaultHeader_separate_chars
	end
	if config.header_ignore_chars then
		configuration.header_ignore_chars = config.header_ignore_chars
	else
		configuration.header_ignore_chars = defaultHeader_ignore_chars
	end
	if config.remark_begin_markers then
		configuration.remark_begin_markers = config.remark_begin_markers
	else
		configuration.remark_begin_markers = defaultRemark_begin_markers
	end
	if config.remark_end_markers then
		configuration.remark_end_markers = config.remark_end_markers
	else
		configuration.remark_end_markers = defaultRemark_end_markers
	end	
end