#ifndef XML_CLEANER_CLEANUP_TRAVERSER_H
#error Do not include this file directly.
#endif


#include "../text_tools.hpp"


/* The inline traverser is a special-purpose transformation
 * that drops text nodes inside text nodes.
*/
template<class OldTop, class MostDerived>
class cleanup_traverser::inline_traverser
	: public transformation_stack::rebind<
		OldTop,
		MostDerived,
		inline_traverser<OldTop, MostDerived>
	  >
{
private:
	using self_t = inline_traverser;
	using base = transformation_stack::rebind<OldTop, MostDerived, self_t>;
protected:
	using typename base::most_derived_t;
private:
	pugi::xml_node outer_text;
	
public:
	inline_traverser(OldTop& top, pugi::xml_node const base_text)
		: base(top), outer_text(base_text)
	{}
	
	template<class O, class D> friend class inline_traverser;
	template<class O, class D>
	inline_traverser(inline_traverser<O,D>& oldStack)
		: base(oldStack), outer_text(oldStack.outer_text)
	{}
	
	void traverse_element(pugi::xml_node const node) /* hide */
	{
		if(str_cmp(node.name(), "text"))
		{
			auto const attrCount = count_attributes(node);
			if( attrCount == 0 || (attrCount == 1 && node.attribute("xml:space")) )
			{
				this->traverse_children(node);
				return;
			}
		}
		
		this->copy_element_traverse(node);
	}
};