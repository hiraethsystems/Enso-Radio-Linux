/* OpenGL 3.3 core functions, loaded through SDL at start-up (Windows'
 * opengl32.dll only exports OpenGL 1.1 directly). */
#ifndef ENSO_GL_H
#define ENSO_GL_H

#include <SDL3/SDL_opengl.h>

#ifndef APIENTRY
#define APIENTRY
#endif

/* name, return type, arguments */
#define ENSO_GL_FUNCS(X)                                                                        \
    X(glGetString, const GLubyte *, (GLenum))                                                  \
    X(glGetError, GLenum, (void))                                                              \
    X(glViewport, void, (GLint, GLint, GLsizei, GLsizei))                                      \
    X(glScissor, void, (GLint, GLint, GLsizei, GLsizei))                                       \
    X(glClearColor, void, (GLfloat, GLfloat, GLfloat, GLfloat))                                \
    X(glClear, void, (GLbitfield))                                                             \
    X(glEnable, void, (GLenum))                                                                \
    X(glDisable, void, (GLenum))                                                               \
    X(glBlendFunc, void, (GLenum, GLenum))                                                     \
    X(glBlendFuncSeparate, void, (GLenum, GLenum, GLenum, GLenum))                             \
    X(glPixelStorei, void, (GLenum, GLint))                                                    \
    X(glDrawArrays, void, (GLenum, GLint, GLsizei))                                            \
    X(glGenBuffers, void, (GLsizei, GLuint *))                                                 \
    X(glDeleteBuffers, void, (GLsizei, const GLuint *))                                        \
    X(glBindBuffer, void, (GLenum, GLuint))                                                    \
    X(glBufferData, void, (GLenum, GLsizeiptr, const void *, GLenum))                          \
    X(glBufferSubData, void, (GLenum, GLintptr, GLsizeiptr, const void *))                     \
    X(glGenVertexArrays, void, (GLsizei, GLuint *))                                            \
    X(glDeleteVertexArrays, void, (GLsizei, const GLuint *))                                   \
    X(glBindVertexArray, void, (GLuint))                                                       \
    X(glVertexAttribPointer, void, (GLuint, GLint, GLenum, GLboolean, GLsizei, const void *))  \
    X(glEnableVertexAttribArray, void, (GLuint))                                               \
    X(glCreateShader, GLuint, (GLenum))                                                        \
    X(glDeleteShader, void, (GLuint))                                                          \
    X(glShaderSource, void, (GLuint, GLsizei, const GLchar *const *, const GLint *))           \
    X(glCompileShader, void, (GLuint))                                                         \
    X(glGetShaderiv, void, (GLuint, GLenum, GLint *))                                          \
    X(glGetShaderInfoLog, void, (GLuint, GLsizei, GLsizei *, GLchar *))                        \
    X(glCreateProgram, GLuint, (void))                                                         \
    X(glDeleteProgram, void, (GLuint))                                                         \
    X(glAttachShader, void, (GLuint, GLuint))                                                  \
    X(glLinkProgram, void, (GLuint))                                                           \
    X(glGetProgramiv, void, (GLuint, GLenum, GLint *))                                         \
    X(glGetProgramInfoLog, void, (GLuint, GLsizei, GLsizei *, GLchar *))                       \
    X(glUseProgram, void, (GLuint))                                                            \
    X(glGetUniformLocation, GLint, (GLuint, const GLchar *))                                   \
    X(glUniform1i, void, (GLint, GLint))                                                       \
    X(glUniform2f, void, (GLint, GLfloat, GLfloat))                                            \
    X(glGenTextures, void, (GLsizei, GLuint *))                                                \
    X(glDeleteTextures, void, (GLsizei, const GLuint *))                                       \
    X(glBindTexture, void, (GLenum, GLuint))                                                   \
    X(glActiveTexture, void, (GLenum))                                                         \
    X(glTexImage2D, void,                                                                      \
      (GLenum, GLint, GLint, GLsizei, GLsizei, GLint, GLenum, GLenum, const void *))           \
    X(glTexSubImage2D, void,                                                                   \
      (GLenum, GLint, GLint, GLint, GLsizei, GLsizei, GLenum, GLenum, const void *))           \
    X(glTexParameteri, void, (GLenum, GLenum, GLint))                                          \
    X(glGenFramebuffers, void, (GLsizei, GLuint *))                                            \
    X(glDeleteFramebuffers, void, (GLsizei, const GLuint *))                                   \
    X(glBindFramebuffer, void, (GLenum, GLuint))                                               \
    X(glFramebufferTexture2D, void, (GLenum, GLenum, GLenum, GLuint, GLint))                   \
    X(glCheckFramebufferStatus, GLenum, (GLenum))                                              \
    X(glBlitFramebuffer, void,                                                                 \
      (GLint, GLint, GLint, GLint, GLint, GLint, GLint, GLint, GLbitfield, GLenum))           \
    X(glUniform1f, void, (GLint, GLfloat))                                                     \
    X(glUniform3f, void, (GLint, GLfloat, GLfloat, GLfloat))                                   \
    X(glUniform4f, void, (GLint, GLfloat, GLfloat, GLfloat, GLfloat))                          \
    X(glUniformMatrix4fv, void, (GLint, GLsizei, GLboolean, const GLfloat *))                  \
    X(glCullFace, void, (GLenum))                                                              \
    X(glFrontFace, void, (GLenum))                                                             \
    X(glGenerateMipmap, void, (GLenum))                                                        \
    X(glTexParameterf, void, (GLenum, GLenum, GLfloat))                                        \
    X(glReadPixels, void, (GLint, GLint, GLsizei, GLsizei, GLenum, GLenum, void *))            \
    X(glDepthMask, void, (GLboolean))                                                          \
    X(glDrawElements, void, (GLenum, GLsizei, GLenum, const void *))

#define ENSO_GL_DECLARE(name, ret, args) extern ret(APIENTRY *enso_##name) args;
ENSO_GL_FUNCS(ENSO_GL_DECLARE)
#undef ENSO_GL_DECLARE

/* The rest of linux/ calls them by their usual names. */
#ifndef ENSO_GL_NO_ALIASES
#define glGetString enso_glGetString
#define glGetError enso_glGetError
#define glViewport enso_glViewport
#define glScissor enso_glScissor
#define glClearColor enso_glClearColor
#define glClear enso_glClear
#define glEnable enso_glEnable
#define glDisable enso_glDisable
#define glBlendFunc enso_glBlendFunc
#define glBlendFuncSeparate enso_glBlendFuncSeparate
#define glPixelStorei enso_glPixelStorei
#define glDrawArrays enso_glDrawArrays
#define glGenBuffers enso_glGenBuffers
#define glDeleteBuffers enso_glDeleteBuffers
#define glBindBuffer enso_glBindBuffer
#define glBufferData enso_glBufferData
#define glBufferSubData enso_glBufferSubData
#define glGenVertexArrays enso_glGenVertexArrays
#define glDeleteVertexArrays enso_glDeleteVertexArrays
#define glBindVertexArray enso_glBindVertexArray
#define glVertexAttribPointer enso_glVertexAttribPointer
#define glEnableVertexAttribArray enso_glEnableVertexAttribArray
#define glCreateShader enso_glCreateShader
#define glDeleteShader enso_glDeleteShader
#define glShaderSource enso_glShaderSource
#define glCompileShader enso_glCompileShader
#define glGetShaderiv enso_glGetShaderiv
#define glGetShaderInfoLog enso_glGetShaderInfoLog
#define glCreateProgram enso_glCreateProgram
#define glDeleteProgram enso_glDeleteProgram
#define glAttachShader enso_glAttachShader
#define glLinkProgram enso_glLinkProgram
#define glGetProgramiv enso_glGetProgramiv
#define glGetProgramInfoLog enso_glGetProgramInfoLog
#define glUseProgram enso_glUseProgram
#define glGetUniformLocation enso_glGetUniformLocation
#define glUniform1i enso_glUniform1i
#define glUniform2f enso_glUniform2f
#define glGenTextures enso_glGenTextures
#define glDeleteTextures enso_glDeleteTextures
#define glBindTexture enso_glBindTexture
#define glActiveTexture enso_glActiveTexture
#define glTexImage2D enso_glTexImage2D
#define glTexSubImage2D enso_glTexSubImage2D
#define glTexParameteri enso_glTexParameteri
#define glGenFramebuffers enso_glGenFramebuffers
#define glDeleteFramebuffers enso_glDeleteFramebuffers
#define glBindFramebuffer enso_glBindFramebuffer
#define glFramebufferTexture2D enso_glFramebufferTexture2D
#define glCheckFramebufferStatus enso_glCheckFramebufferStatus
#define glBlitFramebuffer enso_glBlitFramebuffer
#define glUniform1f enso_glUniform1f
#define glUniform3f enso_glUniform3f
#define glUniform4f enso_glUniform4f
#define glUniformMatrix4fv enso_glUniformMatrix4fv
#define glCullFace enso_glCullFace
#define glFrontFace enso_glFrontFace
#define glGenerateMipmap enso_glGenerateMipmap
#define glTexParameterf enso_glTexParameterf
#define glReadPixels enso_glReadPixels
#define glDepthMask enso_glDepthMask
#define glDrawElements enso_glDrawElements
#endif

/* Loads every function above from the current context. Returns 0, or -1
 * with the first missing name in *missing. */
int gl_load(const char **missing);

#endif
