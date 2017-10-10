#!/usr/bin/env bash

unset j_pid
brief=0
debug=0

while [ ! -z "$1" ]; do
    param="$1"
    case "$param" in
        -b|--brief)
            brief=1
            shift
        ;;
        --debug)
            debug=1
            shift
        ;;
        *)
            j_pid="$param"
            shift
        ;; 
    esac
done

if [ -z "$j_pid" ]; then
    echo "Usage: jmemstat [-b|--brief --debug] <pid>" >&2
    echo "" >&2
    echo "       -b|--brief       - brief output, not that table structure beauty :D" >&2
    echo "       --debug          - raw jstat fields printed" >&2
    echo "" >&2
    exit 1
fi

[ $brief -eq 0 ] && echo "Printing memory info for java process: $j_pid"

read j_eden j_old j_meta < <(jstat -gccapacity $j_pid | awk 'END{eden=$6; old=$10; meta=$13; printf "%0.2f %0.2f %0.2f", eden, old, meta}') 
[ $debug -eq 1 ] && echo "EC=$j_eden, OC=$j_old, MC=$j_meta" >&2
read j_eden_p j_old_p j_meta_p < <(jstat -gcutil $j_pid | awk 'END{eden=$3; old=$4; meta=$5; print eden" "old" "meta}')
[ $debug -eq 1 ] && echo "E=$j_eden_p, O=$j_old_p, M=$j_meta_p" >&2

read j_eden_usage < <(awk 'BEGIN{usage=ARGV[1]*(ARGV[2]/100); printf "%0.2f", usage}' $j_eden $j_eden_p) 
read j_old_usage < <(awk 'BEGIN{usage=ARGV[1]*(ARGV[2]/100); printf "%0.2f", usage}' $j_old $j_old_p)
read j_meta_usage < <(awk 'BEGIN{usage=ARGV[1]*(ARGV[2]/100); printf "%0.2f", usage}' $j_meta $j_meta_p)

read j_sum < <(awk 'BEGIN{sum=0; for (i=1;i<ARGC;i++) {sum+=ARGV[i]}; printf "%0.2f", sum}' $j_eden $j_old $j_meta)
read j_sum_usage < <(awk 'BEGIN{sum=0; for (i=1;i<ARGC;i++) {sum+=ARGV[i]}; printf "%0.2f", sum}' $j_eden_usage $j_old_usage $j_meta_usage)
read j_sum_p < <(awk 'BEGIN{usage=(ARGV[2]/ARGV[1])*100; printf "%0.2f", usage}' $j_sum $j_sum_usage)

os_mem_present=0
if type -p pmap >/dev/null 2>&1; then
    read os_rss os_dirty < <(pmap -x $j_pid | awk 'END{printf "%0.2f %0.2f\n", $4, $5}')
    os_mem_present=1
fi

if [ $brief -eq 1 ]; then
    printf "JVM (%d) total memory usage by JVM (kB): %'.2f / %'.2f (%s%%)\n" $j_pid $j_sum $j_sum_usage $j_sum_p
    if [ $os_mem_present -eq 1 ]; then
        printf "JVM (%d) total memory usage by OS  (kB): %'.2f (RSS), %'.2f (Dirty)\n" $j_pid $os_rss $os_dirty
    else
        echo "[WARN] OS memory usage cannot be determined, pmap not found" >&2
    fi
else
    printf ".------------.----------------.----------------.---------.\n"
    printf "| %-10s | %14s | %14s | %6s%% |\n" "Mem JVM" "Allocated" "Used" "Used "
    printf "|------------|----------------|----------------|---------|\n"
    printf "| %-10s | %'14.2f | %'14.2f | %6s%% |\n" "Eden" $j_eden $j_eden_usage $j_eden_p
    printf "| %-10s | %'14.2f | %'14.2f | %6s%% |\n" "Oldgen" $j_old $j_old_usage $j_old_p
    printf "| %-10s | %'14.2f | %'14.2f | %6s%% |\n" "Metaspace" $j_meta $j_meta_usage $j_meta_p
    printf "|------------|----------------|----------------|---------|\n"
    printf "| %-10s | %'14.2f | %'14.2f | %6s%% |\n" "Total" $j_sum $j_sum_usage $j_sum_p
    printf "'------------'----------------'----------------'---------'\n"
    if [ $os_mem_present -eq 1 ]; then
        echo
        printf ".----------------.----------------.\n"
        printf "| %14s | %14s |\n" "OS RSS" "OS Dirty"
        printf "|----------------|----------------|\n"
        printf "| %'14.2f | %'14.2f |\n" $os_rss $os_dirty
        printf "'----------------'----------------'\n"
        echo
    else
        echo
        echo "[WARN] OS memory usage cannot be determined, pmap not found" >&2
        echo
    fi
fi
