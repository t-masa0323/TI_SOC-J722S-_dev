#define _GNU_SOURCE

#include <dlfcn.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdint.h>
#include <stddef.h>

#include "trace_symbols.h"

#define TRACE_TABLE_MAX 512
#define TRACE_STACK_MAX 1024
#define LOOP_EVERY_N    1000

static __thread int g_in_hook = 0;
static __thread int g_depth = 0;

typedef struct {
    void *fn;
    uint32_t count;
} TraceRateEntry;

typedef struct {
    void *fn;
    int printed;
} TraceStackEntry;

static __thread TraceRateEntry g_rate[TRACE_TABLE_MAX];
static __thread TraceStackEntry g_stack[TRACE_STACK_MAX];
static __thread int g_stack_top = 0;

__attribute__((no_instrument_function))
static const char *lookup_libtivision_symbol(unsigned long offset)
{
    unsigned int i;
    const TraceSymbol *best = NULL;

    for (i = 0; i < g_libtivision_symbols_num; i++) {
        if (g_libtivision_symbols[i].offset <= offset)
            best = &g_libtivision_symbols[i];
        else
            break;
    }

    return best ? best->name : NULL;
}

__attribute__((no_instrument_function))
static void get_func_name(void *addr, char *buf, size_t size)
{
    Dl_info info;

    if (!buf || size == 0)
        return;

    if (dladdr(addr, &info)) {
        if (info.dli_sname) {
            snprintf(buf, size, "%s", info.dli_sname);
            return;
        }

        if (info.dli_fname && strstr(info.dli_fname, "libtivision_apps.so")) {
            unsigned long offset =
                (unsigned long)addr - (unsigned long)info.dli_fbase;

            const char *name = lookup_libtivision_symbol(offset);
            if (name) {
                snprintf(buf, size, "%s+0x%lx", name, offset);
                return;
            }
        }
    }

    snprintf(buf, size, "%p", addr);
}

__attribute__((no_instrument_function))
static uint32_t count_func(void *fn)
{
    int i;

    for (i = 0; i < TRACE_TABLE_MAX; i++) {
        if (g_rate[i].fn == fn) {
            g_rate[i].count++;
            return g_rate[i].count;
        }

        if (g_rate[i].fn == NULL) {
            g_rate[i].fn = fn;
            g_rate[i].count = 1;
            return 1;
        }
    }

    return 1;
}

__attribute__((no_instrument_function))
static int is_loop_or_noisy_func(void *fn, const char *name)
{
    if (fn == (void *)0x406080)
        return 1;

    if (name) {
        if (strstr(name, "app_run_graph_for_one_frame_pipeline") ||
            strstr(name, "appGrpxDraw") ||
            strstr(name, "appPerfStats") ||
            strstr(name, "appLogWaitMsecs") ||
            strstr(name, "vxProcessGraph") ||
            strstr(name, "_ZN3glm") ||
            strstr(name, "glm"))
            return 1;
    }

    return 0;
}

__attribute__((no_instrument_function))
static int is_hard_exclude(const char *name)
{
    if (!name)
        return 0;

    if (strstr(name, "__cyg_profile") ||
        strstr(name, "get_func_name") ||
        strstr(name, "lookup_libtivision_symbol") ||
        strstr(name, "count_func") ||
        strstr(name, "is_loop_or_noisy_func") ||
        strstr(name, "is_hard_exclude"))
        return 1;

    return 0;
}

__attribute__((no_instrument_function))
static void push_stack(void *fn, int printed)
{
    if (g_stack_top < TRACE_STACK_MAX) {
        g_stack[g_stack_top].fn = fn;
        g_stack[g_stack_top].printed = printed;
        g_stack_top++;
    }
}

__attribute__((no_instrument_function))
static int pop_stack(void *fn)
{
    if (g_stack_top <= 0)
        return 0;

    g_stack_top--;

    /*
     * 基本はLIFO一致する想定。
     * 万一ずれても depth を壊さないため printed だけ返す。
     */
    (void)fn;
    return g_stack[g_stack_top].printed;
}

__attribute__((no_instrument_function))
static void print_indent(int depth)
{
    int i;
    for (i = 0; i < depth; i++)
        dprintf(STDERR_FILENO, "  ");
}

__attribute__((no_instrument_function))
void __cyg_profile_func_enter(void *this_fn, void *call_site)
{
    char func[256];
    char caller[256];
    uint32_t cnt;
    int is_loop;
    int printed = 0;

    if (g_in_hook)
        return;

    g_in_hook = 1;

    get_func_name(this_fn, func, sizeof(func));
    get_func_name(call_site, caller, sizeof(caller));

    if (!is_hard_exclude(func)) {
        cnt = count_func(this_fn);
        is_loop = is_loop_or_noisy_func(this_fn, func);

        if (!is_loop || cnt == 1 || (cnt % LOOP_EVERY_N) == 0) {
            print_indent(g_depth);

            if (is_loop) {
                dprintf(STDERR_FILENO,
                        "[ENTER][LOOP cnt=%u] %s (%p) <- %s (%p)\n",
                        cnt, func, this_fn, caller, call_site);
            } else {
                dprintf(STDERR_FILENO,
                        "[ENTER] %s (%p) <- %s (%p)\n",
                        func, this_fn, caller, call_site);
            }

            printed = 1;
        }
    }

    push_stack(this_fn, printed);

    if (printed)
        g_depth++;

    g_in_hook = 0;
}

__attribute__((no_instrument_function))
void __cyg_profile_func_exit(void *this_fn, void *call_site)
{
    int printed;

    (void)call_site;

    if (g_in_hook)
        return;

    g_in_hook = 1;

    printed = pop_stack(this_fn);

    if (printed && g_depth > 0)
        g_depth--;

    g_in_hook = 0;
}
