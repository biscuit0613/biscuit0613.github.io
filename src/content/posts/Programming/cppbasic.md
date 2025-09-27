---
title: cpp赛博扫盲日记
published: 2025-09-04
description: '记录从零开始学习C++的点点滴滴'
image: ''
tags: [cpp,c++，]
category: 'cpp'
draft: false 
lang: ''
---

## &的用法

### 作为取地址运算符

```cpp
int x = 10;
&x;  // &x 获取变量x的地址
```

### &分别修饰返回值类型和传入参数

&修饰的基本意义是**引用**，表示对变量的别名。他和被引用的变量公用同一块内存地址。引用必须在定义时初始化，且一旦绑定到一个变量，就不能再绑定到其他变量。

```cpp
int a = 10,c=60;
int& b = a;  
// b 是 a 的引用，即 b 和 a 共享同一块内存
// 现在对 b 的任何修改都会影响 a
b = c; // 这是“把 c 的值赋给 a”，而不是“让 b 改绑到 c”
```

修饰传入函数的参数时，可以避免对对象的复制，提高性能。如果不使用&的话，传递的是参数的副本，而不是原始变量本身，这样传入的变量在函数内的修改**不会**影响原始变量。

不使用引用的情况：

```cpp
#include <iostream>

void modifyValue(int x) {
    x = 20;  // 仅修改函数内部的副本
}

int main() {
    int a = 10;
    modifyValue(a);  // 传入 a 的副本，副本在函数结束后被销毁，真正的 a 的值不会改变
    std::cout << a;   // 输出 10，原始变量 a 没有变化
    return 0;
}
```

使用&修饰传入参数的情况（以卡尔曼滤波中的为例）

```cpp
virtual void init(const std::vector<boost::any> &param) = 0;
```

其中const表示常量引用，表示参数在函数内部不会被修改

修饰返回类型时，表示函数将返回一个**引用**。常见的有返回**类的对象的引用**（常见于链式调用）；返回**传入参数的引用**（比如数组元素、容器元素）；返回**类的成员变量引用**。可以避免不必要的拷贝，同时函数的调用者可以**修改返回的对象**（如果没有const修饰）

比如在`KF.h`头文件中定义了纯虚函数：

```cpp
virtual Eigen::MatrixXd& getResult() = 0;
```

在`KF.cpp`中的实现：

```cpp
Eigen::MatrixXd& KF::getResult() { return m_statePost; }
```

这里返回的是成员变量`m_statePost`的引用，调用者可以修改`m_statePost`的值。

## virtual虚函数和纯虚函数

虚函数（无=0结尾）

+ virtual开头，但没有=0后缀

+ 可以有默认实现，派生类可以选择重写与否，
+ 包含这个的类（如果不包含纯虚函数）可以被实例化

纯虚函数（=0结尾）

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

## 类和结构体的区别

在 C++ 中，结构体和类几乎完全相同，唯一的区别是结构体默认的成员访问权限是 public（可以直接访问），而类默认的成员访问权限是 private（只能通过类的公共函数接口来访问）。

从语法角度来说，结构体是类的一种特殊形式，可以把它看作是没有封装（默认 public）的类

## 类的构造函数

构造函数是类的一种特殊成员函数，用于在创建对象时初始化对象的成员变量。构造函数的名称必须与类名相同，并且没有返回类型（包括void）。

构造函数可以有多个重载版本，以支持不同的初始化方式。构造函数可以有参数，也可以没有参数（默认构造函数）。如果没有定义任何构造函数，编译器会自动生成一个默认的无参构造函数。

```cpp
class MyClass {
public:
    MyClass() { // 默认构造函数
        // 初始化代码
    }

    MyClass(int value) { // 带参数的构造函数
        // 使用参数初始化代码
    }
};
```

构造函数可以使用**初始化列表**来初始化成员变量，这种方式通常比在构造函数体内赋值更高效，尤其是对于常量成员变量和引用成员变量。

```cpp
class MyClass {
private:
    int x;
    const int y; // 常量成员变量
    int& z;       // 引用成员变量
public:
    MyClass(int a, int b, int& c) : x(a), y(b), z(c) { // 初始化列表
        // 其他初始化代码
    }
};
```

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

### 构造函数的调用

构造函数无法被显式调用，必须通过创建对象来调用。

构造函数在创建对象时自动调用，可以通过以下方式创建对象：

```cpp
MyClass obj1;          // 调用默认构造函数
MyClass obj2(10);      // 调用带参数的构造函数，()里面就是传给构造函数的参数
MyClass* obj3 = new MyClass(20); // 动态分配对象，调用带参数的构造函数
cv::Scalar blue(255, 0, 0); // 蓝色
```

构造函数在创建匿名对象时也会被调用：

```cpp  
MyClass(); // 创建一个匿名对象，调用默认构造函数
MyClass(30); // 创建一个匿名对象，调用带参数的构造函数
```

这种情况一般用于临时对象的创建，通常在函数调用或表达式中使用。

```cpp
drawCircle(cv::Scalar(0, 0, 255)); // 直接传入构造的对象
```

## lambda表达式

Lambda表达式是一种**匿名函数**，可以在需要函数对象的地方定义和使用。它们通常用于简化代码，特别是在需要传递简单函数作为参数时。
基本语法：

```cpp
[capture](parameters) -> return_type { function_body }
```

+ capture：捕获外部变量的方式，可以是值捕获（=）、引用捕获（&）或混合捕获（[=, &var]）
+ parameters：匿名函数的参数列表
+ return_type：返回类型，可以省略，编译器会自动推断
+ function_body：函数的主体

## 头文件引用

```cpp
#include  "项目内.h"
#include <标准库.h>
```

## template<>，模板

c++中的模板：

模板允许我们编写**通用函数**和**通用类**，使得同一段代码可以用于不同的**数据类型**。也就是说通过模板，可以编写能够操作任意数据类型的函数或类

+ 函数模板：

```cpp
    template <typename T>
    T add(T a, T b) {
    return a + b;
    }
    int main() {
    cout << add(3, 4) << endl;        // 用于 int 类型
    cout << add(3.5, 4.5) << endl;    // 用于 double 类型
    cout << add("Hello ", "World!") << endl; // 用于 const char* 类型（字符串拼接）
    return 0;
    }
```

+ 类模板
  
类模板如果没有指定默认类型，在实例化时：

```cpp
类名<类型名> 实例化的类名()
```

如果指定了默认类型，<>内空着就是使用默认类型实例化

```cpp
    #include <iostream>
    using namespace std;
    // 类模板
    template <typename T=int>//类模板可以设置默认参数
    class Box {
    private:
        T value;
    public:
        Box(T v) : value(v) {}
        T getValue() { return value; }
    };

    int main() {
        Box<int> intBox(10);          // 使用 int 类型
        Box<double> doubleBox(5.5);   // 使用 double 类型

        cout << intBox.getValue() << endl;      // 输出 10
        cout << doubleBox.getValue() << endl;   // 输出 5.5
    return 0;
    }
```

模板并不会立即生成代码，只有在特定的**类型**被提供时，模板才会被**实例化**。

## `->`和`.`的区别

`.`用于访问对象的成员，而`->`用于访问指针所指向对象的成员。

`a->b` 等价于 `(*a).b`

即：先解引用指针 `*a` 得到对象，再用 `.` 访问其成员。

这里用单向链表举例：

```lua
 head           second        nullptr
  ↓               ↓
+-------+      +-------+ 
| data:10| ->  | data:20| 
| next  ------>| next  -------> nullptr
+-------+      +-------+    
```

```cpp
struct Node {
    int data;// 节点数据
    Node* next; // 指向下一个节点的指针
};
```

```cpp
#include <iostream>
using namespace std;

int main() {
    // 创建两个结点
    Node* head = new Node;   // 创建一个指针head 是 Node* 类型
    head->data = 10;         // 用 -> 设置数据，相当于 (*head).data = 10;
    head->next = nullptr;

    Node* second = new Node;
    second->data = 20;
    second->next = nullptr;

    // 链接两个结点
    head->next = second;     // 相当于 head -> second

    // 遍历链表
    Node* p = head;
    while (p != nullptr) {
        cout << p->data << " ";  // 访问结点数据
        p = p->next;             // 移动到下一个结点
    }

    // 释放内存
    delete head;
    delete second;

    return 0;
}
```

或者说

```cpp
Node n{5, nullptr};
Node* p = &n;//&取地址

cout << n.data;   // ✅ 用 . 输出5
cout << p->data;  // ✅ 用 -> 输出5
// cout << p.data; // ❌ 错误，p 是指针不是对象
```

```rust
head -> [10 | next] -> [20 | null]
          ↑
        head->data
```

:::warning

`->`用于指针类型时需要确保指针不是空指针，否则会导致运行时错误（解引用空指针）。

`.`用于对象类型时需要确保对象已经被正确初始化，否则可能会访问未定义的内存。

:::

## cpp中的this指针

在 C++ 的类中，`this` 是一个隐含的指针，指向当前**对象**本身。它在类的非静态成员函数中可用，用于访问对象的成员变量和成员函数。

类型：在普通成员函数里，`this` 的类型是指向当前类的指针。

常量成员函数：在 `const` 成员函数里，`this` 的类型是 `const class*`，是**常量指针**，不能修改成员变量。

静态成员函数没有 `this`：因为静态函数属于类，而不是某个对象。

### this区分变量名和成员变量

```cpp
#include <iostream>
using namespace std;
class Demo {
private:
  int num;
  char ch;
public:
  void setMyValues(int num, char ch){
    this->num = num;
    this->ch = ch;
  }
  void displayMyValues(){
    cout << num << endl;
    cout << ch;
  }
};
int main(){
  Demo obj;
  obj.setMyValues(100, 'A');
  obj.displayMyValues();
  return 0;
}
```

在 `setMyValues()` 函数中，使用 `this` 指针来引用当前对象的成员变量 `num` 和 `ch`，并将传入的值赋给它们，这样可以明确地告诉编译器想要访问当前对象的**成员变量**，而不是函数参数或局部变量。

### this返回当前对象的引用（链式编程）

```cpp
#include <iostream>
using namespace std;
class Demo {
public:
  Demo& setMyValues(int num, char ch) {//返回当前对象的引用
    this->num = num;
    this->ch = ch;
    return *this;
  }
  void displayMyValues() {
    this->num = num++;//这里体现链式调用，对对象的数据成员所做的更改将保留以进一步链式调用。
    cout << num << endl;
    cout << ch;
  }
private:
  int num;
  char ch;
};
int main() {
  Demo obj;
  obj.setMyValues(100, 'A').displayMyValues(); // 链式调用
  return 0;
}
```

输出：

```cpp
101 //先setMyValues(100,'A')，然后displayMyValues()，num++，所以是101
A
```

`setMyValues()`返回类型为 `Demo&`，这是一个引用类型， 函数返回 `*this`，即当前对象的**引用**（这里是 `obj`的引用），这样就可以在同一行代码中连续调用多个成员函数，实现链式编程。

如果前面的函数返回的是 `Demo`，那么就无法进行链式调用，因为返回的是对象的副本，而不是对原始对象的引用。链式调用后副本改变，原始对象不变。
