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
			if(cur_filename.link) then
				if(document.actions.do_one_file_per_header) then
					dest_doc:write("<li><tt>\n" )
					GenerateString(dest_doc, cur_filename.name)
					dest_doc:write("</tt></li>\n")
				else
					r = RelativeAddress(dest_name, cur_filename.link.file_name)
					dest_doc:write("<li>\n")
					dest_doc:write("<a href=\""..r.."#"..cur_filename.link.label_name.."\"><tt>\n")
					GenerateString(dest_doc, cur_filename.name)
					dest_doc:write("</tt></a></li>\n")
				end
			end
		end
	end
	for cur_path = 0, #srctree do
		if(srctree[cur_path] == parent_path) then
			dest_doc:write("<li>\n")
			GenerateString(dest_doc, cur_path.name)
			GenerateSourceTreeEntry(dest_doc, dest_name, cur_path, srctree, document)
			dest_doc:write("</li>\n")
		end	
	end
	dest_doc:write("</ul>\n")
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
		cssfile = cssfile.."robodoc.css"
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
			" *   Generated with ROBODoc.\n"
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
			" *   Generated with the Strange Banana stylesheet generator.\n"
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
function GenerateDocStart(dest_doc, src_name, name, dest_name, charset)
--[[
 * INPUTS
 *   o dest_doc  --  the output file.
 *   o src_name  --  The file or directoryname from which 
 *                   this document is Generated.
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
		InsertCSS(dest_doc,dest_name)
		dest_doc:write("<title>"..name.."</title>\n")
		dest_doc:write("<!-- Source: "..src_name.." -->\n")

		if (course_of_action.do_nogenwith) then
		else
			-- copyright comment
		end
		dest_doc:write("</head>\n")
		dest_doc:write("<body>\n")

	end
	GenerateDiv(dest_doc, "logo")
	dest_doc:write("<a name=\"robo_top_of_doc\">")
	if(document_title) then
		GenerateString(dest_doc, document_title)
	end
	dest_doc:write("</a>\n")
	GenerateDivEnd(dest_doc, "logo")

end

function InsertCSS(dest_doc,filename)
	if(css_name) then
		if(filename) then
			dest_doc:write("<link rel=\"stylesheet\" href=\""..filename.."\" type=\"text/css\" />\n")
		end
	end
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

function GenerateDiv(dest_doc, id)
--[[
 * INPUTS
 *   o id -- id Attribute of the div
 * SEE ALSO
 *   RB_HTML_Generate_DivEnd()
 * SOURCE
 ]]
	dest_doc:write("<div id=\""..id.."\">\n")
end


--[[***f* HTML_Generator/RB_HTML_Generate_DivEnd
 * FUNCTION
 *   Write a DivEnd to the destination document
 * SYNOPSIS
 ]]

 function GenerateDivEnd(dest_doc, id)
--[[
 * INPUTS
 *   o id -- id Attirbute of the div
 * SEE ALSO
 *   RB_HTML_Generate_DivEnd()
 * SOURCE
 ]]
	dest_doc:write("</div><!----"..id.."--->\n")
end


--[[***f* HTML_Generator/RB_HTML_Generate_String
 * FUNCTION
 *   Write a string to the destination document, escaping
 *   characters where necessary.
 * SYNOPSIS
 ]]
function GenerateString(dest_doc, a_string)
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
        GenerateChar(dest_doc, c);
	end
end


--[[***f* HTML_Generator/RB_HTML_Generate_Char
 * NAME
 *   RB_HTML_Generate_Char -- Generate a single character for an item.
 * SYNOPSIS
 ]]
function GenerateChar(dest_doc, c)
--[[
 * FUNCTION
 *   This function is called for every character that goes
 *   into an item's body.  This escapes all the reserved
 *   HTML characters such as '&', '<', '>', '"'.
 * SOURCE
 ]]

 	local switch = { 
		['\n'] = function()	-- for case '\n'
			dest_doc:write("")
    	end,
    	['\t'] = function()	-- for case '\t'
        	dest_doc:write("")
    	end,
		['<'] = function()	-- for case '<'
			dest_doc:write("&lt")
		end,
		['>'] = function()  -- for case '<'
			dest_doc:write("&gt")
		end,
		['&'] = function()  -- for case '&'
			dest_doc:write("&amp")
		end
	}
	
	local f = switch[c]
	if (f) then
		f()
	else    
		dest_doc:write(c)               --for default
	end
end

--[[***if* HTML_Generator/RB_HTML_Generate_False_Link
 * FUNCTION
 *   Create a representation for a link that links an word in
 *   a header to the header itself.
 * SYNOPSIS
 ]]
function GenerateFalseLink(dest_doc, name )
--[[
 * INPUTS
 *   * dest_doc -- the file the representation is written to.
 *   * name     -- the word.
 * SOURCE
]]
	dest_doc:write("<strong>")
	GenerateString(dest_doc, name)
	dest_doc:write("</strong>")
end

--[[***f* HTML_Generator/RB_HTML_Generate_Color_String
 * NAME
 *   RB_HTML_Color_string -- Generate vairous colored string.
 * SYNOPSIS
 ]]
 function colorString( dest_doc, open, class, a_string)
	--[[
	 * FUNCTION
	 * 
	 * SOURCE
	 ]]
	if(open==0) then  -- string,closing
		GenerateString(dest_doc, a_string)
		dest_doc:write("</span>")
	elseif(open==1) then   --opening, string
		dest_doc:write("<span class=\""..class.."\"")
		GenerateString(dest_doc, a_string)
	elseif(open==2) then	--opening, string, closing
		dest_doc:write("<span class=\""..class.."\"")
		GenerateString(dest_doc, a_string)
		dest_doc:write("</span>")
		-----------------------------------------TODO ------------
	elseif(open==3) then    -- opening, char, closing
		dest_doc:write("<span class=\""..class.."\">")
		GenerateString(dest_doc, a_string)  -------todo--review -----
		dest_doc:write("</span>")
	end		 
end

--[[****f* HTML_Generator/RB_HTML_Generate_Line_Comment_End
 * FUNCTION
 *   Check if a line comment is active and Generate ending sequence for it.
 *   Should be called at the end of each SOURCE line.
 * SYNOPSIS
 ]]
function GenerateLineCommentEnd(dest_doc)

    -- Check if we are in a line comment
    if ( in_linecomment == 1) then
        -- and end the line comment
        in_linecomment = 0
        colorString(dest_doc, in_linecomment, COMMENT_CLASS, "" );
	end
end


--[[***if* HTML_Generator/RB_HTML_Generate_Index_Shortcuts
 * NAME
 *   RB_HTML_Generate_Index_Shortcuts
 * FUNCTION
 *   Generates alphabetic shortcuts to index entries.
 * SYNOPSIS
 ]]
function GenerateIndexShortcuts(dest_doc)
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
	dest_doc:write("<h2>")

	for c = 97,122 do
		dest_doc:write("<a href=\"#"..("").char(c).."\">")
		GenerateChar(dest_doc, c)
		dest_doc:write("</a> - ")
	end

	for c = 0, 9 do
		dest_doc:write("<a href=\"#"..("").char(c).."\">")
		GenerateChar(dest_doc, ""..c)
		dest_doc:write("</a>")
		if (c != 9)
			dest_doc:write(" - ")
		end
	end
	dest_doc:write("</h2>\n")
end

function GenerateEmptyItem(dest_doc)
	dest_doc:write("<br>\n")
end

--[[***f* HTML_Generator/RB_HTML_Generate_Link
 * NAME
 *   RB_HTML_Generate_Link --
 * SYNOPSIS
 ]]
function GenerateLink(dest_doc, cur_name,filename,labelname,linkname,classname)
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
		dest_doc:write("<a class=\""..classname.."\"")
	else
		dest_doc:write("<a ")
	end
	if( filename and strcmp(filename,cur_name)) then
		local varRelativeAddress = relativeAddress(cur_name,filename)
		dest_doc:write("href=\""..varRelativeAddress.."#"..labelname.."\">")
		GenerateString(cur_doc, linkname)
		dest_doc:write("</a>")
	else
		dest_doc:write("href=\"#"..labelname.."\">") 
		GenerateString(cur_doc, linkname)
		dest_doc:write("</a>")
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


function GenerateBeginContent(dest_doc)

    GenerateDiv( dest_doc, "content" )
end

function GenerateEndContent(dest_doc)

    GenerateDivEnd(dest_doc, "content" )
end

function GenerateBeginNavigation(dest_doc)

    GenerateDiv( dest_doc, "navigation" )
end

function GenerateEndNavigation(dest_doc)
	GenerateDivEnd(dest_doc, "navigation" )
end

function GenerateBeginExtra(dest_doc)
	GenerateDiv(dest_doc, "extra" );
end

function GenerateEndExtra(dest_doc)
	GenerateDivEnd( dest_doc, "extra")
end


function GenerateItemName(dest_doc, name)
	dest_doc:write("<p class=\"item_name\">")
	GenerateString(dest_doc, name)
	dest_doc:write("</p>")
end

function insertCSS(dest_doc, filename) 
	if(css_name) then
		varRelativeAddress = relativeAddress(filename,css_name)
		assert(varRelativeAddress)
		assert(strlen(varRelativeAddress))
		dest_doc:write("<link rel=\"stylesheet\" href=\""..varRelativeAddress.."\" type=\"text/css\" />\n")
	end
end


function GenerateBeginParagraph(dest_doc)
	dest_doc:write("<p>")
end

function GenerateEndParagraph(dest_doc)
	dest_doc:write("</p>\n")
end

function GenerateBeginPreformatted(dest_doc, source)
	if(source) then
		dest_doc:write("<pre class=\""..SOURCE_CLASS.."\">")
	else
		dest_doc:write("<pre>")
	end
end

function GenerateEndPerformatted(dest_doc)
	dest_doc:write("</pre>\n")
end

function GenerateBeginList(dest_doc)
	dest_doc:write("<ul>") 
end

function GenerateEndList(dest_doc)
	dest_doc:write("</ul>\n")
end

function GenerateBeginListItem(dest_doc)
	dest_doc:write("<li>")
end

function GenerateEndListItem(dest_doc)
	dest_doc:write("</li>\n")
end


--[[***f* HTML_Generator/RB_HTML_Generate_Item_Line_Number
 * FUNCTION
 *   Generate line numbers for SOURCE like items
 * SYNOPSIS
 ]]
function GenerateItemLineNumber(dest_doc, lineNumberString)
--[[
 * INPUTS
 *   o line_number_string -- the line number as string.
 * SOURCE
 ]]
	colorString(dest_doc, 2, LINE_NUMBER_CLASS, lineNumberString)
end


function GenerateNavBarOneFilePerHeader(document, current_doc, current_header )
	current_filename = GetFullDocname(current_header.owner.filename)
	target_filename = GetFullDocname(current_header.owner.filename)
	label = GetFullname(current_header.owner.filename)
	if(current_header.parent) then
		target_filename = GetFullDocname(current_header.parent.owner.filename)
		label = current_header.parent.unique_name
		label_name = current_header.parent.function_name
		GenerateLink(current_doc, current_filename, target_filename, label, label_name, "menutiem")
	end
	-- FS TODO  one_file_per_header without   index is not logical
	if( (course_of_action.do_index ) and (course_of_action.do_multidoc)) then
		target_filename = GetSubIndexFileName(document.docroot.name, docuement.extension, current_header.htype)
		label_name = current_header.htype.indexName
		GenerateLink(current_doc, current_filename, target_filename, "robo_top_of_doc", label_name, "menuitem")
	end
end

function GenerateHeaderStart(dest_doc, cur_header)
	if(cur_header.name and cur_header.filename) then
		dest_doc:write("<hr />\n")
		GenerateLabel(dest_doc, cur_header.name)
		dest_doc:write("<a name=\""..cur_header.unique_name.."\"></a><h2>")
		header_type = FindHeaderType(cur_header.htype.typeCharacter)
		for i=1, #cur_header.names do
			-- If Section names only, do not print module name
			if(i==1 and course_of_action.do_sectionsnameonly) then
				GenerateString(dest_doc,cur_header.functioin_name)
			else
				GenerateString(dest_doc, cur_header.names[i-1])
			end
            -- Break lines after a predefined number of header names
			if(i < #cur_header.names) then
				if(i % header_breaks) then
					dest_doc:write(", ")
				else
					dest_doc:write(",<br />")
				end
			end
		end
		-- Print header type (if available and not Section names only)
		if(header_type and !(course_of_action.do_sectionsnameonly)) then
			dest_doc:write(" [ ")
			GenerateString(dest_doc, header_type.indexName)
			dest_doc:write(" ] ")
		end
		dest_doc:write("</h2>\n\n")
end

--[[***f* HTML_Generator/RB_HTML_Generate_IndexMenu
 * FUNCTION
 *   Generates a menu to jump to the various master index files for
 *   the various header types.  The menu is generated for each of the
 *   master index files.  The current header type is highlighted.
 * SYNOPSIS
 ]]
function GenerateIndexMenu(dest_doc, filename, document, cur_type )
--[[
 * INPUTS
 *   * dest_doc       -- the output file.
 *   * filename       -- the name of the output file
 *   * document       -- the gathered documention.
 *   * cur_headertype -- the header type that is to be highlighted.
 ******
 ]]
	GenerateLink(dest_doc, filename, TOCIndexFilename(document), "top", "Table of Contents", "menuitem")
	dest_doc:write("\n")
	for type_char = MIN_HEADER_TYPE,MAX_HEADER_TYPE do
		header_type = RB_FindHeaderType(type_char)
		if(header_type) then
			local n = NumberOfLinks(header_type, nil, false) + NumberOfLinks(header_type,	nil, true)
			if ( n ) then
				targetfilename = GetSubIndexFileName(document.docroot.name,document.ext,header_type)
				assert(targetfilename)
				GenerateLink(dest_doc, filename, targetfilename, "top", header_type.indexName, "menuitem")
				dest_doc:write("\n")
			end			
		end
	end
end

--[[***f* Generator/RB_Generate_TOC_2
 * FUNCTION
 *   Create a Table of Contents based on the headers found in
 *   _all_ source files.   There is also a function to create
 *   a table of contents based on the headers found in a single
 *   source file RB_Generate_TOC_1
 * SYNOPSIS
 ]]
function GenerateTOC2(dest_doc, headers, count, owner, dest_name)
 --[[
 * INPUTS
 *   * dest_doc -- the destination file.
 *   * headers  -- an array of pointers to all the headers.
 *   * count    -- the number of pointers in the array.
 *   * output_mode -- global with the current output mode.
 *   * owner    -- The owner of the TOC. Only the headers that are owned
 *               by this owner are included in the TOC.  Can be NULL,
 *               in which case all headers are included.
 * SOURCE
 ]]
	for i=0,MAX_SECTION_DEPTH do  --todo------------
		sectiontoc_counters[i]= 0;
	end
	dest_doc:write("<h3>TABLE OF CONTENTS</h3>\n")
	if(course_of_action.do_sections) then
		--[[ --sections was specified, create a TOC based on the
         * hierarchy of the headers.
		 ]]
		dest_doc:write("<ul>\n")
		for i=0, count do
			header = headers[i]
			if(owner == nil) then
				if(header.parent) then
					-- Will be done in the subfunction --
				else
					GenerateTOCSection(dest_doc, dest_name, header, headers, count, depth)
				end
			else
				--[[ This is the TOC for a specific RB_Part (MultiDoc
                 * documentation). We only include the headers that
                 * are part of the subtree. That is, headers that are
                 * parth the RB_Part, or that are childern of the
                 * headers in the RB_Part.
				 ]]
				if( header.owner == owner) then
					
                    --[[ Any of the parents of this header should not
                     * have the same owner as this header, otherwise
                     * this header will be part of the TOC multiple times.
					 ]]
					 local no_bad_parent = true
					 local parent = header.parent
					 for i=0, #parent do ----------todo------------
						 if(parent.owner == owner) then
							 no_bad_parent = false
							 break
						 end
					 end
					 if (no_bad_parent) then
						 GenerateTOCSection(dest_doc, dest_name, header, headers, count, depth)
					 end
				end
			end
		end
		dest_doc:write("</ul>\n")
	else
		--[[ No --section option, generate a plain, one-level
         * TOC
		 ]]
		dest_doc:write("<ul>\n")
		for i=0, count do
			header = headers[i]   --------todo---------
			if(header.name and header.functioin_name and ((owner == nil) or ( header.owner == owner))) then
				for j=0, #header.no_names do
					dest_doc:write("<li>")
					GenerateLink(dest_doc, header.filename, header.unique_name, header.names[j], 0)
					dest_doc:write(<"</li>\n")
				end
			end
		end
		dest_doc:write("</ul>\n")
	end
end

--[[***f* HTML_Generator/RB_HTML_Generate_Label
 * FUNCTION
 *   Generate a label (name) that can be refered too.
 *   A label should consist of only alphanumeric characters so
 *   all 'odd' characters are replaced with their ASCII code in
 *   hex format.
 * SYNOPSIS
 ]]
function GenerateLabel(dest_doc, name )
--[[
 * INPUTS
 *   o dest_doc -- the file to write it to.
 *   o name     -- the name of the label.
 * SOURCE
 ]]

	local len = strlen(name)
	dest_doc:write("<a name=\"")
	for i=0, len do
		c = name[i]
		--- todo ----
		if(utf8_isalnum(c)) then
			GenerateChar(dest_doc,c)
		else
			----todo---

		end
	end
	dest_doc:write("\"></a>\n")
end

function GenerateNavBar(dcument, current_doc, current_header)
	current_filename = GetFullDocname(current_header.owner.filename)
	target_filename = GetFullDocname(current_header.owner.filename)
	label = GetFullname(current_header.owner.filename)
	-- Then navigation bar
	current_doc:write("<p>")
	current_doc:write("[ ")
	GenerateLink(current_doc, current_filename, nil, "robo_top_of_doc", "Top", 0)
	current_doc:write(" ] ")

	-- [ "Parentname" ]
	if( current_header.parent) then
		current_doc:write("[ ")
		target_filename = GetFullDocname(current_header.parent.owner.filename)
		label = current_header.parent.unique_name
		label_name = current_header.parent.function_name
		GenerateLink(current_doc, current_filename, target_filename, label, label_name, 0)
		current_doc:write(" ] ")
	end
	current_doc:write("[ ")
	label_name = current_header.htype.indexName
	if( ( course_of_action.do_index) and (course_of_action.do_multidoc)) then
		target_filename = GetSubIndexFileName(document.docroot.name, document.extension, current_header.htype)
		GenerateLink(curren_doc, current_filename, target_filename, "robo_top_of_doc", label_name, 0)
	else
		GenerateString(current_doc, label_name)
	end
	current_doc:write(" ]</p>\n")
end

function GenerateDocEnd(dest_doc, name, src_name)
	GenerateDiv(dest_doc, "footer")
	if(course_of_action.do_nogenwith) then
		dest_doc:write("<p>Generated from "..src_name.." on ")
		TimeStamp(dest_doc)
		dest_doc:write("</p>\n")
	else
		dest_doc:write("<p>Generated from"..src_name.." with <a href=\"http://www.xs4all.nl/~rfsber/Robo/robodoc.html\">ROBODoc</a> V"..VERSION.." on ") 
		TimeStamp(dest_doc)
		dest_doc:write("</p>\n")
	end
	GenerateDivEnd(dest_doc, "footer")
	if(course_of_action.do_footless) then
	else
		dest_doc:write("</body>\n</html>\n")
	end
end