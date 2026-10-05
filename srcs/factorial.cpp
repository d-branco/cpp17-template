#include "factorial.hpp"

long long factorial(int n)
{
    if (n < 0)
    {
        return (-1); // Error case for negative input
    }
    long long result = 1;
    for (int i = 1; i <= n; ++i)
    {
        result *= i;
    }
    return (result);
}

#ifdef TESTING
TEST_CASE("factorial function")
{
    SUBCASE("factorial of negative numbers")
    {
        CHECK(factorial(-1) == -1);
        CHECK(factorial(-10) == -1);
    }

    SUBCASE("factorial of base cases")
    {
        CHECK(factorial(0) == 1);
        CHECK(factorial(1) == 1);
    }

    SUBCASE("factorial of small numbers")
    {
        CHECK(factorial(2) == 2);
        CHECK(factorial(3) == 6);
        CHECK(factorial(4) == 24);
        CHECK(factorial(5) == 120);
    }

    SUBCASE("factorial of larger numbers")
    {
        CHECK(factorial(10) == 3628800);
        CHECK(factorial(12) == 479001600);
    }
}
#endif // TESTING
