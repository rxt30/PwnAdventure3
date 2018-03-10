// #define _GNU_SOURCE

#include <dlfcn.h>
#include <stdio.h>
#include <iostream>

class Player {

    public:
        void Chat(const char *text);

};

struct Vector3 { float x; float y; float z; };

typedef void (*orig_chat_f_type)(Player *, const char *);
typedef void (*orig_pos_f_type)(Player *, const Vector3 *);


void Player::Chat(const char *text)
{
    std::string str(text);

    if (str.compare("Michael") == 0)
    {
        Vector3 pos;
        pos.x =  260255.0;
        pos.y = -249336.0;
        pos.z =    1476.0;

        const Vector3 p = pos;
        orig_pos_f_type orig;
        orig = (orig_pos_f_type) dlsym(RTLD_NEXT, "_ZN5Actor11SetPositionERK7Vector3");
        orig(this, &p);
    }

    // Call orignal Player::Chat() function
    orig_chat_f_type orig;
    orig = (orig_chat_f_type) dlsym(RTLD_NEXT, "_ZN6Player4ChatEPKc");
    orig(this, text);
}
