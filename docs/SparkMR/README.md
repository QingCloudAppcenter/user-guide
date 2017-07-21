# SparkMR on QingCloud AppCenter 用户指南
## 简介

*SparkMR on QingCloud AppCenter* 将 *Apache Hadoop* 和 *Apache Spark* 集成到同一个集群服务中，以AppCenter云应用的形式交付给用户使用。
>目前支持的Hadoop和Spark版本分别是 *Apache Hadoop 2.7.3* 和 *Apache Spark 2.2.0*  。


### *SparkMR* 的主要功能

- *Apache Hadoop*  提供的MapReduce、YARN、HDFS等功能
- *Apache Spark* 提供的Spark streaming、Spark SQL、DataFrame and DataSet、Structed Streaming、MLlib、GraphX、SparkR等功能
- 同时支持Spark Standalone和Spark on YARN两种模式。
>用户可以选择是否开启Spark Standalone模式（默认开启）。开启后用户可以以Spark Standalone模式提交Spark应用；而无论开启或关闭Spark Standalone模式用户都能以Spark on YARN模式提交Spark应用。如用户仅以Spark on YARN模式提交Spark应用，则可以选择关闭Spark Standalone模式以释放资源。
- 为了方便用户提交Python Spark应用，提供了Anaconda发行版的Python 2.7.13和Python 3.6.1 。用户可以选择Python Spark应用的运行环境，支持在Python2和Python3之间进行切换。
- 为了方便用户开发Python Spark机器学习类的应用， 分别在Anaconda发行版的Python2和Python3内提供了Anaconda发行版的数据科学包numpy, scikit-learn, scipy, Pandas, NLTK and Matplotlib 。
- 为了方便用户开发Spark R应用，提供了R语言运行时。
- 支持上传自定义的Spark应用内调度器Fair Schudeler，并支持spark应用内调度模式在FIFO和FARI切换
- 支持上传自定义的YARN调度器CapacityScheduler和FairScheduler，并支持在CapacityScheduler和FairScheduler之间进行切换
- 支持用户选择YARN调度器中用于计量资源的ResourceCalculator。默认的DefaultResourseCalculator在分配资源时只考虑内存，而DominantResourceCalculator则利用Dominant-resource来综合考量多维度的资源如内存，CPU等。
- 配置参数增加到近60个，定制服务更方便
- 针对HDFS、YARN和Spark服务级别的监控告警、健康检查与服务自动恢复
- Hadoop、Spark与QingStor集成
- 指定依赖服务，自动添加依赖服务中的所有节点到SparkMR所有节点的hosts文件中
- 支持水平与垂直扩容
- 可选client节点（为了使用上述全部功能，建议client节点为必选），全自动配置无需任何手动操作。

## 部署SparkMR服务

### 第1步：基本设置

![第1步：基本设置](../../images/SparkMR/basic_config.png)
填写服务`名称`和`描述`，选择版本

### 第2步：HDFS主节点设置

![第2步：HDFS主节点设置](../../images/SparkMR/hdfs_master_config.png)
填写 HDFS主节点 CPU、内存、节点类型、数据盘类型及大小等配置信息。

### 第3步：YARN主节点设置

![第3步：YARN主节点设置](../../images/SparkMR/yarn_master_config.png)
填写 YARN主节点 CPU、内存、节点类型、数据盘类型及大小等配置信息。

### 第4步：从节点设置

![第4步：从节点设置](../../images/SparkMR/slave_config.png)
填写 从节点 CPU、内存、节点类型、数据盘类型及大小等配置信息。

### 第5步：Client节点设置

![第5步：Client节点设置](../../images/SparkMR/client_config.png)
填写Client节点 CPU、内存、节点类型、数据盘类型及大小等配置信息。Client节点为可选，如不需要可设置`节点数量`为0。建议选配Client节点，否则某些功能无法使用（除非手动下载相关软件包并配置好）。

### 第6步：网络设置

![第6步：网络设置](../../images/SparkMR/network_config.png)
出于安全考虑，所有的集群都需要部署在私有网络中，选择自己创建的已连接路由器的私有网络中。

### 第7步：依赖服务设置

![第7步：依赖服务设置](../../images/SparkMR/dependency_config.png)
选择所依赖的服务可以将其中所有节点加入本服务所有节点的hosts文件中

### 第8步：服务环境参数设置

![第8步：服务环境参数设置](../../images/SparkMR/env_config.png)
提供了近60个服务环境参数可以配置，默认仅显示其中两个。可以点击`展开配置`对所有配置项进行修改，也可使用默认值并在集群创建后按需进行修改。

### 第9步: 用户协议

阅读并同意青云 APP Center 用户协议之后即可开始部署应用。

## SparkMR使用场景

## 查看服务详情
![查看服务详情](../../images/SparkMR/cluster_detail.png)
创建成功后，点击集群列表页面相应集群可查看集群详情。可以看到集群分为HDFS主节点、YARN主节点、从节点和Bigdata client四种角色。其中用户可以直接访问client节点，并通过该节点与集群交互如提交Hadoop/Spark job、查看/上传/下载HDFS文件等。

> 如在Spark Standalone模式下(包括spark-shell和spark-submit)运行的spark job需要读取本地文件，则需要将spark-env.sh中的`export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop`注释掉
如需以Spark on YARN模式运行spark job，则需要将该环境变量打开

## 场景一、以Spark-shell模式运行Spark job
- Scala
```shell
cd /opt/spark	
bin/spark-shell --master spark://192.168.0.8:7077

val textFile = spark.read.textFile("/opt/spark/README.md")
textFile.count()
textFile.filter(line => line.contains("Spark")).count()
```
- Python
```shell
cd /opt/spark
bin/pyspark --master spark://192.168.0.8:7077

textFile = spark.read.text("/opt/spark/README.md")
textFile.count()
textFile.filter(textFile.value.contains("Spark")).count()
```

- R
```shell
cd /opt/spark
bin/sparkR --master spark://192.168.0.8:7077

df <- as.DataFrame(faithful)
head(df)
people <- read.df("./examples/src/main/resources/people.json", "json")
printSchema(people)
```
## 场景二、以Spark Standalone模式运行Spark job
- Scala
```shell
cd /opt/spark	

bin/spark-submit --class org.apache.spark.examples.SparkPi --master spark://192.168.0.8:7077 examples/jars/spark-examples_2.11-2.2.0.jar 100
```
- Python
```shell
cd /opt/spark

bin/spark-submit --master spark://192.168.0.8:7077 examples/src/main/python/pi.py 100
```
> 可以在配置参数页面切换Python版本
![切换Python版本](../../images/SparkMR/switch_python.png)

- R
```shell
cd /opt/spark

bin/spark-submit --master spark://192.168.0.8:7077 examples/src/main/r/data-manipulation.R examples/src/main/resources/people.txt
```

## 场景三、以Spark on YARN模式运行Spark job
- Scala
```shell
cd /opt/spark

bin/spark-submit --class org.apache.spark.examples.SparkPi --master yarn --deploy-mode cluster --num-executors 3 --executor-cores 1 --executor-memory 1g examples/jars/spark-examples_2.11-2.2.0.jar 100
```
- Python
```shell
cd /opt/spark

bin/spark-submit --master yarn --deploy-mode client examples/src/main/python/pi.py 100
```

- R
```shell
cd /opt/spark

bin/spark-submit --master yarn --deploy-mode cluster /opt/spark/examples/src/main/r/ml/kmeans.R
```

## 场景四、SparkMR与QingStor集成
QingStor 对象存储为用户提供可无限扩展的通用数据存储服务，具有安全可靠、简单易用、高性能、低成本等特点。用户可将数据上传至 QingStor 对象存储中，以供数据分析。由于 QingStor 对象存储兼容 AWS S3 API，因此 Spark与Hadoop都可以通过 AWS S3 API 与 QingStor 对象存储高效集成，以满足更多的大数据计算和存储场景。有关 QingStor 的更多内容，请参考[QingStor 对象存储用户指南] (https://docs.qingcloud.com/qingstor/guide/index.html)
>目前QingStor 对象存储的开放了sh1a 和 pek3a两个区，后续将开放更多的分区，敬请期待。

如需与QingStor对象存储集成，需要首先在配置参数页面填写如下信息：
![配置QingStor](../../images/SparkMR/qingstor-setting.png)


>有两种方式可以启动 Spark job： 通过 spark-shell 交互式运行和通过 spark-submit 提交 job 到 Spark集群运行，这两种方式都需要通过选项 "--jars $SPARK_S3" 来指定使用 S3 API相关的 jar 包。

假设您在 QingStor 上的 bucket 为 my-bucket, 下面以 spark-shell 为例， 列出常见的 Spark 与 QingStor 集成场景。

- 在 Spark 中读取到 HDFS 上的文件后将其存储到 QingStor 中
```shell
# 首先需要将本地的一个测试文件上传到spark集群的HDFS存储节点上：
cd /opt/hadoop
bin/hdfs dfs -mkdir /input
bin/hdfs dfs -put /opt/spark/README.md /input/

# 然后启动 spark-shell, 输入并执行如下代码将会读取 HDFS 上的 README.md 文件, 然后将其存为QingStor中"my-bucket"下的 test 文件：
cd /opt/spark
bin/spark-shell --master spark://<yarn-master-ip>:7077 --jars $SPARK_S3

val qs_file = sc.textFile("hdfs://<hdfs-master-ip>:9000/input/README.md")
qs_file.saveAsTextFile("s3a://my-bucket/test")
```
- 在 Spark 中读取 QingStor 上的文件，处理过后再存储到 HDFS 文件系统中
```shell
val qs_file = sc.textFile("s3a://my-bucket/test")
qs_file.count()
qs_file.saveAsTextFile("hdfs://<hdfs-master-ip>:9000/output/")
```

- 在 Spark 中读取 QingStor 上的文件， 经过处理后将结果存回 QingStor
```shell
#如下代码将会读取 QingStor 中 my-bucket 下的 test 文件， 从中选出包含字符串 "Spark" 的行， 最后将结果存储到 my-bucket 下的 qingstor-output 文件中
val qs_file = sc.textFile("s3a://my-bucket/test").filter(line => line.contains("Spark"))
qs_file.saveAsTextFile("s3a://my-bucket/output1")
```

- 在 Spark 中创建元素值为 1 到 1000 的数组， 找出其中的奇数并对其求平方， 最后将结果存储到 QingStor 上的文件中
```shell
val data = for (i <- 1 to 1000) yield i
sc.parallelize(data).filter(_%2 != 0).map(x=>x*x).saveAsTextFile("s3a://my-bucket/output2")
```
## 场景一、
- 运行Scala Spark job
```shell
cd /opt/spark

```
- 运行Python Spark job
```shell
cd /opt/spark

```
## 场景一、
- 运行Scala Spark job
```shell
cd /opt/spark

```
- 运行Python Spark job
```shell
cd /opt/spark

```
## 场景一、

## 场景一、

## 场景一、

## 场景一、

## 场景一、

## 场景一、

## 在线伸缩

### 增加节点

### 删除节点

### 纵向伸缩

## 监控告警

### 创建成功

## 配置参数

### 修改配置参数

### 常用配置项