#include <boost/ut.hpp>
#include "%s/%s.hpp"

int main()
{
    using namespace boost::ut;

    "basic_sanity_check"_test = [] {
        expect(1_i == 1);
    };
}
