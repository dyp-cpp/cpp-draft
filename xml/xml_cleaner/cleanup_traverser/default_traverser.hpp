#ifndef XML_CLEANER_CLEANUP_TRAVERSER_H
#error Do not include this file directly.
#endif


#include <stdexcept>
#include <sstream>


template<class OldTop, class MostDerived>
class cleanup_traverser::default_traverser
	: public traverser_base<
		transformation_stack::get_most_derived_t<
			MostDerived,
			default_traverser<OldTop, MostDerived>
		>
	  >
{
	static_assert( std::is_same<OldTop, most_basic_tag>{},
				   "The default_traverser must not have a base class." );
private:
	using self_t = default_traverser;
	using base =
		traverser_base<
			transformation_stack::get_most_derived_t<
				MostDerived,
				default_traverser<OldTop, MostDerived>
			>
		>;
protected:
	using most_derived_t = transformation_stack::get_most_derived_t<MostDerived, self_t>;

public:
	default_traverser(cleanup_traverser& gState)
		: base(gState)
	{}
	
	template<class B, class D>
	default_traverser( default_traverser<B,D>& oldStack )
		: base(oldStack)
	{}
	
	//+ travsersal interface
		void traverse_element(pugi::xml_node const node);
		void traverse_attribute(pugi::xml_attribute const attr) {
			copy_attribute(attr);
		}
		void traverse_text(pugi::xml_text const text) {
			copy_text(text);
		}
	//- traversal interface
	
protected:
	//+ default node handling
		void copy_attribute(pugi::xml_attribute const attr) {
			this->gState.current_node.append_copy(attr);
		}
		
		void copy_element_traverse(pugi::xml_node const node)
		{
			// we cannot use append_copy here, as that would trigger a deep copy
			auto new_node = this->gState.current_node.append_child(node.name());
			
			this->push_and_do(new_node, [&]
			{
				this->traverse_attributes(node);
				this->traverse_children(node);
			});
		}
		
		void copy_text(pugi::xml_text const text)
		{
			auto new_text_node = this->gState.current_node.append_child(pugi::node_pcdata);
			if( ! new_text_node.text().set(text.get()) )
			{
				std::ostringstream err_msg{};
				err_msg << "Failed to set the text content of this node: ";
				err_msg << new_text_node.path();
				err_msg << "\nCopied from this node: ";
				err_msg << text.data().path();
				throw std::runtime_error(err_msg.str());
			}
		}
		
		void traverse_text_element(pugi::xml_node const node)
		{
			if(   str_cmp(this->gState.current_node.last_child().name(), "text")
			   && attributes_mergeable(node, this->gState.current_node.last_child()))
			{
				this->push_and_do(this->gState.current_node.last_child(), [&]
				{
					this->traverse_children(node);
				});
			}else
			{
				copy_element_traverse(node);
			}
		}
	//- default node handling
	
	//+ special node handling
		void traverse_par(pugi::xml_node const node);
		void traverse_inline_element(pugi::xml_node const node);
		void traverse_codeblock(pugi::xml_node const node);
	//- special node handling
	
	void epsilon_traverser(pugi::xml_node) {}
};
