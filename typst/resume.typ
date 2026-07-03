#import "@preview/vantage-cv:1.0.0": vantage-cv, term, skill, styled-link

#vantage-cv(
  name: "邴海诺",
  position: "全栈开发 / AI 应用",
  links: (
    (name: "email", link: "mailto:biscuit060613@gmail.com", display: "biscuit060613@gmail.com"),
    (name: "website", link: "https://biscuit0613.github.io", display: "biscuit0613.github.io"),
    (name: "github", link: "https://github.com/biscuit0613", display: "biscuit0613"),
  ),
  tagline: [],
  [
    === 项目经历

    ==== \ 天工开悟智慧农业平台 \
    _#styled-link("https://www.tgkwai.com/", link("https://www.tgkwai.com/")[天工开悟])_ \
    #term("2025 - 至今", "全栈开发")

    - Kotlin + Compose / React + TypeScript / Java Spring Boot 构建完整全栈
    - 封装 MCP 服务对接大模型，处理流式输出，提升交互体验
    - 参与数据库设计、API 接口开发及前后端联调
    - 正在积极尝试 Rust + Axum 重构后端服务

    ==== 分布式路由模拟实验 \
    _#styled-link("https://github.com/biscuit0613/kvcache-router", "GitHub")_ \
    #term("2025", "")

    - 使用 Go 实现前缀亲和路由算法，支持动态路由表更新
    - 基于 goroutine 并发模型与 channel 通信实现高并发请求处理
    - 编写单元测试与性能分析，验证系统在并发场景下的稳定性

    ==== RoboMaster 哨兵机器人决策导航 \
    #term("2025", "C++ / ROS2")

    - 使用 C++ 与 ROS2 实现哨兵机器人自主导航与决策系统
    - 基于 MaxQ-OP 算法设计路径规划，实现动态环境下最优决策
    - 通过仿真与实地测试优化导航性能

    ==== 个人开发 & 技术探索 \
    #term("2024 - 至今", "Linux")

    - 尝试过 RAG 知识库构建：Ollama + DeepSeek 对话模型
    - 日常使用 Linux 系统开发，熟悉命令行工具链与容器开发
  ],
  [
    == 教育背景

    === 哈尔滨工业大学 \
    #term("2024 - 至今", "哈尔滨")

    AI+先进技术领军班 本科

    主修：数据结构与算法、计算机系统原理、网络与分布式系统、模式识别与机器学习、计算机视觉

    == 技术栈

    #skill("Go", 4)
    #skill("Python", 3)
    #skill("TypeScript", 3)
    #skill("Rust", 3)
    #skill("Java", 3)
    #skill("C++", 3)
    #skill("Kotlin (Compose)", 3)
    #skill("React", 3)
    #skill("Spring Boot", 3)

    == 开发工具

    - CachyOS Linux · Git · Podman
    - MCP · RAG · Ollama · DeepSeek · Claude

    == 语言

    - 中文（母语）
    - 英语（CET-6）
  ],
)
