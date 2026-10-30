FAPB 航点目录
=============

FAPB 使用 YAPB / PODBot 格式的 .pwf 航点文件。

GitHub 仓库为了控制体积，没有包含完整的航点数据
（94 张地图的 .pwf 及配套 .pmt/.exp/.vis/.xml，共 455 个文件，约 170 MB）。
获取完整航点有两种方式：

1. 从 GitHub Releases 下载 FAPB_1.0.zip，解压后把其中的
   wptdefault 文件夹复制到这里；
2. 从已有的 YAPB 安装中复制：
   cstrike/addons/yapb/wptdefault/*  ->  cstrike/addons/fapb/wptdefault/

也可以只放当前地图需要的 .pwf 文件，例如 de_dust2.pwf。
