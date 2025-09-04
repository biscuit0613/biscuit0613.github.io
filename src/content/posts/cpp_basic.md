---
title: cpp赛博扫盲日记
published: 2025-09-04
description: '记录从零开始学习C++的点点滴滴'
image: ''
tags: [cpp,c++，]
category: 'c++'
draft: false 
lang: ''
---

## 2025.9.4 &

### &作为取地址运算符

```cpp
int x = 10;
int *p = &x;  // &x 获取变量x的地址
```

### &分别修饰返回值类型和传入参数

&修饰的基本意义是引用

1. 修饰参数时，可以避免对象的复制，提高性能。如果不使用&的话，传递的是参数的副本，而不是原始变量本身。传入的变量对函数内的修改**不会**影响原始变量。

    不使用引用的情况：

    ```cpp
    #include <iostream>

    void modifyValue(int x) {
        x = 20;  // 仅修改函数内部的副本
    }

    int main() {
        int a = 10;
        modifyValue(a);  // 传入 a 的副本
        std::cout << a;   // 输出 10，原始变量 a 没有变化
        return 0;
    }
    ```

    使用引用的情况（以卡尔曼滤波中的为例）

    ```cpp
    virtual void init(const std::vector<boost::any> &param) = 0;
    ```

    其中const表示常量引用，表示参数在函数内部不会被修改

2. 修饰返回类型时，表示函数将返回一个 引用。这意味着函数将返回一个已经存在的对象的引用，而不是对象的副本。

    可以避免不必要的拷贝，同时函数的调用者**可以修改**返回的对象（如果没有const修饰）

    比如在KF.h头文件中定义了纯虚函数：

    ```cpp
     virtual Eigen::MatrixXd& getResult()
    ```

    在KF.cpp中的实现：

    ```cpp
    Eigen::MatrixXd& KF::getResult() { return m_statePost; }
    ```

### virtual虚函数和纯虚函数

1. 虚函数（无=0结尾）
   
    + virtual开头，但没有=0后缀

    + 可以有默认实现，派生类可以选择重写与否，
    + 包含这个的类（如果不包含纯虚函数）可以被实例化


1. 纯虚函数（=0结尾）

    + 纯虚函数是在抽象类中声明的虚函数，它在基类中只有声明没有默认实现，但要求**任何派生类**都要加上override关键字声明，在派生类或者其.cpp文件中进行实现。

    + 包含纯虚函数的类被称为**抽象类**，**不能直接实例化**

    基本语法：

    ```cpp
    virtual 返回类型 function(params)=0,//在函数声明后面加=0
    ```

    在派生类中重写需要override:

    ```cpp
    返回类型 function(params) override{函数实现}//{函数实现}如果不在类里面就要在.cpp里面，反正一定要有。
    ```

    ```cpp
    class Base {//基类
    public:
          virtual void pureVirtualFunction() = 0;  // 纯虚函数
    };
    //派生类
    class Derived : public Base {
    public:
        void pureVirtualFunction() override {  // 必须提供实现
            std::cout << "Derived class implementation" << std::endl;
        }
    };
    ```

    例如KF.h作为基类，他的子类是Mykarmanfilter.h,KF.h中的两个声明：

    ```cpp
    virtual void setParam(const std::vector<boost::any> &param) = 0;   // 设置在迭代过程中会改变的参数
    virtual void stateUpdate();//更新卡尔曼滤波中的状态空间
    ```

    在myKF.h中的声明：

    ```cpp
    virtual void setParam(const std::vector<boost::any> &param) override;
    ```

    在myKF.cpp中的实现：

    ```cpp
    MyKalmanFilter& MyKalmanFilter::setStateByMeasure() {
    static Eigen::Vector3d lastMeasurement;
    static Eigen::Vector3d lastVelocity;
    //省略114514行
    }
    ```


### 关于类和结构体的区别

在 C++ 中，结构体和类几乎完全相同，唯一的区别是结构体默认的成员访问权限是 public（可以直接访问），而类默认的成员访问权限是 private（只能通过类的公共函数接口来访问）。

从语法角度来说，结构体是类的一种特殊形式，可以把它看作是没有封装（默认 public）的类

### 关于类的构造函数参数列表

const关键字修饰的变量必须在参数列表内初始化。例如KF.h中两个常量测量空间维度和状态空间维度：

```cpp
//构造函数，接收两个参数measureDim->m_measureDimension;stateDim->m_stateDimension
    KF(const int measureDim, const int stateDim)
        : m_measureDimension(measureDim), m_stateDimension(stateDim) 
        {//其他初始化
        }
    //其他成员变量

    const int m_measureDimension;  // 测量向量的维度
    const int m_stateDimension;  // 状态向量的维度
```