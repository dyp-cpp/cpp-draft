#ifndef XML_CLEANER_CLEANUP_TRAVERSER_H
#error Do not include this file directly.
#endif


#include <functional>
#include <map>


template<class OldTop, class Derived>
void cleanup_traverser::default_traverser<OldTop, Derived>::
traverse_element(pugi::xml_node const node)
{
	using func_t = void (self_t::*)(pugi::xml_node);
	constexpr auto t_inline = &self_t::traverse_inline_element;
	constexpr auto t_epsilon = &self_t::epsilon_traverser;
	
	static auto const traversers = std::map<std::string, func_t>
	{
		 {"par"         , &self_t::traverse_par}
		,{"pnum"        , t_epsilon}
		,{"text"        , &self_t::traverse_text_element}
		,{"cvqual"      , t_inline}
		,{"cpp"         , t_inline}
		,{"defnx"		, t_inline}
		,{"doccite"     , t_inline}
		,{"footnoteCall", t_inline}
		,{"grammarterm" , t_inline}
		,{"ICS"         , t_inline}
		,{"logop"       , t_inline}
		,{"nonterminal" , t_inline}
		,{"opt"         , t_inline}
		,{"placeholder" , t_inline}
		,{"ref"         , t_inline}
		,{"tcode"       , t_inline}
		,{"term"        , t_inline}
		,{"terminal"    , t_inline}
		,{"codeblock"   , &self_t::traverse_codeblock}
	};
	
	auto const it = traversers.find(node.name());
	if(it != traversers.end())
	{
		std::bind(it->second, this, node)();
	}else
	{
		copy_element_traverse(node);
	}
}


template<class OldTop, class Derived>
void cleanup_traverser::default_traverser<OldTop, Derived>::
traverse_par(pugi::xml_node const node)
{
	if(auto const res = node.child("pnum"))
	{
		// this is a numbered paragraph; output a <par number="X">
		auto new_node = this->gState.current_node.append_child("par");
		auto const number = res.attribute("number").value();
		new_node.append_attribute("number").set_value(number);
		
		this->push_and_do(new_node, [&]
		{
			this->traverse_children(node);
		});
	}else
	{
		// merge this par with a preceding numbered paragraph
		auto const prev = this->gState.current_node.last_child();
		if(   prev && str_cmp(prev.name(), "par")
		   && prev.attribute("number"))
		{
			this->push_and_do(this->gState.current_node.last_child(), [&]
			{
				this->traverse_children(node);
			});
		}else
		{
			copy_element_traverse(node);
			if(    str_cmp(node.previous_sibling().name(), "title")
			    && str_cmp(node.parent().name(), "section") )
			{
				this->gState.current_node.last_child().append_attribute("number").set_value("0");
			}
		}
	}
}


/*
Inline elements are like <span>s, i.e. in the line of the text.
They're to be merged with the surrounding text/inline elements to a larger text element.
E.g.

<text>The definition can be found in </text>
<ref idref="some.chapter"/>
<text> and is in fact a limerick.</text>

<text>The definition can be found in <ref idref="some.chapter"/> and is in fact a limerick.</text>
*/
template<class Base, class Derived>
auto cleanup_traverser::default_traverser<Base, Derived>::
traverse_inline_element(pugi::xml_node const node) -> void
{
	auto prev_node = this->gState.current_node.last_child();
	if(str_cmp(prev_node.name(), "text"))
	{
		auto new_node = prev_node.append_child(node.name());
		this->push_and_do(new_node, [&]
		{
			/*auto new_traverser = inline_traverser<most_derived_t>{*this, prev_node};
			new_traverser.traverse_attributes(node);
			new_traverser.traverse_children(node);*/
			this->traverse_attributes(node);
			this->traverse_children(node);
		});
	}else
	{
		auto new_text_node = this->gState.current_node.append_child("text");
		this->push_and_do(new_text_node, [&]
		{
			copy_element_traverse(node);
		});
	}
}


template<class OldTop, class Derived>
void cleanup_traverser::default_traverser<OldTop, Derived>::
traverse_codeblock(pugi::xml_node const node)
{
	copy_element_traverse(node);
	
	auto codeblock = this->gState.current_node.last_child();
	
	merge_text(codeblock.first_child());
	
	if(str_cmp(codeblock.first_child().name(), "text"))
	{
		trim_l(codeblock.first_child());
	}
	if(str_cmp(codeblock.last_child().name(), "text"))
	{
		trim_r(codeblock.last_child());
	}
}
