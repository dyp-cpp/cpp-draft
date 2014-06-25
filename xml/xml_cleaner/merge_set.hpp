#ifndef XML_CLEANER_MERGE_SET_H
#define XML_CLEANER_MERGE_SET_H


#include <algorithm>
#include <initializer_list>
#include <vector>


struct merge_set
{
public:
	using string_t = std::string;
private:
	// It is likely that this set is very small
	using set_t = std::vector<string_t>;
	set_t mset;
	
public:
	merge_set(std::initializer_list<string_t> init)
		: mset(init)
	{}
	
	bool contains(string_t const& p) const
	{
		return mset.end() != std::find(begin(mset), end(mset), p);
	}
};


#endif // XML_CLEANER_MERGE_SET_H