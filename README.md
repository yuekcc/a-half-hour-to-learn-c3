# 半小时学会 C3

灵感来自 [A half-hour to learn Zig](https://gist.github.com/ityonemo/769532c2017ed9143f3571e5ac104e50)。

C3 是自称是C语言的进化版，如果你在同时使用 Java/JavaScript，我觉得你也会接受 C3。

## 基础

- `c3c compile-run code.c3` 命令用于编译并进行单个源码文件
- `c3c init` 初始化一个项目

声明一个 main 函数就可以执行你的代码：

```c3
fn void main() {}
```

但是上面代码什么事也做不了。

使用 `import` 语句导入模块，比如实现一个经典的 helloworld：

```c3
import std::io;

fn void main()
{
  io::printfn("hello, world");
}
```

将代码保存为 `code.c3`，使用 `c3c compile-run code.c3` 编译运行，一切正常，你可以看到这样的输出：

```sh
$ c3c compile-run code.c3
Using MSVC SDK at: D:/app/c3-windows-Release/../msvc_sdk
Program linked to executable '.\code.exe'.
Launching .\code.exe
hello, world
Program completed with exit code 0.
```

C3 使用 `int i = 0` 语句声明变量。语法和 C 语言一致。io::printfn 函数也和 printf 一致：

```c3
import std::io;

fn void main()
{
  int a = 1;
  int b = 10
  int c = a + b;
  io::printfn("%d + %d = %d", a, b, c); // 输出 1 + 2 = 3
}
```

注意：C3 中的变量是默认零值初始化！

## 测试

C3 内置了测试框架，可以很简单的地使用：

```fn
fn void test_fn() @test
{
    assert(true == true, "true is definitely true");
}
```

执行：`c3c compile-test --test-filter test_fn --test-show-output`。

## 函数

C3 语言的函数声明语法就如何 main 函数一般。有一点需要注意，C3 函数、类型都是默认为 public，就是全部模块可见。函数调用语法和常规的编程语言一致，比如下面的代码：

```c3
import std::io;

fn int add(int a, int b)
{
  return a + b;
}

fn void main()
{
  int a = 1;
  int b;
  int c = add(a, b);
  io::printfn("%d + %d = %d", a, b, c); // 输出 1 + 0 = 1
}
```

有一个点需要说明，C3 的函数支持默认参数：

```c3
fn int power(int base, int exp = 2)
{
  // ..
}
```

## 结构体

C3 提供了结构体的语法用于声明复杂对象，而且 C3 的结构体支持方法：

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

  // 声明变量并同时初始字段的值
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

State current_state = WAITING; // 或者 '= State.WAITING'
```

C3 对 enum 做了几个重要扩展，详情见：[Types](https://c3-lang.org/language-overview/types/#enum) enums 一节

## 数组、切片

```c3
// 声明数组
int[5] a = { 1, 20, 50, 100, 200 };

// 声明切片
int[] b = a[0 .. 4]; // 整个数组
int[] c = a[2 .. 3]; // 原数组的一部分
```

数组是固定长度的有序序列，切片就是数组的一个视图。

## 字符串

C3 内置了字符串类型 `String`，而且 std 模块也提供了很多常用的字符串方法。

`String` 本质是 `typedef String = inline char[]`，在此基础上 C3 还有：

- ZString -> `typedef ZString = inline char*`
- WString -> `typedef WString = inline Char16*`
- DString -> `typedef DString (OutStream) = void*`，DString 是一种 String builder 实现

**NOTE:** std 模块有很多实用的字符串方法，参考 std::core::string 模块。

## 控制流

**if ... else ...**

```c3
fn int to_numer(bool truely)
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

```c3
switch (a)
{
    case 1:       // Empty case implicit fall-through
    case 2:
        doOne();  // Automatic break
    case 3:
        i = 0;
        nextcase; // Explicit fall-through
    case 4:
        doFour(); // Automatic break
    case 5:
        doFive();
        nextcase; // Explicit fall-through
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

**while/do...while**

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
while(b < 10)
```

**foreach/foreach_r**

```c3
int[4] arr = { };
foreach (idx, &item : arr)
{
    *item = 7 + (int)idx; // Mutates the array element
    // index is usz when not specified, requiring an explicit
    // cast on platforms where usz is larger than int.
    // 0.8+, "sz" rather than usz is used.
}

foreach_r (idx, item : arr)
{
    // Prints 2.0, 1.0
      io::printfn("item: %s", item);
}
```

## 错误处理

错误处理主要是依赖“可选结果”（optional results），一可选结果类型可以包含一个值或一个 fault 值。

> C3 的可选结果和函数式语言可选值是不同的概念，C3 std::collections::Maybe 类型才等价类型。

使用 `faultdef` 关键字声明一个 fault 值：

```c3
faultdef DIVISION_BY_ZERO;
```

使用 try 或 catch 进行解包，可以 `!` 再抛出异常，也可以使用 `!!` 强行解包：

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
    // ratio is an optional result.
    double? ratio = divide(foo(), bar());

    // Handle the optional result value if it exists.
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
    // Flow typing makes "ratio"
    // have the plain type 'double' here.
    io::printfn("Ratio was %f", ratio);
}
```

另外也可以使用 `??` 指定默认值：

```c3
faultdef SOME_ERROR;

fn int? test()
{
  return SOME_ERROR~;
}

fn void? example()
{
  int? a = test();
  int b = a ?? 0;
  // ...
}
```

C3 对 optional result 类型做了很多易用性优化，建议参考官方文档：

- [Essential Error Handling](https://c3-lang.org/language-common/optionals-essential/)
- [Advanced Error Handling](https://c3-lang.org/language-common/optionals-advanced/)

## 指针

C3 的指针和 C 几乎一致：

- `Foo*` 是 Foo 的指针类型
- 使用 `&` 运算符取出对象的地址值
- 使用 `*ptr` 取出指针的指向的值

C3 也支持函数指针：

```c3
alias Callback = fn void(int value)
Callback callback = &test;

fn void test(int a) { /* ... */ }
```

> C3 里函数声明的语法也可能是受到函数指针的影响。

## 内存管理

**C3 是一门手工管理内存**的编程语言，但是 C3 提供了几个优化可以大大减轻心智压力：

C3 默认使用栈内存，比如在函数中声明一个数据，默认使用栈内存。如果是创建大对象时，可以使用堆内存。C3 提供了两个堆内存分配器：`mem` 和 `tmem`。

mem 内存分配器可以在堆上创建一块区域用于储存数据。使用 mem 分配的内存需要使用 mem::free 等方式显式释放。

tmem 则是一个临时内存分配器。tmem 会 @pool 作用域结束时自动释放由 tmem 分配的内存。@pool 可以认为是一个内存池，在 @pool 退出作用域时，自动释放 tmem 分配的内存。tmem 会自动向上查找最近的 @pool。借助这个特性，C3 代码可以大大减少手工管理内存的压力。

C3 也提供一个基于作用域的 defer 功能，可以用于简化资源管理。

```c3
import std::io;

fn String replace_aaa_to_bbb(Allocator allocator, String str)
{
  @pool() {
    String result = str.replace(tmem, "a", "b");
    return result.copy(allocator);
  };
}

fn void main()
{
  String str = replace_aaa_to_bbb(mem, "aaa");
  defer mem::free(str);
  io::printfn("result is %s", str); // result is bbb
}
```


## 宏、编译期运行、泛型

C3 支持编译期运行和基于编译期的反应，并且支持泛型。

这部分内容本文不展开，参考官方文档：

- [Compile Time Evaluation](https://c3-lang.org/generic-programming/compiletime/)
- [Generics](https://c3-lang.org/generic-programming/generics/)
- [Macros](https://c3-lang.org/generic-programming/macros/)

## 其他

C3 还有很多有趣的特性，比如：

- bitstruct
- 有限制的重载
- 特质（Attributes）
- 契约（Contracts）
- 向量
