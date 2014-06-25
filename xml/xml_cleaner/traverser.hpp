#ifndef XML_CLEANER_TRAVERSER_H
#define XML_CLEANER_TRAVERSER_H


#include "pugixml_helper.hpp"
#include "trace.hpp"

/*
The traversers typically use DFS.
pugixml offers a single class pugixml::node for elements, text nodes etc.
We dispatch based on the kind (element, text node, attribute) to one of three
main traversal member functions:

	void traverse_element(pugixml::node const)
	void traverse_text(pugixml::text const)
	void traverse_attribute(pugixml::attribute const)

The dispatching is performed by the free traverse_dispatch helper function.

Note the use of static polymorphism to alter traversal.
*/

// concepts
/*
template<typename T>
concept bool Traverser()
{
	return requires (T t,
	                 pugi::xml_node const node,
	                 pugi::xml_text const text,
	                 pugi::xml_attribute const attr)
	{
		t.traverse_element(node);
		t.traverse_text(text);
		t.travsere_attribute(attr);
	}
}

template<typename T>
concept bool PXObject()
{
	return    std::is_same<T, pugi::xml_node>{}
	       || std::is_same<T, pugi::xml_text>{}
	       || std::is_same<T, pugi::xml_attribute>{}
	       ;
}
*/

//+ pugixml -> traverser interface
	template<class Traverser>
	void traverse_dispatch(Traverser& t, pugi::xml_node const any_node)
	{
		switch(any_node.type())
		{
		case pugi::node_null:
			break;
		
		case pugi::node_document:
		case pugi::node_element:
			trace("traversing: ",any_node.path());
			t.traverse_element(any_node);
			break;
		
		case pugi::node_pcdata:
		case pugi::node_cdata:
			t.traverse_text(any_node.text());
			break;
		
		case pugi::node_comment:
		case pugi::node_pi:
		case pugi::node_declaration:
		case pugi::node_doctype:
			// do nothing
			break;
		}
	}
	
	template<class Traverser>
	void traverse_dispatch(Traverser& t, pugi::xml_attribute const attr)
	{
		t.traverse_attribute(attr);
	}
//- pugixml -> traverser interface


#endif // XML_CLEANER_TRAVERSER_H
