#include "network.h"

#include <mysql/mysql.h>
#include <string>
#include <iostream>
#include <ctime>

const char* DB_HOST = "172.20.128.29";
const char* DB_USER = "Jonathan";
const char* DB_PASS = "amongusishot34";
const char* DB_NAME = "cpu_p";
const int DB_PORT = 3306;

// every client should have a unique ID string that is stored in the database; the
// code will look up the corresponding numeric `users.id` and create the user if
// it does not yet exist.  this avoids hard‑coding a magic integer which was the
// source of the foreign‑key constraint errors.
const char* CLIENT_ID = "some_client_id"; // change to something unique per machine

// return the numeric id for CLIENT_ID, inserting a row when necessary; returns
// 0 on error
static int resolveUserId(MYSQL* conn) {
    std::string sel = "SELECT id FROM users WHERE client_id = '" + std::string(CLIENT_ID) + "'";
    if (mysql_query(conn, sel.c_str()) != 0) {
        std::cerr << "MySQL query error (select user): " << mysql_error(conn) << std::endl;
        return 0;
    }
    MYSQL_RES* res = mysql_store_result(conn);
    if (!res) {
        std::cerr << "MySQL store result error: " << mysql_error(conn) << std::endl;
        return 0;
    }
    MYSQL_ROW row = mysql_fetch_row(res);
    int id = 0;
    if (row) {
        id = atoi(row[0]);
    } else {
        std::string ins = "INSERT INTO users (client_id) VALUES ('" + std::string(CLIENT_ID) + "')";
        if (mysql_query(conn, ins.c_str()) != 0) {
            std::cerr << "MySQL query error (insert user): " << mysql_error(conn) << std::endl;
        } else {
            id = mysql_insert_id(conn);
        }
    }
    mysql_free_result(res);
    return id;
}

void sendCPUUsage(double usage) {
    MYSQL* conn = mysql_init(nullptr);
    
    if (!conn) {
        std::cerr << "MySQL init failed\n";
        return;
    }
    
    // Connect to database
    if (!mysql_real_connect(conn, DB_HOST, DB_USER, DB_PASS, DB_NAME, DB_PORT, nullptr, 0)) {
        std::cerr << "MySQL connection error: " << mysql_error(conn) << std::endl;
        mysql_close(conn);
        return;
    }
    
    // figure out the numeric id for this client; the helper inserts a row
    // in `users` if the client id is not yet present.
    int userId = resolveUserId(conn);
    if (userId == 0) {
        // there was an error in the lookup/insert; abort early
        mysql_close(conn);
        return;
    }

    // Build INSERT query using the resolved userId
    std::string query = "INSERT INTO cpu_metrics (user_id, cpu_usage) VALUES (" 
                      + std::to_string(userId) + ", " 
                      + std::to_string(usage) + ")";

    // Execute query
    if (mysql_query(conn, query.c_str()) != 0) {
        std::cerr << "MySQL query error: " << mysql_error(conn) << std::endl;
    } else {
        std::cout << "CPU usage " << usage << "% inserted into database\n";
    }
    
    mysql_close(conn);
}
