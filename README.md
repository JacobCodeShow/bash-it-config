# [使用教程]
    这个仓库主要用来给 bash-it 提供配置文件。
    如果本机已经有 bash-it, 当前 ~/.bashrc 和现有 bash-it 启动链保持不变。
    如果本机还没有 bash-it, install.sh 会自动执行 git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it, 并把主题配置成 bobby-jacob。
    ```bash
    ./preflight_check.sh
    ./install.sh
    ```
    install.sh 在真正安装前会先自动执行一次 preflight_check.sh, 然后等待用户确认是否继续。
    如果用户选择不继续, 脚本会直接退出, 并提示先修改配置后再重新执行 install.sh。
    如果你已经确认要忽略检查结果直接继续, 可以执行:
    ```bash
    ./install.sh -f
    ```
    或:
    ```bash
    ./install.sh --force
    ```
    install.sh 会做以下事情:
    1. 自动执行 preflight_check.sh 并等待用户确认
    2. 将当前目录同步到 ~/.shell-config
    3. 如果本机没有 bash-it, 自动克隆 bash-it 到 ~/.bash_it
    4. 按文件名字典序执行安装脚本目录下的脚本, 默认目录名是 sw-installers/
    5. 将 bash-it 所需的 alias/plugin/custom 文件同步到 ~/.bash_it
    6. 将 bobby-jacob 主题同步到 ~/.bash_it/themes
    7. 自动启用 shell-config 相关 alias 和 plugin

# [安装前检查]
    在新机器上建议先执行:
    ```bash
    ./preflight_check.sh
    ```
    该脚本会检查基础命令、推荐依赖、可选工具和关键路径是否存在。
    install.sh 也会在安装前自动重新执行一次这个检查, 避免漏看环境问题。
    如果你明确知道风险并且希望跳过确认提示, 可使用 ./install.sh -f 或 ./install.sh --force。

# [推荐执行方式]
    常见执行路径如下:
    1. 标准安装:
    ```bash
    ./install.sh
    ```
    2. 强制继续安装:
    ```bash
    ./install.sh -f
    ```
    3. 单独补装 Atuin:
    ```bash
    bash ~/.shell-config/sw-installers/install-atuin.sh
    ```

# [日志等级]
    install.sh、preflight_check.sh 和 sw-installers/ 下的安装脚本统一使用彩色日志:
    1. OK: 安装或检查成功
    2. INFO: 普通提示, 例如继续执行、已存在配置等
    3. WARN: 需要注意但不中断, 例如 --force 跳过确认
    4. ERROR: 无法继续执行的错误
    5. CMD RUN: 即将执行的命令

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
    5. 软件安装: sw-installers/install-atuin.sh
    6. 其他: modules/aliases.sh

# [bash-it 映射关系]
    install.sh 会直接把包装文件写入 bash-it 框架目录:
    1. aliases: modules/aliases.sh -> ~/.bash_it/aliases/available/shell-config.aliases.bash
    2. plugins: modules/tools/tool-atuin.sh、modules/tools/tool-nvm.sh、modules/completion/completion-local.sh、modules/completion/completion-openbmc.sh、modules/tools/tool-openbmc-ci.sh、modules/terminal/terminal-settings.sh -> ~/.bash_it/plugins/available
    3. sw-installers: 默认目录是 sw-installers/*.sh, 只由 install.sh 调用, 不会被 bash-it 启动链 source
    4. custom: modules/env/env-locale.sh、modules/env/env-vars.sh、modules/env/machine_local.sh、modules/env/env-path.sh -> ~/.bash_it/custom
    5. theme: bobby-jacob/bobby-jacob.theme.bash -> ~/.bash_it/themes/bobby-jacob/

# [NVM 延迟加载]
    modules/tools/tool-nvm.sh 会在 shell 启动时只注册 node、npm 和 nvm 包装函数, 不会立即 source nvm。
    第一次调用这些命令时才会加载 $HOME/.nvm/nvm.sh 和 bash_completion, 以减少 shell 启动开销。

# [Atuin 集成]
    当前仓库按 Atuin 官方 bash 文档接入历史搜索, 但不让官方安装器直接改 ~/.bashrc:
    1. install.sh 会调用 sw-installers/install-atuin.sh, 使用官方安装器把二进制安装到 ~/.atuin/bin
    2. 安装器以非交互方式运行, 且不会直接修改用户 PATH 或 rc 文件
    3. sw-installers/install-atuin.sh 会确保 ~/.bash-preexec.sh 存在
    4. modules/tools/tool-atuin.sh 会在 bash-it plugin 阶段补 PATH, source ~/.bash-preexec.sh, 然后执行 eval "$(atuin init bash)"
    5. 如果只想单独补装 Atuin, 可以执行 bash ~/.shell-config/sw-installers/install-atuin.sh

# [新增安装脚本]
    如果后续还要增加其他安装脚本, 推荐直接新增到 sw-installers/ 目录。
    install.sh 优先使用 sw-installers/；如果目录名改了, 也会自动发现仓库根目录下第一个包含 install-*.sh 的目录。
    install.sh 会按文件名字典序执行 install-*.sh, 所以如需控制顺序, 可以用前缀命名, 例如 10-foo.sh、20-bar.sh。
    如果没有特殊理由, 仍建议保留默认目录名 sw-installers, 这样路径更稳定, 文档和单独执行命令也更直观。

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