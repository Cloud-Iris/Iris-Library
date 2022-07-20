import 'package:flutter/material.dart';
import 'package:flutter_wechat_read/base_card.dart';

class CardFree extends BaseCard{
  @override
  State<BaseCard> createState() => _CardFree();
}


class _CardFree extends BaseCardState{

  List BOOK_LIST = [
    {'title': '暴力沟通', 'cover': '51VykQqGq9L._SY346_.jpg', 'price': '19.6'},
    {'title': '论中国', 'cover': '41APiBzC41L.jpg', 'price': '36.6'},
    {'title': '饥饿得盛世: 乾隆时代得得与失', 'cover': '51M6M87AXOL.jpg', 'price': '19.6'},
    {'title': '焚天之怒第4卷至大结局', 'cover': '51oIE7H5gnL.jpg', 'price': '56.9'},
    {'title': '我就是风口', 'cover': '51vzcX1U1FL.jpg', 'price': '88.8'},
    {'title': '大宋的智慧', 'cover': '517DW6EbhGL.jpg', 'price': '22.8'},
  ];

  @override
  Widget topTitle(String title) {
    return super.topTitle("免费听书馆");
  }
  @override
  Widget subTitle(String title) {
    return super.subTitle("第 108 期");
  }

  @override
  bottomContent() {
    return Expanded(child: Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Expanded(child: _bookList()),
          Padding(padding: EdgeInsets.only(bottom: 20),
            child: _bottomButton(),
          ),
        ],
      ),
    ),);
  }
  Widget _bookList() {
      return GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 10,  // 垂直间距
        crossAxisSpacing: 15, // 水平间距
        childAspectRatio: 0.46,
        padding: EdgeInsets.only(left: 20, right: 20),
        children: BOOK_LIST.map((value){
          return _bookListItem(value);
        }).toList(),
      );
   }
   /// 这里的类型方法是必须的，因为上面的child是 List<Widget>
  Widget _bookListItem (Map<String, String> item) {
      return Container(
        child: Column( children: [
            /// 绝对布局
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Image.network(
                  "http://www.devio.org/io/flutter_beauty/book_cover/${item['cover']}",
                  fit: BoxFit.cover,
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.black38,
                  ),
                  child: Icon(Icons.play_arrow, color: Colors.white,),
                ),
                Positioned(
                  /// 这三个属性既是定位，其实也是被 Positioned 包裹的 容器
                  /// 到外层的距离，也就是可以看作是容器的大小
                  /// 这样，被 Positioned 包裹的 容器就是紧贴着左、右、下的底部容器了
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(color: Colors.black54),
                    child: Text(
                      '原价${item['price']}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 10),
              child: Text(
                item['title']!, /// 非空检查
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      );
    }

  Widget _bottomButton() {
    /// VERY IMPORTANT 使得按钮填满父布局
      return FractionallySizedBox(
        widthFactor: 1,
        child: Padding(padding: EdgeInsets.only(left: 20, right: 20),
          child: ElevatedButton(
            onPressed: (){},
            style: ButtonStyle(
              padding: MaterialStateProperty.all(
                /// VERY IMPORTANT 就这个情景而言，其实可以通过按钮内边距撑开按钮宽度
                EdgeInsets.only(top: 13, bottom: 15),
              ),
              // 按钮颜色
              backgroundColor: MaterialStateProperty.all(Colors.blue),
              // 按钮颜色
              foregroundColor: MaterialStateProperty.all(Colors.white),
              // 圆角
              shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),)
              ),
            ),
            child: Text('免费领取',),
          ),
        ),
      );
  }
}

