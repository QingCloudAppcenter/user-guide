# RadonDB 支持 SQL 集

## 背景

在 SQL 语法上， RadonDB 与 MySQL 完全兼容。

在满足大部分需求场景下， RadonDB 的 SQL 实现只是 MySQL 一个子集，从而更好的使用和规范。

## DDL

### 1. DATABASE

RadonDB 对 Database 的操作只支持创建和删除。

#### 1.1. 创建 DB

`语法:`

```sql
 CREATE DATABASE [IF NOT EXISTS] db_name
```

`说明:`

* RadonDB 会把此语句直接发到所有后端执行并返回。
* *跨分区非原子操作*。

`示例:`

```sql
mysql> CREATE DATABASE sbtest1;
Query OK, 4 rows affected (0.01 sec)
```

#### 1.2. 删除 DB

`语法:`

```sql
 DROP DATABASE [IF EXISTS] db_name
```

`说明:`

* RadonDB 会把此语句直接发到所有后端并返回。
* *跨分区非原子操作*。

`示例:`

```sql
mysql> DROP DATABASE sbtest1;
Query OK, 0 rows affected (0.02 sec)
```

---------------------------------------------------------------------------------------------------

### 2. TABLE

#### 2.1. 创建表

`语法:`

```sql
 CREATE TABLE [IF NOT EXISTS] table_name
    (create_definition,...)
    [ENGINE={InnoDB|TokuDB}]
    [DEFAULT CHARSET=(charset)]
    PARTITION BY HASH(shard-key)
```

`说明:`

* 创建分区信息并在各个分区生成分区表。
* 分区表语法必须包含 `PARTITION BY HASH (分区键)`。
* 分区键仅支持指定一个列， 该列数据类型没有限制 (BINARY/NULL 类型除外)。
* 分区方式为 HASH， 根据分区键 HASH 值均匀分散在各个分区。
* table_options 只支持 ENGINE 和 CHARSET，其他自动被忽略。
* 分区表默认引擎为 InnoDB。
* 表字符集默认为 utf8。
* 不支持非分区键的 PRIMARY/UNIQUE 约束，直接返回错误。
* *跨分区非原子操作*。


`示例:`

```sql
mysql> CREATE TABLE t1(id int, age int) PARTITION BY HASH(id);
Query OK, 0 rows affected (0.09 sec)
```

#### 2.2. 删除表

`语法:`

```sql
DROP TABLE [IF EXISTS] table_name
```

`说明:`


* 删除分区信息及后端分区表。
* *跨分区非原子操作*。

`示例: `

```sql
mysql> DROP TABLE t1;
Query OK, 0 rows affected (0.05 sec)
```

#### 2.3. 更改表引擎

`ALTER TABLE... ENGINE...`用来做表引擎更换。

`语法:`

```sql
ALTER TABLE ... ENGINE={InnoDB|TokuDB...}
```

`说明:`

* RadonDB 根据路由信息，发到相应的后端执行引擎更改。
* *跨分区非原子操作*。

`示例: `

```sql
mysql> SHOW CREATE TABLE t1\G;
*************************** 1. row ***************************
       Table: t1
Create Table: CREATE TABLE `t1` (
  `id` int(11) DEFAULT NULL,
  `age` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8
1 row in set (0.00 sec)

mysql> ALTER TABLE t1 ENGINE=TokuDB;
Query OK, 0 rows affected (0.15 sec)

mysql> SHOW CREATE TABLE t1\G;
*************************** 1. row ***************************
       Table: t1
Create Table: CREATE TABLE `t1` (
  `id` int(11) DEFAULT NULL,
  `age` int(11) DEFAULT NULL
) ENGINE=TokuDB DEFAULT CHARSET=utf8
1 row in set (0.00 sec)
```

#### 2.4. 更改表字符集

RadonDB 的表字符集默认为 utf8，下例语法用来修改表字符集。

`语法:`

```sql
ALTER TABLE table_name CONVERT TO CHARACTER SET {charset}
```

`说明:`

* RadonDB 根据路由信息，发到相应的后端执行表字符集修改。
* *跨分区非原子操作*。

`示例:`

```sql
mysql> create table t1(id int, b int) partition by hash(id);
Query OK, 0 rows affected (0.15 sec)

mysql> show create table t1\G;
*************************** 1. row ***************************
       Table: t1
Create Table: CREATE TABLE `t1` (
  `id` int(11) DEFAULT NULL,
  `b` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8
1 row in set (0.00 sec)

mysql> alter table t1 convert to character set utf8mb4;
Query OK, 0 rows affected (0.07 sec)

mysql> show create table t1\G;
*************************** 1. row ***************************
       Table: t1
Create Table: CREATE TABLE `t1` (
  `id` int(11) DEFAULT NULL,
  `b` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
1 row in set (0.00 sec)
```

#### 2.5. 清空表

`语法:`

```sql
TRUNCATE TABLE table_name
```

`说明:`

* *跨分区非原子操作*。

`示例:`

```sql
mysql> insert into t1(a) values(1);
Query OK, 1 row affected (0.01 sec)

mysql> select * from t1;
+------+
| a    |
+------+
|    1 |
+------+
1 row in set (0.01 sec)

mysql> truncate table t1;
Query OK, 0 rows affected (0.17 sec)

mysql> select * from t1;
Empty set (0.01 sec)
```

---------------------------------------------------------------------------------------------------

### 3. 列操作

#### 3.1. 添加新列

`语法:`

```sql
ALTER TABLE table_name ADD COLUMN (col_name column_definition,...)
```

`说明:`

* 为表增加新列。
* *跨分区非原子操作*。

`示例:`

```sql
mysql> CREATE TABLE t1(a int primary key) PARTITION BY HASHa);
Query OK, 0 rows affected (0.16 sec)

mysql> ALTER TABLE t1 ADD COLUMN (b int, c varchar(100));
Query OK, 0 rows affected (0.10 sec)

mysql> SHOW CREATE TABLE t1\G;
*************************** 1. row ***************************
       Table: t1
Create Table: CREATE TABLE `t1` (
  `a` int(11) NOT NULL,
  `b` int(11) DEFAULT NULL,
  `c` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`a`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1
1 row in set (0.00 sec)

```

#### 3.2. 删除列

`语法:`

```sql
ALTER TABLE table_name DROP COLUMN col_name
```

`说明:`

* 删除表的列。
* *无法删除分区键所在的列*。
* *跨分区非原子操作*。

`示例:`

```sql
mysql> ALTER TABLE t1 DROP COLUMN c;
Query OK, 0 rows affected (0.10 sec)

mysql> SHOW CREATE TABLE t1\G
*************************** 1. row ***************************
       Table: t1
Create Table: CREATE TABLE `t1` (
  `a` int(11) NOT NULL,
  `b` int(11) DEFAULT NULL,
  PRIMARY KEY (`a`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1
1 row in set (0.01 sec)

ERROR:
No query specified

mysql> ALTER TABLE t1 DROP COLUMN a;
ERROR 1105 (HY000): unsupported: cannot.drop.the.column.on.shard.key
```

#### 3.3. 修改列

`语法:`

```sql
ALTER TABLE table_name MODIFY COLUMN col_name column_definition
```

`说明:`

* 修改表的列定义。
* *无法修改分区键所在的列*。
* *跨分区非原子操作*。

`示例:`

```sql
mysql> ALTER TABLE t1 MODIFY COLUMN b bigint;
Query OK, 0 rows affected (0.31 sec)

mysql> SHOW CREATE TABLE t1\G;
*************************** 1. row ***************************
       Table: t1
Create Table: CREATE TABLE `t1` (
  `a` int(11) NOT NULL,
  `b` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`a`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1
1 row in set (0.00 sec)

mysql> ALTER TABLE t1 MODIFY COLUMN a bigint;
ERROR 1105 (HY000): unsupported: cannot.modify.the.column.on.shard.key
```

---------------------------------------------------------------------------------------------------

### 4. INDEX

为了简化索引操作， RadonDB 只支持 CREATE/DROP INDEX 语法。

#### 4.1. 添加索引

`语法:`

```sql
CREATE INDEX index_name ON table_name (index_col_name,...)
```

`说明:`

* RadonDB 根据路由信息，发到相应的后端执行索引添加。
* *跨分区非原子操作*。

`示例:`

```sql
mysql> CREATE INDEX idx_id_age ON t1(id, age);
Query OK, 0 rows affected (0.17 sec)
```

#### 4.2. 删除索引

`语法:`

```sql
  DROP INDEX index_name ON table_name
```

`说明:`

* RadonDB 根据路由信息，发到相应的后端执行索引删除。
* *跨分区非原子操作*。

`示例:`

```sql
mysql> DROP INDEX idx_id_age ON t1;
Query OK, 0 rows affected (0.09 sec)
```

## DML

### 1. SELECT 语句

`语法:`

```sql
SELECT
    select_expr [, select_expr ...]
    [FROM table_references
    [WHERE where_condition]
    [GROUP BY {col_name}
    [ORDER BY {col_name | expr | position}
      [ASC | DESC], ...]
    [LIMIT {[offset,] row_count | row_count OFFSET offset}]]
```

`说明:`

* 支持跨分区的 count, sum, avg, max, min 等聚合函数， *avg 字段必须在 select_expr 中*, 聚合函数只对数值型有效。
* 支持跨分区的 order by, group by, limit 等操作， *字段必须在 select_expr 中*。
* 支持 join 等复杂查询，自动路由到计算节点 (AP-Node) 执行并返回。

`示例:`

```sql
mysql> SELECT id, age, sum(id), avg(age) FROM t1 GROUP BY id ORDER BY id DESC LIMIT 10;
+------+------+---------+----------+
| id   | age  | sum(id) | avg(age) |
+------+------+---------+----------+
|    1 |   25 |       2 |       26 |
|    3 |   32 |       3 |       32 |
+------+------+---------+----------+
2 rows in set (0.01 sec)

```

### 2. INSERT 语句

`语法:`

```sql
INSERT INTO tbl_name
    (col_name,...)
    {VALUES | VALUE}
```

`说明:`

* 支持分布式事务，保证跨分区写入原子性。
* 支持 insert 多个值，这些值可以在不同分区。
* 必须指定写入列。
*  *不支持子句*。

`示例:`

```sql
mysql> INSERT INTO t1(id, age) VALUES(1, 24), (2, 28), (3, 29);
Query OK, 3 rows affected (0.01 sec)
```

### 3. DELETE 语句

`语法:`

```sql
DELETE  FROM tbl_name
    [WHERE where_condition]
```

`说明:`

* 支持分布式事务，保证跨分区删除原子性。
*  *不支持无 WHERE 条件删除*。
*  *不支持子句*。

`示例:`

```sql
mysql> DELETE FROM t1 WHERE id=1;
Query OK, 2 rows affected (0.01 sec)
```

### 4. UPDATE 语句

`语法:`

```sql
UPDATE table_reference
    SET col_name1={expr1|DEFAULT} [, col_name2={expr2|DEFAULT}] ...
    [WHERE where_condition]
```

`说明:`

* 支持分布式事务，保证跨分区更新原子性。
* *不支持无 WHERE 条件更新*。
* *不支持更新分区键*。
*  *不支持子句*。

`示例:`

```sql
mysql> UPDATE t1 set age=age+1 WHERE id=1;
Query OK, 1 row affected (0.00 sec)
```

### 5. REPLACE 语句

`语法:`

```sql
REPLACE INTO tbl_name
    [(col_name,...)]
    {VALUES | VALUE} ({expr | DEFAULT},...),(...),...
```

`说明:`

* 支持分布式事务，保证跨分区写入原子性。
* 支持 replace 多个值，这些值可以在不同分区。
* 必须指定写入列。

`示例:`

```sql
mysql> REPLACE INTO t1 (id, age) VALUES(3,34),(5, 55);
Query OK, 2 rows affected (0.01 sec)
```

## SHOW

### 1. SHOW ENGINES

`语法:`

```sql
SHOW ENGINES
```

`说明:`

* 后端分区 MySQL 支持的引擎列表。

`示例:`

```sql
mysql> SHOW ENGINES;
+--------------------+---------+----------------------------------------------------------------------------+--------------+------+------------+
| Engine             | Support | Comment                                                                    | Transactions | XA   | Savepoints |
+--------------------+---------+----------------------------------------------------------------------------+--------------+------+------------+
| MyISAM             | YES     | MyISAM storage engine                                                      | NO           | NO   | NO         |
| MRG_MYISAM         | YES     | Collection of identical MyISAM tables                                      | NO           | NO   | NO         |
| InnoDB             | DEFAULT | Percona-XtraDB, Supports transactions, row-level locking, and foreign keys | YES          | YES  | YES        |
| BLACKHOLE          | YES     | /dev/null storage engine (anything you write to it disappears)             | NO           | NO   | NO         |
| CSV                | YES     | CSV storage engine                                                         | NO           | NO   | NO         |
| PERFORMANCE_SCHEMA | YES     | Performance Schema                                                         | NO           | NO   | NO         |
| ARCHIVE            | YES     | Archive storage engine                                                     | NO           | NO   | NO         |
| TokuDB             | YES     | Percona TokuDB Storage Engine with Fractal Tree(tm) Technology             | YES          | YES  | YES        |
| FEDERATED          | NO      | Federated MySQL storage engine                                             | NULL         | NULL | NULL       |
| MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables                  | NO           | NO   | NO         |
+--------------------+---------+----------------------------------------------------------------------------+--------------+------+------------+
10 rows in set (0.00 sec)
```

### 2. SHOW DATABASES

`语法:`

```sql
SHOW DATABASES
```

`说明:`

* 包含系统 DB，比如 mysql, information_schema

`示例:`

```sql
mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sbtest             |
| sbtest1            |
| sys                |
| test               |
+--------------------+
7 rows in set (0.00 sec)
```

### 3. SHOW TABLES

`语法:`

```sql
SHOW TABLES
[FROM db_name]
```

`说明:`

* 如果未指定 db_name, 则返回当前 DB 下的表。

`示例:`

```sql
mysql> SHOW TABLES;
+----------------+
| Tables_in_test |
+----------------+
| t1             |
| t2             |
| t3             |
| t4             |
| t5             |
+----------------+
5 rows in set (0.00 sec)
```

### 4. SHOW CREATE TABLE

`语法:`

```sql
SHOW CREATE TABLE table_name
```

`说明:`

* N/A

`示例:`

```sql
mysql> SHOW CREATE TABLE t1\G;
*************************** 1. row ***************************
       Table: t1
Create Table: CREATE TABLE `t1` (
  `id` int(11) DEFAULT NULL,
  `b` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8
1 row in set (0.00 sec)
```

### 5. SHOW PROCESSLIST

`语法:`

```sql
SHOW PROCESSLIST
```

`说明:`

* 显示的为 client 到 RadonDB 的连接情况，并非后端分区 MySQL。

`示例:`

```sql
mysql> SHOW PROCESSLIST;
+------+------+-------------------+------+---------+------+-------+------+-----------+---------------+
| Id   | User | Host              | db   | Command | Time | State | Info | Rows_sent | Rows_examined |
+------+------+-------------------+------+---------+------+-------+------+-----------+---------------+
|    1 | mock | 192.168.0.3:35346 | test | Sleep   |  379 |       |      |         0 |             0 |
+------+------+-------------------+------+---------+------+-------+------+-----------+---------------+
1 row in set (0.00 sec)
```

### 6. SHOW VARIABLES

`语法:`

```sql
SHOW VARIABLES
    [LIKE 'pattern' | WHERE expr]
```

`说明:`

* 为了兼容 JDBC/mydumper 。
* SHOW VARIABLES 命令会发往后端分区 MySQL (随机分区)获取并返回。

## USE

### 1. USE DATABASE

`语法:`

```sql
USE db_name
```

`说明:`

* 切换当前 session 的 database

`示例:`

```sql
mysql> use test;
Database changed
```

## KILL

### 1. KILL processlist_id

`语法:`

```sql
KILL processlist_id
```

`说明:`

* kill 某个链接(包含终止链接正在执行的语句)。

`示例:`

```sql
mysql> show processlist;
+------+------+-----------------+------+---------+------+-------+------+-----------+---------------+
| Id   | User | Host            | db   | Command | Time | State | Info | Rows_sent | Rows_examined |
+------+------+-----------------+------+---------+------+-------+------+-----------+---------------+
|   11 | mock | 127.0.0.1:43028 | test | Sleep   |  291 |       |      |         0 |             0 |
+------+------+-----------------+------+---------+------+-------+------+-----------+---------------+
1 row in set (0.00 sec)

mysql> kill 11;
ERROR 2013 (HY000): Lost connection to MySQL server during query
```

## SET

`说明:`

* 为了兼容 JDBC/mydumper 。
* SET 是一个空操作，*所有操作并不会生效*，请勿直接使用。

