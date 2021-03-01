-- Robodoc translation to Lua

require("submodsearcher")

local globals = require("robodoc.globals")
-- Collection of all globals
--[[
logger = nil			-- Logging object
parser = nil			-- command line argument parser used here and in config file
docformats = nil		-- all supported doc formats. Every generator should register it here 
whoami = nil			-- program argument given to run it
args = nil				-- arguments parsed by argparse
configuration = nil		-- configuration of the run
]]

-- Use the Lua Logging library for logging messages
local log_console = require"logging.console"				-- https://github.com/lunarmodules/lualogging

local logger = log_console()
globals.logger = logger
--logger:setLevel("INFO")
logger:setLevel("DEBUG")

local tu = require("tableUtils")			-- https://github.com/aryajur/tableUtils
-- Using argparse module https://github.com/luarocks/argparse
local ap = require("argparse")
local parser = ap()	-- Create a parser
globals.parser = parser

local docformats = {
	{ name = "html",ext="html"}
}
globals.docformats = docformats

local info = require("robodoc.info")	-- Also sets up command line arguments using argparse
local config = require("robodoc.config")
local docgen = require("robodoc.docgen")

logger:info("Run Robodoc version "..info.VERSION.." on "..os.date())
logger:info(string.rep("-",50))

-- Import all document exporters here they wll setup and fill the docformats array
globals.html = require("robodoc.outputs.html")
-- Setup the docformat options here
do
	local formats = {}
	for i = 1,#docformats do
		formats[i] = docformats[i].name
	end
	parser:option("--output","Specify the output file format."):args(1):count(1):choices(formats)
end

-- Command line arguments
globals.whoami = arg[0]

local cfgFile
local args = {}
do
	local i = 1
	while i<#arg do
		if arg[i] == "--rc" then
			cfgFile = arg[i + 1]
			i = i + 1
		else
			args[#args + 1] = arg[i]
		end
		i = i + 1
	end
end

-- Steps to load the configuration
-- # Load and validate the configuration file - done by config.readConfigFile
-- # Run config.setupConfig to merge all options in the configuration file with the options in the command line arguments and set them up
--       config.setupConfig returns the final combined arguments
local cfg = {}
if cfgFile then
	logger:info("Looking for configuration file "..cfgFile)
	cfg = config.readConfigFile(cfgFile)	-- read the configuration file given by the name rc
end
do 
	local msg
	args,msg = config.setupConfig(cfg,args)
	if not args then
		logger:error("Invalid Arguments: "..msg..". Exiting!")
		os.exit()
	end
end
globals.args = args

-- Find the doctype
--local doctype = tu.inArray(docformats,args,function(one,two) return two[one] end)
doctype = 1
local doctype = tu.inArray(docformats,args.output,function(one,two) return one.name == two end)
local document = {
	document_title = args.documenttitle,
	doctype = doctype,
	actions = config.findActions(),
	debugmode = args.debug,
	charset = args.charset,
	extension = args.ext or docformats[doctype].ext,
	srcextension = args.srcext,
	section = args.mansection,
	first_section_level = args.first_section_level,
	srcroot = args.src,
	docroot = args.doc
}

local pcall = pcall

local M = {}
package.loaded[...] = M
if setfenv and type(setfenv) == "function" then
	setfenv(1,M)	-- Lua 5.1
else
	_ENV = M		-- Lua 5.2+
end

-- Initialize all the docformats
for i = 1,#docformats do
	if globals[docformats[i].name].init then
		local stat,msg = pcall(globals[docformats[i].name].init,document)
		if not stat then
			logger:error("Error running output initialization function for "..docformats[i].name)
		end
	end
end

function generateDocumentation()
	docgen.docgen(document)
end

generateDocumentation()


