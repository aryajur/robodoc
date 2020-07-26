-- Robodoc translation to Lua

-- Collection of all globals
logger = nil			-- Logging object
parser = nil			-- command line argument parser
args = nil				-- arguments parsed by argparse
actions = nil			-- all actions to be done
configuration = nil		-- configuration of the run
doctype = nil			-- output document type
whoami = nil			-- program argument given to run it
docformats = nil		-- all supported doc formats. Every generator should register it here 
document_title = nil	-- Title of the document
course_of_action = nil	-- Action list
tab_stops = nil			-- Tab stops array. Each array location has a number which tells how many spaces for that tab


-- Use the Lua Logging library for logging messages
local log_console = require"logging.console"

local logger = log_console()
logger:setLevel("INFO")

-- Using argparse module https://github.com/luarocks/argparse
local ap = require("argparse")
parser = ap()	-- Create a parser

docformats = {}

local info = require("robodoc.info")	-- Also sets up command line arguments using argparse
local config = require("robodoc.config")

-- Import all document exporters here


-- Setup the docformat options here
parser:option("--output","Specify the output file format."):args(1):count(1):choices(docformats)

-- Command line arguments
whoami = arg[0]

local cfg = config.readConfigFile(args.rc)	-- read the configuration file given by the name rc
args = config.setupConfig(cfg)

if args.debug then
	logger:setLevel("DEBUG")
end

if args.license then
	print(info.license)
	os.exit()
end

if args.version then
	print(info.VERSION)
	os.exit()
end

-- Find the doctype
for i = 1,#docformats do
	if parser[docformats[i]] then
		doctype = docformats[i]
		break
	end
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
    do_robo_head= true,
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
local function findActions()
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

local document = {
	doctype = doctype,
	actions = findActions(),
	debugmode = args.debug,
	charset = args.charset,
	extension = args.ext,
	css = args.css,
	section = args.mansection,
	first_section_level = args.first_section_level,
}
document_title = args.doctumenttitle
course_of_action = document.actions
-- setup tab_stops
do
	tab_stops = {}
	local tabsize = args.tabsize or config.defaultTabSize
	if args.tabstops then
		for i = 1,256 do
			tab_stops[i] = tabsize*i
		end	
	else
		for i = 1,#args.tabstops do
			tab_stops[i] = args.tabstops[i]
		end
	end
end
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
