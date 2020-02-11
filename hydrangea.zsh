#!/bin/zsh
# hydrangea.zsh
# Copyright (c) 2020 Hiroki Konishi <relastle@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

POWERLINE_SEPARATOR=''
POWERLINE_SEPARATOR_FILL=''
NERD_FONT_HOME=''
NERD_FONT_DOCKER=''
NERD_FONT_GIT=' '
NERD_FONT_GIT_UNSTAGED='ﰂ'
NERD_FONT_GIT_STAGED='洛'

TEXT_COLOR_WHITE="white"
TEXT_COLOR_BLACK="black"

BRANCH_COLOR_MASTER="yello"
BRANCH_COLOR_NON_MASTER="white"

POWERLINE_SUCCESS_COLOR="2" # normal green
POWERLINE_FAILURE_COLOR="9" # bright red


status_color=${POWERLINE_SUCCESS_COLOR}
last_exit_code=''

POWERLINE_BASE_COLOR='10'
POWERLINE_DANGER_COLOR='9'

POWERLINE_ACCENT_COLOR1="4" # normal blue (used for git indicator)


vi_status='INSERT'
VI_INSERT_COLOR='yello'
VI_NORMAL_COLOR='cyan'
vi_status_color="${VI_INSERT_COLOR}"

chpwd_flag=false

# set STATUS_COLOR: cyan for "insert", green for "normal" mode.
prompt_hydrangea_vim_mode() {
	vi_status="${${KEYMAP/vicmd/NORMAL}/(main|viins)/INSERT}"
	vi_status_color="${${KEYMAP/vicmd/${VI_NORMAL_COLOR}}/(main|viins)/${VI_INSERT_COLOR}}"
    zle reset-prompt
}

# Set branch color dependent on branch name.
# if `master`, then color will be yellow
prompt_hydrangea_branch_color() {
    current_branch=$(git branch 2>/dev/null | grep \* | cut -d ' ' -f2)
    if [[ ${current_branch} = 'master' ]] ; then
        fmt_branch="%F{${BRANCH_COLOR_MASTER}}%b%f%u%c%f"
    else
        fmt_branch="%F{${BRANCH_COLOR_NON_MASTER}}%b%f%u%c%f"
    fi
    zstyle ':vcs_info:*' formats "${fmt_branch}"
}

prompt_hydrangea_precmd () {
    # change color for status color according to previous cmd exit status
    local LAST_EXIT_CODE=$?
    if [[ $LAST_EXIT_CODE -ne 0 ]]; then
        # last_exit_code=${LAST_EXIT_CODE}
        last_exit_code=''
        status_color=${POWERLINE_FAILURE_COLOR}
    else;
        last_exit_code=''
        status_color=${POWERLINE_SUCCESS_COLOR}
    fi

    # echo "chpwd_flag = ${chpwd_flag} @ precmd"
    if [[ $chpwd_flag != true ]] then
        prompt_hydrangea_branch_color
        vcs_info #&& echo "get VCS_INFO precmd"
    fi
    chpwd_flag=false
}

prompt_hydrangea_preexec () {
    chpwd_flag=false
}

prompt_hydrangea_chpwd () {
    prompt_hydrangea_branch_color
    vcs_info #&& echo "get VCS_INFO chpwd"
    chpwd_flag=true
}

prompt_hydrangea_render() {

    # -------------------------------------
    # LEFT PROMPT
    # -------------------------------------

    if [ -z "$DOCKER_CONTAINER" ]
    then
        POWERLINE_LEFT_DOCKER=""
    else
        POWERLINE_LEFT_DOCKER="%K{${POWERLINE_BASE_COLOR}}%F{${TEXT_COLOR_WHITE}} $NERD_FONT_DOCKER $DOCKER_CONTAINER"
    fi

    if [[ $(hostname) != ${HYDRANGEA_WHITE_HOST_NAME} ]] then
        display_host_name=" $(hostname):"
    else
        display_host_name=""
    fi

    if [[ ${HYDRANGEA_HOST_NAME_DANGER} != "" && $(Hostname) =~ "${HYDRANGEA_HOST_NAME_DANGER}" ]] then
        POWERLINE_HOSTNAME_COLOR=${POWERLINE_DANGER_COLOR}
        BEGIN_POWERLINE_SEPERATOR="%K{${POWERLINE_DANGER_COLOR}}%F{${POWERLINE_BASE_COLOR}}$POWERLINE_SEPARATOR_FILL"
    else
        POWERLINE_HOSTNAME_COLOR=${POWERLINE_BASE_COLOR}
        BEGIN_POWERLINE_SEPERATOR="%K{${POWERLINE_BASE_COLOR}}%F{${TEXT_COLOR_WHITE}}$POWERLINE_SEPARATOR"
    fi

    END_POWERLINE_SEPERATOR="%K{${POWERLINE_ACCENT_COLOR1}}%F{${POWERLINE_HOSTNAME_COLOR}}$POWERLINE_SEPARATOR_FILL"

    # for current directory name (and host name if sshed)
    POWERLINE_LEFT_HOSTNAME="${BEGIN_POWERLINE_SEPERATOR} "$NERD_FONT_HOME""${display_host_name}" %c ${END_POWERLINE_SEPERATOR}"

    # for git branch and status
    POWERLINE_LEFT_GIT="%K{${POWERLINE_ACCENT_COLOR1}}%F{${TEXT_COLOR_WHITE}} $NERD_FONT_GIT "'${vcs_info_msg_0_}'" %k%f%K{"'${status_color}'"%}%F{${POWERLINE_ACCENT_COLOR1}}"$POWERLINE_SEPARATOR_FILL

    POWERLINE_LEFT_EXIT_CODE="%F{${TEXT_COLOR_BLACK}}"'${last_exit_code}'"%k%f%{${reset_color}%}%F{"'${status_color}'"}""${POWERLINE_SEPARATOR_FILL}%{${reset_color}%}"

    PROMPT="${POWERLINE_LEFT_TMP}${POWERLINE_LEFT_DOCKER}${POWERLINE_LEFT_HOSTNAME}${POWERLINE_LEFT_GIT}${POWERLINE_LEFT_EXIT_CODE} %f%k"

    # -------------------------------------
    # Right PROMPT
    # -------------------------------------
    RPROMPT="%F{"'${vi_status_color}'"}[--"'${vi_status}'"--] %F{green}%~%f"
}

prompt_hydrangea_setup() {
    export KEYTIMEOUT=20

    fmt_staged="%F{red} ${NERD_FONT_GIT_STAGED}%f"
    fmt_unstaged="%F{yellow} ${NERD_FONT_GIT_UNSTAGED}%f"
    fmt_branch="%F{${TEXT_COLOR_WHITE}}%b%f%u%c%f"
    fmt_action="%F{red}[%a]%f"

	add-zsh-hook precmd prompt_hydrangea_precmd
	add-zsh-hook preexec prompt_hydrangea_preexec
	add-zsh-hook chpwd prompt_hydrangea_chpwd

	zle -N zle-line-init prompt_hydrangea_vim_mode
	zle -N zle-keymap-select prompt_hydrangea_vim_mode

    autoload -Uz vcs_info
    zstyle ":vcs_info:*" enable git
    zstyle ':vcs_info:git:*' check-for-changes true
    zstyle ':vcs_info:git:*' stagedstr "${fmt_staged}"
    zstyle ':vcs_info:git:*' unstagedstr "${fmt_unstaged}"
    zstyle ':vcs_info:*' formats "${fmt_branch}"
    zstyle ':vcs_info:*' actionformats "${fmt_branch}${fmt_action}"

    prompt_hydrangea_render
}

prompt_hydrangea_setup
