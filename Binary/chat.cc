// #define _GNU_SOURCE

#include <dlfcn.h>
#include <stdio.h>
#include <iostream>

class Player {

    public:
        void Chat(const char *text);

};


typedef void (*orig_chat_f_type)(Player *, const char *);


void Player::Chat(const char *text)
{
    std::string str(text);
    std::cout << "Chat: " << str << "\n";

    // Call original Player::Chat() function
    orig_chat_f_type orig;
    orig = (orig_chat_f_type) dlsym(RTLD_NEXT, "_ZN6Player4ChatEPKc");
    orig(this, text);
}
