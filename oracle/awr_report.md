---
title: "AWRレポート"
format: html
---

## AWRレポート

AWRスナップショットではCPU使用時間などの実行統計値を観測し、インスタンス起動後の累積統計値を表にしたものを記録している。<br>
AWRスナップショットを2点で指定し、その間の実行統計を読みやすいように整形したHTMLファイルがAWRレポート

oracleに接続し、sqlplusスクリプトを実行することでレポートを作成できる。<br>
レポートは以下のコマンドを実行したディレクトリで作成される。

```  bash
$ sqlplus / as sysdba
```

このコマンドでログインし、AWRレポートを作成するとプラガブルDBすべての統計情報が出力される。<br>
AWRレポートは以下のSQL文を実行し、`$ORACLE_HOME/rdbms/admin`でディレクトリ内にあるawrrpt内のSQLスクリプトを実行する。


``` sql 
SQL> @?/rdbms/admin/awrrpt
```

実行後出力形式を問われる。デフォルトはHTML

```
Specify the Report Type
~~~~~~~~~~~~~~~~~~~~~~~
AWR reports can be generated in the following formats.  Please enter the
name of the format at the prompt.  Default value is 'html'.

'html'          HTML format (default)
'text'          Text format
'active-html'   Includes Performance Hub active report

report_typeに値を入力してください:

```
次にDBIDとインスタンスの指定がされる。awrrpt.sqlの場合今接続しているOracleインスタンスに決め打ちされる。<br>
この次にどのスナップショットを使うか、ファイル名の指定がある。<br>

### AWRスナップショットの手動取得

以下の文でスナップショットの取得が行える。

``` sql
SQL> EXEC DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT;

PL/SQLプロシージャが正常に完了しました。
```

スナップショットのIDの戻り値は以下の通り

``` sql
SQL> SELECT DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT() FROM DUAL;

DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT()
------------------------------------------
                                      3258

```


