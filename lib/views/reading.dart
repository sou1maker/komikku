import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:komikku/dex/apis/at_home_api.dart';
import 'package:komikku/dex/retrieving.dart';
import 'package:komikku/dto/chapter_dto.dart';
import 'package:komikku/utils/extensions.dart';
import 'package:komikku/utils/timeago.dart';
import 'package:komikku/utils/toast.dart';
import 'package:komikku/widgets/builder_checker.dart';

/// 阅读页
class Reading extends StatefulWidget {
  const Reading({
    Key? key,
    required this.id,
    required this.index,
    required this.arrays,
  }) : super(key: key);

  /// 当前的章节id
  /// 因为每个章节可能存在多个扫描组的内容，所以必须明确章节id
  final String id;

  /// 当前所处在[arrays]中的位置
  final int index;

  /// 二维数组
  /// 章节与章节内多个扫描组的内容
  /// 当章节内只有一个扫描组内容时，List.length = 1
  final Iterable<Iterable<ChapterDto>> arrays;

  @override
  State<Reading> createState() => _ReadingState();
}

class _ReadingState extends State<Reading> {
  final _scrollController = ScrollController();
  var _currentId = '';
  var _currentIndex = 0;

  @override
  void initState() {
    _currentId = widget.id;
    _currentIndex = widget.index;
    _scrollController.addListener(listener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: FutureBuilder<List<String>>(
        future: _getChapterPages(),
        builder: (context, snapshot) {
          return BuilderChecker(
            snapshot: snapshot,
            builder: (context) => ListView.builder(
              controller: _scrollController,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: snapshot.data![index],
                  fit: BoxFit.fitWidth,
                  fadeOutDuration: const Duration(milliseconds: 1),
                  progressIndicatorBuilder: (context, url, progress) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: progress.progress,
                        ),
                      ),
                    );
                  },
                  errorWidget: (context, url, progress) =>
                      Image.asset('assets/images/image-failed.png'),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// 获取章节图片
  Future<List<String>> _getChapterPages() async {
    var atHome = await AtHomeApi.getHomeServerUrlAsync(_currentId);
    return Retrieving.getChapterPages(atHome.baseUrl, atHome.chapter.hash, atHome.chapter.data);
  }

  /// 滚动监听
  Future<void> listener() async {
    if (_scrollController.onBottom) {
      if (_currentIndex == widget.arrays.length - 1) {
        showText(text: '您已经读到最新一章');
        return;
      }
      await _pageTurn(true);
    }

    if (_scrollController.onTop) {
      if (_currentIndex == 0) {
        showText(text: '往后看吧，前面没有了');
        return;
      }
      await _pageTurn(false);
    }
  }

  /// 翻页
  Future<void> _pageTurn(bool next) async {
    // 是否是下一章
    next ? _currentIndex++ : _currentIndex--;
    var values = widget.arrays.elementAt(_currentIndex).toList();

    // 只有一条内容时，不弹窗显示，而是自己显示上一章/下一章
    if (values.length == 1) {
      setState(() => _currentId = values[0].id);
      showText(text: '第 ${values[0].chapter ?? _currentIndex} 章，共 ${values[0].pages} 页');
      return;
    }

    await showBottomModal(
      context: context,
      title: '第 ${values[0].chapter ?? _currentIndex} 章',
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: values.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              borderRadius: BorderRadius.circular(4),
              color: Colors.black12,
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                dense: true,
                title: Text(
                  '${values[index].title ?? index}',
                  style: const TextStyle(overflow: TextOverflow.ellipsis),
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _ExpandedText(timeAgo(values[index].readableAt)),
                    const Padding(padding: EdgeInsets.only(left: 5)),
                    _ExpandedText(values[index].scanlationGroup ?? ''),
                    const Padding(padding: EdgeInsets.only(left: 5)),
                    _ExpandedText(values[index].uploader ?? ''),
                    const Padding(padding: EdgeInsets.only(left: 5)),
                    _ExpandedText(
                      '共 ${values[index].pages} 页',
                      alignment: Alignment.centerRight,
                    ),
                  ],
                ),
                onTap: () {
                  // 点击事件时，再次将页数更改（相当于更改了2次，但后续在关闭时会恢复一次）
                  next ? _currentIndex++ : _currentIndex--;
                  Navigator.pop(context);
                  setState(() => _currentId = values[index].id);
                },
              ),
            ),
          );
        },
      ),
      // 关闭时恢复一次（此时如果没有onTap操作，则状态未变）
    ).then((value) => next ? _currentIndex-- : _currentIndex++);
  }
}

/// 自适应文字
class _ExpandedText extends StatelessWidget {
  const _ExpandedText(this.text, {Key? key, this.alignment}) : super(key: key);

  final String text;
  final Alignment? alignment;

  @override
  Widget build(BuildContext context) {
    if (alignment != null) {
      return Expanded(
        child: Container(
          alignment: alignment,
          child: Text(text, style: const TextStyle(overflow: TextOverflow.ellipsis)),
        ),
      );
    }

    return Expanded(
      child: Text(text, style: const TextStyle(overflow: TextOverflow.ellipsis)),
    );
  }
}
