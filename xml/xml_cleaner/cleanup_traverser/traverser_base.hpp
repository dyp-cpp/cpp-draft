#ifndef XML_CLEANER_CLEANUP_TRAVERSER_H
#error Do not include this file directly.
#endif


#include "../merge_set.hpp"


template<class Derived>
class cleanup_traverser::traverser_base
{
private:
	using self_t = traverser_base;

public:
	traverser_base(cleanup_traverser& gState)
		: gState(gState)
	{}
	
	template<class D> friend class traverser_base;
	template<class D>
	traverser_base( traverser_base<D>& oldStack )
		: gState(oldStack.gState)
	{}
	
protected:
	using state_t = cleanup_traverser&;
	state_t gState;
	
	// Set current_node to new_current_node for the duration of `f()`
	template<class F>
	void push_and_do(pugi::xml_node new_current_node, F f)
	{
		// could be done RAII-style..
		auto const reset = gState.current_node;
		gState.current_node = new_current_node;
		f();
		gState.current_node = reset;
	}
	
	//+ static polymorphism helpers
		using most_derived_t = transformation_stack::get_most_derived_t< Derived, self_t >;
		
		auto most_derived() -> most_derived_t&
		{ return static_cast<most_derived_t&>(*this); }
		
		template<class T>
		/*static virtual*/ void traverse(T&& t) {
			traverse_dispatch(most_derived(), std::forward<T>(t));
		}
		template<class Traverser, class Node>
		void traverse_with(Traverser&& t, Node&& n) {
			traverse_dispatch(std::forward<Node>(n), std::forward<Traverser>(t));
		}
	//- static polymorphism helpers
	
	//+ merging helpers
		bool is_mergeable(merge_set const& merge_targets,
						  pugi::xml_node const node) const
		{
			auto const node_is_merge_target = merge_targets.contains(node.name());
			auto const prev_is_merge_target =
				merge_targets.contains(gState.current_node.last_child().name());
			return prev_is_merge_target && not node_is_merge_target;
		}
	//- merging helpers

public:
	//+ traversal helpers
		void traverse_attributes(pugi::xml_node const node) {
			for(auto attribute : node.attributes()) traverse(attribute);
		}
		void traverse_children(pugi::xml_node const node) {
			for(auto child : node.children()) traverse(child);
		}
	//- traversal helpers
};
