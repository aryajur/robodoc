-- Robodoc translation to Lua

-- Use the Lua Logging library for logging messages
local log_console = require"logging.console"

local logger = log_console()
logger:setLevel("INFO")

-- Using argparse module https://github.com/luarocks/argparse
local ap = require("argparse")
parser = ap()	-- Create a parser


local info = require("robodoc.info")	-- Also sets up command line arguments using argparse
local config = require("robodoc.config")


-- Command line arguments
whoami = arg[0]
args = parser:parse()


-- Actions
actions = {
	do_nosort = true,
	do_nodesc = true,
    do_toc= true,
    do_include_internal= true,
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

config.readConfigFile(args.rc)	-- read the configuration file given by the name rc

