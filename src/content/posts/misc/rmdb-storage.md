---
title: rmdb-storage
published: 2026-05-22
description: ''
image: ''
tags: []
category: '数据库'
draft: false 
lang: ''
---

## 一、磁盘文件层（持久化存储）

每个数据库对应一个操作系统目录，该目录下包含三类核心文件：

| 文件类型   | 命名规则             | 内容说明                                       | 管理模块              |
| ---------- | -------------------- | ---------------------------------------------- | --------------------- |
| 元数据文件 | `<database>.meta`    | 数据库内所有表的结构（表名、列定义、索引信息） | `system/DbMeta`       |
| 日志文件   | `<database>.log`     | WAL日志记录，用于故障恢复                      | `recovery/LogManager` |
| 表数据文件 | `<表名>`（无扩展名） | 每个表一个文件，存储该表的实际记录行           | `record/RmFileHandle` |
| 索引文件   | 由索引模块自行管理   | B+树索引存储，文件名与表、索引相关             | `index/IxIndexHandle` |

> 表的数据和表的元数据是**物理分离**的。

---

## 二、表数据文件的内部组织（文件 → 页 → 记录）

### 1. 文件头（第0页）：`RmFileHdr`

每个表文件的**第一个数据页（page_no = 0）** 固定存储文件头，结构如下：

```cpp
struct RmFileHdr {
    int record_size;            // 表中每条记录的长度（定长）
    int num_pages;              // 文件已分配的页总数（初始为1）
    int num_records_per_page;   // 每个页最多能存多少条记录
    int first_free_page_no;     // 当前第一个有空闲slot的页号（-1表示没有）
    int bitmap_size;            // 每个页中bitmap所占的字节数
};
```

- **`record_size`** 在表创建时根据所有 `ColMeta.len` 之和确定。
- **`bitmap_size`** 可根据 `num_records_per_page` 计算（每个记录需要1位）。

### 2. 数据页（page_no ≥ 1）：`Page` + `RmPageHandle`

每个数据页在磁盘上是固定的 `PAGE_SIZE`（4KB）。在内存中对应一个 `Page` 对象，该对象的 `data_` 数组存储以下布局：

| 区域        | 长度                   | 说明                                                                             |
| ----------- | ---------------------- | -------------------------------------------------------------------------------- |
| `page_lsn_` | 约4-8字节              | 本页最后修改对应的日志序列号（恢复用）                                           |
| `page_hdr`  | `sizeof(RmPageHdr)`    | 当前页的元信息：`num_records`（已用记录数）、`next_free_page_no`（下一个空闲页） |
| `bitmap`    | `file_hdr.bitmap_size` | 位图，标记每个slot是否已被占用                                                   |
| `slots`     | 动态                   | 连续存放实际的记录数据，每个记录长度为 `record_size`                             |

在内存中操作该页时，使用 `RmPageHandle` 结构体来方便地定位各个部分：

```cpp
struct RmPageHandle {
    const RmFileHdr *file_hdr;   // 指向表文件头（元信息）
    Page *page;                  // 指向内存中的Page对象
    RmPageHdr *page_hdr;         // 指向page->data中的RmPageHdr
    char *bitmap;                // 指向page->data中的bitmap起始地址
    char *slots;                 // 指向page->data中的slots起始地址
};
```

### 3. 记录标识符：`Rid`

每条记录在表文件中被唯一标识为：

```cpp
struct Rid {
    int page_no;    // 页号（从1开始，0为文件头）
    int slot_no;    // 该页内的slot下标（从0开始）
};
```

通过 `Rid` 可以快速定位：表文件 → 读取第 `page_no` 页 → 在该页的 `slots` 区域偏移 `slot_no * record_size` 处读取/写入记录数据。

### 4. 内存中的记录：`RmRecord`

当一条记录被读到内存后，用 `RmRecord` 表示：

```cpp
struct RmRecord {
    char *data;     // 指向连续的记录数据缓冲区（长度为 record_size）
    int size;       // = record_size
};
```

这个 `data` 中按照 `ColMeta.offset` 存放着每一列的值。

---

## 三、元数据的存储与加载（数据库层面）

### 1. 数据库元数据：`DbMeta` 类

数据库打开时，`<database>.meta` 文件被加载到内存中的 `DbMeta` 对象：

```cpp
class DbMeta {
    std::string name_;                              // 数据库名称
    std::map<std::string, TabMeta> tabs_;           // 表名 → 表的元数据
};
```

### 2. 表的元数据：`TabMeta` 结构

```cpp
struct TabMeta {
    std::string name;                       // 表名
    std::vector<ColMeta> cols;              // 所有列的定义
    std::vector<IndexMeta> indexes;         // 所有索引的定义
};
```

### 3. 列的元数据：`ColMeta` 结构

```cpp
struct ColMeta {
    std::string tab_name;    // 表名
    std::string name;        // 列名
    ColType type;            // INT / FLOAT / STRING
    int len;                 // 字段长度（字节）
    int offset;              // 该列在记录中的起始偏移量（字节）
};
```

- **`offset`** 在表创建时由系统按顺序累加 `len` 计算。

- 这个偏移量是**查询执行时**从 `RmRecord.data` 中提取列的**核心依据**。

```sql
CREATE TABLE student (
    id   INT,
    name VARCHAR(20),
    age  INT
);
```

DbMeta 中增加一个 TabMeta，名称为 "student"。

TabMeta.cols 包含三个 ColMeta：

```
{tab_name:"student", name:"id", type:TYPE_INT, len:4, offset:0}

{tab_name:"student", name:"name", type:TYPE_STRING, len:20, offset:4}

{tab_name:"student", name:"age", type:TYPE_INT, len:4, offset:24}

record_size = 4+20+4 = 28 字节（定长）。
```

磁盘上生成文件 student。文件头 RmFileHdr 写入：record_size=28，num_records_per_page = 每页能存多少条（根据页面大小和bitmap开销计算），bitmap_size 等。

分配第 0 页存储 RmFileHdr，第 1 页及以后用来存记录。

```sql
INSERT INTO student VALUES (1, 'Alice', 20);
```

从 RmFileHandle 中找到第一个有空闲 slot 的数据页（例如第 1 页）。

在该页的 bitmap 中标记某个 slot（比如 slot 0）为已用。

将 28 字节的数据（1 转成 4 字节，'Alice' 占 20 字节，20 转成 4 字节）写入 slots[0] 位置。

返回 Rid(page_no=1, slot_no=0)

```sql
SELECT id, age FROM student WHERE name='Alice';
```

**全表扫描算子**通过 RmFileHandle 遍历所有数据页和每个页内的 slots，获取 RmRecord（即整行数据 data 指针）。

对于每一行，根据 TabMeta.cols 中的 offset 提取列：

id 的值：从 data + offset_of_id(0) 读取 4 字节 → 1

age 的值：从 data + offset_of_age(24) 读取 4 字节 → 20

再通过 name 列的条件（data+4 处比较字符串）筛选出 'Alice' 的行。

---

## 四、内存缓冲层（Buffer Pool）

### 1. 缓冲池管理器：`BufferPoolManager`

缓冲池是内存中的一个固定大小的帧数组，每个帧可以存放一个磁盘页面（`Page` 对象）。

```cpp
class BufferPoolManager {
    size_t pool_size_;                           // 帧的数量
    Page *pages_;                                // 连续存放的 Page 对象数组
    std::unordered_map<PageId, frame_id_t> page_table_;  // 页号 → 帧号映射
    std::list<frame_id_t> free_list_;            // 空闲帧列表
    LRUReplacer *replacer_;                      // 页面替换策略
    std::mutex latch_;                           // 并发控制
};
```

- 当需要访问某个 `(fd, page_no)` 时，先在 `page_table_` 中查找是否已在缓冲池中；
- 若不在，则从 `free_list_` 或通过 `replacer_` 驱逐一个帧，调用 `DiskManager` 读取磁盘页到该帧；
- 返回 `Page*` 指针，上层通过 `RmPageHandle` 操作该页。

### 2. 页面替换策略：`LRUReplacer`

```cpp
class LRUReplacer {
    std::list<frame_id_t> LRUList_;              // 按最近使用时间排序的帧列表
    std::unordered_map<frame_id_t, iterator> LRUhash_; // 帧号 → 列表中的迭代器
    size_t max_size_;
};
```

- 当帧被固定（pin）时，从替换器中移除；
- 当帧被解固定（unpin）时，加入替换器；
- 需要驱逐时，返回 `LRUList_` 尾部的帧（最近最少使用）。

### 3. 页面的并发控制：`ReaderWriterLatch`

每个 `Page` 对象内部有一个读写锁：

```cpp
ReaderWriterLatch rw_latch_;
```

- 读操作前加读锁（共享）；
- 写操作前加写锁（排他）；
- 保证同一时刻只有一个线程能修改页面，但允许多个线程同时读取。

---

## 五、索引存储层次（简要）

索引文件（B+树）也采用类似的分页存储：

- **文件头**：`IxFileHdr` 存储根页号、树阶数、字段信息等。
- **内部节点/叶子节点页**：每个节点存储在一个 `Page` 中，通过 `IxPageHdr` 记录父节点、是否为叶子、前后兄弟等。
- **键值对**：`<key, Rid>`，其中 `Rid` 指向表文件中的记录位置。
- **上层接口**：`IxIndexHandle` 提供插入、删除、查找；`IxScan` 提供叶子链遍历。

---

## 六、完整的存储层次图（从上到下）

```text
[SQL 语句]
    ↓
[查询执行器] 使用火山模型 (Next) 访问算子
    ↓
[算子] 通过 RmFileHandle 进行表扫描，或者通过 IxIndexHandle 走索引
    ↓
[RmFileHandle] 提供 record-level 接口：insert_record(record, rid)、get_record(rid) 等
    ↓
[BufferPoolManager] 提供 page-level 接口：FetchPage(page_id)、UnpinPage(page_id)、FlushPage()
    ↓
[Page] 内存中的 4KB 数据块，包含 `data_` 数组和 lsn、pin_count、is_dirty、读写锁
    ↓
[DiskManager] 提供 file-level 接口：ReadPage(fd, page_no, data)、WritePage(fd, page_no, data)
    ↓
[操作系统文件] 数据库目录下的 .meta、.log、表文件、索引文件
```

---

## 七、数据与元数据的对应关系

| 存储对象                   | 存放位置                                    | 关键数据结构                          | 映射/定位方式                     |
| -------------------------- | ------------------------------------------- | ------------------------------------- | --------------------------------- |
| 表的**记录数据**           | 表文件（如 `student`）的 ≥1 页的 `slots` 区 | `Page`、`RmPageHandle`、`RmRecord`    | 通过 `Rid(page_no, slot_no)` 定位 |
| 表的**元数据**（名称、列） | `<database>.meta` 文件（加载到 `DbMeta`）   | `DbMeta` → `TabMeta` → `ColMeta`      | 表名映射到 `TabMeta`              |
| 列的**具体值**             | 在 `RmRecord.data` 缓冲区中                 | `ColMeta.offset`                      | `data + offset` 读取/写入         |
| 列与记录的**对应关系**     | 纯计算逻辑，不存储                          | `record_size` = 各 `ColMeta.len` 之和 | 创建表时固化，永不改变            |
| 索引键值对                 | 索引文件（B+树）                            | `IxFileHdr`、`IxPageHdr`              | 叶子节点中存储 `<key, Rid>`       |

> **RMDB 的存储层次是：数据库目录 → 表文件/元数据文件/日志文件 → 表文件内的数据页 → 页内的 bitmaps + slots → 槽内的定长记录 → 记录通过 ColMeta.offset 解析出列值；同时 BufferPoolManager 与 LRUReplacer 负责在内存中缓存数据页，所有元数据由 DbMeta/TabMeta/ColMeta 单独管理。**
