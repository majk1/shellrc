# Utils

z - git clone url: https://github.com/rupa/z.git

## jmemstat

```
[0:user@hostname] ~ $ ps aux | grep '[S]erver:'
user    10489 14.6  8.0 7173756 988344 pts/0  Sl+  10:31   0:22 /opt/java/jdk8/bin/java -D[Server:n1] -Xms3g -Xmx3g -XX:+UseStringDeduplication -XX:+UseG1GC ...
```

all info:
```
[0:user@hostname] ~ $ jmemstat 10489                                                                                                                                                                                                          pts/1 | 10:31
Printing memory info for java process: 10489
.------------.----------------.----------------.---------.
| Mem JVM    |      Allocated |           Used |  Used % |
|------------|----------------|----------------|---------|
| Eden       |   3,141,632.00 |     469,988.15 |  14.96% |
| Oldgen     |       4,096.00 |       3,072.00 |  75.00% |
| Metaspace  |      98,688.00 |      90,546.24 |  91.75% |
|------------|----------------|----------------|---------|
| Total      |   3,244,416.00 |     563,606.39 |  17.37% |
'------------'----------------'----------------'---------'

.----------------.----------------.
|         OS RSS |       OS Dirty |
|----------------|----------------|
|     962,196.00 |     929,940.00 |
'----------------'----------------'
```

brief:
```
[0:user@hostname] ~ $ jmemstat -b 10489                                                                                                                                                                                                       pts/1 | 10:31
JVM (10489) total memory usage by JVM (kB): 3,244,416.00 / 565,805.53 (17.44%)
JVM (10489) total memory usage by OS  (kB): 964,108.00 (RSS), 931,856.00 (Dirty)
```

oneliner:
```
[0:user@hostname] ~ $ jmemstat -1 10489                                                                                                                                                                                                       pts/1 | 10:31
JVM: 3,244,416.00 / 566,748.02 (17.47%), OS: 964,516.00 (RSS), 932,264.00 (Dirty)
```