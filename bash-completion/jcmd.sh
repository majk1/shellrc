# jcmd completion

_jcmd()
{
    local cur prev jcmds jcmdlist jpids jmainclasses
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    jcmds="-f
PerfCounter.print
JFR.stop
JFR.start
JFR.dump
JFR.check
VM.native_memory
VM.check_commercial_features
VM.unlock_commercial_features
ManagementAgent.stop
ManagementAgent.start_local
ManagementAgent.start
Thread.print
GC.class_stats
GC.class_histogram
GC.heap_dump
GC.run_finalization
GC.run
VM.uptime
VM.flags
VM.system_properties
VM.command_line
VM.version
help"

    jcmdlist="$(jcmd -l | grep -v 'sun.tools.jcmd.JCmd')"
    jpids="$(echo -e "$jcmdlist" | awk '{print $1}')"
    jmainclasses="$(echo -e "$jcmdlist" | awk '{print $2}' | grep -v '^$' | sort | uniq)"

    if [[ ${prev} == jcmd ]]; then
        if [[ ${cur} =~ [a-z].* ]]; then
            COMPREPLY=( $(compgen -S ' ' -W "$jmainclasses" -- ${cur}) )
        else
            COMPREPLY=( $(compgen -S ' ' -W "$jpids" -- ${cur}) )
        fi
    else
        if [[ ${prev} == -f ]]; then
            compopt -o default
            COMPREPLY=()
            return 0
        else
            COMPREPLY=( $(compgen -S ' ' -W "$jcmds" -- ${cur}) )
        fi
    fi
}

complete -o default -F _jcmd jcmd
COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
