# J722S Vision Apps Module Configuration from Logs

この構成図は、取得済みログから見えているモジュール境界を整理したものです。

## 見えている大きな構成

| 層 | 主なモジュール |
|---|---|
| Linux / A53 | `vx_app_multi_cam.out`, app_common, TIOVX Host, RemoteService Client, IPC, FileIO, Graphics Overlay |
| App Modules | Sensor, Capture, VISS, AEWB, LDC, ImgMosaic, Display |
| MCU2_0 / FreeRTOS | APP Init, SCICLIENT, MEM/UDMA, IPC, RemoteService Server, TIOVX Target Runtime, FVID2, Display App, CSI2RX/TX, ISS |
| C7x_1 / C7x_2 | FreeRTOS APP Init, IPC/RemoteService, TIOVX DSP target runtime |
| Hardware | VPAC(LDC/MSC/VISS/FC), DMPAC(DOF/SDE), Capture targets, Display targets, CSI, SN65DSI bridge, UB960/IMX390 |

## 重要な接続

- Linux A53 の `app_querry_sensor` / `app_init_sensor` は RemoteService + IPC 経由で MCU2_0 の ISS / Image Sensor Service に到達する。
- MCU2_0 は VPAC/VHWA、CSI2RX/TX、Display、ISSを初期化する。
- C7x_1/C7x_2 は TIOVX DSP target runtime として登録される。
- Graph上の Capture/VISS/LDC/Display などは TIOVX Host から各 target へ接続される。
- ログ上のセンサ失敗点は UB960 de-serializer register access failure。
