#ifndef HARL_HPP
#define HARL_HPP

#include <cstdint>
#include <iostream>
#include <string_view>

class Harl
{
  public:
    Harl()                            = default;
    Harl(const Harl &)                = default;
    Harl &operator=(const Harl &)     = default;
    Harl(Harl &&) noexcept            = default;
    Harl &operator=(Harl &&) noexcept = default;
    ~Harl()                           = default;

    enum class LogLevel : std::uint8_t
    {
        Debug   = 1,
        Info    = 2,
        Warning = 3,
        Error   = 4
    };

    static constexpr std::string_view aec_debug   = "\033[90m";
    static constexpr std::string_view aec_info    = "\033[36m";
    static constexpr std::string_view aec_warning = "\033[93m";
    static constexpr std::string_view aec_error   = "\033[91m";
    static constexpr std::string_view aec_reset   = "\033[0m";

#ifdef HARL
    static void debug(std::string_view msg);
    static void info(std::string_view msg);
    static void warning(std::string_view msg);
    static void error(std::string_view msg);
#else
    static void debug(std::string_view /*msg*/)
    {
    }

    static void info(std::string_view /*msg*/)
    {
    }

    static void warning(std::string_view /*msg*/)
    {
    }

    static void error(std::string_view /*msg*/)
    {
    }
#endif // HARL
};

#endif // HARL_HPP
