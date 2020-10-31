-- Information and help text are all stored here

local globals = require("robodoc.globals")
local parser = globals.parser
local tonumber = tonumber
local io = io

local M = {}
package.loaded[...] = M
if setfenv and type(setfenv) == "function" then
	setfenv(1,M)	-- Lua 5.1
else
	_ENV = M		-- Lua 5.2
end

VERSION = "1.20.07.23"

authors = {
	"Frans Slothouber",
	"Jacco van Weert",
	"Petteri Kettunen",
	"Bernd Koesling",
	"Thomas Aglassinger",
	"Anthon Pang",
	"Stefan Kost",
	"David Druffner",
	"Sasha Vasko",
	"Kai Hofmann", 
	"Thierry Pierron",
	"Friedrich Haase",
	"Gergely Budai",
	"Milind Gupta"
}

local license = [[Distributed under the GNU GENERAL PUBLIC LICENSE
	TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
 See the source archive for a copy of the complete licence
 If you do not have it you can get it from URL
 http://www.gnu.org/copyleft/gpl.html
]] 

parser:option("--rc","Specify an alternate configuration file.")
	:default("robodoc.rc")
	:convert(globals.fileExists)
	:args(1)
	:count(1)
parser:flag("--debug","same as --tell, but with lots more details.")
	:action(function()
			globals.logger:setlevel("DEBUG")
		end)
parser:flag("--tell","ROBODoc will tell you what it is doing.")
parser:flag("--license","Print open source license information and exit.")
	:action(function()
			print(license)
			os.exit(0)
		end)
parser:flag("--version","Print version info and exit.")
	:action(function()
		print(VERSION)
		os.exit(0)
	end)
parser:mutex(
	parser:flag("--singledoc","All documentation directed to a single document given by the --doc option"),
	parser:flag("--singlefile","Generate documentation from a single source file specified by the --src option. Document specified by the --doc option."),
	parser:flag("--multidoc","Generate one document per source file, and copy the directory hierarchy.")
)
parser:flag("--no_subdirectories","Do no create documentation subdirectories.")
parser:flag("--one_file_per_header","Create a separate documentation file for each header")
parser:flag("--sections","Add sections and subsections.")
parser:flag("--internal","Also include internal headers.")
parser:flag("--ignore_case_when_linking","Ignore the case of the symbols when trying to create crosslinks.")
parser:flag("--internalonly","Only include internal headers.")
parser:flag("--toc","Add a table of contents.")
parser:flag("--index","Add an index.")
parser:flag("--nosource","Do not include SOURCE items.")
parser:flag("--nodesc","Do not descent into subdirectories.")
parser:flag("--nogeneratedwith","Do not add the 'generated by robodoc' message at the top of each documentation file.")
--parser:flag("--cmode","Use ANSI C grammar in source items (html only).")	-- Removed in the Lua version since we can specify keywords directly no need to hardcode C keywords
parser:flag("--lockheader","Recognize only one header marker per file.")
parser:flag("--footless","Do not create the foot of a document.")
parser:flag("--verbal","????????????????????????????????")	---- ################################################???????????????????????
parser:flag("--headless","Do not create the head of a document.")
parser:flag("--nopre","Do not use <PRE> </PRE> in the HTML output.")
parser:flag("--nosort","Do not sort the headers.")
parser:flag("--sectionnameonly","Generate section header with name only.")
parser:mutex(
	parser:flag("--syntaxcolors","Turn on all syntax highlighting features in SOURCE items"),
    parser:option("--syntaxcolors_enable","Enable only specific syntax highlighting features in SOURCE items (html only)")
		:args("1-6")
		:choices({"quotes","squotes","line_comments","block_comments","keywords","non_alpha"})
)
parser:flag("--source_line_numbers","Display original source line numbers for SOURCE items")
-- The below 2 should be added/handled by the latex generator module
--[[
parser:flag("--altlatex","Alternate LaTeX file format (bigger / clearer than normal)")
parser:flag("--latexparts",help="Make the first module level as PART in LaTeX output")
]]
parser:option("--charset","Add character encoding information."):args(1)
parser:option("--ext","Set extension for generated files."):args(1)
parser:option("--srcext","Set extension for source files."):args("+"):count(1)
-- The css option is removed from here since html will manage it
--parser.option("--css","Specify the stylesheet to use."):convert(io.open):args(1)
-- The following option for troff was removed. The troff exporter should handle it
--parsr:option("--compress","Only supported by TROFF output format. Defines by which program manpages will be compressed. Either bzip2 or gzip."):args(1):choices({"bzip2","gzip"})
parser:option("--mansection","Manual section where pages will be inserted (default: 3).")
	:default(3)
	:convert(tonumber)
	:args(1)
parser:option("--documenttitle","Set the document title")
parser:option("--first_section_level","Start the first section not at 1 but at level NUMBER.")
	:default(1)
	:convert(tonumber)
	:args(1)
-- doctype_name and doctype_location should be handled directly by the docbook generator
--[[
parser:option("--doctype_name","<!DOCTYPE> tag version"):args(1)
parser:option("--doctype_location","<!DOCTYPE> tag location information."):args(1)
]]
parser:option("--tabsize","Set the tab size."):convert(tonumber):args(1)
parser:option("--tabstops","Set TAB stops"):convert(tonumber):args("1-256")
parser:option("--masterindex","Specify the title and filename for master index page"):args(2)
parser:option("--sourceindex","Specify the title and filename for source files index page"):args(2)
--parser:option("--dotname","Specify the name (and path / options) of DOT tool","dot"):args(1)
parser:option("--header_breaks","Insert a linebreak after every NUMBER header names (default value: 2, set to zero to disable)")
	:default(2)
	:convert(tonumber)
	:args(1)
parser:option("--src","Source files root path or single file (for --singlefile option)")
	:args(1)
	:count(1)
	:convert(function(path)
		local p = globals.sanitizePath(path)
		local pf = globals.sanitizePath(path,true)
		if not globals.verifyPath(p) then
			-- maybe its a file
			if not globals.fileExists(pf) then
				return nil,"Invalid path or file."
			end
			return pf
		end
		return p
	end)
parser:option("--doc","Path of the documentation directory. Or the documentation file for --singedoc, --singlefile option")
	:args(1)
	:count(1)
	:convert(function(path)
		local p = globals.sanitizePath(path)
		local pf = globals.sanitizePath(path,true)
		if not globals.verifyPath(p) then
			-- Could be a file or invalid path
			if globals.fileExists(pf) then
				return nil,"File already exists."
			elseif not globals.fileCreatable(pf) then
				return nil,"Invalid path or file"
			end
			-- It is a file
			return pf
		end
		return p
	end)
	
