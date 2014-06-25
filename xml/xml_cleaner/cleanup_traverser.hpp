#ifndef XML_CLEANER_CLEANUP_TRAVERSER_H
#define XML_CLEANER_CLEANUP_TRAVERSER_H


#include "traverser.hpp"
#include "transformation_stack.hpp"
#include "pugixml_helper.hpp"


class cleanup_traverser
{
private:
	pugi::xml_document out; // kind-of value semantics
	pugi::xml_node current_node; // pointer semantics!
	
	using most_basic_tag = transformation_stack::most_basic_tag;
	using most_derived_tag = transformation_stack::most_derived_tag;
	
	template<class Derived>
	class traverser_base;
	
	template<class OldTop = most_basic_tag, class Derived = most_derived_tag>
	class default_traverser;

	template<class OldTop, class Derived = most_derived_tag>
	class definition_traverser;
	
	template<class OldTop, class Derived = most_derived_tag>
	class inline_traverser;
	
public:
	void traverse_document(pugi::xml_document const& doc);
	
	void write(std::ostream& o) const
	{
		// Usage of pugixml output resulted in either
		// indenting or white-space problems
		/*auto const indent = "\t";
		auto const flags = pugi::format_indent;
		auto const encoding = pugi::encoding_utf8;
		out.save(o, indent, flags, encoding);*/
		
		output_traverser<std::ostream> w(o, out);
		w.write();
	}
};


#include "cleanup_traverser/cleanup_traverser.ipp"


#endif // XML_CLEANER_CLEANUP_TRAVERSER_H
