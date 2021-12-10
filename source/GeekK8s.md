-- 《深入剖析Kubernetes》
 
   [原文](https://time.geekbang.org/column/intro/116) | 
   [转载](http://xujl.site/2019/04/25/深入剖析Kubernetes/) | 
   [!image](https://static001.geekbang.org/resource/image/0d/cb/0da944e5bac4fe1d00d3f01a747e86cb.jpg)
## 1. 预习篇 · 小鲸鱼大事记（一）：初出茅庐 
## 2. 预习篇 · 小鲸鱼大事记（二）：崭露头角 
## 3. 预习篇 · 小鲸鱼大事记（三）：群雄并起 
## 4. 预习篇 · 小鲸鱼大事记（四）：尘埃落定 
## 5. 白话容器基础（一）：从进程说开去 
而容器技术的核心功能，就是通过约束和修改进程的动态表现，从而为其创造出一个“边界”。
对于 Docker 等大多数 Linux 容器来说，Cgroups 技术是用来制造约束的主要手段，而Namespace 技术则是用来修改进程视图的主要方法。
我们在 Docker 里最开始执行的 /bin/sh，就是这个容器内部的第 1 号进程（PID=1），
Namespace 机制： 对被隔离应用的进程空间做了手脚，使得这些进程只能看到重新计算过的进程编号，比如 PID=1。可实际上，他们在宿主机的操作系统里，还是原来的第 100 号进程。
int pid = clone(main_function, stack_size, CLONE_NEWPID | SIGCHLD, NULL); 
Linux 操作系统提供了 PID、Mount、UTS、IPC、Network 和 User 这些 Namespace，用来对各种不同的进程上下文进行“障眼法”操作。
容器，其实是一种特殊的进程而已。
容器隔离性没办法达到虚拟机的级别。
容器是一个单进程。 jdk, netstat, ping等在运行，但它们不受docker的控制，就像野孩子。所以单进程意思不是只能运行一个进程，而是只有一个进程是可控的。
docker engine 最好虚线标识，表示他只是一种启动时用，运行时并不需要，真实进程是直接run在host os上

## 6. 白话容器基础（二）：隔离与限制 
容器是一个“单进程”模型。
一个正在运行的 Docker 容器，其实就是一个启用了多个 Linux Namespace 的应用进程，而这个进程能够使用的资源量，则受 Cgroups 配置的限制。
由于一个容器的本质就是一个进程，用户的应用进程实际上就是容器里 PID=1 的进程，也是其他后续创建的所有进程的父进程。这就意味着，在一个容器中，你没办法同时运行两个不同的应用，除非你能事先找到一个公共的 PID=1 的程序来充当两个不同应用的父进程，这也是为什么很多人都会用 systemd 或者 supervisord 这样的软件来代替应用本身作为容器的启动进程。
希望容器和应用能够同生命周期
跟 Namespace 的情况类似，Cgroups 对资源的限制能力也有很多不完善的地方，被提及最多的自然是 /proc 文件系统的问题
容器里执行 top 指令，就会发现，它显示的信息居然是宿主机的 CPU 和内存数据，而不是当前容器的数据。 应用程序在容器里读取到的 CPU 核数、可用内存等信息都是宿主机上的数据
Namespace 技术实际上修改了应用进程看待整个计算机“视图”，即它的“视线”被操作系统做了限制，只能“看到”某些指定的内容。
Docker Engine并不像 Hypervisor 那样对应用进程的隔离环境负责，也不会创建任何实体的“容器”，真正对隔离环境负责的是宿主机操作系统本身
一个运行着 CentOS 的 KVM 虚拟机启动后，在不做优化的情况下，虚拟机自己就需要占用 100~200 MB 内存。此外，用户应用运行在虚拟机里面，它对宿主机操作系统的调用就不可避免地要经过虚拟化软件的拦截和处理，这本身又是一层性能损耗，尤其对计算资源、网络和磁盘 I/O 的损耗非常大。
“敏捷”和“高性能”是容器相较于虚拟机最大的优势，也是它能够在 PaaS 这种更细粒度的资源管理平台上大行其道的重要原因。
隔离得不彻底。
首先，既然容器只是运行在宿主机上的一种特殊的进程，那么多个容器之间使用的就还是同一个宿主机的操作系统内核。
其次，在 Linux 内核中，有很多资源和对象是不能被 Namespace 化的，最典型的例子就是：时间。
    容器中的程序使用 settimeofday(2) 系统调用修改了时间，整个宿主机的时间都会被随之修改.
    安全问题。Seccomp 等技术有损性能，难以实现。
    基于虚拟化或者独立内核技术的容器实现， 平衡了隔离与性能。 
Linux Cgroups 就是 Linux 内核中用来为进程设置资源限制的一个重要功能。
Linux Cgroups 的全称是 Linux Control Group。它最主要的作用，就是限制一个进程组能够使用的资源上限，包括 CPU、内存、磁盘、网络带宽等等。
```
/sys/fs/cgroup
$ mount -t cgroup 
ls /sys/fs/cgroup/cpu
root@ubuntu:/sys/fs/cgroup/cpu$ mkdir container
root@ubuntu:/sys/fs/cgroup/cpu$ ls container/
cgroup.clone_children cpu.cfs_period_us cpu.rt_period_us  cpu.shares notify_on_release
cgroup.procs      cpu.cfs_quota_us  cpu.rt_runtime_us cpu.stat  tasks
$ while : ; do : ; done &
[1] 226
$ top
%Cpu0 :100.0 us, 0.0 sy, 0.0 ni, 0.0 id, 0.0 wa, 0.0 hi, 0.0 si, 0.0 st
$ cat /sys/fs/cgroup/cpu/container/cpu.cfs_quota_us 
-1
$ cat /sys/fs/cgroup/cpu/container/cpu.cfs_period_us 
100000
$ echo 20000 > /sys/fs/cgroup/cpu/container/cpu.cfs_quota_us
$ echo 226 > /sys/fs/cgroup/cpu/container/tasks 
$ top
%Cpu0 : 20.3 us, 0.0 sy, 0.0 ni, 79.7 id, 0.0 wa, 0.0 hi, 0.0 si, 0.0 st
```
blkio，为​​​块​​​设​​​备​​​设​​​定​​​I/O 限​​​制，一般用于磁盘等设备；
cpuset，为进程分配单独的 CPU 核和对应的内存节点；
memory，为进程设定内存使用的限制。
Linux Cgroups 的设计还是比较易用的，简单粗暴地理解呢，它就是一个子系统目录加上一组资源限制文件的组合。
对于 Docker 等 Linux 容器项目来说，它们只需要在每个子系统下面，为每个容器创建一个控制组（即创建一个新目录），然后在启动容器进程之后，把这个进程的 PID 填写到对应控制组的 tasks 文件中就可以了。
```
$ docker run -it --cpu-period=100000 --cpu-quota=20000 ubuntu /bin/bash
$ cat /sys/fs/cgroup/cpu/docker/5d5c9f67d/cpu.cfs_period_us 
100000
$ cat /sys/fs/cgroup/cpu/docker/5d5c9f67d/cpu.cfs_quota_us 
20000
```

## 7. 白话容器基础（三）：深入理解容器镜像 
rootfs。它只是一个操作系统的所有文件和目录，并不包含内核，最多也就几百兆。
结合使用 Mount Namespace 和 rootfs，容器就能够为进程构建出一个完善的文件系统隔离环境。得益于 chroot 和 pivot_root 这两个系统调用切换进程根目录的能力。
层: 使用多个增量 rootfs 联合挂载一个完整 rootfs 
容器镜像打通了“开发 - 测试 - 部署”流程的每一个环节, 将会成为未来软件的主流发布方式。
```shell script
  int container_pid = clone(container_main, container_stack+STACK_SIZE, CLONE_NEWNS | SIGCHLD , NULL);
```
Mount Namespace 修改的，是容器进程对文件系统“挂载点”的认知。
```shell script
  mount("none", "/tmp", "tmpfs", 0, "");

$ gcc -o ns ns.c
$ ./ns
Parent - start a container!
Container - inside the container!
$ ls /tmp

$ mount -l | grep tmpfs
none on /tmp type tmpfs (rw,relatime)
```
Mount Namespace 跟其他 Namespace 的使用 不同 ：它对容器进程视图的改变，一定是伴随着挂载操作（mount）才能生效。
在容器进程启动之前重新挂载它的整个根目录“/” . 由于 Mount Namespace 的存在，这个挂载对宿主机不可见，所以容器进程就可以在里面随便折腾了。
chroot: “change root file system”，即改变进程的根目录到你指定的位置。
Mount Namespace 正是基于对 chroot 的不断改良才被发明出来的，它也是 Linux 操作系统里的第一个 Namespace。
rootfs: 这个挂载在容器根目录上、用来为容器进程提供隔离后执行环境的文件系统，就是所谓的“容器镜像”。它还有一个更为专业的名字，叫作：rootfs（根文件系统）。 
```shell script
# 常见rootfs(容器镜像)根目录
$ ls /
bin dev etc home lib lib64 mnt opt proc root run sbin sys tmp usr var
```
Docker 项目来说，它最核心的原理实际上就是为待创建的用户进程：启用 Linux Namespace 配置；设置指定的 Cgroups 参数；切换进程的根目录（Change Root）。
rootfs 只是一个操作系统所包含的文件、配置和目录，并不包括操作系统内核。在 Linux 操作系统中，这两部分是分开存放的，操作系统只有在开机启动时才会加载指定版本的内核镜像。
容器和宿主机共用内核， 若单独配置内核参数、加载额外的内核模块，以及跟内核进行直接的交互，是操作的全局变量。
由于 rootfs 的存在，容器才有了一个被反复宣传至今的重要特性：一致性。
由于 rootfs 里打包的不只是应用，而是整个操作系统的文件和目录，也就意味着，应用以及它运行所需要的所有依赖，都被封装在了一起。
对一个应用来说，操作系统本身才是它运行所需要的最完整的“依赖库”。
这种深入到操作系统级别的运行环境一致性，打通了应用在本地开发和远端执行环境之间难以逾越的鸿沟。
联合文件系统（Union File System）Union File System 也叫 UnionFS，最主要的功能是将多个不同位置的目录联合挂载（union mount）到同一个目录下。
$ mount -t aufs -o dirs=./A:./B none ./C
docker info
AuFS 的全称是 Another UnionFS，后改名为 Alternative UnionFS，再后来干脆改名叫作 Advance UnionFS
AuFS关键目录： /var/lib/docker/aufs/diff/<layer_id>   `ls /var/lib/docker/overlay2/`
$ docker image inspect ubuntu:latest
挂载点就是 /var/lib/docker/aufs/mnt/
$ ls /var/lib/docker/aufs/mnt/6e3be5d2ecccae7cc0fcfa2a2f5c89dc21ee30e166be823ceaeba15dce645b3e
bin boot dev etc home lib lib64 media mnt opt proc root run sbin srv sys tmp usr var
如何被联合挂载的 /sys/fs/aufs 
```
$ cat /proc/mounts| grep aufs
none /var/lib/docker/aufs/mnt/6e3be5d2ecccae7cc0fc... aufs rw,relatime,si=972c6d361e6b32ba,dio,dirperm1 0 0
```
$ cat /sys/fs/aufs/si_972c6d361e6b32ba/br[0-9]*
第一部分，只读层。第二部分，可读写层。第三部分，Init 层。
删除操作，AuFS 会在可读写层创建一个 whiteout 文件，把只读层里的文件“遮挡”起来。如 可读写层创建了一个名叫.wh.foo 的文件
“ro+wh”的挂载方式，即只读 +whiteout 的含义。 白障。
Init 层。Init 层是 Docker 项目单独生成的一个内部层，专门用来存放 /etc/hosts、/etc/resolv.conf 等信息。用户执行 docker commit 只会提交可读写层，所以是不包含这些内容的。


## 8. 白话容器基础（四）：重新认识Docker容器 
![image](https://static001.geekbang.org/resource/image/2b/18/2b1b470575817444aef07ae9f51b7a18.png)

Dockerfile
CMD [“python”, “app.py”] 等价于 "docker run python app.py"。 等价于ENTRYPOINT CMD /bin/sh -c “python app.py”
Docker 容器的启动进程为 ENTRYPOINT，而不是 CMD。
Dockerfile 中的每个原语执行后，都会生成一个对应的镜像层。
$ docker inspect --format '{{ .State.Pid }}'  4ddf4638572d
$ ls -l  /proc/25686/ns
docker exec 的实现原理: 一个进程，可以选择加入到某个进程已有的 Namespace 当中，从而达到“进入”这个进程所在容器的目的。
 ```shell script
    # setns() 的 Linux 系统调用
    fd = open(argv[1], O_RDONLY);
    if (setns(fd, 0) == -1) {
        errExit("setns");
    }
    execvp(argv[2], &argv[2]); 

$ gcc -o set_ns set_ns.c 
$ ./set_ns /proc/25686/ns/net /bin/bash 
$ ifconfig
# 共享了net ns
ps aux | grep /bin/bash
$ ls -l /proc/28499/ns/net
$ ls -l  /proc/25686/ns/net
lrwxrwxrwx 1 root root 0 Aug 13 14:05 /proc/25686/ns/net -> net:[4026532281]
```

$ docker run -it --net container:4ddf4638572d busybox ifconfig 直接加入到 ID=4ddf4638572d 的容器 Network Namespace 中
–net=host，就意味着这个容器不会为进程启用 Network Namespace。共享宿主机的网络栈.

只读层在宿主机上是共享的，不会占用额外的空间。
而由于使用了联合文件系统，你在容器里对镜像 rootfs 所做的任何修改，都会被操作系统先复制到这个可读写层，然后再修改。这就是所谓的：Copy-on-Write。
Init 层的存在，就是为了避免你执行 docker commit 时，把 Docker 自己对 /etc/hosts 等文件做的修改，也一起提交掉。

Volume（数据卷）。
Volume 机制，允许你将宿主机上指定的目录或者文件，挂载到容器里面进行读取和修改操作。
$ docker run -v /test ...  # 创建一个临时目录 /var/lib/docker/volumes/[VOLUME_ID]/_data，然后把它挂载到容器的 /test 目录上。
$ docker run -v /home:/test ...
在 rootfs 准备好之后，在执行 chroot 之前，把 Volume 指定的宿主机目录（比如 /home 目录），挂载到指定的容器目录（比如 /test 目录）在宿主机上对应的目录（即 /var/lib/docker/aufs/mnt/[可读写层 ID]/test）上，这个 Volume 的挂载工作就完成了。
容器进程 ，是 Docker 创建的一个容器初始化进程 (dockerinit)，而不是应用进程 (ENTRYPOINT + CMD)。dockerinit 会负责完成根目录的准备、挂载设备和目录、配置 hostname 等一系列需要在容器内进行的初始化操作。最后，它通过 execv() 系统调用，让应用进程取代自己，成为容器里的 PID=1 的进程。
保证容器的隔离性不会被 Volume 打破： 挂载事件只在这个容器里可见。你在宿主机上，是看不见容器内部的这个挂载点的。 容器进程创建-挂载-chroot
Linux 的绑定挂载（bind mount）机制。  inode 替换的过程。
    mount --bind /home /test，会将 /home 挂载到 /test 上。其实相当于将 /test 的 dentry，重定向到了 /home 的 inode。
    修改 /test 目录时，实际修改的是 /home 目录的 inode，不会影响容器镜像的内容。
    一旦执行 umount 命令，/test 目录原先的内容就会恢复：因为修改真正发生在的，是 /home 目录里。
/test 目录里的内容，既然挂载在容器 rootfs 的可读写层，它也不会被 docker commit 提交。  因为 在宿主机看来，容器中可读写层的 /test 目录（/var/lib/docker/aufs/mnt/[可读写层 ID]/test），始终是空的。    
容器 Volume 里的信息，并不会被 docker commit 提交掉；但这个挂载点目录 /test 本身，则会出现在新的镜像当中。

```shell script
$ docker run -d -v /test helloworld
cf53b766fa6f
$ docker volume ls
DRIVER              VOLUME NAME
local               cb1c2f7221fa9b0971cc35f68aa1034824755ac44a034c0c0a1dd318838d3a6d
$ ls /var/lib/docker/volumes/cb1c2f7221fa/_data/
$ docker exec -it cf53b766fa6f /bin/sh
cd test/
touch text.txt
$ ls /var/lib/docker/volumes/cb1c2f7221fa/_data/
text.txt
$ ls /var/lib/docker/aufs/mnt/6780d0778b8a/test
```

## 9. 从容器到容器云：谈谈Kubernetes的本质
容器运行时和容器镜像。
实际上，过去很多的集群管理项目（比如 Yarn、Mesos，以及 Swarm）所擅长的，都是把一个容器，按照某种规则，放置在某个最佳节点上运行起来。这种功能，我们称为“调度”。
而 Kubernetes 项目所擅长的，是按照用户的意愿和整个系统的规则，完全自动化地处理好容器之间的各种关系。这种功能，就是我们经常听到的一个概念：编排。

“容器”，实际上是一个由 Linux Namespace、Linux Cgroups 和 rootfs 三种技术构建出来的进程的隔离环境。
    一组联合挂载在 /var/lib/docker/aufs/mnt 上的 rootfs，这一部分我们称为“容器镜像”（Container Image），是容器的静态视图；
    一个由 Namespace+Cgroups 构成的隔离环境，这一部分我们称为“容器运行时”（Container Runtime），是容器的动态视图。
    
只要从我这个承载点向 Docker 镜像制作者和使用者方向回溯，整条路径上的各个服务节点，比如 CI/CD、监控、安全、网络、存储等等，都有我可以发挥和盈利的余地。
通过容器镜像，它们可以和潜在用户（即，开发者）直接关联起来。
容器就从一个开发者手里的小工具，一跃成为了云计算领域的绝对主角；而能够定义容器组织和管理规范的“容器编排”技术，则当仁不让地坐上了容器技术领域的“头把交椅”。
最具代表性的容器编排工具，当属 Docker 公司的 Compose+Swarm 组合，以及 Google 与 RedHat 公司共同主导的 Kubernetes 项目。
![image](https://static001.geekbang.org/resource/image/c7/bd/c7ed0043465bccff2efc1a1257e970bd.png)
每一个核心特性的提出，几乎都脱胎于 Borg/Omega 系统的设计与经验
要解决的问题： 编排？调度？容器云？还是集群管理？ 路由网关、水平扩展、监控、备份、灾难恢复 。。。PaaS。
控制节点，即 Master 节点，由三个紧密协作的独立组件组合而成，它们分别是负责 API 服务的 kube-apiserver、负责调度的 kube-scheduler，以及负责容器编排的 kube-controller-manager。整个集群的持久化数据，则由 kube-apiserver 处理后保存在 Ectd 中。
计算节点上最核心的部分，则是一个叫作 kubelet 的组件。
kubelet 主要负责同容器运行时（比如 Docker 项目）打交道。依赖CRI（Container Runtime Interface）的远程调用接口
    而具体的容器运行时，比如 Docker 项目，则一般通过 OCI 这个容器运行时规范同底层的 Linux 操作系统进行交互，即：把 CRI 请求翻译成对 Linux 操作系统的调用（操作 Linux Namespace 和 Cgroups 等）。
kubelet 还通过 gRPC 协议同一个叫作 Device Plugin 的插件进行交互。
kubelet 调用网络插件和存储插件为容器配置网络和持久化存储。 CNI（Container Networking Interface）和 CSI（Container Storage Interface）。
Borg 对于 Kubernetes 项目的指导作用在master节点
从一开始，Kubernetes 项目就没有像同时期的各种“容器云”项目那样，把 Docker 作为整个架构的核心，而仅仅把它作为最底层的一个容器运行时实现。
一个 Web 应用与数据库之间的访问关系，一个负载均衡器和它的后端服务之间的代理关系，一个门户应用与授权组件之间的调用关系。一个 Web 应用与日志搜集组件之间的文件交换关系。
那些原先拥挤在同一个虚拟机里的各个应用、组件、守护进程，都可以被分别做成镜像，然后运行在一个个专属的容器中。它们之间互不干涉，拥有各自的资源配额，可以被调度在整个集群里的任何一台机器上。而这，正是一个 PaaS 系统最理想的工作状态，也是所谓“微服务”思想得以落地的先决条件。
所以，Kubernetes 项目最主要的设计思想是，从更宏观的角度，以统一的方式来定义任务之间的各种关系，并且为将来支持更多种类的关系留有余地。
![image](https://static001.geekbang.org/resource/image/16/06/16c095d6efb8d8c226ad9b098689f306.png)

除了应用与应用之间的关系外，应用运行的形态是影响“如何容器化这个应用”的第二个重要因素。
Job，用来描述一次性运行的 Pod（比如，大数据任务）；再比如 DaemonSet，用来描述每个宿主机上必须且只能运行一个副本的守护进程服务；又比如 CronJob，则用于描述定时任务等等。
首先，通过一个“编排对象”，比如 Pod、Job、CronJob 等，来描述你试图管理的应用；
然后，再为它定义一些“服务对象”，比如 Service、Secret、Horizontal Pod Autoscaler（自动水平扩展器）等。这些对象，会负责具体的平台级功能。
这种使用方法，就是所谓的“声明式 API”。这种 API 对应的“编排对象”和“服务对象”，都是 Kubernetes 项目中的 API 对象（API Object）。

## 10. Kubernetes一键部署利器：kubeadm 
有部署规模化生产环境的需求，我推荐使用kops或者 SaltStack 这样更复杂的部署工具。
kubeadm 对 Kubernetes 项目特性的使用和集成，确实要比其他项目“技高一筹”，非常值得我们学习和借鉴
k8s容器化“表达能力”，具有独有的先进性和完备性。
各大云厂商最常用的部署的方法，是使用 SaltStack、Ansible 等运维工具自动化地执行这些步骤: 各个组件编译成二进制文件外，用户还要负责为这些二进制文件编写对应的配置文件、配置自启动脚本，以及为 kube-apiserver 配置授权文件等等诸多运维工作
```shell script
# 创建一个 Master 节点
$ kubeadm init
# 将一个 Node 节点加入到当前集群中
$ kubeadm join <Master 节点的 IP 和端口 >
```

如果现在 kubelet 本身就运行在一个容器里，那么直接操作宿主机就会变得很麻烦。
kubelet 做的挂载操作，不能被“传播”到宿主机上。不推荐你用容器去部署 Kubernetes 项目。
把 kubelet 直接运行在宿主机上，然后使用容器部署其他的 Kubernetes 组件。
kubeadm ,1 “Preflight Checks”，2生成 Kubernetes 对外提供服务所需的各种证书和对应的目录。
kubeadm 为 Kubernetes 项目生成的证书文件都放在 Master 节点的 /etc/kubernetes/pki 目录下。在这个目录下，最主要的证书文件是 ca.crt 和对应的私钥 ca.key。
 apiserver-kubelet-client.crt 文件，对应的私钥是 apiserver-kubelet-client.key。
 /etc/kubernetes/pki/ca.{crt,key}
kubeadm 3接下来会为其他组件生成访问 kube-apiserver 所需的配置文件。 4 为 Master 组件生成 Pod 配置文件。
```shell script
ls /etc/kubernetes/
admin.conf  controller-manager.conf  kubelet.conf  scheduler.conf
```
Kubernetes 有三个 Master 组件 kube-apiserver、kube-controller-manager、kube-scheduler，而它们都会被使用 Pod 的方式部署起来。
“Static Pod”
 kubeadm 中，Master 组件的 YAML 文件会被生成在 /etc/kubernetes/manifests 路径下。比如，kube-apiserver.yaml
```shell script
$ ls /etc/kubernetes/manifests/
etcd.yaml  kube-apiserver.yaml  kube-controller-manager.yaml  kube-scheduler.yaml
```
 kubelet 监视的 /etc/kubernetes/manifests 目录,自动创建pod
 kubeadm 会通过检查 localhost:6443/healthz 这个 Master 组件的健康检查 URL，等待 Master 组件完全运行起来。
kubeadm 就会为集群生成一个 bootstrap token。
在 token 生成之后，kubeadm 会将 ca.crt 等 Master 节点的重要信息，通过 ConfigMap 的方式保存在 Etcd 当中，供后续部署 Node 节点使用。这个 ConfigMap 的名字是 cluster-info。
kubeadm init 的最后一步，就是安装默认插件。Kubernetes 默认 kube-proxy 和 DNS 这两个插件是必须安装的。它们分别用来提供整个集群的服务发现和 DNS 功能。其实，这两个插件也只是两个容器镜像而已，所以 kubeadm 只要用 Kubernetes 客户端创建两个 Pod 就可以了。

#### kubeadm join 的工作流程
kubeadm init 生成 bootstrap token 之后，你就可以在任意一台安装了 kubelet 和 kubeadm 的机器上执行 kubeadm join 了。
只要有了 cluster-info 里的 kube-apiserver 的地址、端口、证书，kubelet 就可以以“安全模式”连接到 apiserver 上，
#### 配置 kubeadm 的部署参数
`$ kubeadm init --config kubeadm.yaml`


## 11. 从0到1：搭建一个完整的Kubernetes集群 
这个集群有一个 Master 节点和多个 Worker 节点；使用 Weave 作为容器网络插件；使用 Rook 作为容器持久化存储插件；使用 Dashboard 插件提供了可视化的 Web 界面。

$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
$ cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
$ apt-get update
$ apt-get install -y docker.io kubeadm

$ kubeadm init --config kubeadm.yaml

kubeadm join 10.168.0.2:6443 --token 00bwbx.uvnaa2ewjflwu1ry --discovery-token-ca-cert-hash sha256:00eb62a2a6020f94132e3fe1ab721349bbcd3e9b94da9654cfe15f2985ebd711

// 刚刚部署生成的 Kubernetes 集群的安全配置文件，保存到当前用户的.kube 目录下
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
$ kubectl get nodes

$ kubectl describe node master

$ kubectl get pods -n kube-system

$ kubectl apply -f https://git.io/weave-kube-1.6


$ kubectl apply -f https://git.io/weave-kube-1.6

$ kubectl get pods -n kube-system 
NAME                             READY     STATUS    RESTARTS   AGE
coredns-78fcdf6894-j9s52         1/1       Running   0          1d
coredns-78fcdf6894-jm4wf         1/1       Running   0          1d
etcd-master                      1/1       Running   0          9s
kube-apiserver-master            1/1       Running   0          9s
kube-controller-manager-master   1/1       Running   0          9s
kube-proxy-xbd47                 1/1       Running   0          1d
kube-scheduler-master            1/1       Running   0          9s
weave-net-cmk27                  2/2       Running   0          19s

市面上的所有容器网络开源项目都可以通过 CNI 接入 Kubernetes，比如 Flannel、Calico、Canal、Romana 等等，它们的部署方式也都是类似的“一键部署”。

#### 部署 Kubernetes 的 Worker 节点
$ kubeadm join 10.168.0.2:6443 --token 00bwbx.uvnaa2ewjflwu1ry --discovery-token-ca-cert-hash sha256:00eb62a2a6020f94132e3fe1ab721349bbcd3e9b94da9654cfe15f2985ebd711
#### 通过 Taint/Toleration 调整 Master 执行 Pod 的策略
默认情况下 Master 节点是不允许运行用户 Pod 的。而 Kubernetes 做到这一点，依靠的是 Kubernetes 的 Taint/Toleration 机制。

$ kubectl taint nodes node1 foo=bar:NoSchedule
```shell script
$ kubectl taint nodes node1 foo=bar:NoSchedule

apiVersion: v1
kind: Pod
...
spec:
  tolerations:
  - key: "foo"
    operator: "Equal"
    value: "bar"
    effect: "NoSchedule"

$ kubectl describe node master 
Name:               master
Roles:              master
Taints:             node-role.kubernetes.io/master:NoSchedule

apiVersion: v1
kind: Pod
...
spec:
  tolerations:
  - key: "foo"
    operator: "Exists"
    effect: "NoSchedule"

# 删除这个前缀的所有键
$ kubectl taint nodes --all node-role.kubernetes.io/master-
```

#### 部署 Dashboard 可视化插件
https://github.com/kubernetes/dashboard
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
$ kubectl get pods -n kube-system
kubernetes-dashboard-6948bdb78-f67xk   1/1       Running   0          1m

#### 部署容器存储插件
持久化： 存储插件会在容器里挂载一个基于网络或者其他机制的远程数据卷，使得在容器里创建的文件，实际上是保存在远程存储服务器上
Rook、Ceph、GlusterFS、NFS 等，都可以为 Kubernetes 提供持久化存储能力。
Rook 持久化存储集群 在自己的实现中加入了水平扩展、迁移、灾难备份、监控等大量的企业级功能。
$ kubectl apply -f https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/operator.yaml 
$ kubectl apply -f https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/cluster.yaml
$ kubectl get pods -n rook-ceph-system
NAME                                  READY     STATUS    RESTARTS   AGE
rook-ceph-agent-7cv62                 1/1       Running   0          15s
rook-ceph-operator-78d498c68c-7fj72   1/1       Running   0          44s
rook-discover-2ctcv                   1/1       Running   0          15s
$ kubectl get pods -n rook-ceph
NAME                   READY     STATUS    RESTARTS   AGE
rook-ceph-mon0-kxnzh   1/1       Running   0          13s
rook-ceph-mon1-7dn2t   1/1       Running   0          2s
所有 Pod 就能够通过 Persistent Volume（PV）和 Persistent Volume Claim（PVC）的方式，在容器里挂载由 Ceph 提供的数据卷了。
Rook 项目的实现，就会发现它巧妙地依赖了 Kubernetes 提供的编排能力，合理的使用了很多诸如 Operator、CRD 等重要的扩展特性。

在很多时候，大家说的所谓“云原生”，就是“Kubernetes 原生”的意思。而像 Rook、Istio 这样的项目，正是贯彻这个思路的典范。

## 12. 牛刀小试：我的第一个容器化应用 
而像这样的 Kubernetes API 对象，往往由 Metadata 和 Spec 两部分组成，其中 Metadata 里的 Labels 字段是 Kubernetes 过滤对象的主要手段。
上面这些基于 YAML 文件的容器管理方式，跟 Docker、Mesos 的使用习惯都是不一样的，而从 docker run 这样的命令行操作，向 kubectl apply YAML 文件这样的声明式 API 的转变，是每一个容器技术学习者，必须要跨过的第一道门槛。
Deployment，是一个定义多副本应用（即多个副本 Pod）的对象
使用一种 API 对象（Deployment）管理另一种 API 对象（Pod）的方法，在 Kubernetes 中，叫作“控制器”模式（controller pattern）。
而这个过滤规则的定义，是在 Deployment 的“spec.selector.matchLabels”字段。我们一般称之为：Label Selector。
像 Deployment 这样的控制器对象，就可以通过这个 spec.template.metadata.Labels 字段从 Kubernetes 中过滤出它所关心的被控制对象。
Annotations是k8s本身使用的。
$ kubectl create -f nginx-deployment.yaml
$ kubectl get pods -l app=nginx
在命令行中，所有 key-value 格式的参数，都使用“=”而非“:”表示。
$ kubectl describe pod nginx-deployment-67594d6bf6-9gdvr
Events查看异常
$ kubectl replace -f nginx-deployment.yaml
```
$ kubectl apply -f nginx-deployment.yaml
# 修改 nginx-deployment.yaml 的内容 
$ kubectl apply -f nginx-deployment.yaml
```
而当应用本身发生变化时，开发人员和运维人员可以依靠容器镜像来进行同步；当应用部署参数发生变化时，这些 YAML 文件就是他们相互沟通和信任的媒介。
Kubernetes 的 emptyDir 类型，只是把 Kubernetes 创建的临时目录作为 Volume 的宿主机目录，交给了 Docker。这么做的原因，是 Kubernetes 不想依赖 Docker 自己创建的那个 _data 目录。
$ kubectl exec -it nginx-deployment-5c678cfb6d-lg9lw -- /bin/bash
# ls /usr/share/nginx/html
$ kubectl delete -f nginx-deployment.yaml
```shell script
spec:
      containers:
      - name: nginx
        image: nginx:1.8
        ports:
        - containerPort: 80
        volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: nginx-vol
      volumes:
      - name: nginx-vol
        emptyDir: {}
      
      volumes:
      - name: nginx-vol
        hostPath: 
          path: /var/data

      

```
## 13. 为什么我们需要Pod？ 
一个运行在虚拟机里的应用，哪怕再简单，也是被管理在 systemd 或者 supervisord 之下的一组进程，而不是一个进程。
一个容器，就是一个进程。这是容器技术的“天性”，不可能被修改。
Swarm 这种单容器的工作方式，就难以描述真实世界里复杂的应用架构了。
Pod，实际上是在扮演传统基础设施里“虚拟机”的角色；而容器，则是这个虚拟机里运行的用户程序。
把整个虚拟机想象成为一个 Pod，把这些进程分别做成容器镜像，把有顺序关系的容器，定义为 Init Container。这才是更加合理的、松耦合的容器编排诀窍，也是从传统应用架构，到“微服务架构”最自然的过渡方式。

Pod，是 Kubernetes 项目的原子调度单位。
Kubernetes 就是操作系统！容器的本质是进程。Namespace 做隔离，Cgroups 做限制，rootfs 做文件系统。
$ pstree -g
容器的“单进程模型”，并不是指容器里只能运行“一个”进程，而是指容器没有管理多个进程的能力。
比如，你的应用是一个 Java Web 程序（PID=1），然后你执行 docker exec 在后台启动了一个 Nginx 进程（PID=3）。可是，当这个 Nginx 进程异常退出的时候，你该怎么知道呢？这个进程退出后的垃圾收集工作，又应该由谁去做呢？
Docker Swarm 成组调度（gang scheduling）没有被妥善处理的例子。 affinity=main    资源不够用的时候。
Mesos 中就有一个资源囤积（resource hoarding）的机制。Affinity 约束的任务都达到时，才开始对它们统一进行调度。
Google Omega 论文中，则提出了使用乐观调度处理冲突的方法，即：先不管这些冲突，而是通过精心设计的回滚机制在出现了冲突之后解决问题。
资源囤积带来了不可避免的调度效率损失和死锁的可能性；而乐观调度的复杂程度，则不是常规技术团队所能驾驭的。
像rsyslogd的 imklog、imuxsock 和 main 函数主进程这样的三个容器，正是一个典型的由三个容器组成的 Pod。Kubernetes 项目在调度时，自然就会去选择可用内存等于 3 GB 的 node-1 节点进行绑定，而根本不会考虑 node-2。
“超亲密关系”：文件交换、使用 localhost 或者 Socket 文件进行本地通信、频繁的远程调用、共享某些 Linux Namespace（比如，一个容器要加入另一个容器的 Network Namespace）等等。
容器设计模式。
Pod 最重要的一个事实是：它只是一个逻辑概念。
Pod，其实是一组共享了某些资源的容器。
Pod 里的所有容器，共享的是同一个 Network Namespace，并且可以声明共享同一个 Volume。
Pod 的实现需要使用一个中间容器，这个容器叫作 Infra 容器。k8s.gcr.io/pause。 永远都是第一个被创建的容器。 一个用汇编语言编写的、永远处于“暂停”状态的容器，解压后的大小也只有 100~200 KB 左右。
    而其他用户定义的容器，则通过 Join Network Namespace 的方式，与 Infra 容器关联在一起。
将来如果你要为 Kubernetes 开发一个网络插件时，应该重点考虑的是如何配置这个 Pod 的 Network Namespace，而不是每一个用户容器如何使用你的网络配置，这是没有意义的。
第一个最典型的例子是：WAR 包与 Web 服务器。
WAR 包容器的类型不再是一个普通容器，而是一个 Init Container 类型的容器。
这个所谓的“组合”操作，正是容器设计模式里最常用的一种模式，它的名字叫：sidecar。
sidecar 指的就是我们可以在一个 Pod 中，启动一个辅助容器，来完成一些独立于主进程（主容器）之外的工作。
```
apiVersion: v1
   kind: Pod
   metadata:
     name: javaweb-2
   spec:
     initContainers:
     - image: geektime/sample:v2
       name: war
       command: ["cp", "/sample.war", "/app"]
       volumeMounts:
       - mountPath: /app
         name: app-volume
     containers:
     - image: geektime/tomcat:7.0
       name: tomcat
       command: ["sh","-c","/root/apache-tomcat-7.0.42-v2/bin/start.sh"]
       volumeMounts:
       - mountPath: /root/apache-tomcat-7.0.42-v2/webapps
         name: app-volume
       ports:
       - containerPort: 8080
         hostPort: 8001 
     volumes:
     - name: app-volume
       emptyDir: {}
```
第二个例子，则是容器的日志收集。

Istio 这个微服务治理项目：Pod 所有容器都共享同一个 Network Namespace。

## 14. 深入解析Pod对象（一）：基本概念 
$GOPATH/src/k8s.io/kubernetes/vendor/k8s.io/api/core/v1/types.go 里，type Pod struct ，尤其是 PodSpec 部分的内容。
凡是调度、网络、存储，以及安全相关的属性，基本上是 Pod 级别的。
NodeSelector：是一个供用户将 Pod 与 Node 进行绑定的字段
HostAliases：定义了 Pod 的 hosts 文件（比如 /etc/hosts）里的内容。 不能修改hosts文件（会覆盖）
NodeName：一旦 Pod 的这个字段被赋值，Kubernetes 项目就会被认为这个 Pod 已经经过了调度。 测试或者调试的时候可以骗过调度器。
shareProcessNamespace=true。 这个 Pod 里的容器要共享 PID Namespace。 
docker run 里的 -it（-i 即 stdin，-t 即 tty）参数。
```
$ kubectl attach -it nginx -c shell
/ # ps ax
PID   USER     TIME  COMMAND
    1 root      0:00 /pause
    8 root      0:00 nginx: master process nginx -g daemon off;
   14 101       0:00 nginx: worker process
   15 root      0:00 sh
   21 root      0:00 ps ax
```
   
凡是 Pod 中的容器要共享宿主机的 Namespace，也一定是 Pod 级别的定义
共享宿主机的 Network、IPC 和 PID Namespace。这就意味着，这个 Pod 里的所有容器，会直接使用宿主机的网络、直接与宿主机进行 IPC 通信、看到宿主机里正在运行的所有进程。
```shell script
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  hostNetwork: true
  hostIPC: true
  hostPID: true
  containers:
  - name: nginx
    image: nginx
  - name: shell
    image: busybox
    stdin: true
    tty: true
```
Image（镜像）、Command（启动命令）、workingDir（容器的工作目录）、Ports（容器要开发的端口），以及 volumeMounts（容器要挂载的 Volume）都是构成 Kubernetes 项目中 Container 的主要字段
ImagePullPolicy  默认是 Always，即每次创建 Pod 都重新拉取一次镜像。 Never 或者 IfNotPresent
Lifecycle 字段。它定义的是 Container Lifecycle Hooks。 可实现优雅退出。
```shell script
apiVersion: v1
kind: Pod
metadata:
  name: lifecycle-demo
spec:
  containers:
  - name: lifecycle-demo-container
    image: nginx
    lifecycle:
      postStart:
        exec:
          command: ["/bin/sh", "-c", "echo Hello from the postStart handler > /usr/share/message"]
      preStop:
        exec:
          command: ["/usr/sbin/nginx","-s","quit"]
```
Pod生命周期
Pending（可能是调度未成功）、Running（容器都创建成功，至少1个运行中）、Succeeded（一次性任务常见）、Failed（至少一个容器非0退出）、Unknown（可能是主从节点通信问题）。
PodScheduled、Ready（>Running)、Initialized，以及 Unschedulable（Pending）。

## 15. 深入解析Pod对象（二）：使用进阶 
Projected Volume： 有几种特殊的 Volume，它们存在的意义不是为了存放容器里的数据，也不是用来进行容器和宿主机之间的数据交换。这些特殊 Volume 的作用，是为容器提供预先定义好的数据。
Secret；ConfigMap；Downward API；ServiceAccountToken。

Secret，一旦其对应的 Etcd 里的数据被更新，这些 Volume 里的文件内容，同样也会被更新。其实，这是 kubelet 组件在定时维护这些 Volume。
需要注意的是，这个更新可能会有一定的延时。所以在编写应用程序时，在发起数据库连接的代码处写好重试和超时的逻辑，绝对是个好习惯。

Downward API Volume，则声明了要暴露 Pod 的 metadata.labels 信息给容器。
$ kubectl create -f dapi-volume.yaml
$ kubectl logs test-downwardapi-volume
Downward API 能够获取到的信息，一定是 Pod 里的容器进程启动之前就能够确定下来的信息。
Secret、ConfigMap，以及 Downward API 这三种 Projected Volume 定义的信息，大多还可以通过环境变量的方式出现在容器里。但是，通过环境变量获取这些信息的方式，不具备自动更新的能力。所以，一般情况下，我都建议你使用 Volume 文件的方式获取这些信息。
ServiceAccountToken，只是一种特殊的 Secret 而已。必须使用这个 ServiceAccountToken 里保存的授权信息，也就是 Token，才可以合法地访问 API Server。
默认“服务账户”（default Service Account） 无需显示地声明挂载它
```shell script
$ kubectl describe pod nginx-deployment-5c678cfb6d-lg9lw
Containers:
...
  Mounts:
    /var/run/secrets/kubernetes.io/serviceaccount from default-token-s8rbq (ro)
Volumes:
  default-token-s8rbq:
  Type:       Secret (a volume populated by a Secret)
  SecretName:  default-token-s8rbq
  Optional:    false
```
Kubernetes 其实在每个 Pod 创建的时候，自动在它的 spec.volumes 部分添加上了默认 ServiceAccountToken 的定义，然后自动给每个容器加上了对应的 volumeMounts 字段。这个过程对于用户来说是完全透明的。

这种把 Kubernetes 客户端以容器的方式运行在集群里，然后使用 default Service Account 自动授权的方式，被称作“InClusterConfig”，也是我最推荐的进行 Kubernetes API 编程的授权方式。

Pod 的另一个重要的配置：容器健康检查和恢复机制。

## 16. 编排其实很简单：谈谈“控制器”模型 
## 17. 经典PaaS的记忆：作业副本与水平扩展 
Deployment 控制 ReplicaSet（版本），ReplicaSet 控制 Pod（副本数）。
## 18. 深入理解StatefulSet（一）：拓扑状态 
## 19. 深入理解StatefulSet（二）：存储状态 
## 20. 深入理解StatefulSet（三）：有状态应用实践 
## 21. 容器化守护进程的意义：DaemonSet 
## 22. 撬动离线业务：Job与CronJob 
## 23. 声明式API与Kubernetes编程范式 
## 24. 深入解析声明式API（一）：API对象的奥秘 
## 25. 深入解析声明式API（二）：编写自定义控制器 
## 26. 基于角色的权限控制：RBAC 
## 27. 聪明的微创新：Operator工作原理解读 
## 28. PV、PVC、StorageClass，这些到底在说啥？ 
## 29. PV、PVC体系是不是多此一举？从本地持久化卷谈起 
## 30. 编写自己的存储插件：FlexVolume与CSI 
## 31. 容器存储实践：CSI插件编写指南 
## 32. 浅谈容器网络 
## 33. 深入解析容器跨主机网络 
## 34. Kubernetes网络模型与CNI网络插件 
## 35. 解读Kubernetes三层网络方案 
## 36. 为什么说Kubernetes只有soft multi-tenancy？ 
## 37. 找到容器不容易：Service、DNS与服务发现 
## 38. 从外界连通Service与Service调试“三板斧” 
## 39. 谈谈Service与Ingress 
## 40. Kubernetes的资源模型与资源管理 
## 41. 十字路口上的Kubernetes默认调度器 
## 42. Kubernetes默认调度器调度策略解析 
## 43. Kubernetes默认调度器的优先级与抢占机制 
## 44. Kubernetes GPU管理与Device Plugin机制 
## 45. 幕后英雄：SIG-Node与CRI 
## 46. 解读 CRI 与 容器运行时 
## 47. 绝不仅仅是安全：Kata Containers 与 gVisor 
## 48. Prometheus、Metrics Server与Kubernetes监控体系 
## 49. 阿忠伯的特别放送 答疑解惑01 