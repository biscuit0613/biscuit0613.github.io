---
title: rm竞培营作业
published: 2025-08-30
description: ''
image: ''
tags: [opencv,RM]
category: 'RM'
draft: false 
lang: ''
---

关于opencv模块方面的内容，可以参考[菜鸟教程](https://www.runoob.com/opencv/cpp-opencv-basic-modules.html)

## opencv图像容器：Mat类

opencv中图像的基本数据类型是Mat类，Mat类是一个矩阵类，包含了图像的所有信息，包括图像的宽、高、通道数、数据类型等。是操作图像的基础。

Mat构造函数有很多，这里不一一介绍，常用的有以下几种：

```cpp
cv::Mat(); //默认构造函数，创建一个空矩阵
cv::Mat(int rows, int cols, int type); //创建一个指定大小和类型的矩阵
cv::Mat(int rows, int cols, int type, const cv::Scalar& s); //创建一个指定大小和类型的矩阵，并用指定的值初始化
cv::Mat(const cv::Mat& m); //拷贝构造函数，创建一个与m相同的矩阵
cv::Mat(const cv::Mat& m, const cv::Range& rowRange, const cv::Range& colRange); //创建一个m的子矩阵
```

这里的拷贝构造函数是**浅拷贝**，即两个Mat对象**共享同一块内存空间**，修改其中一个对象会影响另一个对象。如果需要**深拷贝**，可以使用`clone()`函数。

```cpp
cv::Mat img2 = img1.clone(); //深拷贝
```

Mat实例化

```cpp
cv::Mat img1; //空矩阵
cv::Mat img2(480,640,CV_8UC3); //创建一个480*640的3通道8位无符号整型矩阵
cv::Mat img3=imread("test.jpg"); //从文件中读取图像
cv::Mat img4=imread("test.jpg",IMREAD_GRAYSCALE); //读取灰度图像
cv::Mat img5(img4); //拷贝构造函数
cv::Mat img6(img4,cv::Range(0,240),cv::Range(0,320)); //创建img4的子矩阵
```

CV_8UC3是用来表示图像的数据类型的宏，具体含义如下：

- CV：OpenCV的命名空间
- 8U：表示8位无符号整型(U表示unsigned)
- C3：表示3个通道(C表示channel)
  
其格式为：

```plaintext
CV_<位数><数据类型><通道数>
```

其中：

- 位数：表示每个**通道**的**数据位数**，如8、16、32等
- 数据类型：表示数据的**类型**，如U（无符号整型）、S（有符号整型）、F（浮点型）等
- 通道数：表示图像的**通道数**，如1（灰度图）、3（彩色图）等

Mat类的常用成员函数

```cpp
img.rows; //图像的行数
img.cols; //图像的列数
img.channels(); //图像的通道数
img.type(); //图像的数据类型
img.size(); //图像的尺寸
img.empty(); //判断图像是否为空
img.at<Vec3b>(i,j); //访问图像(i,j)像素的像素值，Vec3b表示3通道8位无符号整型
img.ptr<uchar>(i); //访问图像的某一行，返回指向该行的指针
//这个uchar是unsigned char的缩写
```

在使用ptr函数时，需要注意以下几点：

1. ptr函数返回的是指向指定行的指针，指针类型需要与图像的数据类型一致。

2. 访问像素值时，需要根据图像的通道数来计算像素值在指针中的位置。指针指向的行是一个**一维数组**，数组的长度是图像的**列数 $\times$ 通道数**。

    - 例如，对于一张3通道的图像，第j列的第channel通道的像素值在指针中的位置是j*3+channel。

3. 使用ptr函数访问像素值时，需要确保行索引在图像的范围内，否则会导致访问越界。

:::warning
对于每一个像素的像素值，opencv的RGB颜色空间是按BGR顺序存储的，即第一个通道是蓝色，第二个通道是绿色，第三个通道是红色。
:::

在opencv中，图像的像素值是按**行优先存储**的，即先存储第一行的所有像素的像素值，再存储第二行的所有像素值，以此类推。

所以，访问图像的**像素值**时，可以通过行列索引来访问（两次遍历），也可以通过指针来随机访问访问。

```cpp
int channel = 0; 
cv::Mat img = cv::imread("apple.jpg");
img.at<cv::Vec3b>(i,j)[channel]; //访问第i行第j列第channel通道的像素值,0表示蓝色通道，1表示绿色通道，2表示红色通道

uchar* p = img.ptr<uchar>(i); //获取第i行的指针

p[j*3+channel]; //访问第i行第j列第channel通道的像素值

for(int r=0;r<img.rows;r++){
    uchar* row_ptr= img.ptr<uchar>(r); //获取第r行的指针
    for(int c=0;c<img.cols;c++){
        row_ptr[c*3+channel]; //访问第r行第c列第channel通道的像素值
    }
}
```

## opencv数据容器：vec和Scalar类

### Vec类

Vec类是一个模板类，可以表示任意维度的向量，常用于表示图像的像素值。Vec类的每个元素都是一个指定类型的数值，表示一个通道的值。

```cpp
template<typename _Tp, int cn> class Vec;

Vec<变量类型，长度> 变量名;
```

用`[]`访问Vec类的元素，索引从0开始。

```cpp
cv::Vec3b pixel = img.at<cv::Vec3b>(i,j); //访问(i,j)像素的像素值，Vec3b表示3通道8位无符号整型
uchar blue = pixel[0]; //蓝色通道
uchar green = pixel[1]; //绿色通道
uchar red = pixel[2]; //红色通道
```

### Scalar类

Scalar类是一个4维向量类，用于固定长度的数值，常用于表示**颜色、像素值**等。Scalar类的每个元素都是一个double类型的数值，表示一个**通道的值**。

Scalar构造函数：

```cpp
cv::Scalar(double v0, double v1 = 0, double v2 = 0, double v3 = 0);
```

实例化:对于不同的颜色空间，传入的参数意义不同；如果传入的参数不满4个，最后的参数会被自动补0。

BGR颜色空间：v0：蓝色，v1：绿色，v2：红色

```cpp
cv::Scalar blue(255, 0, 0); // 蓝色
cv::Scalar green(0, 255, 0); // 绿色
cv::Scalar red(0, 0, 255); // 红色
```

HSV颜色空间：v0：色调H，v1：饱和度S，v2：亮度V

```cpp
cv::Scalar hsv_red(0, 255, 255); // 红色
```

## opencv基于颜色空间的图像分割

opencv中常用的颜色空间有BGR、HSV、Lab等，不同的颜色空间适用于不同的图像处理任务。基于颜色空间的图像分割是指通过颜色空间的转换和阈值分割来实现图像的分割。

### 颜色空间转换

opencv中常用的颜色空间转换函数是`cvtColor()`，该函数可以实现多种颜色空间之间的转换。常用的转换代码如下：

```cpp
cv::cvtColor(输入图像, 输出图像, 颜色空间转换方式);
```

转换方式包括：`cv::COLOR_BGR2GRAY`、`cv::COLOR_BGR2HSV`、`cv::COLOR_BGR2Lab`等。格式是`cv::COLOR_<源颜色空间>2<目标颜色空间>`

```cpp
cv::Mat img = cv::imread("apple.jpg");
cv::Mat img_hsv;
cv::cvtColor(img, img_hsv, cv::COLOR_BGR2HSV); //BGR转HSV
```

在HSV颜色空间中，H表示色调（红绿蓝），S表示饱和度（深红浅红），V表示亮度（明暗）。HSV颜色空间更符合人类的视觉感知，适合用于颜色分割。

任务要求识别苹果，首先需要确定苹果在HSV颜色空间中的范围。根据经验，红色的HSV范围大致为：

- H: 0-10 或 160-180
- S: 100-255
- V: 100-255

所以，可以设置两个范围来覆盖红色：

```cpp
cv::Scalar lowerRed1(0, 100, 100);
cv::Scalar upperRed1(10, 255, 255);
cv::Scalar lowerRed2(160, 100, 100);
cv::Scalar upperRed2(180, 255, 255);
```

### 阈值分割

核心概念：**掩膜**

掩膜是一个与原图像大小相同的**二值图像**，用于指示哪些区域是感兴趣的。掩膜中的**白色**区域(255)表示**保留**的区域，**黑色**区域(0)表示被**忽略**的区域。

掩膜可以用来：

- 提取目标区域，过滤背景

- 统计像素数量
- 做图像运算（如 bitwise_and, bitwise_or）
- 轮廓检测、形态学处理等

opencv中常用的阈值分割函数是`inRange()`，该函数可以根据指定的范围对图像进行二值化处理。参数列表的最后一个表示输出的掩膜：

```cpp
cv::Mat mask;
void inRange(输入图像, 颜色下界, 颜色上界,mask);
//这个mask就是掩膜
```

```cpp
cv::Mat mask1, mask2;
cv::inRange(img_hsv, lowerRed1, upperRed1, mask1); //生成掩膜1
cv::inRange(img_hsv, lowerRed2, upperRed2, mask2); //生成掩膜2
```

因为红色在HSV空间中有两个范围，所以需要生成两个掩膜，然后将它们合并，常见的方法是使用`bitwise_or()`函数,参数列表中最后一个参数表示输出的合并结果：


```cpp
cv::Mat red_mask;
cv::bitwise_or(mask1, mask2, red_mask); //合并掩膜
```

现在，掩膜`red_mask`中白色区域表示图像中红色的部分，可以用来提取苹果。

## 形态学操作：腐蚀与膨胀

形态学操作是基于图像形状的处理方法，常用于去噪、填充孔洞等。常用的形态学操作有腐蚀（Erosion）和膨胀（Dilation）。形态学操作往往作用于**二值图像**。

### 结构元素：kernel

结构元素是一个`Mat`类的矩阵，用于定义形态学操作的邻域关系。常用的结构元素有矩形、椭圆和十字形。可以使用`getStructuringElement()`函数来创建结构元素。

```cpp
cv::Mat kernel = cv::getStructuringElement(cv::MORPH_RECT，cv::Size(5, 5));
```

其中`cv::MORPH_RECT`表示结构元素的**形状**为矩形，`cv::Size(5, 5)`表示结构元素的**大小**为5x5。还可以使用`cv::MORPH_ELLIPSE`和`cv::MORPH_CROSS`分别表示椭圆和十字形结构元素。

```cpp
cv::Mat kernel = cv::getStructuringElement(cv::MORPH_RECT，cv::Size(5, 5));
```

### 腐蚀和膨胀操作

腐蚀操作会使**白色区域变小**，去除小的噪点，常用的方法是`erode()`函数。

```cpp
cv::erode(输入图像, 输出图像, kernel);
```

膨胀操作会使**白色区域变大**，填充小的孔洞，常用的方法是`dilate()`函数。

```cpp
cv::dilate(输入图像, 输出图像, kernel);
```

这两个结合就出现了开运算和闭运算，用`cv::MORPH_OPEN`和`cv::MORPH_CLOSE`来区分。

**开运算**：**先腐蚀后膨胀**，去除小的噪点，常用的方法是`morphologyEx()`函数。

```cpp
cv::morphologyEx(输入图像, 输出图像, cv::MORPH_OPEN, kernel);
```

**闭运算**：**先膨胀后腐蚀**，填充小的孔洞，常用的方法是`morphologyEx()`函数。

```cpp
cv::morphologyEx(输入图像, 输出图像, cv::MORPH_CLOSE, kernel);
```

在苹果的例子中，经过阈值分割后，掩膜可能会有一些噪点和孔洞，可以使用形态学操作来优化掩膜。

```cpp
// 开运算去除噪声，闭运算填充空洞
cv::Mat kernel = cv::getStructuringElement(cv::MORPH_ELLIPSE, cv::Size(5, 5));
cv::morphologyEx(red_mask, red_mask, cv::MORPH_OPEN, kernel);
cv::morphologyEx(red_mask, red_mask, cv::MORPH_CLOSE, kernel);
```

## 轮廓的提取与筛选

轮廓是图像中连续的边界线，可以用来表示物体的形状。opencv中常用的轮廓提取函数是`findContours()`，该函数可以从二值图像中提取轮廓。

```cpp
cv::findContours(red_mask, contours, hierarchy, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);
```

- `red_mask`：输入的二值图像
- `contours`：输出的**轮廓集合**，是一个`vector<vector<Point>>`类型的变量。
  - `vector<Point>`表示一个轮廓，`Point`表示一个点的坐标，`vector<vector<Point>>`表示多个轮廓的集合
  - `contours.size()`表示**轮廓的数量**，`contours[i]`表示第i个轮廓，`contours[i].size()`表示第i个**轮廓的点数**，`contours[i][j]`表示第i个轮廓的第j个点
- `hierarchy`：输出的轮廓层级关系，是一个`vector<Vec4i>`类型的变量
- `cv::RETR_EXTERNAL`：轮廓检索模式，这里表示只检测外部轮廓
- `cv::CHAIN_APPROX_SIMPLE`：轮廓近似方法，这里表示只保存轮廓的端点。

提取到轮廓后，可以根据轮廓的面积、周长、轮廓点集的长度等属性进行筛选，去除一些不符合要求的轮廓。常用的方法是`contourArea()`和`arcLength()`函数。

在苹果的例子中，可以根据轮廓的面积，轮廓的点数（方便拟合）来筛选轮廓，去除一些过小的噪声轮廓。

```cpp
 // 过滤轮廓：根据面积过滤小噪声
    double min_area = 500;  // 最小面积
    for (size_t i = 0; i < contours.size(); ++i) {
        double area = cv::contourArea(contours[i]);
        if (area > min_area && contours[i].size() > 5) {
            cv::Point2f center;
            float radius;
            cv::minEnclosingCircle(contours[i], center, radius);
            cv::circle(img, center, static_cast<int>(radius), cv::Scalar(0, 255, 0), 2);
            std::string label = "Apple";
            cv::putText(img, label, cv::Point(static_cast<int>(center.x - radius), static_cast<int>(center.y - radius - 10)),
                        cv::FONT_HERSHEY_SIMPLEX, 0.5, cv::Scalar(0, 255, 0), 2);
        }
    }
```

这里面也用到了opencv的拟合函数`minEnclosingCircle()`，该函数可以拟合一个最小外接圆，用于表示苹果的位置和大小。

```cpp
cv::Point2f center;
float radius;
cv::minEnclosingCircle(contours[i], center, radius);
```

- `contours[i]`：输入的轮廓点集
- `center`：输出的圆心坐标，是一个`Point2f`类型的变量
- `radius`：输出的圆的半径，是一个`float`类型的变量