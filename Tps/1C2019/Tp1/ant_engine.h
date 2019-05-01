#ifndef __ANT_ENGINE_H__
#define __ANT_ENGINE_H__


#define panic(s)       \
  do {                 \
    fprintf(stderr, "%s: %s\n", __FUNCTION__, s);\
    exit(1);            \
  } while(0);

#endif /* __ANT_ENGINE_H__ */
