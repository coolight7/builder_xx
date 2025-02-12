// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:builder_xx/store/MyGlobalStoreBase.dart';
import 'MyScreenUtil.dart';
import 'MyText.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MyMarkdown extends StatelessWidget {
  final String data;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const MyMarkdown({
    super.key,
    required this.data,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
  });

  const MyMarkdown.inContentNoScroll({
    super.key,
    required this.data,
  })  : padding = EdgeInsets.zero,
        physics = const NeverScrollableScrollPhysics(),
        shrinkWrap = true;

  @override
  Widget build(BuildContext context) {
    final theme = MyGlobalStoreBase.theme_s.mytheme;
    return Markdown(
      data: data,
      padding: padding ??
          const MyEdgeInsets.only(
            top: 70,
            bottom: 70,
            left: 50,
            right: 50,
          ),
      physics:
          (true == shrinkWrap) ? const NeverScrollableScrollPhysics() : physics,
      shrinkWrap: shrinkWrap,
      onTapLink: (text, href, title) {
        // 点击链接
        if (null != href) {
          launchUrlString(
            href,
            mode: LaunchMode.externalNonBrowserApplication,
          );
        }
      },
      styleSheetTheme: MarkdownStyleSheetBaseTheme.cupertino,
      styleSheet: MarkdownStyleSheet(
        h1: const MyTextMainStyle(rFontSize: 60),
        h2: const MyTextMainStyle(rFontSize: 56),
        h3: const MyTextMainStyle(rFontSize: 42),
        h4: const MyTextMainStyle(rFontSize: 48),
        h5: const MyTextMainStyle(rFontSize: 44),
        h6: const MyTextMainStyle(rFontSize: 40),
        p: const MyTextCrossStyle(),
        listBullet: const MyTextCrossStyle(),
        code: TextStyle(
          color: theme.primaryColor,
          fontSize: 42.sp,
          backgroundColor: theme.textCrossColor.withOpacity(0.2),
          fontFamily: MyGlobalStoreBase.theme_s.defFontFamily,
          fontWeight: MyTextCross.defFontWeight,
        ),
        a: MyTextCrossStyle(
          color: theme.primaryColor,
        ),
        blockquoteDecoration: BoxDecoration(
          borderRadius: const MyBorderRadius(MyRadius(30)),
          color: theme.backgroundColorCross,
        ),
        codeblockDecoration: BoxDecoration(
          borderRadius: const MyBorderRadius(MyRadius(30)),
          color: theme.backgroundColorCross,
        ),
      ),
    );
  }
}
