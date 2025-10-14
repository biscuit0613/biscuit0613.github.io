---
title: cpp赛博扫盲日记
published: 2025-09-04
description: '记录从零开始学习C++的点点滴滴'
image: ''
tags: [cpp,c++]
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

## 类和结构体的区别

在 C++ 中，结构体和类几乎完全相同，唯一的区别是结构体默认的成员访问权限是 public（可以直接访问），而类默认的成员访问权限是 private（只能通过类的公共函数接口来访问）。

从语法角度来说，结构体是类的一种特殊形式，可以把它看作是没有封装（默认 public）的类

## 类的成员变量

类的成员变量是类中定义的变量，用于存储对象的状态信息。成员变量可以有不同的访问权限（public、private、protected），决定了它们在类外部的可见性。

```cpp
class MyClass {
public:
    int publicVar; // 公共成员变量，可以在类外部访问
private:
    int privateVar; // 私有成员变量，不能在类外部直接访问
protected:
    int protectedVar; // 受保护成员变量，不能在类外部直接访问，但可以在派生类中访问
};
```

成员变量可以是任何数据类型，包括基本类型（如 int、float）、其他类的对象以及指针和引用。

在类被实例化后，每个对象都有自己独立的成员变量副本（对于非静态成员变量），修改一个对象的成员变量不会影响其他对象的成员变量。

### 静态成员变量

静态成员变量是类专属的变量，而不是每个对象都有自己的副本。换句话说，类的所有对象访问的都是同一个静态变量

静态成员变量在类定义中使用 `static` 关键字声明，并且必须在**类外部**（.cpp或.h里）进行定义和初始化。

`inline`关键字修饰的静态成员变量可以直接在类内初始化（C++17及以上版本支持）

```cpp
class MyClass {
public:
    static int staticVar; // 静态成员变量声明
    inline static int inlineStaticVar = 42; // C++17及以上版本支持类内初始化
};

int MyClass::staticVar = 0; // 静态成员变量定义和初始化
```

## 类的成员函数

类的成员函数是定义在类内部的函数，用于操作类的成员变量和实现类的行为。

在.h头文件中声明成员函数，在.cpp文件中实现成员函数。实现的时候，成员函数可以访问类的所有成员变量（包括私有成员变量）

在cpp文件中实现成员函数时，需要使用**作用域解析运算符** `::` 来指定该函数属于哪个类。

```cpp
MyClass::memberFunction() {
    // 函数实现
}
```

在类实例化后，可以通过对象调用成员函数,这时候成员函数就操作该对象的成员变量。

### virtual虚函数和纯虚函数

虚函数（无=0结尾）

```cpp
virtual 返回类型 function(params);
```

+ virtual开头，但没有=0后缀

+ 可以有默认实现，派生类可以选择重写与否，
+ 包含这个的类（如果不包含纯虚函数）可以被实例化

纯虚函数（=0结尾）

```cpp
virtual 返回类型 function(params) = 0;
```

+ 纯虚函数是在抽象类中声明的虚函数，它在基类中只有声明没有默认实现，但要求**任何派生类**都要加上override关键字声明，在派生类或者其.cpp文件中进行实现。

+ 包含纯虚函数的类被称为**抽象类**，**不能直接实例化**
+ virtual开头，但没有=0后缀
+ 可以有默认实现，派生类可以选择重写与否，需要`override`关键字声明
+ 包含这个的类（如果不包含纯虚函数）可以被实例化

### 子类或cpp文件中实现虚函数

```cpp
返回类型 function(params) override{函数实现}
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

### 类的构造函数

构造函数是类的一种特殊成员函数，用于在创建对象时初始化对象的成员变量。构造函数的名称必须与类名相同，并且没有返回类型（包括void）。

构造函数可以有多个重载版本，以支持不同的初始化方式。构造函数可以有参数，也可以没有参数（默认构造函数）。

如果没有定义任何构造函数，编译器会自动生成一个默认的无参构造函数。

构造函数可以使用**初始化列表**来初始化**成员变量**，具体是在构造函数的参数列表后面使用冒号 `:`，然后`成员变量（值）`的形式列出成员变量的初始化,逗号分割，可以只列部分）

:::warning
C++ 初始化类成员时，是按照类声明的顺序初始化的，而不是按照初始化列表的顺序。
:::

```cpp
class MyClass {
private:
    int x;
    const int y; // 常量成员变量
    int& z;       // 引用成员变量
public:
    MyClass(int a, int b, int& c) : x(a), y(b), z(c) // 初始化列表
    { 
        // 其他初始化代码
    }
};
```

`const`关键字修饰的变量必须在参数列表内初始化。例如KF.h中两个常量测量空间维度和状态空间维度：

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

```cpp
MyClass obj1;          // 调用默认构造函数
MyClass obj2(10);      // 调用带参数的构造函数，()里面就是传给构造函数的参数
MyClass* obj3 = new MyClass(20); // 动态分配对象，调用带参数的构造函数
Detctor::detect():m_globalRoi{0, 0, image.Width,image.Height} {}// 传入参数列表
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

## cpp函数指针

函数指针是指向函数的指针变量，可以用来存储函数的地址，从而实现函数的动态调用。函数指针的定义和使用方法如下：

```cpp
返回类型 (*函数指针名)(参数类型列表)
```

```cpp
// 定义一个函数指针类型，指向返回类型为int，参数为两个int的函数
typedef int (*FuncPtr)(int, int);
// 定义一个函数，符合上述函数指针类型
int add(int a, int b) {
    return a + b;
}
int main() {
    // 声明一个函数指针变量，并将其指向add函数
    FuncPtr ptr = add;
    // 通过函数指针调用函数
    int result = ptr(3, 4); // 相当于调用add(3, 4)
    std::cout << "Result: " << result << std::endl;
    return 0;
}
```

## cpp智能指针

智能指针是 C++11 引入的一种用于自动管理动态分配内存的工具。它们通过 RAII（资源获取即初始化）原则，在智能指针对象的生命周期结束时自动释放所管理的内存，避免内存泄漏和悬挂指针等问题。

C++ 标准库提供了三种主要的智能指针：

+ `std::unique_ptr`：表示独占所有权的智能指针。一个 `unique_ptr` 只能有一个所有者，**不能被复制，但可以被移动**。适用于需要明确单一所有权的场景。

    ```cpp
    std::unique_ptr<int> ptr1(new int(10)); // 创建 unique_ptr
    ```

    ```cpp
    std::unique_ptr<int> ptr2 = ptr1; // 错误，不能复制
    std::unique_ptr<int> ptr2 = std::move(ptr1); // 正确，ptr1 的所有权被转移到 ptr2
    ```

+ `std::shared_ptr`：表示共享所有权的智能指针。多个 `shared_ptr` 可以指向同一个对象，通过**引用计数**来管理对象的生命周期。当最后一个 `shared_ptr` 被销毁时，所管理的对象也会被释放。适用于需要多个所有者的场景。

    ```cpp
    std::shared_ptr<int> ptr1(new int(20)); // 创建 shared_ptr
    std::shared_ptr<int> ptr2 = ptr1; // 共享所有权，引用计数增加
    std::cout << ptr1.use_count(); // 输出 2，表示有两个 shared_ptr 指向同一个对象
    ```

    ```cpp
    std::shared_ptr<Person> personPtr = std::make_shared<Person>("Alice", 30); // 使用 make_shared 创建类对象，用personPtr指向
    std::cout << personPtr->name << ", " << personPtr->age << std::endl; // 访问类成员
    ```

+ `std::weak_ptr`：与 `shared_ptr` 配合使用的智能指针。它并不拥有所指向的对象，而是对 `shared_ptr` 的一种弱引用，用于解决循环引用问题。

    ```cpp
    std::shared_ptr<int> ptr1(new int(30));
    std::weak_ptr<int> weakPtr = ptr1; // 创建 weak_ptr，不增加引用计数
    if (auto sharedPtr = weakPtr.lock()) { // 尝试获取 shared_ptr
        std::cout << *sharedPtr; // 输出 30
    }
    ```

三种指针的创建语法都差不多：

```cpp
auto ptr = std::make_unique<Type>(args); // 创建 unique_ptr
auto ptr = std::make_shared<Type>(args); // 创建 shared_ptr

std::weak_ptr<Type> ptr = sharedPtr; // 创建 weak_ptr
```

当 `<type>` 是类类型时，可以直接传入**构造函数**的参数，创建一个由智能指针管理的对象，可以用`->`访问其成员。

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
