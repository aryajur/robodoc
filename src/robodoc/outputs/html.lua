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

local str;


--[[***f* HTML_Generator/RB_HTML_Generate_Div
 * FUNCTION
 *   Write a Div to the destination document 
 * SYNOPSIS
 ]]

function generateDiv(id)
--[[
 * INPUTS
 *   o id -- id Attribute of the div
 * SEE ALSO
 *   RB_HTML_Generate_DivEnd()
 * SOURCE
 ]]
	str = str.."<div id=\""..id.."\">\n"
end


--[[***f* HTML_Generator/RB_HTML_Generate_DivEnd
 * FUNCTION
 *   Write a DivEnd to the destination document
 * SYNOPSIS
 ]]

 function generateDivEnd(id)
--[[
 * INPUTS
 *   o id -- id Attirbute of the div
 * SEE ALSO
 *   RB_HTML_Generate_DivEnd()
 * SOURCE
 ]]
	str = str.."</div><!----"..id.."--->\n"
end


--[[***f* HTML_Generator/RB_HTML_Generate_String
 * FUNCTION
 *   Write a string to the destination document, escaping
 *   characters where necessary.
 * SYNOPSIS
 ]]
function GenerateString(a_string)
--[[
 * INPUTS
 *   o a_string -- a nul terminated string.
 * SEE ALSO
 *   RB_HTML_Generate_Char()
 * SOURCE
]]
    l = #a_string
    for i=0,#a_string do
        c = a_string[i];
        GenerateChar(c);
	end
end


--[[***f* HTML_Generator/RB_HTML_Generate_Char
 * NAME
 *   RB_HTML_Generate_Char -- generate a single character for an item.
 * SYNOPSIS
 ]]
function generateChar(c)
--[[
 * FUNCTION
 *   This function is called for every character that goes
 *   into an item's body.  This escapes all the reserved
 *   HTML characters such as '&', '<', '>', '"'.
 * SOURCE
 ]]

 	local switch = { 
    	['\n'] = function()	-- for case '\n'
        	str = str..""
    	end,
    	['\t'] = function()	-- for case '\t'
        	str = str..""
    	end,
    	['<'] = function()	-- for case '<'
        	str = str.."&lt"
		end,
		['>'] = function()  -- for case '<'
			str = str.."&gt"
		end,
		['&'] = function()  -- for case '&'
			str = str.."&amp"
		end
	}
	
	local f = switch[c]
	if (f) then
		f()
	else                   --for default
		str = str..c 
	end
end