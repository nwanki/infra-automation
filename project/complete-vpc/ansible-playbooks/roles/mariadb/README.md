MariaDB
=========

Ansible role to manage [MariaDB](http://mariadb.com).

Requirements
------------

The only external dependency is the python bindings for mysql, which
this role will install.

Role Variables
--------------

When configuring MariaDB, you are encouraged to review the
[MariaDB documentation](https://mariadb.com/kb/en/documentation/) and
the recommendations for [configuring MariaDB for optimal performance](https://mariadb.com/kb/en/mariadb/configuring-mariadb-for-optimal-performance/].

- **mariadb_owner**:  The system user account that will own files in the
  data directory.
- **mariadb_conf_path**: Path to where the main configuration file is
  located.  Defaults to `/etc/my.cnf`.
- **mariadb_conf_include_dir**: Path to directory where configuration
  files will be included.  Defaults to `/etc/my.cnf.d`.
- **mariadb_root_username**: The MariaDB root user account name.
  Defaults to `root`.
- **mariadb_root_password**: The MariaDB root user account password.
  Defaults to `root`.
- **mariadb_root_home**: The home directory where the system user
  `.my.cnf` will be stored.  Defaults to `/root`.
- **mariadb_do_backup**: Whether to deploy a script to perform database
  backups.  Defaults to `no`.
- **mariadb_backup_dir**: Path to where backups should be kept.

The following variables control configuration of the daemon.  Refer to
the MariaDB documentation
[server system variables](https://mariadb.com/kb/en/mariadb/server-system-variables/). 

- **mariadb_port**:  The port to listen on; defaults to `3306`.
- **mariadb_bind_address**: The address to bind to; defaults to
  `0.0.0.0`.
- **mariadb_datadir**: The data directory for MariaDB; defaults to
  `/var/lib/mysql`.
- **mariadb_pid_file**: Path to where the PID file is stored; defaults
  to `/var/run/mariadb/mariadb.pid`.
- **mariadb_socket**: Path to the mysqld socket; defaults to
  `/var/lib/mysql/mysql.sock`.
- **mariadb_log_error**: Path to file for error logging; defaults to
  `/var/log/mariadb/mariadb.log`.
- **mariadb_max_connections**: Maximum number of allowed connections;
  defaults to `151`.

The following controls
[InnoDB specific settings](https://mariadb.com/kb/en/mariadb/xtradbinnodb-server-system-variables/).
Refer to the documentation for what the variable does.  This will
document the defaults.

- **mariadb_innodb_file_per_table**: Defaults to `1`.
- **mariadb_innodb_buffer_pool_size**: Defaults to `512M`.  Can be set
  up to 80% of the total memory.
- **mariadb_innodb_additional_mem_pool_size**: Defaults to `20M`.
- **mariadb_innodb_log_file_size**: Default is `64M`.
- **mariadb_innodb_log_buffer_size**: Default is `8M`.
- **mariadb_innodb_flush_log_at_trx_commit**: Default is `1`.
- **mariadb_innodb_lock_wait_timeout**: Default is `50`.

You can define what databases and database users to create using
`mariadb_databases` and `mariadb_users`.

* **mariadb_databases**: A list of databases to manage.  Each item in the list
  may define the keys `name` (name of the database), `encoding`
  (language encoding, defaults to `utf8`), `collation` (defaults to
  `utf8_general_ci`), and `state` (defaults to `present`).  It is
  typically only necessary to define the `name`.  Example:
```
mariadb_databases:
  - name: example
```
* **mariadb_users**: A list of users to manage.  Each item in the list
  may define the keys `name` (name of the database user), `host`
  (defaults to `localhost`), `password` (password for the user account),
  `priv` (privileges to grant user on the database), and `state`
  (defaults to `present`).  Example:
```
mariadb_users:
  - name: icarus
    password: poor-password
    priv: "example.*:ALL"
```


The following controls
[replication](https://mariadb.com/kb/en/mariadb/setting-up-replication/).
Refer to the MariaDB documentation for how to set up replication between
servers.

* **mariadb_server_id**: The MariaDB server ID.  Defaults to `1`.
* **mariadb_replication_user**: Same structure as `mariadb_user`.  Used
  specifically for replication.
* **mariadb_replication_role**: The replication role of the server in
  question.  Can be *master* or *slave*.
* **mariadb_replication_master**:  The replication master.

Dependencies
---------------

No dependency on other roles.

Example Playbook
----------------

A trivial example:

    - hosts: servers
      roles:
        - { role: sfromm.mariadb }
        
License
-------

GPLv2

Author Information
------------------

See https://github.com/sfromm
