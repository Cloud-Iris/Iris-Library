# Java Stream 流

## 1、什么是流

流是从支持数据处理操作的源生成的元素序列，源可以是数组、文件、集合、函数。流不是集合元素，它不是数据结构并不保存数据，它的主要目的在于计算。

## 2、如何生成流

生成流的方式主要有五种

1、通过集合`List`生成，应用中最常用的一种

```java
List<Integer> integerList = Arrays.asList(1, 2, 3, 4, 5, 6);
Stream<Integer> stream = integerList.stream();
```


2、通过数组生成

```java
int[] intArr = {1, 2, 3, 4, 5, 6};
IntStream stream = Arrays.stream(intArr);
```


通过`Arrays.stream`方法生成流，并且该方法生成的流是数值流【即IntStream】而不是 Stream。补充一点：**使用数值流可以避免计算过程中拆箱装箱，提高性能。**

Stream API提供了mapToInt、mapToDouble、mapToLong三种方式将对象流【即Stream 】转换成对应的数值流，同时提供了boxed方法将数值流转换为对象流。

3、通过值生成

```java
Stream<Integer> stream = Stream.of(1, 2, 3, 4, 5, 6);
```


通过Stream的of方法生成流，通过Stream的empty方法可以生成一个空流。

4、通过文件生成

```java
Stream<String> lines = Files
    .lines(Paths.get("data.txt"), Charset.defaultCharset());
```


通过Files.line方法得到一个流，并且得到的每个流是给定文件中的一行。

5、通过函数生成

**iterator**

```java
Stream<Integer> stream = Stream.iterate(0, n -> n + 2).limit(5);
```


iterate方法接受两个参数，第一个为初始化值，第二个为进行的函数操作，因为iterator生成的流为无限流，通过limit方法对流进行了截断，只生成5个偶数。

**generator**

```java
Stream<Double> stream = Stream.generate(Math::random).limit(5);
```


generate方法接受一个参数，方法参数类型为Supplier ，由它为流提供值。generate生成的流也是无限流，因此通过limit对流进行了截断。



## 3、流的操作类型

流的操作类型主要分为两种

### 3.1、中间操作

一个流可以后面跟随零个或多个中间操作。其目的主要是打开流，做出某种程度的数据映射/过滤，然后返回一个新的流，交给下一个操作使用。这类操作都是惰性化的，仅仅调用到这类方法，并没有真正开始流的遍历，真正的遍历需等到终端操作时才开始。

常见的中间操作有下面即将介绍的 filter、map 等。

### 3.2、终端操作

一个流有且只能有一个终端操作，当这个操作执行后，流就被关闭了，无法再被操作，因此一个流只能被遍历一次，若想在遍历需要通过源数据在生成流。终端操作的执行，才会真正开始流的遍历。如下面即将介绍的 count、collect 等。



## 4、流的使用

### 4.1 中间操作

#### filter 筛选

通过使用filter方法进行条件筛选，filter的方法参数为一个条件（过滤保留函数返回值为 true 的元素）。

```java
List<Integer> integerList = Arrays.asList(1, 2, 3, 4, 5, 6);
Stream<Integer> stream = integerList.stream().filter(i -> i > 3);
```



结果为：4,5,6

#### distinct 去重

通过distinct方法快速去除重复的元素。

```java
List<Integer> integerList = Arrays.asList(1, 1, 2, 3, 4, 5);
Stream<Integer> stream = integerList.stream().distinct();
```


结果为：1,2,3,4,5

#### limit 返回指定流个数

通过limit方法指定返回流的个数，limit的参数值必须 >=0，否则将会抛出异常。

```java
List<Integer> integerList = Arrays.asList(1, 1, 2, 3, 4, 5);
Stream<Integer> stream = integerList.stream().limit(3);
```


结果为： 1,1,2

#### skip 跳过流中的元素

通过skip方法跳过流中的元素。

```java
List<Integer> integerList = Arrays.asList(1, 1, 2, 3, 4, 5);
Stream<Integer> stream = integerList.stream().skip(2);
```


结果为： 2,3,4,5

skip的参数值必须>=0，否则将会抛出异常。

#### map 流映射

所谓流映射就是将接受的元素映射成另外一个元素。

```java
List<String> stringList = Arrays.asList("Java 8", "Lambdas", "In", "Action");

List<Integer> collect = stringList.stream()
        .map(String::length)
        .collect(Collectors.toList());
```


结果为：[6, 7, 2, 6]

通过map方法可以完成映射，该例子完成中 String -> Integer 的映射。

#### flatMap 流转换

将一个流中的每个值都转换为另一个流。

```java
List<String> wordList = Arrays.asList("Java 8", "Lambdas", "In", "Action");

List<String> strList = wordList.stream()
        .map(w -> w.split(" "))
        .flatMap(Arrays::stream)
        .distinct()
        .collect(Collectors.toList());
```


结果为：[Java, 8, Lambdas, In, Action]

map(w -> w.split(" ")) 的返回值为 Stream<String[]>，想获取 Stream，可以通过flatMap方法完成 Stream ->Stream 的转换。

#### allMatch 匹配所有元素

```java
List<Integer> integerList = Arrays.asList(1, 2, 3, 4, 5);

if (integerList.stream().allMatch(i -> i > 3)) {
    System.out.println("所有元素值都大于3");
} else {
    System.out.println("并非所有元素值都大于3");
}
```



#### anyMatch匹配其中一个

```java
List<Integer> integerList = Arrays.asList(1, 2, 3, 4, 5);

if (integerList.stream().anyMatch(i -> i > 3)) {
    System.out.println("存在值大于3的元素");
} else {
    System.out.println("不存在值大于3的元素");
}
```


等同于

```java
for (Integer i : integerList) {
    if (i > 3) {
        System.out.println("存在大于3的值");
        break;
    }
}
```



#### noneMatch全部不匹配

```java
List<Integer> integerList = Arrays.asList(1, 2, 3, 4, 5);

if (integerList.stream().noneMatch(i -> i > 3)) {
    System.out.println("值都小于3的元素");
} else {
    System.out.println("值不都小于3的元素");
}
```



### 4.2 终端操作

#### count 统计流中元素个数

```java
List<Integer> integerList = Arrays.asList(1, 2, 3, 4, 5);
Long result = integerList.stream().count();
```


结果为：5

#### findFirst 查找第一个

```java
List<Integer> integerList = Arrays.asList(1, 2, 3, 4, 5);

Optional<Integer> result = integerList.stream().filter(i -> i > 3).findFirst();

System.out.println(result.orElse(-1));
```


结果为：4

#### findAny 随机查找一个

```java
List<Integer> integerList = Arrays.asList(1, 2, 3, 4, 5);

Optional<Integer> result = integerList.stream().filter(i -> i > 3).findAny();

System.out.println(result.orElse(-1));
```


结果为：4

通过findAny方法查找到其中一个大于三的元素并打印，因为内部进行优化的原因，当找到第一个满足大于三的元素时就结束，该方法结果和findFirst方法结果一样。提供findAny方法是为了更好的利用并行流，findFirst方法在并行上限制更多【本篇文章将不介绍并行流】。

#### reduce 将流中的元素组合

用于求和：

```java
List<Integer> integerList = Arrays.asList(1, 2, 3, 4, 5);

int sum = integerList.stream()
        .reduce(0, Integer::sum);
```


结果为：15

等同于

```java
int sum = 0;
for (int i : integerList) {
    sum += i;
}
```


reduce接受两个参数，一个初始值这里是0，一个 `BinaryOperatoraccumulator`
来将两个元素结合起来产生一个新值，另外reduce方法还有一个没有初始化值的重载方法。返回的值的类型是Optional。

##### reduce用于获取最大最小值

```java
List<String> stringList = Arrays.asList("Java 8", "Lambdas", "In", "Action");

Optional<Integer> min = stringList.stream()
        .map(String::length)
        .reduce(Integer::min);

Optional<Integer> max = stringList.stream()
        .map(String::length)
        .reduce(Integer::max);
```


结果为：Optional[2] 和 Optional[7]

#### min/max 获取最小最大值

方法参数为 Comparator<?superT>comparator

写法1：

```java
List<String> stringList = Arrays.asList("Java 8", "Lambdas", "In", "Action");

Optional<Integer> min = stringList.stream()
        .map(String::length)
        .min(Integer::compareTo);

Optional<Integer> max = stringList.stream()
        .map(String::length)
        .max(Integer::compareTo);
```


结果为：Optional[2] 和 Optional[7]

写法2：

```java
List<String> stringList = Arrays.asList("Java 8", "Lambdas", "In", "Action");

OptionalInt
        min = stringList.stream()
        .mapToInt(String::length)
        .min();

OptionalInt
        max = stringList.stream()
        .mapToInt(String::length)
        .max();
```


方法3：使用reduce获取最大最小值

```java
List<String> stringList = Arrays.asList("Java 8", "Lambdas", "In", "Action");

Optional<Integer> min = stringList.stream()
        .map(String::length)
        .reduce(Integer::min);

Optional<Integer> max = stringList.stream()
        .map(String::length)
        .reduce(Integer::max);
```



#### sum / summingxxx / reduce 求和

求和的实现方式有很多种如下：

方式1：sum（推荐）

```java
List<String> stringList = Arrays.asList("Java 8", "Lambdas", "In", "Action");

int sum = stringList.stream()
        .mapToInt(String::length)
        .sum();
```


方式2：summingInt

如果数据类型为double、long，则通过summingDouble、summingLong方法进行求和。

```java
List<String> stringList = Arrays.asList("Java 8", "Lambdas", "In", "Action");

int sum = stringList.stream()
        .collect(summingInt(String::length));
```


方式3：reduce

```java
List<String> stringList = Arrays.asList("Java 8", "Lambdas", "In", "Action");

int sum = stringList.stream()
        .map(String::length)
        .reduce(0, Integer::sum);
```


在上面求和、求最大值、最小值的时候，对于相同操作有不同的方法可以选择执行。可以选择collect、reduce、min/max/sum方法，推荐使用min、max、sum方法。因为它最简洁易读，同时通过mapToInt将对象流转换为数值流，避免了装箱和拆箱操作

#### averagingxxx 求平均值

方式1：averagingxxx

```java
List<String> stringList = Arrays.asList("Java 8", "Lambdas", "In", "Action");

double average = stringList.stream()
        .collect(averagingInt(String::length));
```



#### summarizingxxx 同时求总和、平均值、最大值、最小值

如果数据类型为double、long，则通过summarizingDouble、summarizingLong方法

```java
List<String> stringList = Arrays.asList("Java 8", "Lambdas", "In", "Action");

IntSummaryStatistics intSummaryStatistics = stringList.stream()
        .collect(summarizingInt(String::length));

double average = intSummaryStatistics.getAverage(); // 获取平均值
int min = intSummaryStatistics.getMin();            // 获取最小值
int max = intSummaryStatistics.getMax();            // 获取最大值
long sum = intSummaryStatistics.getSum();           // 获取总和
```



#### foreach 遍历

```java
List<String> stringList = Arrays.asList("Java 8", "Lambdas", "In", "Action");

stringList.stream().forEach(System.out::println);
```



#### collect 返回集合

```java
List<String> stringList = Arrays.asList("Java 8", "Lambdas", "In", "Action");

List<Integer> intList = stringList.stream()
        .map(String::length)
        .collect(toList());

Set<Integer> intSet = stringList.stream()
        .map(String::length)
        .collect(toSet());
```


等价于

```java
List<Integer> intList = new ArrayList<>();
Set<Integer> intSet = new HashSet<>();
for (String item : stringList) {
    intList.add(item.length());
    intSet.add(item.length());
}
```


通过遍历和返回集合的使用发现流只是把原来的外部迭代放到了内部进行，这也是流的主要特点之一。内部迭代可以减少好多代码量。

#### joining 拼接流中的元素

```java
List<String> stringList = Arrays.asList("Java 8", "Lambdas", "In", "Action");

String result = stringList.stream()
        .map(String::toLowerCase)
        .collect(Collectors.joining("-"));
```


结果为：java 8-lambdas-in-action

#### groupingBy 分组

在collect方法中传入groupingBy进行分组，其中groupingBy的方法参数为分类函数。

```java
List<String> stringList = Arrays.asList("Java 8", "Lambdas", "In", "Action");

Map<Integer, List<String>> collect = stringList.stream().collect(groupingBy(String::length));
```


结果为：{2=[In], 6=[Java 8, Action], 7=[Lambdas]}

还可以通过嵌套使用groupingBy进行多级分类

```java
List<String> stringList = Arrays.asList("Java 12", "Lambdas", "In", "Action");

Map<Integer, Map<Integer, List<String>>> collect = stringList.stream()
        .collect(groupingBy(
                String::length,
                groupingBy(String::hashCode)
        ));
```


结果为：
{2={2373=[In]}, 6={1955883606=[Action]}, 7={1611513196=[Lambdas], -155279169=[Java 12]}}

```java
List<String> stringList = Arrays.asList("Java 12", "Lambdas", "In", "Action");

Map<Integer, Map<String, List<String>>> collect = stringList.stream()
        .collect(groupingBy(
                String::length,
                groupingBy(item -> {
                    if (item.length() <= 2) {
                        return "level1";
                    } else if (item.length() <= 6) {
                        return "level2";
                    } else {
                        return "level3";
                    }
                })
        ));
```


结果为：{2={level1=[In]}, 6={level2=[Action]}, 7={level3=[Java 12, Lambdas]}}

#### partitioningBy 分区

分区是特殊的分组，它分类依据是true和false，所以返回的结果最多可以分为两组。

```java
List<String> stringList = Arrays.asList("Java 12", "Lambdas", "In", "Action");

Map<Boolean, List<String>> collect = stringList.stream().collect(partitioningBy(String::isEmpty));
```


结果为：{false=[Java 12, Lambdas, In, Action], true=[]}

```java
List<Integer> integerList = Arrays.asList(1, 2, 3, 4, 5);

Map<Boolean, List<Integer>> result = integerList.stream().collect(partitioningBy(i -> i < 3));
```


结果为：{false=[3, 4, 5], true=[1, 2]}