#!/bin/bash
set -e

SDK=~/ti-processor-sdk-rtos-j722s-evm-11_01_00_04
APP_PATH=$SDK/vision_apps/apps/basic_demos/app_multi_cam
OUT_PATH=$SDK/vision_apps/out/J722S/A53/LINUX/release

TARGET_IP=192.168.10.2   # ←自分の環境に合わせて
TARGET_USER=root

echo "==== 1. Build SDK ===="
cd $SDK/sdk_builder
make sdk -j$(nproc)

echo "==== 2. Generate symbol list ===="
cd $SDK

nm -an $OUT_PATH/libtivision_apps.so \
  | awk '$2=="t" || $2=="T" {print $1, $3}' \
  | sort > libtivision_symbols.txt

echo "==== 3. Generate trace_symbols.h ===="

cat > gen_trace_symbols.sh << 'EOF'
#!/bin/bash
IN=$1
OUT=$2

echo '#ifndef TRACE_SYMBOLS_H' > $OUT
echo '#define TRACE_SYMBOLS_H' >> $OUT
echo '' >> $OUT
echo 'typedef struct {' >> $OUT
echo '    unsigned long offset;' >> $OUT
echo '    const char *name;' >> $OUT
echo '} TraceSymbol;' >> $OUT
echo '' >> $OUT
echo 'static const TraceSymbol g_libtivision_symbols[] = {' >> $OUT

awk '{printf("    { 0x%sUL, \"%s\" },\n", $1, $2);}' $IN >> $OUT

echo '};' >> $OUT
echo '' >> $OUT
echo 'static const unsigned int g_libtivision_symbols_num =' >> $OUT
echo '    sizeof(g_libtivision_symbols) / sizeof(g_libtivision_symbols[0]);' >> $OUT
echo '' >> $OUT
echo '#endif' >> $OUT
EOF

chmod +x gen_trace_symbols.sh

./gen_trace_symbols.sh \
  libtivision_symbols.txt \
  $APP_PATH/trace_symbols.h

echo "==== 4. Rebuild app (hook + header反映) ===="
cd $SDK/sdk_builder

rm -f $OUT_PATH/module/apps.basic_demos.app_multi_cam/hook_trace.o
rm -f $OUT_PATH/vx_app_multi_cam.out

make sdk -j$(nproc)

echo "==== 5. Deploy to target ===="

scp $OUT_PATH/vx_app_multi_cam.out $TARGET_USER@$TARGET_IP:/opt/vision_apps/
scp $OUT_PATH/libtivision_apps.so.11.1.0 $TARGET_USER@$TARGET_IP:/usr/lib/

ssh $TARGET_USER@$TARGET_IP << 'EOF'
sync
ldconfig
echo "Deploy done"
EOF

echo "==== DONE ===="
