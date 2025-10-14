---
title: 概率论第一章习题
published: 2025-09-18
description: '随机事件，样本空间，事件的运算'
image: ''
tags: [概率论]
category: '概率论'
draft: false 
lang: ''
---



>eg1: 事件A，B，C两两独立，且每件事情发生的概率都是x，且三个事件不同时发生，求证 $x\leq\frac{1}{2}$

:::tip
概率不等式一般通过事件的包含关系来解决
:::

由题：
$$
\begin{alignedat}{2}
&\qquad\quad P(AB)&&=P(A)P(B)\\
&\qquad\quad P(AC)&&=P(A)P(C)\\
&\qquad\quad P(CB)&&=P(C)P(B)\\
&\qquad P(ABC)&&=0\\
&P(A\cup B\cup C)&&=P(A)+P(B)+P(C)-P(AB)-P(AC)-P(CB)+P(ABC)\\
&\quad&&=3x-3x^2\\
&\qquad P(A\cup B)&&=P(A)+P(B)-P(AB)\\
&\quad&&=2x-x^2\\
&\because \qquad A\cup B&&\sub A\cup B\cup C\\
&\therefore \quad 3x-3x^2&&\leq 2x-x^2\\
&\quad &&x\leq\frac{1}{2}
\end{alignedat}
$$

>eg2: 有三个地区的报名表和男女比例如下：随机从三个地区里选一个，先后抽两张报名表

||一|二|三
|---|---|---|---
|报名表数量|10|15|25
|女生数量|3|7|5

>求（1）第一次抽到女生报名表的概率  
>
>（2）已知已知后抽到报名表是男生，求先抽到的是女生报名表的概率


(1):设事件 $A_i$ 表示抽到第i个地区，事件 $B_i$ 表示第i次抽到了女生
$$
\begin{align*}
P&=P(B_1)\\
&=\sum_{i=1}^3P(A_iB_1)\\
&=\sum_{i=1}^3P(A_i)P(B_1|A_i)=\frac{29}{90}
\end{align*}
$$
(2):
$$
\begin{align*}
q&=P(B_1|\bar{B_2})\\[10bp]
&=\frac{P(B_1)P(\bar{B_2}|B_1)}{P(\bar{B_2})} 
\end{align*}
$$

>eg3: 某考生要去三个图书馆只为借一本书，每一个图书馆有这本书的概率相同，若有，则借到书的概率也相同。三个图书馆的书是独立的。求该生能借到书的概率

设事件 $A_i$ ：学生能借到书，事件 $B_i$：图书馆i能借到书，事件 $C_i$ 图书馆i是有书的
$$
\begin{align*}
&P(C_1)=P(C_2)=P(C_3)=\frac{1}{2}\\
&P(B_1|C_1)=P(B_2|C_2)=P(B_3|C_3)=\frac{1}{2}\\
&P(B_1)=P(C_1)P(B_1|C_1)=\frac{1}{4}=P(B_2)=P(B_3)\\
&P(A)=1-P(\bar{A})=1-P(\bar{B_1}\bar{B_2}\bar{B_3})
\end{align*}
$$

>eg4：巴拿赫火柴盒
>
>有两盒火柴，每一盒开始均有n个火柴，当一个人需要点火时，他会等可能的从两个火柴盒中选择一个并取走一根火柴。当第一次发现一个盒子空了（指选到那个火柴盒才能发现里面有没有，拿出最后一根时并不知道自己拿的是最后一根）之后，求另一个火柴盒刚好剩下k根火柴的概率？

:::tip
最后一次实验的结果是A盒子空掉，B盒子剩了k根火柴，可以理解为倒数第二次以及之前，A盒子总共被摸了n次，B盒子总共被摸了n-k次，然后最后一次恰好选到A盒子，发现A盒子为空。设摸到A盒子为成功，B盒子为失败，摸到A盒子的次数是X，倒数第二次以及之前 $X\sim B(2n-k,\frac{1}{2})$，最后一次再乘1/2即可
:::

设事件B：当第一次发现A盒子空了之后，B火柴盒刚好剩下k根火柴

事件A：当第一次发现一个盒子空了之后，另一个火柴盒刚好剩下k根火柴

$$
P(A)=2P(B)\\
P(B)=\frac{1}{2}C_{2n-k}^n(\frac{1}{2})^n(\frac{1}{2})^{n-r}
$$

>eg5 ：一个口袋中有m个正品硬币，n个次品硬币，次品硬币的正反面都是国徽，从袋中任取一只，已知将它抛掷r次，每次都得到国徽，问这只硬币是正品的概率

设事件A：取到的硬币是正品，事件B：抛掷r次硬币得到的均是国徽
$$
\begin{alignedat}{2}
&\quad P(A)&&=\frac{m}{m+n}\\
&\quad P(B)&&=P(AB)+P(\bar{A}B)\\
&\quad &&=P(A)P(B|A)+P(\bar{A})P(B|\bar{A})\\
&\quad &&=\frac{m}{m+n}(\frac{1}{2})^r+\frac{n}{m+n}\cdot1\\
&P(A|B)&&=\frac{P(A)P(B|A)}{P(B)}\\[10bp]
&\quad&&=\frac{1}{m+n\cdot2^r} 
\end{alignedat}
$$

>eg6 ：一个教室里面有4名一年级男生，6名一年级女生，6名二年级男生，x名二年级女生。为使随机抽一名学生时性别和年级是相互独立的，教室里的二年级女生应该有多少人？

设事件$A_i$表示抽到i年级的学生，i=1,2,事件$B$表示抽中男生，$\bar{B}$表示抽中女生
$$
P(A_2B)=P(A_2)P(B)\\
\frac{6}{16+x}=\frac{6+x}{16+x}\cdot\frac{10}{16+x}\\
x=9
$$

>eg7：过程性伯努利实验：在伯努利实验中，成功的概率为p，求第n次实验时得到r次成功的概率

等价于n-1次实验中成功了r-1次，并且第n次又成功
$$
p=C_{n-1}^{r-1}p^{r-1}(1-p)^{n-r}\cdot p=C_{n-1}^{r-1}p^r(1-p)^{n-r}
$$

>eg8：泊松分布近似：一台仪器中装有2000个同样的零件，每个零件损坏的概率是0.0005，若任意元件损坏，机器停止工作，求停止工作的概率

设损坏的零件数量是随机变量X，$X\sim B(2000,0.0005)$，事件A是机器停止工作
$$
\begin{alignedat}{2}
  &P(A)&&=1-P(X=0)\\
  &\quad np&&=\lambda=1\\
  &P(A)&&=1-\sum_{k=1}^{2000}\frac{1}{k!e}\approx0.63216  
\end{alignedat}

$$

>eg9：泊松分布的推导过程：设昆虫产k个卵的概率是$p_k=\frac{\lambda^k\cdot e^{-\lambda}}{k!}$，又设一个虫卵能孵化成昆虫的概率是p，若卵的孵化是相互独立的，问昆虫下一代有L条虫的概率

设昆虫的产卵数是随机变量X，$X\sim P(\lambda)$，设卵能孵出来的数量是Y，$Y\sim B(X,p)$
$$
\begin{alignedat}{2}
&P(Y=L|X=k)&&=C_{k}^{L}p^L(1-p)^{k-L}\\
&\qquad\quad P(Y=L)&&=\sum_{k=L}^{\infin}P(Y=L|X=k)P(X=k)\\
&\quad &&=\sum_{k=L}^{\infin}C_k^Lp^L(1-p)^{K-L}\cdot\frac{\lambda^ke^{-\lambda}}{k!}\\
&\quad &&=\sum_{k=L}^{\infin}\frac{k!}{L!(K-L)!}p^L(1-p)^{K-L}\cdot\frac{\lambda^ke^{-\lambda}}{k!}\\
&\quad &&=\frac{p^Le^{-\lambda}}{L!}\sum_{k=L}^{\infin}\frac{(1-p)^{k-L}\lambda^{k-L}\cdot\lambda^L}{(k-L)!}\\
&\qquad\qquad\qquad\quad e^x &&=\sum_{n=0}^{\infin}\frac{n}{x^n}\\
&\qquad\quad P(Y=L)&&=\frac{(\lambda p)^L e^{-\lambda}}{L!}\cdot e^{\lambda(1-p)}\\
&\quad &&=\frac{(p\lambda)^L e^{-p\lambda}}{L!}
\end{alignedat}
$$
