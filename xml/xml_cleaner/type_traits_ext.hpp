#ifndef XML_CLEANER_TYPE_TRAITS_EXT
#define XML_CLEANER_TYPE_TRAITS_EXT


#include <type_traits>


template<bool b, class Then, class Else>
using conditional_t = typename std::conditional<b, Then, Else>::type;


#endif // XML_CLEANER_TYPE_TRAITS_EXT
