---
title: yolo训练
published: 2025-09-26
description: 'yolo训练相关内容'
image: ''
tags: [yolo,RM]
category: 'RM'
draft: false 
lang: ''
---

## yolo训练启动的参数

```python
from ultralytics import YOLO

if __name__ == "__main__":
# 1. 加载模型（可选用yolov8n.pt、yolov8s.pt等预训练权重）
    model = YOLO('yolo11s.pt')  # 你也可以用'yolov8n.pt'等

    # 2. 开始训练
    model.train(
        data='data.yaml',  # 数据集配置文件
        epochs=200,           # 训练轮数
        imgsz=640,            # 输入图片分辨率
        batch=32,             # 批次大小
        device=0,             # 用GPU 0训练，若无GPU可设为'cpu'
        workers=4,            # 数据加载线程数
        project='runs/train', # 训练结果保存目录
        name='exp',           # 实验名
        exist_ok=True,         # 若目录已存在则覆盖
        augment=True,         # 开启数据增强
                      # 自定义超参数
        flipud= 0,    # 上下翻转的概率
        fliplr= 0.5,    # 左右翻转的概率
        scale= 0.5,     # 随机缩放范围（缩放比例）
        shear= 10.0,    # 随机错切（倾斜）角度
        perspective= 0.0,  # 随机透视变换（0为关闭）
        hsv_h= 0.015,   # 色调增强范围（颜色变化）
        hsv_s= 0.7,     # 饱和度增强范围（颜色变化）
        hsv_v= 0.4,     # 亮度增强范围（颜色变化）
        degrees= 5.0,   # 随机旋转角度范围（度数）
        translate= 0.1, # 随机平移范围（比例）

   
)
```

前面的都是常用的参数，影响训练效果的，后面的是数据增强相关的参数，可以根据需要调整。

参考官方文档：[yolo train](https://docs.ultralytics.com/zh/modes/train/#train-settings)
