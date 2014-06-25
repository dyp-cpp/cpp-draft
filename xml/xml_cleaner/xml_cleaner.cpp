#include "pugixml_helper.hpp"
#include "output_traverser.hpp"
#include "cleanup_traverser.hpp"


#include <iostream>

void printUsage(std::ostream& o)
{
	o << "This program requires exactly one argument:\n";
	o << "The path of the xml file to clean.\n";
	o << "The cleaned file will be output to stdout.";
}

int main(int argc, char* argv[])
{
	if(argc != 2)
	{
		printUsage(std::cerr);
		return 1;
	}
	
	auto const input_file_name = argv[1];
	
	pugi::xml_document xml_doc;
	auto const flags =
		  pugi::parse_doctype
		| pugi::parse_cdata
		| pugi::parse_ws_pcdata_single
		| pugi::parse_eol
		| pugi::parse_wnorm_attribute;
	auto const encoding = pugi::encoding_utf8;
	auto const parse_result = xml_doc.load_file(input_file_name, flags, encoding);
	if( ! parse_result)
	{
		std::cerr << "Parsing the xml document failed:\n"
		          << parse_result.description() << "\n";
		return 2;
	}

	cleanup_traverser m{};
	m.traverse_document(xml_doc);
	m.write(std::cout);
}
