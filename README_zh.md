# MoonPtime - POSIX 时间库（适用于 MoonBit）| [ENGLISH](README.md)

一个轻量级的高精度时间处理库，专注于以皮秒（picosecond）精度表示的 POSIX 时间点与时间间隔（span）。

## 什么是 Ptime？

Ptime 是一个以时间点（time points）和时间间隔（time spans）为核心的时间库，避免复杂的日历和时区处理，提供：

- 高精度：皮秒级（12 位小数）子秒精度
- 简洁的 API：以时间点与时长为主要接口
- 遵循 POSIX：使用标准 Unix 时间戳（自 1970-01-01 00:00:00 UTC 的秒数）
- 支持 RFC 3339：标准时间字符串格式化（UTC）
- 纯 MoonBit 实现：无外部依赖

## 特性

- ✅ POSIX 时间表示（自 1970-01-01 00:00:00 UTC 起的秒数）
- ✅ 使用（seconds, picoseconds）二元表示，提供皮秒精度
- ✅ 时间点算术（对时间点加减时间间隔）
- ✅ 时间间隔操作（加、减、乘、比较）
- ✅ RFC 3339 字符串格式化（如 `2025-01-01T12:00:00Z`）
- ✅ 浮点转换（秒级 Double/Float）
- ✅ 比较运算与规范化（normalize）
- ✅ 简洁、易用的 API

## 使用方法

### 安装

```powershell
moon add Asterless/MoonPtime
```

（在 PowerShell 中运行上述命令以从 MoonBit 仓库添加依赖。）

### 基本示例

```moonbit
// 创建时间点
let epoch = @ptime.Ptime::epoch()
let now = @ptime.Ptime::of_float(1640995200.0) // 2022-01-01 00:00:00 UTC
let specific_time = @ptime.Ptime::of_ymd_hms(2025, 8, 22, 15, 30, 45)

// 创建时间间隔
let one_hour = @ptime.Span::of_seconds(3600L)
let half_second = @ptime.Span::of_ms(500L)

// 时间算术
let later = now.unwrap().add_span(one_hour)
let duration = later.diff(now.unwrap())

// RFC 3339 格式化
let time_string = later.to_rfc3339() // "2022-01-01T01:00:00Z"
```

## API 概览

### 核心类型

- `Ptime` — 表示自 POSIX epoch 起的时间点，采用（seconds, picoseconds）表示
- `Span` — 表示时长，可为正或负，同样采用（seconds, picoseconds）表示

### 时间点函数（示例）

- `Ptime::epoch() -> Ptime` — 创建 POSIX 纪元（1970-01-01 00:00:00 UTC）
- `Ptime::of_float(seconds: Double) -> Ptime?` — 从浮点秒创建时间点（可能失败，返回 Option）
- `Ptime::of_seconds(seconds: Int64) -> Ptime` — 从整数秒创建时间点
- `Ptime::of_ymd_hms(year, month, day, hour, minute, second) -> Ptime?` — 从年月日时分秒创建时间点
- `to_float(self) -> Double` — 将时间点转换为浮点秒
- `to_rfc3339(self) -> String` — 以 RFC 3339（UTC）格式输出字符串
- `get_seconds(self) -> Int64` — 获取 seconds 分量
- `get_picoseconds(self) -> Int64` — 获取 picoseconds 分量

### 时间算术

- `add_span(self, span: Span) -> Ptime` — 为时间点加上时间间隔
- `sub_span(self, span: Span) -> Ptime` — 从时间点减去时间间隔
- `diff(self, other: Ptime) -> Span` — 计算两个时间点之间的差值
- `compare(self, other: Ptime) -> Int` — 比较两个时间点（返回 -1, 0, 1）

### 时间间隔函数（示例）

- `Span::zero() -> Span` — 创建零时长
- `Span::of_float(seconds: Double) -> Span?` — 从浮点秒创建时长
- `Span::of_seconds(seconds: Int64) -> Span` — 从整数秒创建时长
- `Span::of_ms(milliseconds: Int64) -> Span` — 从毫秒创建时长
- `add(self, other: Span) -> Span` — 加法
- `sub(self, other: Span) -> Span` — 减法
- `scalar(self, n: Int64) -> Span` — 乘以整数因子（标量乘法）
- `neg(self) -> Span` — 取反（改变方向）

### Span 属性

- `is_positive(self) -> Bool` — 判定是否为正时长
- `is_negative(self) -> Bool` — 判定是否为负时长
- `is_zero(self) -> Bool` — 判定是否为零时长
- `compare(self, other: Span) -> Int` — 比较两个时长

## 示例

请参阅 `src/example.mbt`，其中包含：

- 基本时间点创建与转换
- 时间间隔运算示例
- 时间点加减与差值计算
- 时间比较示例
- 精度/规范化演示
- RFC 3339 输出示例

## RFC 3339 支持

库提供 RFC 3339 风格的字符串格式化（UTC）：

- 格式：`YYYY-MM-DDTHH:MM:SSZ`（不包含时区偏移，固定为 UTC）
- 示例：`2025-08-22T15:30:45Z`
- 当前实现：字符串输出支持秒级精度（如需更高精度字符串可扩展）

## 精度说明

MoonPtime 使用 `(seconds, picoseconds)` 表示法：

- seconds：`Int64` — 可表示很长时间范围的绝对时刻
- picoseconds：`Int64` — 提供 12 位小数的子秒精度
- 优势：适合高精度计时、日志和科学应用

## 测试

运行测试套件：

```powershell
moon test
```

测试包括：

- 时间点创建与转换验证
- 时间间隔算术与比较测试
- RFC 3339 输出验证
- 边界与异常条件测试
- 精度与规范化测试

## 性能

实现面向性能优化：

- 最小化分配：使用紧凑的值表示
- 快速算术：对基础运算优化（整型与模运算）
- 规范化操作：确保溢出/借位被正确处理

## 项目结构（简要）

```text
MoonPtime/
├── src/                        # 源文件
│   ├── moon.pkg.json           # 包描述与依赖（moon.pkg.json）
│   ├── pkg.generated.mbti      # 自动生成的包接口（由工具输出）
│   ├── ptime.mbt               # 核心实现（合并的实现文件）
│   ├── ptime_test.mbt          # 测试套件
│   ├── span.mbt                # Span 相关实现
│   ├── span_test.mbt           # Span 测试
│   ├── types.mbt               # 类型与共享定义
│   └── utils.mbt               # 工具辅助函数
├── target/                     # 构建产物（由 `moon` 生成）
├── README.md                   # 英文 README
├── README_zh.md                # 中文 README（本文件）
├── moon.mod.json               # 模块元信息
└── LICENSE                     # 许可证文件

说明：当前仓库使用合并的 `.mbt` 源文件（例如 `ptime.mbt`、`span.mbt`）。历史分支或某些 fork 可能将实现拆分为更多独立文件。
```

## 许可证

本项目使用 Apache License 2.0，详见 `LICENSE` 文件。

## 贡献指南

欢迎贡献！请遵循以下要点：

- 遵循 MoonBit 代码风格
- 新功能应附带测试
- 保持性能与接口稳定
- 更新文档以反映行为变化

## 常见问题（FAQ）

Q: 为什么不处理时区？

A: MoonPtime 专注于绝对时间点（UTC）与时长运算。若需时区处理，请在上层封装时区逻辑。

Q: 为什么使用皮秒精度？

A: 提供未来适用的高精度能力，适用于科学与高分辨率计时场景，避免子秒精度丢失。

Q: 是否适用于嵌入式系统？

A: 是的，库设计为低依赖与高效率，适合资源受限环境。

---

如果你希望我将中文 README 替换主 README（`README.md`），或将主 README 增加到中文索引、或者在包元数据中注册 `README_zh.md`，告诉我需求，我可以继续完成这些更改。
