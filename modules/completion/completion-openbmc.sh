# =========================================
# OpenBMC/Yocto 自动补全配置
# 由 install-obmc-completion.sh 安装
# =========================================
export OBMC_COMPLETION_LOADED=1

# 加载 OpenBMC 环境配置
if [[ -f "$HOME/.config/obmc/obmc-env.bash" ]]; then
    source "$HOME/.config/obmc/obmc-env.bash"
fi

# 加载系统级补全
if [[ -d "$HOME/.local/share/bash-completion/completions" ]]; then
    for file in "$HOME/.local/share/bash-completion/completions"/*; do
        [[ -f "$file" ]] && source "$file"
    done
fi

# 自定义提示符显示 OpenBMC 环境
if [[ -n "$BASH_VERSION" ]]; then
    _obmc_ps1() {
        if [[ -f "oe-init-build-env" ]] || [[ -f "setup" ]] || [[ -d "meta-inventec" ]]; then
            echo "[OBMC] "
        fi
    }
    
    # 如果已经有 PS1，添加我们的标记
    if [[ -n "$PS1" ]]; then
        PS1='$(_obmc_ps1)'"$PS1"
    fi
fi

# 测试函数
test-obmc-completion() {
    echo "测试 OpenBMC 补全系统:"
    echo "1. bitbake <Tab> 应该显示 recipes"
    echo "2. bitbake -c <Tab> 应该显示任务"
    echo "3. devtool <Tab> 应该显示子命令"
    echo "4. 输入 'obmc-status' 查看环境状态"
    echo "5. 输入 'obmc-reload' 重新加载补全"
}

