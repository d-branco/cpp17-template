#include "header.hpp"

#ifndef TESTING
int main()
{
    Harl::debug("level  1");
    Harl::info("level  2");
    Harl::warning("level  3");
    Harl::error("level  4");

    std::cout << "end of main()\n";
    return (EXIT_SUCCESS);
}

#else  // TESTING
TEST_CASE("main(): placeholder")
{
    CHECK(true == true);
    CHECK(42 != 225);
}

TEST_CASE("Harl: log level ordering")
{
    SUBCASE("LogLevel values are ordered")
    {
        CHECK(static_cast<std::uint8_t>(Harl::LogLevel::Debug)
              < static_cast<std::uint8_t>(Harl::LogLevel::Info));
        CHECK(static_cast<std::uint8_t>(Harl::LogLevel::Info)
              < static_cast<std::uint8_t>(Harl::LogLevel::Warning));
        CHECK(static_cast<std::uint8_t>(Harl::LogLevel::Warning)
              < static_cast<std::uint8_t>(Harl::LogLevel::Error));
    }
}
#endif // TESTING
