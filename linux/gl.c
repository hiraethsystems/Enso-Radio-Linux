#define ENSO_GL_NO_ALIASES
#include "gl.h"

#include <SDL3/SDL.h>

#define ENSO_GL_DEFINE(name, ret, args) ret(APIENTRY *enso_##name) args;
ENSO_GL_FUNCS(ENSO_GL_DEFINE)
#undef ENSO_GL_DEFINE

int gl_load(const char **missing)
{
#define ENSO_GL_LOAD(name, ret, args)                                                           \
    enso_##name = (ret(APIENTRY *) args)SDL_GL_GetProcAddress(#name);                           \
    if (!enso_##name) {                                                                         \
        *missing = #name;                                                                      \
        return -1;                                                                             \
    }
    ENSO_GL_FUNCS(ENSO_GL_LOAD)
#undef ENSO_GL_LOAD
    return 0;
}
