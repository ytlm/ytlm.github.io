---
title: MySQL 使用总结
date: 2016-07-24 15:14:56
tags: 
    - MySQL
categories: 
    - 学习
---
下面是在学习MySQL的时候一些命令的纪录

<!--more-->

1，增
```MySQL
INSERT INTO "tableName(列1,列2,...)" VALUES(值1,值2,...)
/* 1,列和值需要意义对应。
   2，列可以省略，省略时值应该和数据表中的值顺序保持一致。
*/
```

2，删
```MySQL
DELETE FROM "tableName" WHERE "condition1" AND "condition2" ...
/* 在执行删除语句的时候一定要写好where后面的条件。 */
```

3，改
```MySQL
UPDATE "tableName" SET "key = value" WHERE "condition1" AND "condition2" ...
/* 根据where后面的条件，对表中某些字段数据进行修改。*/
```

4，查
```MySQL
SELECT "fields" FROM "tableName" WHERE "condition"
/* 单表查询，根据条件查询某张表中的某几列数据。where和列(fields)可以省略。 */

SELECT "fields" FROM "table1, table2,..." WHERE "condition1" AND "condition2" ...
/* 多表查询，根据表与表之间的关联关系查询所需要的数据。*/
```

5，数据库
```MySQL
CREATE DATABASE "databaseName" /* 创建数据库 */

DROP DATABASE "databaseName" /* 删除数据库 */
```

6，数据表
```MySQL
CREATE TABLE table_name (columnName columnType) /* 创建数据表，column_type为列类型及属性 */

DROP TABLE "tableName" /* 删除数据表 */

ALTER TABLE "tableName" RENAME TO "newTableName"  /* 修改表名称*/
```

7，ALTER
```MySQL
ALTER TABLE "tableName" DROP "columnName" /*删除表中的某个字段 */

ALTER TABLE "tableName" ADD "columnName columnType" FIRST/[AFTER "columnName"]
/*在数据表中第一位或者在某个字段之后添加某个字段 */

ALTER TABLE "tableName" MODIFY "columnName" "newColumnType" /* 修改表中某个字段的类型属性 */

ALTER TABLE "tableName" CHANGE "columnName" "columnName newColumnType"
/* 修改表中的的某个字段名并添加可以添加新的类型，还可以值修改字段类型 */

ALTER TABLE "tableName" RENAME TO "newTableName"  /* 修改表名称*/
```

8，权限
```MySQL
GRANT "power" ON "databaseName" TO "user" /* 给用户user添加数据库databaseName对应的权限power*/
REVOKE "power" ON "databaseName" FROM "user" /* 移除用户user在数据库databaseName上的权限power */
FLUSH PRIVILEGES /* 在不重启MySQL服务的情况下使得权限操作生效 */
```

9, 显示表详细结构
```MySQL
SHOW TABLES; 显示所有的表

DESCRIBE table_name; 显示表结构下的所有字段信息 相当于SHOW FIELDS FROM table_name

SHOW FULL FIELDS FROM table_name 显示表结构下的所有字段信息 包含注释
```

10，其他
```MySQL
GROUP BY "columnName" /* 对某一列查询结果进行分组统计 */
ORDER BY "columnName"  ASC/DESC /* 对某一列查询结果进行排序操作，升序ASC，降序DESC */
SUM("columnName") /* 对某一分组进行统计 */
COUNT("columnName") /* 对某一分组进行计数 */
AVG("columnName") /* 对某一分组进行求平均值操作 */
.......................等等函数
```

***后续在学习中会继续进行补充，谢谢！***

---
>如有疑问欢迎批评指正，谢谢！


