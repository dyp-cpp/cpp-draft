#ifndef XML_CLEANER_PUGIXML_H
#define XML_CLEANER_PUGIXML_H


#define PUGIXML_HEADER_ONLY
#include <pugixml.hpp>
#include <pugixml.cpp> // sic, header-only

#include "text_tools.hpp"


inline bool has_children        (pugi::xml_node const node);
inline int  count_attributes    (pugi::xml_node const node);
inline bool attributes_mergeable(pugi::xml_node const p0, pugi::xml_node const p1);
inline void merge_text          (pugi::xml_node node); // merges adjacent text nodes
inline void trim_l              (pugi::xml_node node);
inline void trim_r              (pugi::xml_node node);


inline bool has_children(pugi::xml_node const node)
{
	return node.begin() != node.end();
}

int count_attributes(pugi::xml_node const node)
{
	return std::distance(node.attributes_begin(), node.attributes_end());
}

inline bool attributes_mergeable(pugi::xml_node const p0, pugi::xml_node const p1)
{
	// I'm using an O(n^2) algorithm here, since atm it is unlikely
	// we'll ever have more than 10 attributes
	assert(count_attributes(p0) + count_attributes(p1) < 20);
	
	for(auto const& attr1 : p1.attributes())
	{
		auto const attr0 = p0.attribute(attr1.name()); // O(n)
		if(attr0 && not str_cmp(attr0.value(), attr1.value()))
		{
			return false;
		}
	}
	
	return true;
}

inline void merge_text(pugi::xml_node node)
{
	auto merge_target = pugi::xml_node();
	
	for(auto next = node.first_child();
		next;
		)
	{
		auto curr = next;
		next = next.next_sibling();
		
		if(curr.type() == pugi::node_pcdata || curr.type() == pugi::node_cdata)
		{
			if(merge_target)
			{
				auto const merged = std::string(merge_target.text().get()) + curr.text().get();
				merge_target.text().set(merged.c_str());
				node.remove_child(curr);
			}else
			{
				merge_target = curr;
			}
		}else
		{
			merge_target = pugi::xml_node();
		}
	}
}

inline void trim_l(pugi::xml_node node)
{
	node.text().set( trim_l(std::string(node.text().get())).c_str() );
}
inline void trim_r(pugi::xml_node node)
{
	node.text().set( trim_r(std::string(node.text().get())).c_str() );
}


#endif // XML_CLEANER_PUGIXML_H
