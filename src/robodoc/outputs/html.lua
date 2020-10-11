-- HTML Generation module as done in original Robodoc

--[[***h* ROBODoc/HTML_Generator
 * FUNCTION
 *   The generator for HTML output.
 *
 *   The generator supports sections upto 7 levels deep.  It supports
 *   a Table of Contents based on all headers.  A masterindex for
 *   all headertypes and seperate masterindexes for each headertype.
 *
 * MODIFICATION HISTORY
 *  
 *   
 ]]

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



 --[[***v* Globals/course_of_action [2.0]
 * NAME
 *   course_of_action
 * FUNCTION
 *   Global Variable that defines the course of action.
 * SOURCE
 ]]
 course_of_action = nil

 
function TOCIndexFilename(document)
	toc_index_name = "toc_index.html"
	toc_index_path = document.docroot.name
	toc_index_path = toc_index_path..toc_index_name
	return toc_index_name
end


function GenerateSourceTreeEntry(dest_doc, dest_name, parent_path, srctree, document )
	local cur_path
	local cur_filename
	dest_doc:write("<ul>\n")
	cur_filename = srctree
	for i=0,#srctree do
		if(cur_filename[i].path == parent_path) then
			if(cur_filename.link)
		end
	end
	----------- to do -------------
end

function GenerateSourceTree(dest_doc, dest_name, document)
	GenerateSourceTreeEntry(dest_doc, dest_name,nil, srctree, document)
end


--[[***if* HTML_Generator/RB_HTML_Generate_False_Link
 * FUNCTION
 *   Create a representation for a link that links an word in
 *   a header to the header itself.
 * SYNOPSIS
]]
function Generate_False_Link(dest_doc, name )
--[[
 * INPUTS
 *   * dest_doc -- the file the representation is written to.
 *   * name     -- the word.
 * SOURCE
]]
	dest_doc:write("<strong>")
	GenerateString( dest_doc, name );
	dest_doc:write("</strong>")
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
	local cssfile = ""

	if(document.action.do_multidoc) then
		cssfile = string.copy(document.docroot)
		cssfile = cssfile + "robodoc.css"
	end

	if(document.css) then
		-- The user specified its own css file,
        -- so we use the content of that.
		local docCss = io.open(document.css,"r")
		local data = docCss:read("*a");
		docCss:close()
		local CssfileVar = io.open(cssfile,"w")
		CssfileVar:write(data)
		CssfileVar:close();
	else
		local CssfileVar = io.open(cssfile,"w")
		if(CssfileVar) then
			CssfileVar:write("/****h* ROBODoc/ROBODoc Cascading Style Sheet\n"
			" * FUNCTION\n"
			" *   This is the default cascading style sheet for documentation\n"
			" *   generated with ROBODoc.\n"
			" *   You can edit this file to your own liking and then use\n"
			" *   it with the option\n"
			" *      --css <filename>\n"
			" *\n"
			" *   This style-sheet defines the following layout\n"
			" *      +----------------------------------------+\n"
			" *      |    logo                                |\n"
			" *      +----------------------------------------+\n"
			" *      |    extra                               |\n"
			" *      +----------------------------------------+\n"
			" *      |                              | navi-   |\n"
			" *      |                              | gation  |\n"
			" *      |      content                 |         |\n"
			" *      |                              |         |\n"
			" *      +----------------------------------------+\n"
			" *      |    footer                              |\n"
			" *      +----------------------------------------+\n"
			" *\n"
			" *   This style-sheet is based on a style-sheet that was automatically\n"
			" *   generated with the Strange Banana stylesheet generator.\n"
			" *   See http://www.strangebanana.com/generator.aspx\n"
			" *\n"
			" ******\n"
			" * $Id: html_generator.c,v 1.93 2008/03/13 10:34:50 thuffir Exp $\n"
			" */\n"
			"\n"
			"body\n"
			"{\n"
			"    background-color:    rgb(255,255,255);\n"
			"    color:               rgb(98,84,55);\n"
			"    font-family:         Arial, serif;\n"
			"    border-color:        rgb(226,199,143);\n"
			"}\n"
			"\n"
			"pre\n"
			"{\n"
			"    font-family:      monospace;\n"
			"    margin:      15px;\n"
			"    padding:     5px;\n"
			"    white-space: pre;\n"
			"    color:       #000;\n"
			"}\n"
			"\n"
			"pre.source\n"
			"{\n"
			"    background-color: #ffe;\n"
			"    border: dashed #aa9 1px;\n"
			"}\n"
			"\n"
			"p\n"
			"{\n"
			"    margin:15px;\n"
			"}\n"
			"\n"
			"p.item_name \n"
			"{\n"
			"    font-weight: bolder;\n"
			"    margin:5px;\n"
			"    font-size: 120%%;\n"
			"}\n"
			"\n"
			"#content\n" "{\n" "    font-size:           100%%;\n")

			CssfileVar:write("    color:               rgb(0,0,0);\n"
			"    background-color:    rgb(255,255,255);\n"
			"    border-left-width:   0px; \n"
			"    border-right-width:  0px; \n"
			"    border-top-width:    0px; \n"
			"    border-bottom-width: 0px;\n"
			"    border-left-style:   none; \n"
			"    border-right-style:  none; \n"
			"    border-top-style:    none; \n"
			"    border-bottom-style: none;\n"
			"    padding:             40px 31px 14px 17px;\n"
			"    border-color:        rgb(0,0,0);\n"
			"    text-align:          justify;\n"
			"}\n"
			"\n"
			"#navigation\n"
			"{\n"
			"    background-color: rgb(98,84,55);\n"
			"    color:            rgb(230,221,202);\n"
			"    font-family:      \"Times New Roman\", serif;\n"
			"    font-style:       normal;\n"
			"    border-color:     rgb(0,0,0);\n"
			"}\n"
			"\n"
			"a.menuitem\n"
			"{\n"
			"    font-size: 120%%;\n"
			"    background-color:    rgb(0,0,0);\n"
			"    color:               rgb(195,165,100);\n"
			"    font-variant:        normal;\n"
			"    text-transform:      none;\n"
			"    font-weight:         normal;\n"
			"    padding:             1px 8px 3px 1px;\n"
			"    margin-left:         5px; \n"
			"    margin-right:        5px; \n"
			"    margin-top:          5px; \n"
			"    margin-bottom:       5px;\n"
			"    border-color:        rgb(159,126,57);\n"
			"    text-align:          right;\n"
			"}\n"
			"\n"
			"#logo, #logo a\n"
			"{\n"
			"    font-size: 130%%;\n"
			"    background-color:   rgb(198,178,135);\n"
			"    color:              rgb(98,84,55);\n"
			"    font-family:        Georgia, serif;\n"
			"    font-style:         normal;\n"
			"    font-variant:       normal;\n"
			"    text-transform:     none;\n"
			"    font-weight:        bold;\n"
			"    padding:            20px 18px 20px 18px;\n"
			"    border-color:       rgb(255,255,255);\n"
			"    text-align:         right;\n"
			"}\n"
			"\n"
			"#extra, #extra a\n"
			"{\n"
			"    font-size: 128%%;\n"
			"    background-color:    rgb(0,0,0);\n"
			"    color:               rgb(230,221,202);\n"
			"    font-style:          normal;\n"
			"    font-variant:        normal;\n"
			"    text-transform:      none;\n"
			"    font-weight:         normal;\n" )
			CssfileVar:write("    border-left-width:   0px; \n"
			"    border-right-width:  0px; \n"
			"    border-top-width:    0px; \n"
			"    border-bottom-width: 0px;\n"
			"    border-left-style:   none; \n"
			"    border-right-style:  none; \n"
			"    border-top-style:    none; \n"
			"    border-bottom-style: none;\n"
			"    padding: 12px 12px 12px 12px;\n"
			"    border-color:        rgb(195,165,100);\n"
			"    text-align:          center;\n"
			"}\n"
			"\n"
			"#content a\n"
			"{\n"
			"    color:              rgb(159,126,57);\n"
			"    text-decoration:    none;\n"
			"}\n"
			"\n"
			"#content a:hover, #content a:active\n"
			"{\n"
			"    color:              rgb(255,255,255);\n"
			"    background-color:   rgb(159,126,57);\n"
			"}\n"
			"\n"
			"a.indexitem\n"
			"{\n"
			"    display: block;\n"
			"}\n"
			"\n"
			"h1, h2, h3, h4, h5, h6\n"
			"{\n"
			"    background-color: rgb(221,221,221);\n"
			"    font-family:      Arial, serif;\n"
			"    font-style:       normal;\n"
			"    font-variant:     normal;\n"
			"    text-transform:   none;\n"
			"    font-weight:      normal;\n"
			"}\n"
			"\n"
			"h1\n"
			"{\n"
			"    font-size: 151%%;\n"
			"}\n"
			"\n"
			"h2\n"
			"{\n"
			"    font-size: 142%%;\n"
			"}\n"
			"\n"
			"h3\n"
			"{\n"
			"    font-size: 133%%;\n"
			"}\n"
			"\n"
			"h4\n"
			"{\n"
			"    font-size: 124%%;\n"
			"}\n"
			"\n"
			"h5\n"
			"{\n"
			"    font-size: 115%%;\n"
			"}\n"
			"\n"
			"h6\n"
			"{\n"
			"    font-size: 106%%;\n"
			"}\n"
			"\n"
			"#navigation a\n"
			"{\n"
			"    text-decoration: none;\n"
			"}\n"
			"\n"
			".menuitem:hover\n"
			"{\n"
			"    background-color:   rgb(195,165,100);\n"
			"    color:              rgb(0,0,0);\n"
			"}\n"
			"\n"
			"#extra a\n"
			"{\n"
			"    text-decoration: none;\n"
			"}\n"
			"\n"
			"#logo a\n"
			"{\n"
			"    text-decoration: none;\n"
			"}\n"
			"\n"
			"#extra a:hover\n"
			"{\n"
			"}\n"
			"\n"
			"/* layout */\n"
			"#navigation\n"
			"{\n"
			"    width:       22%%; \n"
			"    position:    relative; \n"
			"    top:         0; \n"
			"    right:       0; \n"
			"    float:       right; \n"
			"    text-align:  center;\n"
			"    margin-left: 10px;\n"
			"}\n"
			"\n"
			".menuitem       {width: auto;}\n"
			"#content        {width: auto;}\n"
			".menuitem       {display: block;}\n" "\n" "\n")
			CssfileVar:write(                     "div#footer\n"
			"{\n"
			"    background-color: rgb(198,178,135);\n"
			"    color:      rgb(98,84,55);\n"
			"    clear:      left;\n"
			"    width:      100%%;\n"
			"    font-size:   71%%;\n"
			"}\n"
			"\n"
			"div#footer a\n"
			"{\n"
			"    background-color: rgb(198,178,135);\n"
			"    color:            rgb(98,84,55);\n"
			"}\n"
			"\n"
			"div#footer p\n"
			"{\n"
			"    margin:0;\n"
			"    padding:5px 10px\n"
			"}\n"
			"\n"
			"span.keyword\n"
			"{\n"
			"    color: #00F;\n"
			"}\n"
			"\n"
			"span.comment\n"
			"{\n"
			"    color: #080;\n"
			"}\n"
			"\n"
			"span.quote\n"
			"{\n"
			"    color: #F00;\n"
			"}\n"
			"\n"
			"span.squote\n"
			"{\n"
			"    color: #F0F;\n"
			"}\n"
			"\n"
			"span.sign\n"
			"{\n"
			"    color: #008B8B;\n"
			"}\n"
			"\n"
			"span.line_number\n"
			"{\n"
			"    color: #808080;\n"
			"}\n"
			"\n"
			"@media print\n"
			"{\n"
			"    #navigation {display: none;}\n"
			"    #content    {padding: 0px;}\n"
			"    #content a  {text-decoration: underline;}\n"
			"}\n" )

			CssfileVar:close()

		else
			logger:warn("can't open css file file")
		end
	end
	
end

--[[***f* HTML_Generator/RB_HTML_Generate_Doc_Start
 * NAME
 *   RB_HTML_Generate_Doc_Start --
 * FUNCTION
 *   Generate the first part of a HTML document.
 *   As far as ROBODoc is concerned a HTML document
 *   consists of three parts:
 *   * The start of a document
 *   * The body of a document
 *   * The end of a document
 * SYNOPSIS
 ]]
function htmlGenerateDocStart(dest_doc, src_name, name, dest_name, charset)
--[[
 * INPUTS
 *   o dest_doc  --  the output file.
 *   o src_name  --  The file or directoryname from which 
 *                   this document is generated.
 *   o name      --  The title for this document
 *   o dest_name --  the name of the output file.
 *   o charset   --  the charset to be used for the file.
 * SOURCE
 ]]
	if(course_of_action.do_headless) then
		-- The user wants a headless document, so we skip everything
        -- upto and until <BODY>
	else
		dest_doc:write("<?xml version=\"1.0\" encoding=\"%s\"?>\n")
		dest_doc:write("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n")
		dest_doc:write("                      \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n")
		dest_doc:write("<html  xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">\n" )
		dest_doc:write("<head>\n")
		dest_doc:write("<meta http-equiv=\"Content-Style-Type\" content=\"text/css\" />\n")
		dest_doc:write("<meta http-equiv=\"Content-type\" content=\"text/html; charset=%s\" />\n")

	end

end

function RBInsertCSS(dest_doc,filename)
	if()
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
 function colorString( open, class, a_string)
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


--- todo ---
function GenerateNavBarOneFilePerHeader(document, current_doc, current_header )

end


