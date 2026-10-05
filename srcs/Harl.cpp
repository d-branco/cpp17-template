#include "Harl.hpp"

#ifdef HARL
void Harl::debug(std::string_view msg)
{
    if (HARL <= static_cast<int>(LogLevel::Debug))
        std::cerr << aec_debug << "==DEBUG== " << msg << aec_reset << std::endl;
}

void Harl::info(std::string_view msg)
{
    if (HARL <= static_cast<int>(LogLevel::Info))
        std::cerr << aec_info << "_I_N_F_O_ " << msg << aec_reset << std::endl;
}

void Harl::warning(std::string_view msg)
{
    if (HARL <= static_cast<int>(LogLevel::Warning))
        std::cerr << aec_warning << "_WARNING_ " << msg << aec_reset << std::endl;
}

void Harl::error(std::string_view msg)
{
    if (HARL <= static_cast<int>(LogLevel::Error))
        std::cerr << aec_error << "[[ERROR]] " << msg << aec_reset << std::endl;
}
#endif // HARL
