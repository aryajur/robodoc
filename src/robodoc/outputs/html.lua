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

function strcmp(a,b) return a==b end
local str
local in_linecomment = 0
local SOURCE_CLASS = "source"
local LINE_NUMBER_CLASS = "line_number"
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
function generateString(a_string)
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

--[[***f* HTML_Generator/RB_HTML_Generate_Color_String
 * NAME
 *   RB_HTML_Color_string -- generate vairous colored string.
 * SYNOPSIS
 ]]
 function colorString(open,class,a_string)
	--[[
	 * FUNCTION
	 * 
	 * SOURCE
	 ]]
	if(open==0) then  -- string,closing
		generateString(a_string)
		str=str+"</span>"
	elseif(open==1) then   --opening, string
		str=str+"<span class=\"" + class + "\""
		generateString(a_string)
	elseif(open==2) then	--opening, string, closing
		str=str+"<span class=\"" + class + "\""
		generateString(a_string)
		str=str+"</span>"
	end		 
end

--[[****f* HTML_Generator/RB_HTML_Generate_Line_Comment_End
 * FUNCTION
 *   Check if a line comment is active and generate ending sequence for it.
 *   Should be called at the end of each SOURCE line.
 * SYNOPSIS
 ]]
function generateLineCommentEnd()

    -- Check if we are in a line comment
    if ( in_linecomment == 1) then
        -- and end the line comment
        in_linecomment = 0
        colorString(in_linecomment, COMMENT_CLASS, "" );
	end
end


--[[***if* HTML_Generator/RB_HTML_Generate_Index_Shortcuts
 * NAME
 *   RB_HTML_Generate_Index_Shortcuts
 * FUNCTION
 *   Generates alphabetic shortcuts to index entries.
 * SYNOPSIS
 ]]
function generateIndexShortcuts()
	--[[
 * INPUTS
 *   o dest        -- the file to write to
 * TODO
 *   - Only list used letters.
 *   - List all letters (accented, signs, etc), not just the common ones.
 *   - Should be better to implement it as a <div> ?
 * SOURCE
 ]]
	local c
	str = str + "<h2>"

	for c = 97,122 do
		str = str + "<a href=\"#"+("").char(c)+"\">"
		generateChar(c)
		str = str + "</a> - "
	end

	for c = 0, 9 do
		str = str + "<a href=\"#"+("").char(c)+"\">"
		generateChar(""..c)
		str = str + "</a>"
		if (c != 9)
			str = str + " - "
		end
	end

	str = str + "</h2>\n"
end

function generateEmptyItem()
	str = str + "<br>\n"
end

--[[***f* HTML_Generator/RB_HTML_Generate_Link
 * NAME
 *   RB_HTML_Generate_Link --
 * SYNOPSIS
 ]]
function generateLink(cur_name,filename,labelname,linkname,classname)
--[[
 * INPUTS
 *   cur_doc  --  the file to which the text is written
 *   cur_name --  the name of the destination file
 *                (the file from which we link)
 *   filename --  the name of the file that contains the link
 *                (the file we link to)
 *   labelname--  the name of the unique label of the link.
 *   linkname --  the name of the link as shown to the user.
 * SOURCE
 ]]
	if(classname) then
		str = str + "<a class=\""+classname + "\""
	else
		str = str + "<a "
	end
	if( filename and strcmp(filename,cur_name)) then
		local varRelativeAddress = relativeAddress(cur_name,filename)
		str = str + "href=\"" + varRelativeAddress + "#" + labelname + "\">"
		generateString(linkname)
		str = str + "</a>"
	else
		str = str + "href=\"#" +labelname + "\">" 
		generateString(linkname)
		str = str + "</a>"
	end
end

--[[***f* HTML_Generator/RB_HTML_RelativeAddress
 * FUNCTION
 *   Link to 'that' from 'this' computing the relative path.  Here
 *   'this' and 'that' are both paths.  This function is used to
 *   create links from one document to another document that might be
 *   in a completely different directory.
 * SYNOPSIS
 ]]
function relativeAddress(thisname,thatname)
	--[[
 * EXAMPLE
 *   The following two
 *     this /sub1/sub2/sub3/f.html
 *     that /sub1/sub2/g.html
 *   result in 
 *     ../g.html
 *
 *     this /sub1/f.html
 *     that /sub1/sub2/g.html
 *     ==
 *     ./sub2/g.html
 *
 *     this /sub1/f.html
 *     that /sub1/g.html
 *     ==
 *     ./g.html
 *
 *     this /sub1/doc3/doc1/tt.html
 *     that /sub1/doc5/doc2/qq.html
 *     ==
 *     ../../doc5/doc2/qq.html
 *
 * NOTES
 *   Notice the execelent docmentation.
 * SOURCE
 ]]
	local relative = ""
	relative[0] = '\0'

	assert(thisname)
	assert(thatname)

	return relative
	
end


function generateBeginContent()

    generateDiv( "content" )
end

function generateEndContent()

    generateDivEnd("content" )
end

function generateBeginNavigation()

    generateDiv( "navigation" )
end

void generateEndNavigation()
	generateDivEnd("navigation" )
end

function generateBeginExtra()
	generateDiv("extra" );
end

function generateEndExtra()
	generateDivEnd("extra")
end


function generateItemName(name)
	str=str+"<p class=\"item_name\">"
	generateString(name)
	str=str+"</p>"
end

function insertCSS(filename) 
	if(css_name) then
		varRelativeAddress = relativeAddress(filename,css_name)
		assert(varRelativeAddress)
		assert(strlen(varRelativeAddress))
		str = str + "<link rel=\"stylesheet\" href=\""+varRelativeAddress+"\" type=\"text/css\" />\n"
	end
end


function generateBeginParagraph()
	str=str+"<p>"
end

function generateEndParagraph()
	str=str+"</p>\n"
end

function generateBeginPreformatted(source)
	if(source) then
		str=str+"<pre class=\""+SOURCE_CLASS+"\">"
	else
		str=str+"<pre>"
	end
end

function generateEndPerformatted()
	str = str + "</pre>\n"
end

function generateBeginList()
	str = str + "<ul>"
end

function generateEndList()
	str = str + "</ul>\n"
end

function generateBeginListItem()
	str = str + "<li>"
end

function generateEndListItem()
	str = str + "</li>\n"
end


--[[***f* HTML_Generator/RB_HTML_Generate_Item_Line_Number
 * FUNCTION
 *   Generate line numbers for SOURCE like items
 * SYNOPSIS
 ]]
function generateItemLineNumber(lineNumberString)
--[[
 * INPUTS
 *   o line_number_string -- the line number as string.
 * SOURCE
 ]]
	colorString(2,LINE_NUMBER_CLASS,lineNumberString)
end

