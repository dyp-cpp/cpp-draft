#ifndef XML_CLEANER_TEXT_TOOLS_H
#define XML_CLEANER_TEXT_TOOLS_H


#include <algorithm>
#include <cstring>
#include <iostream>


//+ string helper functions
	inline bool is_ascii_space(char const c)
	{
		return  c <= 0x20 &&
		       (c == ' ' || c == '\f' || c == '\n' || c == '\r' || c == '\t' || c == '\v');
	}
	// returns a proper boolean, and is more intuitive IMHO
	inline bool str_cmp(char const* lhs, char const* rhs)
	{
		return 0 == std::strcmp(lhs, rhs);
	}

	template<class Char, class Char_traits, class Allocator>
	inline auto trim_l(std::basic_string<Char, Char_traits, Allocator> const& target)
	-> std::basic_string<Char, Char_traits, Allocator>
	{
		auto const beg = std::find_if_not(target.begin(), target.end(), is_ascii_space);
		return std::basic_string<Char, Char_traits, Allocator>(beg, target.end());
	}

	template<class Char, class Char_traits, class Allocator>
	inline auto trim_r(std::basic_string<Char, Char_traits, Allocator> const& target)
	-> std::basic_string<Char, Char_traits, Allocator>
	{
		auto const end = std::find_if_not(target.rbegin(), target.rend(), is_ascii_space).base();
		return std::basic_string<Char, Char_traits, Allocator>(target.begin(), end);
	}
//- string helper functions


//+ an iostream manipulator that prints a character N times
	template<class T>
	struct repeat_helper
	{
	private:
		T t;
		int count;
	public:
		repeat_helper(T t, int count)
			: t(t), count(count)
		{}
		
		template<class Char, class Char_traits>
		friend auto operator<<(std::basic_ostream<Char, Char_traits>& o,
		                       repeat_helper const r)
		-> std::basic_ostream<Char, Char_traits>&
		{
			for(auto i = 0; i < r.count; ++i) o << r.t;
			return o;
		}
	};

	template<class T>
	repeat_helper<T> repeat(T t, int count)
	{
		return repeat_helper<T>(t, count);
	}
//- iostream manipulator


#endif // XML_CLEANER_TEXT_TOOLS_H
