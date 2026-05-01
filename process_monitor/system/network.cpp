#include "network.h"

#include <mysql/mysql.h>
#include <string>
#include <iostream>
#include <ctime>
#include <unistd.h>    // for gethostname, sysconf

// Database connection details
const char* DB_HOST = "172.20.128.29";
const char* DB_USER = "Jonathan";
const char* DB_PASS = "amongusishot34";
const char* DB_NAME = "cpu_p";
const int DB_PORT = 3306;

// Automatically generate a unique CLIENT_ID per machine
std::string getUniqueClientId() {
    long hostname_max = sysconf(_SC_HOST_NAME_MAX);
    if (hostname_max < 1) hostname_max = 64; // fallback

    char* hostname = new char[hostname_max + 1];
    if (gethostname(hostname, hostname_max) == 0) {
        std::string id(hostname);
        delete[] hostname;
        return id;  // use hostname as CLIENT_ID
    } else {
        delete[] hostname;
        // fallback if hostname fails
        return "client_" + std::to_string(time(nullptr));
    }
}

// Use a global string so all functions share the same CLIENT_ID
std::string CLIENT_ID = getUniqueClientId();

// Return the numeric id for CLIENT_ID, inserting a row when necessary
// Returns 0 on error
static int resolveUserId(MYSQL* conn) {
    std::string sel = "SELECT id FROM users WHERE client_id = '" + CLIENT_ID + "'";
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
        std::string ins = "INSERT INTO users (client_id) VALUES ('" + CLIENT_ID + "')";
        if (mysql_query(conn, ins.c_str()) != 0) {
            std::cerr << "MySQL query error (insert user): " << mysql_error(conn) << std::endl;
        } else {
            id = mysql_insert_id(conn);
        }
    }

    mysql_free_result(res);
    return id;
}

// Sends CPU usage to the database for this client
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

    // Resolve numeric user ID
    int userId = resolveUserId(conn);
    if (userId == 0) {
        mysql_close(conn);
        return;
    }

    // Insert CPU usage
    std::string query = "INSERT INTO cpu_metrics (user_id, cpu_usage) VALUES (" 
                        + std::to_string(userId) + ", " 
                        + std::to_string(usage) + ")";
    
    if (mysql_query(conn, query.c_str()) != 0) {
        std::cerr << "MySQL query error: " << mysql_error(conn) << std::endl;
    } else {
        std::cout << "CPU usage " << usage << "% inserted into database for CLIENT_ID: " 
                  << CLIENT_ID << std::endl;
    }

    mysql_close(conn);
}