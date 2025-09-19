use clap::{Parser, Subcommand};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use tokio;
use chrono::{DateTime, Utc};
use uuid::Uuid;

/// Demo工具程序 - 数据处理和系统监控工具
#[derive(Parser)]
#[command(name = "demo-tools")]
#[command(about = "Rust工具程序，用于数据处理和系统监控", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// 数据处理工具
    Data {
        #[command(subcommand)]
        action: DataCommands,
    },
    /// 系统监控工具
    Monitor {
        #[command(subcommand)]
        action: MonitorCommands,
    },
    /// API测试工具
    Api {
        #[command(subcommand)]
        action: ApiCommands,
    },
}

#[derive(Subcommand)]
enum DataCommands {
    /// 生成测试用户数据
    GenerateUsers {
        /// 生成用户数量
        #[arg(short, long, default_value_t = 10)]
        count: u32,
        /// 输出文件路径
        #[arg(short, long, default_value = "users.json")]
        output: String,
    },
    /// 验证JSON数据格式
    ValidateJson {
        /// JSON文件路径
        #[arg(short, long)]
        file: String,
    },
}

#[derive(Subcommand)]
enum MonitorCommands {
    /// 系统信息监控
    System,
    /// 进程监控
    Process {
        /// 进程名称
        #[arg(short, long)]
        name: Option<String>,
    },
}

#[derive(Subcommand)]
enum ApiCommands {
    /// 测试API健康状态
    Health {
        /// API服务器地址
        #[arg(short, long, default_value = "http://localhost:8080")]
        url: String,
    },
    /// 测试用户API
    TestUsers {
        /// API服务器地址
        #[arg(short, long, default_value = "http://localhost:8080")]
        url: String,
    },
}

#[derive(Serialize, Deserialize, Debug)]
struct User {
    id: u32,
    name: String,
    email: String,
    created_at: DateTime<Utc>,
    uuid: String,
}

#[derive(Serialize, Deserialize, Debug)]
struct SystemInfo {
    timestamp: DateTime<Utc>,
    hostname: String,
    uptime: String,
    memory_usage: String,
    cpu_usage: String,
}

#[tokio::main]
async fn main() {
    let cli = Cli::parse();

    match cli.command {
        Commands::Data { action } => {
            handle_data_commands(action).await;
        }
        Commands::Monitor { action } => {
            handle_monitor_commands(action).await;
        }
        Commands::Api { action } => {
            handle_api_commands(action).await;
        }
    }
}

/**
 * 处理数据相关命令
 * @param action 数据命令类型
 */
async fn handle_data_commands(action: DataCommands) {
    match action {
        DataCommands::GenerateUsers { count, output } => {
            generate_test_users(count, &output).await;
        }
        DataCommands::ValidateJson { file } => {
            validate_json_file(&file).await;
        }
    }
}

/**
 * 处理监控相关命令
 * @param action 监控命令类型
 */
async fn handle_monitor_commands(action: MonitorCommands) {
    match action {
        MonitorCommands::System => {
            monitor_system_info().await;
        }
        MonitorCommands::Process { name } => {
            monitor_process_info(name).await;
        }
    }
}

/**
 * 处理API相关命令
 * @param action API命令类型
 */
async fn handle_api_commands(action: ApiCommands) {
    match action {
        ApiCommands::Health { url } => {
            test_api_health(&url).await;
        }
        ApiCommands::TestUsers { url } => {
            test_users_api(&url).await;
        }
    }
}

/**
 * 生成测试用户数据
 * @param count 用户数量
 * @param output_file 输出文件路径
 */
async fn generate_test_users(count: u32, output_file: &str) {
    println!("🔧 生成 {} 个测试用户数据...", count);
    
    let mut users = Vec::new();
    let names = vec![
        "张三", "李四", "王五", "赵六", "钱七", "孙八", "周九", "吴十",
        "郑十一", "王十二", "冯十三", "陈十四", "褚十五", "卫十六", "蒋十七", "沈十八"
    ];
    
    for i in 1..=count {
        let name_index = ((i - 1) % names.len() as u32) as usize;
        let user = User {
            id: i,
            name: format!("{}{}", names[name_index], i),
            email: format!("user{}@example.com", i),
            created_at: Utc::now(),
            uuid: Uuid::new_v4().to_string(),
        };
        users.push(user);
    }
    
    match serde_json::to_string_pretty(&users) {
        Ok(json_data) => {
            match std::fs::write(output_file, json_data) {
                Ok(_) => {
                    println!("✅ 成功生成用户数据文件: {}", output_file);
                    println!("📊 生成用户数量: {}", count);
                }
                Err(e) => {
                    eprintln!("❌ 写入文件失败: {}", e);
                }
            }
        }
        Err(e) => {
            eprintln!("❌ JSON序列化失败: {}", e);
        }
    }
}

/**
 * 验证JSON文件格式
 * @param file_path JSON文件路径
 */
async fn validate_json_file(file_path: &str) {
    println!("🔍 验证JSON文件: {}", file_path);
    
    match std::fs::read_to_string(file_path) {
        Ok(content) => {
            match serde_json::from_str::<serde_json::Value>(&content) {
                Ok(json_value) => {
                    println!("✅ JSON格式验证通过");
                    
                    // 尝试解析为用户数组
                    if let Ok(users) = serde_json::from_str::<Vec<User>>(&content) {
                        println!("📊 检测到用户数据，共 {} 条记录", users.len());
                        
                        // 显示前3条记录作为示例
                        for (index, user) in users.iter().take(3).enumerate() {
                            println!("  {}. {} ({})", index + 1, user.name, user.email);
                        }
                        
                        if users.len() > 3 {
                            println!("  ... 还有 {} 条记录", users.len() - 3);
                        }
                    } else {
                        println!("📄 通用JSON数据，结构如下:");
                        if let Some(obj) = json_value.as_object() {
                            for key in obj.keys().take(5) {
                                println!("  - {}", key);
                            }
                        }
                    }
                }
                Err(e) => {
                    eprintln!("❌ JSON格式验证失败: {}", e);
                }
            }
        }
        Err(e) => {
            eprintln!("❌ 读取文件失败: {}", e);
        }
    }
}

/**
 * 监控系统信息
 */
async fn monitor_system_info() {
    println!("🖥️  系统信息监控");
    
    let system_info = SystemInfo {
        timestamp: Utc::now(),
        hostname: std::env::var("HOSTNAME").unwrap_or_else(|_| "unknown".to_string()),
        uptime: "模拟运行时间: 2天3小时".to_string(),
        memory_usage: "内存使用: 4.2GB / 16GB (26%)".to_string(),
        cpu_usage: "CPU使用率: 15%".to_string(),
    };
    
    println!("📊 系统状态:");
    println!("  🕐 时间戳: {}", system_info.timestamp.format("%Y-%m-%d %H:%M:%S UTC"));
    println!("  🏠 主机名: {}", system_info.hostname);
    println!("  ⏱️  运行时间: {}", system_info.uptime);
    println!("  💾 {}", system_info.memory_usage);
    println!("  🔥 {}", system_info.cpu_usage);
}

/**
 * 监控进程信息
 * @param process_name 进程名称（可选）
 */
async fn monitor_process_info(process_name: Option<String>) {
    match process_name {
        Some(name) => {
            println!("🔍 监控进程: {}", name);
            println!("📊 进程状态: 运行中");
            println!("  💾 内存使用: 128MB");
            println!("  🔥 CPU使用: 2.5%");
            println!("  🆔 进程ID: 12345");
        }
        None => {
            println!("📋 系统进程概览:");
            let processes = vec![
                ("demo-backend", "12345", "128MB", "2.5%"),
                ("node", "12346", "256MB", "5.2%"),
                ("demo-tools", "12347", "32MB", "0.8%"),
            ];
            
            for (name, pid, memory, cpu) in processes {
                println!("  📦 {} (PID: {}) - 内存: {}, CPU: {}", name, pid, memory, cpu);
            }
        }
    }
}

/**
 * 测试API健康状态
 * @param api_url API服务器地址
 */
async fn test_api_health(api_url: &str) {
    println!("🏥 测试API健康状态: {}", api_url);
    
    let health_url = if api_url.ends_with("/health") {
        api_url.to_string()
    } else {
        format!("{}/api/health", api_url)
    };
    
    match reqwest::get(&health_url).await {
        Ok(response) => {
            let status = response.status();
            println!("📡 HTTP状态码: {}", status);
            
            if status.is_success() {
                match response.text().await {
                    Ok(body) => {
                        println!("✅ API服务正常运行");
                        println!("📄 响应内容: {}", body);
                    }
                    Err(e) => {
                        println!("⚠️  无法读取响应内容: {}", e);
                    }
                }
            } else {
                println!("❌ API服务异常，状态码: {}", status);
            }
        }
        Err(e) => {
            eprintln!("❌ 连接API失败: {}", e);
            eprintln!("💡 请确保后端服务正在运行在 {}", api_url);
        }
    }
}

/**
 * 测试用户API接口
 * @param api_url API服务器地址
 */
async fn test_users_api(api_url: &str) {
    println!("👥 测试用户API接口: {}", api_url);
    
    let users_url = if api_url.contains("/api/users") {
        api_url.to_string()
    } else {
        format!("{}/api/users", api_url)
    };
    
    // 测试获取用户列表
    println!("🔍 测试获取用户列表...");
    match reqwest::get(&users_url).await {
        Ok(response) => {
            let status = response.status();
            println!("📡 HTTP状态码: {}", status);
            
            if status.is_success() {
                match response.text().await {
                    Ok(body) => {
                        println!("✅ 用户列表API正常");
                        
                        // 尝试解析用户数据
                        if let Ok(users) = serde_json::from_str::<Vec<User>>(&body) {
                            println!("📊 用户数量: {}", users.len());
                            for (index, user) in users.iter().take(3).enumerate() {
                                println!("  {}. {} ({})", index + 1, user.name, user.email);
                            }
                        } else {
                            println!("📄 响应内容: {}", body);
                        }
                    }
                    Err(e) => {
                        println!("⚠️  无法读取响应内容: {}", e);
                    }
                }
            } else {
                println!("❌ 用户API异常，状态码: {}", status);
            }
        }
        Err(e) => {
            eprintln!("❌ 连接用户API失败: {}", e);
            eprintln!("💡 请确保后端服务正在运行在 {}", api_url);
        }
    }
    
    // 测试创建用户
    println!("\n📝 测试创建用户...");
    let new_user = HashMap::from([
        ("name", "测试用户"),
        ("email", "test@example.com"),
    ]);
    
    let client = reqwest::Client::new();
    match client.post(&users_url)
        .json(&new_user)
        .send()
        .await {
        Ok(response) => {
            let status = response.status();
            println!("📡 HTTP状态码: {}", status);
            
            if status.is_success() {
                match response.text().await {
                    Ok(body) => {
                        println!("✅ 创建用户成功");
                        println!("📄 响应内容: {}", body);
                    }
                    Err(e) => {
                        println!("⚠️  无法读取响应内容: {}", e);
                    }
                }
            } else {
                println!("❌ 创建用户失败，状态码: {}", status);
            }
        }
        Err(e) => {
            eprintln!("❌ 创建用户请求失败: {}", e);
        }
    }
}
