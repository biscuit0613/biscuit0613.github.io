---
title: RM_ROS2入门
published: 2025-09-10
description: 'ROS2操作，包括python和C++的节点编写'
image: ''
tags: [ROS2,RM]
category: 'ROS2'
draft: false 
lang: ''
---

:::note
本文主要介绍ros2中的通讯机制，用于结营项目中python与C++的通讯
:::

## 安装

ROS2 Humble的安装参考这篇文章：[UbuntuCondaRos](https://a1kari8.github.io/posts/fedora_install_ros/)

## 基本概念

1. 节点（Node）： 进程里的一个“角色”（比如“发布者”或“订阅者”）。

2. 话题（Topic）： 大喇叭频道，节点可以在上面发消息或收消息。

3. 消息（Message）： 话题里传的内容，有固定的字段结构。

4. 发布与订阅： Python 节点发布；C++ 节点订阅。

就这些，够用了。

## 创建工作空间

```bash
mkdir -p ~/ros2_ws/src
#-p参数表示如果上级目录（这里是ros2_ws）不存在就创建
cd ~/ros2_ws
```

这里采用最简单的结构，所有包都放在`src`目录下。不用命令行构建

得到一个这样的目录结构：

```bash
ros2_ws/
└── src/
    ├── publisher.py
    └── ball_coord_sub/
        ├──  src/
        │      └──subscriber.cpp
        ├── CMakeLists.txt
        └── package.xml
```

## 编写节点

无论是python还是cpp,其核心功能都源自继承。实际上cpp可以类和实现代码分开的但我懒得分了。

```python
import rclpy
from rclpy.node import Node
from geometry_msgs.msg import PointStamped
from rclpy.qos import QoSProfile, QoSReliabilityPolicy

class YoloBallPublisher(Node):
    def __init__(self):
        super().__init__('yolo_ball_publisher')  
        self.declare_parameter('video_path', 'test4/rgb.mp4')
        self.declare_parameter('model_path', 'v1.pt')
        self.declare_parameter('conf_thresh', 0.7)
        video_path = self.get_parameter('video_path').get_parameter_value().string_value
        qos = QoSProfile(depth=100, reliability=QoSReliabilityPolicy.RELIABLE)
        self.pub_center = self.create_publisher(PointStamped, '/ball/center_px', qos)
        fps = self.cap.get(cv2.CAP_PROP_FPS)
        period = 1.0 / fps if fps and fps > 0 else 0.03
        self.timer = self.create_timer(period, self.loop) 
        msg_center = PointStamped()
        msg_center.header.stamp = self.get_clock().now().to_msg()  
        msg_center.header.frame_id = str(obj_id)  
        msg_center.point.x = cx
        msg_center.point.y = cy
        msg_center.point.z = width
        self.pub_center.publish(msg_center)  
        self.get_logger().info('视频放完了')  
        self.get_logger().error(f"打不开视频: {video_path}")  

def main():
    rclpy.init()  
    node = YoloBallPublisher()
    rclpy.spin(node)  
    rclpy.shutdown()  
```

一点一点拆开来讲：

### 1. 节点的初始化与命名

```python
class YoloBallPublisher(Node):
    def __init__(self):
        super().__init__('yolo_ball_publisher')  
```

`super()` 表示调用 **父类**（这里是 `Node`）的方法。

`__init__('publisher_node')` 是在调用 `Node` 的构造函数，并给节点设置名字 `"publisher_node"`。

### 2. 构建发布器publisher

```python
qos = QoSProfile(depth=100,
                  reliability=QoSReliabilityPolicy.RELIABLE)
self.pub_center = self.create_publisher(PointStamped, 
                  '/ball/center_px', qos)
```

在 Python 中，发布器是通过 `create_publisher` 方法创建的：

```python
publisher = self.create_publisher(消息类型, '话题名', 队列大小（或者QoS配置）)
```

其中**消息类型**有很多种，这里用的是 `PointStamped`，表示带时间戳的三维点。

qos是质量服务（Quality of Service）的缩写，用于配置消息传递的可靠性、延迟等属性。这里设置了深度为100和可靠性为RELIABLE，表示消息传递要等到接收方确认收到后再继续。

#### 2.1. 定时器

定时器的创建

```python
fps = self.cap.get(cv2.CAP_PROP_FPS)
period = 1.0 / fps if fps and fps > 0 else 0.03
self.timer = self.create_timer(period, self.loop) 
```

`create_timer` 用于创建一个**定时器**，定时（`period`参数）调用指定的回调函数（`self.loop`代表的参数）。定时器让节点启动后**周期性执行回调函数**（这里是`self.loop`）。节点发送消息的功能都在**回调函数**里实现。

#### 2.2. 回调函数

```python
def loop(self):
    ret, frame = self.cap.read()
    if not ret:
        self.get_logger().info('视频放完了')  
        self.cap.set(cv2.CAP_PROP_POS_FRAMES, 0)  
        return
    # 省略中间的YOLO检测代码
    msg_center = PointStamped()
    msg_center.header.stamp = self.get_clock().now().to_msg()  
    msg_center.header.frame_id = str(obj_id)  
    msg_center.point.x = cx
    msg_center.point.y = cy
    msg_center.point.z = width
    self.pub_center.publish(msg_center)  
```

消息是通过topic传递的内容，其内容是由消息类型决定的。这里的消息类型是`PointStamped`，它有两个主要部分：`header`(包含时间戳`stamp`和坐标系信息`frame_id`)和`point`(表示三维坐标)。

构建好消息内容（`msg_center`）之后，调用发布器(`pub_center`)的 `publish` 方法发送消息。

### 3. 节点启动与定时器的触发

```python
def main():
    rclpy.init()  
    node = YoloBallPublisher()
    rclpy.spin(node)  
    rclpy.shutdown()  
```

`rclpy.init()` 用于初始化 ROS2。

`node = YoloBallPublisher()` 创建节点实例。

`rclpy.spin(node)` 会让节点开始工作，进入循环，等待并处理回调函数（比如定时器触发的`self.loop`）。

`rclpy.shutdown()` 用于关闭 ROS2，释放资源。

### cpp版本的节点

```cpp
#include <rclcpp/rclcpp.hpp>
#include <geometry_msgs/msg/point32.hpp>
#include <geometry_msgs/msg/point_stamped.hpp>
#include <std_msgs/msg/float32.hpp>
#include <fstream>

class BallCoordSub : public rclcpp::Node {
public:
  BallCoordSub() : Node("ball_coord_sub") {//在这里声明节点名称
    rclcpp::QoS qos_profile(100);
    qos_profile.reliability(RMW_QOS_POLICY_RELIABILITY_RELIABLE);
    // 构建订阅器subscriber
    sub_center_ =create_subscription<geometry_msgs::msg::PointStamped>(
      "/ball/center_px", //topic的名称
      qos_profile,//qos配置
      //lambda表达式，回调函数
      [this](const geometry_msgs::msg::PointStamped::SharedPtr msg){
        last_cx_ = msg->point.x;
        last_cy_ = msg->point.y;
        last_w_ = msg->point.z; 
        last_stamp_ = msg->header.stamp;
        have_center_ = true;
        have_width_ = true;//这两个布尔值用来判定是否收到了消息
        printIfReady(msg);//回调函数里调用printIfReady(msg);
      });
    // 构建发布器publisher
    kf_pub_ = this->create_publisher<geometry_msgs::msg::PointStamped>("/ball/kf_pos", 100);
  }

  ~BallCoordSub() {
   
  }

private:
  double last_cx_{0}, last_cy_{0}, last_w_{0};
  bool have_center_{false}, have_width_{false};
  rclcpp::Subscription<geometry_msgs::msg::PointStamped>::SharedPtr sub_center_;// 订阅器,采用shared_ptr智能指针
  rclcpp::Publisher<geometry_msgs::msg::PointStamped>::SharedPtr kf_pub_;// 发布器，采用shared_ptr智能指针
  rclcpp::Time last_stamp_;
  // 这个函数在收到消息后调用
  void printIfReady(const geometry_msgs::msg::PointStamped::SharedPtr& msg) {
    if (have_center_ && have_width_) {
      // 获取id的方法在这里，在publisher.py里面id被放在消息头header里面。
      int ball_id = 0;
      try {
        ball_id = std::stoi(msg->header.frame_id);//注意header里面的是字符串，需要转int
      } catch (...) {//如果获取不到或者说只有一个，id=0
        ball_id = 0;
      }
      // 省略solvePnP方法，发布卡尔曼滤波结果，带时间戳和id
      //打包要发出去的卡尔曼滤波结果
        geometry_msgs::msg::PointStamped kf_msg;
        kf_msg.header.stamp = last_stamp_;
        kf_msg.header.frame_id = std::to_string(ball_id);
        kf_msg.point.x = kf_map_[ball_id].getPosition()[0];
        kf_msg.point.y = kf_map_[ball_id].getPosition()[1];
        kf_msg.point.z = kf_map_[ball_id].getPosition()[2];
        kf_pub_->publish(kf_msg);
      } else {
        RCLCPP_WARN(this->get_logger(), "solvePnP 没成功");
      }
      have_center_ = have_width_ = false;
    }
  }

int main(int argc, char** argv) {
  rclcpp::init(argc, argv);
  auto node = std::make_shared<BallCoordSub>();
  rclcpp::spin(node);
  rclcpp::shutdown();
  return 0;
}

```

## 编译构建

python直接运行，cpp用cmake编译

运行（开两个终端，一个运行发布节点，一个运行订阅节点）：

看到 C++ 终端打印像素中心与宽度，说明通信打通。

```bash
[INFO] [1757568208.860369488] [ball_coord_sub]: Pixel center=(78.3, 561.8), width=49.9
```

## 信息传递流程（以id为例）

1. **publisher.py**：YOLO `track` 获得 `boxes.id`，发布 `msg.header.frame_id = str(obj_id)`。

2. **subscriber.cpp**：`ball_id = std::stoi(msg->header.frame_id)`，用 `kf_map_[ball_id]` 滤波，发布结果。

3. **visualize.py**：`ball_id = int(msg.header.frame_id)`，存储到 `points_dict`。
