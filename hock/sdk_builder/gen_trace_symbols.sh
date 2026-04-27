#!/bin/sh

IN="$1"
OUT="$2"

echo '#ifndef TRACE_SYMBOLS_H' > "$OUT"
echo '#define TRACE_SYMBOLS_H' >> "$OUT"
echo '' >> "$OUT"
echo 'typedef struct {' >> "$OUT"
echo '    unsigned long offset;' >> "$OUT"
echo '    const char *name;' >> "$OUT"
echo '} TraceSymbol;' >> "$OUT"
echo '' >> "$OUT"
echo 'static const TraceSymbol g_libtivision_symbols[] = {' >> "$OUT"

awk '{
    printf("    { 0x%sUL, \"%s\" },\n", $1, $2);
}' "$IN" >> "$OUT"

echo '};' >> "$OUT"
echo '' >> "$OUT"
echo 'static const unsigned int g_libtivision_symbols_num =' >> "$OUT"
echo '    sizeof(g_libtivision_symbols) / sizeof(g_libtivision_symbols[0]);' >> "$OUT"
echo '' >> "$OUT"
echo '#endif' >> "$OUT"
