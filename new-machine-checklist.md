# 新机器最小迁移清单

## 目标

这份清单只覆盖最小可用路径:
1. 在新机器接入当前仓库中的个人配置
2. 保留当前 bash-it 的 ~/.bashrc
3. 让本仓库只作为 bash-it 配置来源

## 0. 安装前确认

优先执行:

```bash
./preflight_check.sh
```

如果还需要手工确认, 再检查这些命令:

```bash
command -v bash
command -v git
command -v curl
command -v grep
command -v awk
```

建议额外具备这些能力, 但不是绝对强制:

```bash
command -v rsync
command -v dircolors
command -v tput
```

如果新机器要用历史搜索和跳转, 再确认:

```bash
command -v autojump
```

atuin 不需要在安装前手工准备, install.sh 会自动安装到 ~/.atuin/bin, 并补齐 ~/.bash-preexec.sh。

## 1. 确认当前 bash-it 启动链

```bash
grep -n 'bash_it.sh' ~/.bashrc
```

如果当前机器还没有 bash-it 接入, 先按你自己的方式完成 bash-it 官方安装。这个仓库不会生成或覆盖 ~/.bashrc。

## 2. 获取配置仓库

把当前目录复制或 clone 到新机器任意位置, 例如:

```bash
git clone <your-repo-url> ~/shell-config-src
cd ~/shell-config-src
```

如果不是 git 仓库, 直接把整个目录拷过去也可以。

## 3. 安装当前配置

```bash
cd ~/shell-config-src
./install.sh
```

执行 install.sh 时, 脚本会先自动跑一次 preflight_check.sh。
看完输出后, 需要你手工确认是否继续安装。

如果你已经确认风险并且希望跳过确认提示, 可以执行:

```bash
./install.sh -f
```

如果确认继续, 会完成这些动作:
1. 同步配置到 ~/.shell-config
2. 按文件名字典序执行安装脚本目录下的 install-*.sh, 默认目录名是 sw-installers/, 当前会安装 Atuin 到 ~/.atuin/bin, 并补齐 ~/.bash-preexec.sh
3. 将 bash-it 需要的 alias/plugin/custom 文件同步到 ~/.bash_it
4. 将 bobby-jacob 主题同步到 ~/.bash_it/themes
5. 自动启用 shell-config 相关 alias 和 plugin
6. 保留当前 ~/.bashrc 不变, 继续使用你现有的 bash-it 启动链

如果不继续, install.sh 会直接退出, 并提示你先修改配置后再重新执行 install.sh。
如果使用了 -f 或 --force, install.sh 会打印 WARN 级别提示, 然后跳过确认直接继续。

## 4. 填写机器专属配置

首次迁移时, 建议从模板开始:

```bash
cp ~/.shell-config/modules/env/machine-local.example.sh ~/.shell-config/modules/env/machine_local.sh
```

然后至少检查这些变量:
1. BMC_IP
2. BMC_USER_NAME
3. BMC_PASSWORD
4. LDAP_USER
5. BT_USER_NAME
6. BT_PWD

如果新机器上的工具目录不同, 再检查这些文件:
1. modules/aliases.sh
2. modules/env/env-path.sh
3. modules/completion/completion-local.sh

## 5. 重新加载并验证

```bash
source ~/.bashrc
```

先做最小验证:

```bash
alias ll
alias ipmi
echo "$BMC_IP"
echo "$PATH"
type ci
```

如果你依赖 OpenBMC 补全和 atuin, 再额外检查:

```bash
type test-obmc-completion
command -v atuin
test -f ~/.bash-preexec.sh
atuin doctor | grep preexec
```

如果 atuin 没装上, 可以单独执行:

```bash
bash ~/.shell-config/sw-installers/install-atuin.sh
```

如果后续新增其他安装脚本, 推荐也放在 ~/.shell-config/sw-installers/ 下。即使目录名改了, install.sh 也会自动发现仓库根目录下包含 install-*.sh 的目录并执行。

## 6. 常见问题快速检查

如果启动 shell 后报错, 先检查:

```bash
ls ~/.bash_it
ls ~/.shell-config
ls ~/.bash_it/aliases/enabled | grep shell-config
ls ~/.bash_it/plugins/enabled | grep shell-config
ls ~/.bash_it/themes/bobby-jacob
```

如果 alias 存在但命令不可用, 重点看:
1. machine_local.sh 是否填写正确
2. aliases.sh 中引用的路径在新机器是否存在
3. env-path.sh 中追加的目录是否真实存在

## 7. bash-it 卸载和回滚

只移除导入到 bash-it 的 shell-config 文件:

```bash
cd ~/.shell-config
./uninstall.sh
```

连 bash-it 框架目录一起删除:

```bash
cd ~/.shell-config
./uninstall.sh --remove-framework
```

如果你只想完全回到迁移前状态:

```bash
rm -rf ~/.bash_it
```

## 8. 建议的最小迁移范围

首次上新机器时, 不要一开始就追求所有工具都恢复。优先保证以下能力:
1. Bash 能正常启动
2. bash-it 能正常启动
3. 常用 alias 可用
4. 核心环境变量正确
5. 回滚命令有效

等这些稳定后, 再补 atuin、autojump、OpenBMC 补全、私有工具路径, 或按需接入 bash-it 框架。