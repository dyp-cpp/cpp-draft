#ifndef XML_CLEANER_TRANSFORMATION_STACK_H
#define XML_CLEANER_TRANSFORMATION_STACK_H


#include "type_traits_ext.hpp"


/*
A statically polymorphic transformation stack.
The XML is structured as a tree. Some elements, or more generally sub-trees,
need to be transformed in a specific way.
The default transformation uses a depth-first traversal.
When we need a specific transformation of a sub-tree,
we create a new transformation object and push it onto a stack.
When we're finished with the sub-tree, we pop the specific transformation
and continue on the next sibling with the previous transformation.

Instead of using an explicit stack data structure and runtime polymorphism,
this implementation uses local objects (automatic storage duration => on the stack)
which provide the transformation functions and state.

Most often, we want a transformation just slightly different from the previous tranformation,
to cover a special case (e.g. a special element).
This is implemented by using inheritance and polymorphism:
* Each transformation derives from the previous transformation used.
* The derived class overrides some functionality of the base class.
* Base class functions can call function overriden by the derived class.

The polymorphism is static, implemented via CRTP.
Of course, this prohibits circles (due to infinite template instantiation),
but it's enough for the transformations required here.

A typical transformation can be used anywhere in the stack.
This implies that its base class must be a template parameter,
but to implement static polymorphism, it also needs to now the most-derived type
(knowing its direct child class is also possible, but probably harder to implement).

Therefore, a typical transformation has two template parameters:
`Base` and `MostDerived`, corresponding roughly to the base and stack pointers:

super special transformation < <
       |                     | |
       v                     | |
special transformation ------+ |
       |                       |
       v                       |
default transformation --------+

The type of the object is:

super_special_trafo<
	special_trafo<
		default_trafo< none, super_special_trafo>
		, super_special_trafo
	>
	, none
>

where `super_special_trafo` is an abbreviation of the whole type (CRTP).

If you push a new transformation onto an existing type stack,
you need to change the type stack's most derived type.
This requires a rebinding mechanism.
Due to the recurring nature of the type, this cannot be done but in the
base clause of the most-derived type, where the name of the most-derived type
is already visible and usable.

Currently, only the types are stacked in such a way.
The different transformation objects are independent.
This implies that a new transformation object needs to copy the entire state
of the previous transformation object.
Since the state is rather small, this isn't a problem here.
It also guarantees that the state is restored correctly.

If you push a new transformation, you pass the old transformation object
plus any additional state to the ctor of the new transformation object.
For all non-top types, this requires a copy constructor taking a sibling type
(the derived and base template parameters are changed due to CRTP).
Therefore, most transformation types have two constructors.
*/
namespace transformation_stack
{
	struct most_derived_tag {};
	struct most_basic_tag {};

	template<class Derived, class Current>
	using get_most_derived_t = conditional_t<
		  std::is_same<Derived, most_derived_tag>{}
		, Current, Derived >;
	

	/*
	To push a type of the transformation stack,
	we need to change the most-derived type of the current transformation type.
	*/
	template<class Base, class Derived, class Self>
	struct rebind_derived;

	template< template<class, class> class Base, class Base2, class OldDerived,
			  class NewDerived, class Self >
	struct rebind_derived< Base<Base2, OldDerived>, NewDerived, Self>
	{
		using type = Base<Base2, get_most_derived_t<NewDerived, Self>>;
	};

	template< class NewDerived, class Self >
	struct rebind_derived< most_basic_tag, NewDerived, Self >
	{
		using type = most_basic_tag;
	};

	template<class Base, class Derived, class Self>
	using rebind_derived_t = typename rebind_derived<Base, Derived, Self>::type;
	
	
	template<class Base, class Derived, class Self>
	using rebind = rebind_derived_t<Base, get_most_derived_t<Derived, Self>, Self>;
} // namespace transformation_stack


#endif // XML_CLEANER_TRANSFORMATION_STACK_H
