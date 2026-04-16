# [使用教程]
    这个仓库主要用来给 bash-it 提供配置文件。
    如果本机已经有 bash-it, 当前 ~/.bashrc 和现有 bash-it 启动链保持不变。
    如果本机还没有 bash-it, install.sh 会自动执行 git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it, 并把主题配置成 bobby-jacob。
    ```bash
    ./preflight_check.sh
    ./install.sh
    ```
    install.sh 会做以下事情:
    1. 将当前目录同步到 ~/.shell-config
    2. 如果本机没有 bash-it, 自动克隆 bash-it 到 ~/.bash_it
    3. 将 bash-it 所需的 alias/plugin/custom 文件同步到 ~/.bash_it
    4. 将 bobby-jacob 主题同步到 ~/.bash_it/themes
    5. 自动启用 shell-config 相关 alias 和 plugin

# [安装前检查]
    在新机器上建议先执行:
    ```bash
    ./preflight_check.sh
    ```
    该脚本会检查基础命令、推荐依赖、可选工具和关键路径是否存在

# [提示符实现]
    当前提示符改为由 bash-it 主题 bobby-jacob 提供
    提示符会显示以下信息:
    1. 时间
    2. 命令计数
    3. user@hostname
    4. 当前目录
    5. git 分支和状态
    6. 上一条命令执行状态
    7. 当前用户对应的 #/$

# [当前模块命名]
    已按职责整理为以下几类:
    1. bash-it 主题: bobby-jacob/bobby-jacob.theme.bash
    2. 环境: modules/env/env-locale.sh、modules/env/env-vars.sh、modules/env/env-path.sh、modules/env/machine_local.sh
    3. 补全与工具: modules/completion/completion-local.sh、modules/completion/completion-openbmc.sh、modules/tools/tool-atuin.sh、modules/tools/tool-nvm.sh、modules/tools/tool-openbmc-ci.sh
    4. 终端: modules/terminal/terminal-settings.sh
    5. 其他: modules/aliases.sh

# [bash-it 映射关系]
    install.sh 会直接把包装文件写入 bash-it 框架目录:
    1. aliases: modules/aliases.sh -> ~/.bash_it/aliases/available/shell-config.aliases.bash
    2. plugins: modules/tools/tool-atuin.sh、modules/tools/tool-nvm.sh、modules/completion/completion-local.sh、modules/completion/completion-openbmc.sh、modules/tools/tool-openbmc-ci.sh、modules/terminal/terminal-settings.sh -> ~/.bash_it/plugins/available

# [NVM 延迟加载]
    modules/tools/tool-nvm.sh 会在 shell 启动时只注册 node、npm 和 nvm 包装函数, 不会立即 source nvm。
    第一次调用这些命令时才会加载 $HOME/.nvm/nvm.sh 和 bash_completion, 以减少 shell 启动开销。
    3. custom: modules/env/env-locale.sh、modules/env/env-vars.sh、modules/env/machine_local.sh、modules/env/env-path.sh -> ~/.bash_it/custom
    4. theme: bobby-jacob/bobby-jacob.theme.bash -> ~/.bash_it/themes/bobby-jacob/

# [主题启用]
    如果本机已经有 bash-it, 安装脚本会把主题文件复制到 ~/.bash_it/themes/bobby-jacob, 但不会改你的 bash-it 配置。
    如果本机还没有 bash-it, 安装脚本会自动 bootstrap bash-it 并把 ~/.bashrc 里的主题配置成 bobby-jacob。

# [bash-it 卸载]
    如果想移除已安装的 shell-config:
    ```bash
    ./uninstall.sh
    ```
    如果还想删除 ~/.bash_it 目录:
    ```bash
    ./uninstall.sh --remove-framework
    ```
    uninstall.sh 会删除 ~/.shell-config、导入到 ~/.bash_it 的 shell-config 文件以及 bobby-jacob 主题。
    如果 bash-it 是由 install.sh 自动 bootstrap 的, 执行 ./uninstall.sh --remove-framework 时也会清理 ~/.bashrc 中由 shell-config 自动写入的 bash-it 启动块。

# [机器专属配置]
    新机器请优先复制 modules/env/machine-local.example.sh 为 modules/env/machine_local.sh, 然后修改其中的 IP、用户名、密码和机器路径
    ```bash
    cp ~/.shell-config/modules/env/machine-local.example.sh ~/.shell-config/modules/env/machine_local.sh
    ```
    modules/env/machine_local.sh 会在通用模块之后加载, 便于做覆盖和迁移

# [shell支持列表]
    - "bash"

# [npm 全局安装路径]
    默认会把 npm 全局安装前缀设为 $HOME/.local/npm, 避免系统 npm 在 /usr/local 下做全局安装时出现权限错误。
    对应可执行文件目录 $HOME/.local/npm/bin 会自动加入 PATH。