#!/bin/sh
systemctl stop vision_apps
sleep 3
/opt/vision_apps/vx_app_multi_cam.out --is_interactive 1 --cfg /opt/vision_apps/app_multi_cam.cfg