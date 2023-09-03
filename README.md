# AutoQSignForMac

为 macOS 构建的 QSign 一键包，受到 [Xiangze-Li/qsign-gocq-deploy-pack](https://github.com/Xiangze-Li/qsign-gocq-deploy-pack) 和 [rhwong/unidbg-fetch-qsign-onekey](https://github.com/rhwong/unidbg-fetch-qsign-onekey/) 的启发。

在终端运行 `start.sh` 即可配置和启动签名服务器。如果提示 `zsh: access denied`，需要先运行 `chmod -x start.sh` 来给予权限。

# 初次启动
会让您选择 txlib 版本，及运行 QSign 的主机、端口和 API Key。通常情况下，您可以回车跳过而使用默认配置。

# 忽略的文件
考虑到可能的版权问题，txlib 配置文件不包括在源代码中，请自行取得并放置在 txlib 文件夹中