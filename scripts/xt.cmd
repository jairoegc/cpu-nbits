* Lab-4 Extracting a LEF/DEF Database
* ===================================

LEF_FILE		: tech.lef cells.lef
TOP_DEF_FILE		: toprt.def

BLOCK			: toprt
MAPPING_FILE		: xt.mapping

NETLIST_FORMAT		: SPEF
NETLIST_FILE		: toprt.SPEF 

STAR_DIRECTORY 		: ./star 
EXTRACTION		: RC
COUPLE_TO_GROUND	: NO 

SIMULTANEOUS_MULTI_CORNER: YES
CORNERS_FILE: corners.txt
SELECTED_CORNERS: typ