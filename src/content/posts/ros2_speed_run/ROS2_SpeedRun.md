---
title: ROS2_SpeedRun
published: 2025-09-10
description: 'ROS2快速入门指南'
image: ''
tags: [ROS2]
category: 'ROS2'
draft: false 
lang: ''
---

:::note
本文主要介绍ros2中的通讯机制，用于结营项目中python与C++的通讯
:::

## 安装

ROS2 Humble的安装参考这篇文章：[UbuntuCondaRos](../UbuntuCondaRos)

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

## 编写发布节点

编辑`publisher.py`(init.py文件的名字可以随便改，节点代码主体在这里面)：

```python
import rclpy
from rclpy.node import Node
from geometry_msgs.msg import Point32
from std_msgs.msg import Float32
from ultralytics import YOLO
import cv2
import os

class YoloBallPublisher(Node):
    def __init__(self):
        super().__init__('yolo_ball_publisher')

        # 声明 ROS 参数（可在 launch 或命令行中覆盖）
        self.declare_parameter('video_path', 'rgb.mp4')
        self.declare_parameter('model_path', 'v1.pt')
        self.declare_parameter('ball_class_id', 0)
        self.declare_parameter('conf_thresh', 0.7)

        # 创建 ROS 发布器：中心点和宽度
        self.pub_center = self.create_publisher(Point32, '/ball/center_px', 10)
        #这里面参数的意义：Point32是消息类型，'/ball/center_px'是话题（topic）名称，10是队列大小
        self.pub_width  = self.create_publisher(Float32, '/ball/width_px', 10)

        # 获取参数值
        video_path = self.get_parameter('video_path').get_parameter_value().string_value
        video_path = os.path.abspath(video_path)
        print(f"[DEBUG] Try to open video: {video_path}")
        model_path = self.get_parameter('model_path').get_parameter_value().string_value
        self.ball_cls = self.get_parameter('ball_class_id').get_parameter_value().integer_value
        self.conf = self.get_parameter('conf_thresh').get_parameter_value().double_value

        # 加载 YOLO 模型
        self.model = YOLO(model_path)

        # 打开视频文件
        self.cap = cv2.VideoCapture(video_path, cv2.CAP_FFMPEG)
        if not self.cap.isOpened():
            self.get_logger().error(f"Failed to open video: {video_path}")
            self.destroy_node()
            return

        # 设置定时器周期（根据视频帧率）
        fps = self.cap.get(cv2.CAP_PROP_FPS)
        period = 1.0 / fps if fps and fps > 0 else 0.03
        self.timer = self.create_timer(period, self.loop)

        # 初始化轨迹字典：每个 obj_id 对应一个点序列
        self.trajectories = {}

    def loop(self):
        ok, frame = self.cap.read()
        if not ok:
            self.get_logger().info('Video ended.')
            cv2.destroyAllWindows()
            self.destroy_node()
            return

        # YOLO 跟踪推理
        results = self.model.track(frame, persist=True, conf=self.conf)

        if len(results) and results[0].boxes is not None:
            boxes = results[0].boxes
            xyxy = boxes.xyxy.cpu().numpy()
            clss = boxes.cls.cpu().numpy()

            # 遍历所有检测框
            for i, box in enumerate(xyxy):
                if int(clss[i]) != self.ball_cls:
                    continue

                x1, y1, x2, y2 = map(float, box)
                cx = (x1 + x2) * 0.5
                cy = (y1 + y2) * 0.5
                w  = max(1.0, x2 - x1)

                # 获取目标 ID（如果模型支持 ID 跟踪）
                obj_id = i  # 如果你用的是 YOLOv8 + tracker，可以改为 boxes.id[i]

                # 记录轨迹
                if obj_id not in self.trajectories:
                    self.trajectories[obj_id] = []
                self.trajectories[obj_id].append((cx, cy))

                # 发布当前中心点和宽度
                msg_center = Point32(x=cx, y=cy, z=0.0)
                msg_width  = Float32(data=w)
                self.pub_center.publish(msg_center)
                self.pub_width.publish(msg_width)

                # 可视化检测框和中心点
                cv2.rectangle(frame, (int(x1), int(y1)), (int(x2), int(y2)), (0,255,0), 2)
                cv2.circle(frame, (int(cx), int(cy)), 5, (0,0,255), -1)

                # 可视化轨迹线
                pts = self.trajectories[obj_id]
                for j in range(1, len(pts)):
                    pt1 = (int(pts[j - 1][0]), int(pts[j - 1][1]))
                    pt2 = (int(pts[j][0]), int(pts[j][1]))
                    cv2.line(frame, pt1, pt2, (255, 0, 0), 2)

                break  # 只处理一个目标，保持简单

        # 显示图像窗口
        cv2.imshow("YOLO Tracking", frame)
        cv2.waitKey(1)

def main():
    rclpy.init()
    node = YoloBallPublisher()
    rclpy.spin(node)
    rclpy.shutdown()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
```

这个节点会打开一个视频文件，使用YOLO模型检测篮球，并发布篮球的中心坐标和宽度。
这个节点运行的时候直接打开对应的虚拟环境然后运行python脚本即可：

## 编写订阅节点

编辑`subscriber.cpp`(注意文件位置)：

```cpp
#include <rclcpp/rclcpp.hpp>
#include <geometry_msgs/msg/point32.hpp>
#include <std_msgs/msg/float32.hpp>

class BallCoordSub : public rclcpp::Node {
public:
  BallCoordSub() : Node("ball_coord_sub") {
    sub_center_ = create_subscription<geometry_msgs::msg::Point32>(
      "/ball/center_px", 10,
      [this](const geometry_msgs::msg::Point32::SharedPtr msg){
        last_cx_ = msg->x; last_cy_ = msg->y; have_center_ = true;
        printIfReady();
      });

    sub_width_ = create_subscription<std_msgs::msg::Float32>(
      "/ball/width_px", 10,
      [this](const std_msgs::msg::Float32::SharedPtr msg){
        last_w_ = msg->data; have_width_ = true;
        printIfReady();
      });
  }

private:
  void printIfReady() {
    if (have_center_ && have_width_) {
      RCLCPP_INFO(this->get_logger(), "Pixel center=(%.1f, %.1f), width=%.1f",
                  last_cx_, last_cy_, last_w_);
      have_center_ = have_width_ = false; // 本次打印后清一次（简单节流）
    }
  }

  rclcpp::Subscription<geometry_msgs::msg::Point32>::SharedPtr sub_center_;
  rclcpp::Subscription<std_msgs::msg::Float32>::SharedPtr sub_width_;
  double last_cx_{0}, last_cy_{0}, last_w_{0};
  bool have_center_{false}, have_width_{false};
};

int main(int argc, char** argv) {
  rclcpp::init(argc, argv);
  rclcpp::spin(std::make_shared<BallCoordSub>());
  rclcpp::shutdown();
  return 0;
}
```

这个节点订阅两个话题，打印收到的篮球像素坐标和宽度。
然后修改`yolo_ball_sub/CMakeLists.txt`，

```cmake
cmake_minimum_required(VERSION 3.8)
project(ball_coord_sub)

find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(geometry_msgs REQUIRED)
find_package(std_msgs REQUIRED)

add_executable(subscriber src/subscriber.cpp)
ament_target_dependencies(subscriber rclcpp geometry_msgs std_msgs)
install(TARGETS subscriber DESTINATION lib/${PROJECT_NAME})

ament_package()
```

+ `subscriber` 是运行节点时的命令名

+ `src/subscriber.cpp` 是 C++ 源文件路径，告诉 ROS 2 去哪里找入口。

最后在`yolo_ball_sub/package.xml`中添加依赖：

```xml
<buildtool_depend>ament_cmake</buildtool_depend>
<depend>rclcpp</depend>
<depend>geometry_msgs</depend>
<depend>std_msgs</depend>
```

## 编译构建

python直接运行，cpp用cmake编译

运行（开两个终端，一个运行发布节点，一个运行订阅节点）：

看到 C++ 终端打印像素中心与宽度，说明通信打通。

```bash
[INFO] [1757568208.860369488] [ball_coord_sub]: Pixel center=(78.3, 561.8), width=49.9
```
