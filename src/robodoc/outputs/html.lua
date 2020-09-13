-- HTML Generation module as done in original Robodoc


local globals = require("robodoc.globals")
local docformats = globals.docformats
local logger = globals.logger
local os = os

local M = {}
package.loaded[...] = M
if setfenv and type(setfenv) == "function" then
	setfenv(1,M)	-- Lua 5.1
else
	_ENV = M		-- Lua 5.2
end

docformats[#docformats + 1] = {
	name = "html",
	ext="html"
}

-- Setup the arguments in the commandline
globals.parser.option("--css","Specify the stylesheet to use.")
	:args(1)
	:convert(globals.fileExists)

function init(document)
	document.css = globals.args.css
end


--[[***f* HTML_Generator/RB_Create_CSS
 * FUNCTION
 *   Create the .css file.  Unless the user specified it's own css
 *   file robodoc creates a default one.
 *
 *   For multidoc mode the name of the .css file is
 *      robodoc.css
 *   For singledoc mode the name of the .css file is equal
 *   to the name of the documentation file.
 * SYNOPSIS
 ]]
function createCSS(document)
--[[
 * INPUTS
 *   o document -- the document for which to create the file.
 * SOURCE
 ]]
end
