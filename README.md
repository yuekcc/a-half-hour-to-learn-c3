# 半小时学会 C3

灵感来自 [A half-hour to learn Zig](https://gist.github.com/ityonemo/769532c2017ed9143f3571e5ac104e50)。

C3 是一门自称“C 语言的进化版”的编程语言。如果你和一样，同时使用 Java 和 JavaScript，相信你也会很快接受 C3。

本文是针对 **c3c 0.8** 编写。

## 基础

- `c3c compile-run code.c3` 命令用于编译并运行单个源码文件。
- `c3c init` 用于初始化一个项目。

> c3c 是 C3 语言目前唯一的编译器实现，安装请参考 [Install C3 Compiler Binary](https://c3-lang.org/getting-started/prebuilt-binaries/)。

声明一个 `main` 函数即可让你的代码运行起来：

```c3
fn void main() {}
```

不过，上面这段代码什么也做不了。

使用 `import` 语句导入模块，来实现一个经典的 Hello World：

```c3
import std::io;

fn void main()
{
  io::printfn("hello, world");
}
```

将代码保存为 `code.c3`，执行 `c3c compile-run code.c3` 编译并运行。如果一切正常，你将看到如下输出：

```sh
$ c3c compile-run code.c3
Using MSVC SDK at: D:/app/c3-windows-Release/../msvc_sdk
Program linked to executable '.\code.exe'.
Launching .\code.exe
hello, world
Program completed with exit code 0.
```

C3 使用 `int i = 0` 语句声明变量，语法和 C 语言一致。`io::printfn` 函数的用法也类似于 `printf`：

```c3
import std::io;

fn void main()
{
  int a = 1;
  int b = 10;
  int c = a + b;
  io::printfn("%d + %d = %d", a, b, c); // 输出：1 + 10 = 11
}
```

> 🔰 **重要**：C3 中的变量默认会被初始化为零值！这意味着即使你不显式赋值，变量也会有一个确定的初始值（例如 `int` 为 `0`，`bool` 为 `false`）。这个特性也适用于结构体的字段以及函数的默认参数，有助于避免未初始化内存带来的问题。

## 测试

C3 内置了测试框架，使用起来非常简单：

```c3
faultdef DIVISION_BY_ZERO;

fn double? divide(int a, int b)
{
    if (b == 0) return DIVISION_BY_ZERO~;
    return (double)(a) / (double)(b);
}

fn void test_fn() @test
{
    test::@check(2 == 2, "divide: %d", divide(6, 3)!!);
}
```

执行命令：`c3c compile-test --test-filter test_fn --test-show-output`。

> 💡 **提示**：在实际项目中，测试函数通常放在独立的测试文件（如 `*_test.c3`）中，而不是与被测代码混在一起。

## 函数

C3 函数的声明语法与 `main` 函数相同。有一点需要留意：C3 中的函数和类型默认是 `public` 的，即对**同一模块内的其他文件**以及**导入该模块的外部模块**均可见。如果希望仅在当前文件内使用，可以在前面加上 `@private` 属性：

```c3
fn int internal_helper() @private
{
    //...
}
```

函数调用语法与其他常见编程语言一致，例如：

```c3
import std::io;

fn int add(int a, int b)
{
    return a + b;
}

fn void main()
{
    int a = 1;
    int b;          // b 自动初始化为 0
    int c = add(a, b);
    io::printfn("%d + %d = %d", a, b, c); // 输出：1 + 0 = 1
}
```

另外，C3 的函数支持默认参数（未传入的实参同样会自动初始化为零值）：

```c3
fn int power(int base, int exp = 2)
{
    // ..
}
```

## 结构体

C3 提供了结构体语法用于声明复合类型，并且结构体还支持定义方法：

```c3
import std::io;

struct MyNumber
{
    int value;
}

fn int MyNumber.add(self, MyNumber b) // 声明 MyNumber.add 方法
{
    return self.value + b.value;
}

fn void main()
{
    MyNumber a;
    a.value = 10;

    // 声明变量并同时初始化字段
    MyNumber b = {
      .value = 20,
    };

    int result = a.add(b);
    io::printfn("a + b is %d", result); // 输出：a + b is 30
}
```

## 枚举

```c3
enum State : int
{
    WAITING,
    RUNNING,
    TERMINATED
}

State current_state = WAITING; // 或者写为 '= State.WAITING'
```

C3 对 `enum` 做了多项重要扩展，详情可参阅：[Types](https://c3-lang.org/language-overview/types/#enum) 中的 enums 一节。

## 数组、切片

```c3
// 声明数组
int[5] a = { 1, 20, 50, 100, 200 };

// 声明切片（注意：C3 的切片范围是包含终点的）
int[] b = a[0 .. 4]; // 包含 a[0] 到 a[4]，共 5 个元素
int[] c = a[2 .. 3]; // 包含 a[2] 和 a[3]，共 2 个元素
```

数组是固定长度的有序序列，切片则是数组的一个视图。与许多其他语言不同，**C3 的切片范围 `[start .. end]` 是包含 `end` 元素的**，这点在使用时需要特别留意。

切片还支持 `arr[<start-index> : <slice-length>]`，`arr[<start-index>..]`，`arr[..<end-index>]` 写法，更多可以参考 [Slice](https://c3-lang.org/language-common/arrays/#slice)。

## 字符串

C3 内置了字符串类型 `String`，同时 `std` 模块也提供了大量常用的字符串处理方法。

`String` 本质上是 `typedef String = inline char[]`。在此基础上，C3 还提供了以下相关类型：

- `ZString` → `typedef ZString = inline char*`
- `WString` → `typedef WString = inline Char16*`
- `DString` → `typedef DString (OutStream) = void*`，`DString` 是一种字符串构造器（String builder）实现。

**提示**：`std` 模块中包含了大量实用的字符串方法，可参考 `std::core::string` 模块。

## 控制流

**if ... else ...**

```c3
fn int to_number(bool truely)
{
  if (truely)
  {
    return 1;
  }
  else
  {
    return 0;
  }
}
```

**switch**

`switch` 语句默认每个非空 `case` 都会自动 `break`，不会再出现 C 语言中常见的“忘记写 `break` 导致意外贯穿”的问题。如果需要显式贯穿，使用 `nextcase` 关键字。而空的 `case` 块则会遵循传统 C 的隐式 fall-through 行为，用于多个 `case` 共享同一段代码。

```c3
switch (a)
{
    case 1:       // 空 case 会隐式 fall-through
    case 2:
        doOne();  // 自动 break
    case 3:
        i = 0;
        nextcase; // 显式 fall-through，贯穿到 case 4
    case 4:
        doFour(); // 自动 break
    case 5:
        doFive();
        nextcase; // 显式 fall-through，贯穿到 default
    default:
        return false;
}
```

**for**

```c3
for (int i = 0; i < 10; i++)
{

}
```

**while / do...while**

```c3
int a = 0;
while (a < 10)
{
  io::printfn("a is %d", a);
  a++;
}

int b = 0;
do
{
  io::printfn("b is %d", b);
  b++;
}
while(b < 10);
```

**foreach / foreach_r**

```c3
int[4] arr = { };
foreach (idx, &item : arr)
{
    *item = 7 + (int)idx; // 通过指针直接修改数组元素
    // 若不显式指定类型，idx 的类型为 usz，在 usz 大于 int 的平台上需要显式转换。
    // 从 0.8 版本起，使用 "sz" 而非 "usz"。
}

foreach_r (idx, item : arr)
{
    // 按逆序打印：2.0, 1.0, ...
    io::printfn("item: %s", item);
}
```

> 💡 **注意**：`foreach` 中如果使用 `&item` 获取元素的引用，通过 `*item` 修改会直接作用于原数组。如果省略 `&`，`item` 则是元素的副本，修改不会影响原数组。

## 错误处理

错误处理主要依赖"可选结果"（optional results）。一个可选结果类型既可以包含一个正常的值，也可以包含一个 fault 值。

> C3 的"可选结果"与函数式语言中的可选值（Option）概念不同，C3 中的 `std::collections::Maybe` 类型才与之等价。

使用 `faultdef` 关键字声明一个 fault 值：

```c3
faultdef DIVISION_BY_ZERO;
```

使用 `try` 或 `catch` 进行解包，也可以使用 `!` 向上抛出异常，或使用 `!!` 强制解包：

```c3
faultdef DIVISION_BY_ZERO;

fn double? divide(int a, int b)
{
    if (b == 0) return DIVISION_BY_ZERO~;
    return (double)a / (double)b;
}

fn void? test_may_fail()
{
    divide(foo(), bar())!;
}

fn void main()
{
    // ratio 是一个可选结果
    double? ratio = divide(foo(), bar());

    // 如果存在错误值，则处理它
    if (catch err = ratio)
    {
        switch (err)
        {
            case DIVISION_BY_ZERO:
                io::printn("Division by zero");
                return;
            default:
                io::printn("Unexpected error!");
                return;
        }
    }
    // 根据流类型推断（flow typing），此处的 ratio
    // 已被确定为普通类型 'double'。
    io::printfn("Ratio was %f", ratio);
}
```

此外，还可以使用 `??` 指定默认值：

```c3
faultdef SOME_ERROR;

fn int? test()
{
  return SOME_ERROR~;
}

fn void? example()
{
  int? a = test();
  int b = a ?? 0;  // 如果 a 包含错误，则 b 取默认值 0
  // ...
}
```

C3 对可选结果类型做了大量易用性优化，建议进一步阅读官方文档：

- [Essential Error Handling](https://c3-lang.org/language-common/optionals-essential/)
- [Advanced Error Handling](https://c3-lang.org/language-common/optionals-advanced/)

## 指针

C3 的指针与 C 语言几乎一致：

- `Foo*` 表示指向 `Foo` 类型的指针。
- 使用 `&` 运算符获取对象的地址。
- 使用 `*ptr` 解引用指针。

C3 支持函数指针：

```c3
alias Callback = fn void(int value);
Callback callback = &test;

fn void test(int a) { /* ... */ }
```

> 事实上，C3 函数声明的语法也多少受到了函数指针语法的影响。

## 内存管理

**C3 是一门需要手动管理内存**的编程语言，但它提供了一些特性，可以大幅减轻心智负担。

C3 默认使用栈内存。在函数中声明的变量通常分配在栈上。如果需要创建较大的对象，可以使用堆内存。C3 提供了两种堆内存分配器：`mem` 和 `tmem`。

- `mem` 分配器在堆上分配内存区域用于存储数据。通过 `mem` 分配的内存需要使用 `mem::free` 等方式显式释放。
- `tmem` 是一个临时内存分配器。在 `@pool` 作用域结束时，由 `tmem` 分配的内存会被自动释放。可以把 `@pool` 理解为一个内存池，`tmem` 会自动向上查找最近的 `@pool`。借助这个特性，可以大大减少手动管理内存的工作量。

C3 还提供了基于作用域的 `defer` 语句，可用于简化资源管理。

```c3
import std::io;

fn String replace_aaa_to_bbb(Allocator allocator, String str)
{
  @pool() {
    String result = str.replace(tmem, "a", "b");
    return result.copy(allocator);
  };
  // @pool 作用域结束，tmem 分配的临时内存在此自动释放
}

fn void main()
{
  String str = replace_aaa_to_bbb(mem, "aaa");
  defer mem::free(str);  // 确保函数返回前释放内存
  io::printfn("result is %s", str); // 输出：result is bbb
}
```

## 宏、编译期求值与泛型

C3 支持编译期求值、基于编译期的反射，也支持泛型。

这部分内容在本文中不展开，请参考官方文档：

- [Compile Time Evaluation](https://c3-lang.org/generic-programming/compiletime/)
- [Generics](https://c3-lang.org/generic-programming/generics/)
- [Macros](https://c3-lang.org/generic-programming/macros/)

## 其他

C3 还有许多有趣的特性，例如：

- bitstruct
- 有限制的重载
- 特质（Attributes）
- 契约（Contracts）
- 向量

更多内容，请参考 C3 语言官网：[https://c3-lang.org/](https://c3-lang.org/)
