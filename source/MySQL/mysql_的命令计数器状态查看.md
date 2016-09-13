title: mysql 的命令计数器状态查看
id: 263
categories:
  - mysql
date: 2015-01-22 20:35:31
tags:
---

mysql 的命令计数器状态查看

&nbsp;

mysql&gt; show status like '%questions%';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| Questions | 19 |
+---------------+-------+
1 row in set
mysql&gt; show status like '%questions%';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| Questions | 20 |
+---------------+-------+
1 row in set

&nbsp;

&nbsp;

mysql&gt; show status like '%com_%';

+---------------------------+-------+
| Variable_name | Value |
+---------------------------+-------+
| Com_admin_commands | 0 |
| Com_assign_to_keycache | 0 |
| Com_alter_db | 0 |
| Com_alter_db_upgrade | 0 |
| Com_alter_event | 0 |
| Com_alter_function | 0 |
| Com_alter_procedure | 0 |
| Com_alter_server | 0 |
| Com_alter_table | 0 |
| Com_alter_tablespace | 0 |
| Com_analyze | 0 |
| Com_begin | 0 |
| Com_binlog | 0 |
| Com_call_procedure | 0 |
| Com_change_db | 1 |
| Com_change_master | 0 |
| Com_check | 0 |
| Com_checksum | 0 |
| Com_commit | 0 |
| Com_create_db | 0 |
| Com_create_event | 0 |
| Com_create_function | 0 |
| Com_create_index | 0 |
| Com_create_procedure | 0 |
| Com_create_server | 0 |
| Com_create_table | 0 |
| Com_create_trigger | 0 |
| Com_create_udf | 0 |
| Com_create_user | 0 |
| Com_create_view | 0 |
| Com_dealloc_sql | 0 |
| Com_delete | 0 |
| Com_delete_multi | 0 |
| Com_do | 0 |
| Com_drop_db | 0 |
| Com_drop_event | 0 |
| Com_drop_function | 0 |
| Com_drop_index | 0 |
| Com_drop_procedure | 0 |
| Com_drop_server | 0 |
| Com_drop_table | 0 |
| Com_drop_trigger | 0 |
| Com_drop_user | 0 |
| Com_drop_view | 0 |
| Com_empty_query | 0 |
| Com_execute_sql | 0 |
| Com_flush | 0 |
| Com_grant | 0 |
| Com_ha_close | 0 |
| Com_ha_open | 0 |
| Com_ha_read | 0 |
| Com_help | 0 |
| Com_insert | 0 |
| Com_insert_select | 0 |
| Com_install_plugin | 0 |
| Com_kill | 0 |
| Com_load | 0 |
| Com_lock_tables | 0 |
| Com_optimize | 0 |
| Com_preload_keys | 0 |
| Com_prepare_sql | 0 |
| Com_purge | 0 |
| Com_purge_before_date | 0 |
| Com_release_savepoint | 0 |
| Com_rename_table | 0 |
| Com_rename_user | 0 |
| Com_repair | 0 |
| Com_replace | 0 |
| Com_replace_select | 0 |
| Com_reset | 0 |
| Com_resignal | 0 |
| Com_revoke | 0 |
| Com_revoke_all | 0 |
| Com_rollback | 0 |
| Com_rollback_to_savepoint | 0 |
| Com_savepoint | 0 |
| Com_select | 0 |
| Com_set_option | 1 |
| Com_signal | 0 |
| Com_show_authors | 0 |
| Com_show_binlog_events | 0 |
| Com_show_binlogs | 0 |
| Com_show_charsets | 0 |
| Com_show_collations | 0 |
| Com_show_contributors | 0 |
| Com_show_create_db | 0 |
| Com_show_create_event | 0 |
| Com_show_create_func | 0 |
| Com_show_create_proc | 0 |
| Com_show_create_table | 0 |
| Com_show_create_trigger | 0 |
| Com_show_databases | 0 |
| Com_show_engine_logs | 0 |
| Com_show_engine_mutex | 0 |
| Com_show_engine_status | 0 |
| Com_show_events | 0 |
| Com_show_errors | 0 |
| Com_show_fields | 0 |
| Com_show_function_status | 0 |
| Com_show_grants | 0 |
| Com_show_keys | 0 |
| Com_show_master_status | 0 |
| Com_show_open_tables | 0 |
| Com_show_plugins | 0 |
| Com_show_privileges | 0 |
| Com_show_procedure_status | 0 |
| Com_show_processlist | 0 |
| Com_show_profile | 0 |
| Com_show_profiles | 0 |
| Com_show_relaylog_events | 0 |
| Com_show_slave_hosts | 0 |
| Com_show_slave_status | 0 |
| Com_show_status | 5 |
| Com_show_storage_engines | 0 |
| Com_show_table_status | 0 |
| Com_show_tables | 0 |
| Com_show_triggers | 0 |
| Com_show_variables | 0 |
| Com_show_warnings | 0 |
| Com_slave_start | 0 |
| Com_slave_stop | 0 |
| Com_stmt_close | 0 |
| Com_stmt_execute | 0 |
| Com_stmt_fetch | 0 |
| Com_stmt_prepare | 0 |
| Com_stmt_reprepare | 0 |
| Com_stmt_reset | 0 |
| Com_stmt_send_long_data | 0 |
| Com_truncate | 0 |
| Com_uninstall_plugin | 0 |
| Com_unlock_tables | 0 |
| Com_update | 0 |
| Com_update_multi | 0 |
| Com_xa_commit | 0 |
| Com_xa_end | 0 |
| Com_xa_prepare | 0 |
| Com_xa_recover | 0 |
| Com_xa_rollback | 0 |
| Com_xa_start | 0 |
| Compression | OFF |
| Flush_commands | 1 |
| Handler_commit | 0 |
+---------------------------+-------+
142 rows in set

&nbsp;

&nbsp;