#ifndef XML_CLEANER_TRACE_H
#define XML_CLEANER_TRACE_H


#ifndef NDEBUG
	#include <iostream>
	
	namespace xml_cleaner_detail
	{
		template<int...> struct gen_seq {};
		template<int N, int... Is> struct make_seq : make_seq<N-1, N-1, Is...> {};
		template<int... Is> struct make_seq<0, Is...> : gen_seq<Is...> {};
	}
	
	template<class... T>
	void trace(T&&... t)
	{
		int dummy[] = { 0, (void(std::cerr << t), 0)... };
		(void)dummy;
	}
#else
	template<class... T>
	void trace(T&&...) {}
#endif


#endif // XML_CLEANER_TRACE_H