#ifndef XML_CLEANER_OUTPUT_TRAVERSER_H
#define XML_CLEANER_OUTPUT_TRAVERSER_H


#include "text_tools.hpp"
#include "transformation_stack.hpp"
#include "traverser.hpp"


// The output traverser writes an XML document to an ostream.
template<class Ostream>
class output_traverser // implements Traverser
{
private:
	using self_t = output_traverser;
	
	Ostream& o;
	pugi::xml_document const& doc;
	
	template<class Derived = transformation_stack::most_derived_tag>
	struct default_traverser;
	
	struct text_traverser;
	
public:
	output_traverser(Ostream& o, pugi::xml_document const& doc)
		: o(o), doc(doc)
	{}
	
	void write()
	{
		o << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
		auto traverser = default_traverser<>(*this);
		traverse_dispatch(traverser, doc.first_child());
	}
};


#include "output_traverser.ipp"


#endif // XML_CLEANER_OUTPUT_TRAVERSER_H
