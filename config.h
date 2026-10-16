// config.h —— 中间层全局配置（生产级：从 JSON 配置文件加载，支持环境变量覆盖）
#pragma once

#include <string>
#include <fstream>
#include <json.hpp>

namespace mw {

struct Config {
    // HTTP / HTTPS
    int http_port = 8899;
    bool use_https = false;             // 是否启用 HTTPS
    std::string cert_path;              // 证书文件（.crt/.pem）
    std::string key_path;               // 私钥文件（.key）

    // MySQL
    std::string mysql_host = "43.157.39.171";
    int mysql_port = 3306;
    std::string mysql_user = "oj_user";
    std::string mysql_pass = "12345678";
    std::string mysql_db = "oj";

    // LSM
    std::string lsm_host = "43.157.39.171";
    int lsm_port = 6380;

    // 限流
    int rate_limit_max = 60;      // 每 client 每分钟最大请求数
    int rate_limit_window = 60;   // 秒

    static Config load(const std::string& path) {
        Config c;
        std::ifstream f(path);
        if (!f.is_open()) return c;  // 用默认值
        try {
            nlohmann::json j = nlohmann::json::parse(f);
            if (j.contains("http_port")) c.http_port = j["http_port"];
            if (j.contains("use_https")) c.use_https = j["use_https"];
            if (j.contains("cert_path")) c.cert_path = j["cert_path"];
            if (j.contains("key_path")) c.key_path = j["key_path"];
            if (j.contains("mysql")) {
                auto& m = j["mysql"];
                if (m.contains("host")) c.mysql_host = m["host"];
                if (m.contains("port")) c.mysql_port = m["port"];
                if (m.contains("user")) c.mysql_user = m["user"];
                if (m.contains("pass")) c.mysql_pass = m["pass"];
                if (m.contains("db")) c.mysql_db = m["db"];
            }
            if (j.contains("lsm")) {
                auto& l = j["lsm"];
                if (l.contains("host")) c.lsm_host = l["host"];
                if (l.contains("port")) c.lsm_port = l["port"];
            }
            if (j.contains("rate_limit")) {
                auto& r = j["rate_limit"];
                if (r.contains("max")) c.rate_limit_max = r["max"];
                if (r.contains("window")) c.rate_limit_window = r["window"];
            }
        } catch (...) {}
        return c;
    }
};

} // namespace mw
