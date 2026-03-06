#include <curl/curl.h>
#include <string>
#include <iostream>

// alternate implementation, kept only for reference
void sendCPUUsageServer(double usage) {
    CURL *curl = curl_easy_init();

    if (!curl) return;

    std::string json =
        "{ \"cpu_usage\": " + std::to_string(usage) + " }";

    struct curl_slist *headers = nullptr;
    headers = curl_slist_append(headers, "Content-Type: application/json");

    curl_easy_setopt(curl, CURLOPT_URL, "http://172.20.128.29:8080/cpu");
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, json.c_str());
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);

    CURLcode res = curl_easy_perform(curl);

    if (res != CURLE_OK) {
        std::cerr << "Failed to send data: "
                  << curl_easy_strerror(res) << std::endl;
    }

    curl_slist_free_all(headers);
    curl_easy_cleanup(curl);
}