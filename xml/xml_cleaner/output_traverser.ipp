#ifndef XML_CLEANER_OUTPUT_TRAVERSER_H
#error Do not include this file directly.
#endif


// The default output traverser prints indented elements to the ostream
template<class Ostream>
template<class Derived>
struct output_traverser<Ostream>::default_traverser
{
private:
	using self_t = default_traverser;
	
public:
	default_traverser(output_traverser& gState)
		: gState(gState), indent(0)
	{}

	// The text_traverser derived class needs to be able to copy the internal state
	// to construct its base class subobject.
	// Due to CRTP, its base class is different from the default_traverser it builds upon.
	// This friend declaration allows copy construction of different specializations.
	template<class D> friend struct default_traverser;
	
	template<class D>
	default_traverser(default_traverser<D>& source)
		: gState(source.gState), indent(source.indent)
	{}
	
	void traverse_text(pugi::xml_text const text)
	{
		gState.o << text.get();
	}

	void traverse_attribute(pugi::xml_attribute const attr)
	{
		gState.o << " " << attr.name() << "=\"" << attr.value() << "\"";
	}
	
	void traverse_element(pugi::xml_node const node);
	
protected:
	output_traverser& gState;
	int indent;
	
	//+ static polymorphism helpers
		using most_derived_t = transformation_stack::get_most_derived_t<Derived, self_t>;
			
		auto most_derived() -> most_derived_t&
		{ return static_cast<most_derived_t&>(*this); }
	
		template<class PXObject>
		/*static virtual*/ void traverse(PXObject&& o)
		{
			traverse_dispatch(most_derived(), std::forward<PXObject>(o));
		}
		template<class PXObject, class Traverser>
		void traverse_with(PXObject&& o, Traverser&& t)
		{
			traverse_dispatch(std::forward<Traverser>(t), std::forward<PXObject>(o));
		}
	//- static polymorphism helpers
	
	void traverse_element_noindent(pugi::xml_node const node);
};


// The text traverser class prints all elements inside without indentation.
// This is intended for inline (in-text) elements.
template<class Ostream>
struct output_traverser<Ostream>::text_traverser final
	: default_traverser<text_traverser>
{
	text_traverser(default_traverser<>& gState)
		: default_traverser<text_traverser>(gState)
	{}
	
	void traverse_element(pugi::xml_node const node) /* hide */
	{
		this->traverse_element_noindent(node);
	}
};


template<class Ostream>
template<class Derived>
auto output_traverser<Ostream>::default_traverser<Derived>::
traverse_element(pugi::xml_node const node) -> void
{
	static const auto indent_str = "  ";
	
	gState.o << "\n" << repeat(indent_str, indent);
	
	if(node.name() == std::string("text"))
	{
		auto new_traverser = text_traverser(*this);
		traverse_with(node, new_traverser);
	}else
	{
		most_derived().traverse_element_noindent(node);
	}
	
	if( ! node.next_sibling() )
	{
		gState.o << "\n" << repeat(indent_str, indent-1);
	}
}


template<class Ostream>
template<class Derived>
void output_traverser<Ostream>::default_traverser<Derived>::
traverse_element_noindent(pugi::xml_node const node)
{
	gState.o << "<"<<node.name();
	for(auto const attr : node.attributes())
	{
		traverse(attr);
	}
	if(has_children(node))
	{
		gState.o << ">";
		++indent;
		for(auto const child : node.children())
		{
			traverse(child);
		}
		--indent;
		gState.o << "</"<<node.name()<<">";
	}else
	{
		gState.o << "/>";
	}
}