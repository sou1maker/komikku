import 'package:flutter/material.dart';
import 'package:komikku/widgets/image.dart';

/// 漫画搜索子项布局
class ListViewItem extends StatelessWidget {
  const ListViewItem({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  final String imageUrl;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(4),
            child: ExtendedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.fill,
              width: 75,
              height: 120,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 2, 2, 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.black45)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 漫画栅格子项布局
class GridViewItem extends StatelessWidget {
  const GridViewItem({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.titleStyle,
  }) : super(key: key);

  final String imageUrl;
  final String title;
  final String subtitle;
  final TitleStyle titleStyle;

  @override
  Widget build(BuildContext context) {
    final Widget image = Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      clipBehavior: Clip.antiAlias,
      child: ExtendedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
      ),
    );

    switch (titleStyle) {
      case TitleStyle.imageOnly:
        return image;
      case TitleStyle.header:
        return GridTile(
          header: Material(
            color: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(2),
                bottom: Radius.circular(2),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _GridTileBar(
              title: _TitleText(text: title),
              subtitle: _TitleText(text: subtitle),
              backgroundColor: Colors.black38,
            ),
          ),
          child: image,
        );
      case TitleStyle.footer:
        return GridTile(
          footer: Material(
            color: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(2),
                bottom: Radius.circular(2),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _GridTileBar(
              title: _TitleText(text: title),
              subtitle: _TitleText(text: subtitle),
              backgroundColor: Colors.black38,
            ),
          ),
          child: image,
        );
    }
  }
}

/// 标题栏
class _GridTileBar extends StatelessWidget {
  const _GridTileBar({
    Key? key,
    this.backgroundColor,
    this.title,
    this.subtitle,
  }) : super(key: key);

  final Color? backgroundColor;
  final Widget? title;
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) {
    BoxDecoration? decoration;
    if (backgroundColor != null) {
      decoration = BoxDecoration(color: backgroundColor);
    }

    final ThemeData darkTheme = ThemeData.dark();
    return Container(
      padding: const EdgeInsetsDirectional.only(start: 2, end: 2),
      decoration: decoration,
      height: (title != null && subtitle != null) ? 40 : 30,
      child: Theme(
        data: darkTheme,
        child: IconTheme.merge(
          data: const IconThemeData(color: Colors.white),
          child: Row(
            children: <Widget>[
              if (title != null && subtitle != null)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      DefaultTextStyle(
                        style: darkTheme.textTheme.subtitle1!,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        child: title!,
                      ),
                      DefaultTextStyle(
                        style: darkTheme.textTheme.caption!,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        child: subtitle!,
                      ),
                    ],
                  ),
                )
              else if (title != null || subtitle != null)
                Expanded(
                  child: DefaultTextStyle(
                    style: darkTheme.textTheme.subtitle1!,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    child: title ?? subtitle!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 标题
class _TitleText extends StatelessWidget {
  final String text;

  const _TitleText({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 12,
      ),
    );
  }
}

/// 标题样式
enum TitleStyle {
  /// 只有图片
  imageOnly,

  /// 在头部
  header,

  /// 在底部
  footer,
}
