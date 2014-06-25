#ifndef XML_CLEANER_CLEANUP_TRAVERSER_H
#error Do not include this file directly.
#endif


#include "traverser_base.hpp"
#include "default_traverser.hpp"
#include "inline_traverser.hpp"

#include "default_traverser.ipp"


void cleanup_traverser::traverse_document(pugi::xml_document const& doc)
{
	current_node = out;

	auto traverser = default_traverser<>{*this};
	traverser.traverse_children(doc);
	
	current_node = pugi::xml_node();
}
