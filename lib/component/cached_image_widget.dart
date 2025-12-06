import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class CachedImageWidget extends StatelessWidget {
  final String url;
  final double height;
  final double? width;
  final BoxFit? fit;
  final Color? color;
  final String? placeHolderImage;
  final AlignmentGeometry? alignment;
  final bool usePlaceholderIfUrlEmpty;
  final bool circle;
  final double? radius;
  final Widget? child;

  const CachedImageWidget({
    required this.url,
    required this.height,
    this.width,
    this.fit,
    this.color,
    this.placeHolderImage,
    this.alignment,
    this.radius,
    this.usePlaceholderIfUrlEmpty = true,
    this.circle = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (url.validate().isEmpty) {
      return Container(
        margin: const EdgeInsets.all(8),
        decoration: boxDecorationWithRoundedCorners(
          borderRadius: BorderRadius.circular(
              radius ?? (circle ? (height / 2) : defaultRadius)),
          backgroundColor: color ?? context.primaryColor.withValues(alpha: 0.1),
        ),
        height: height,
        width: width ?? height,
        color: color ?? context.primaryColor.withValues(alpha: 0.1),
        alignment: alignment,
        child: Stack(
          children: [
            PlaceHolderWidget(
              height: height,
              width: width,
              alignment: alignment ?? Alignment.center,
            ),
            child ?? const Offstage(),
          ],
        ),
      );
    } else if (url.validate().startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(
            radius ?? (circle ? (height / 2) : defaultRadius)),
        child: CachedNetworkImage(
          placeholder: (_, __) {
            return Stack(
              children: [
                PlaceHolderWidget(
                  height: height,
                  width: width,
                  alignment: alignment ?? Alignment.center,
                ),
                child ?? const Offstage(),
              ],
            );
          },
          imageUrl: url,
          height: height,
          width: width ?? height,
          fit: fit ?? BoxFit.cover,
          color: color,
          alignment: alignment as Alignment? ?? Alignment.center,
          errorWidget: (_, s, d) {
            return Stack(
              children: [
                PlaceHolderWidget(
                  height: height,
                  width: width,
                  alignment: alignment ?? Alignment.center,
                ),
                child ?? const Offstage(),
              ],
            );
          },
        ),
      );
    } else {
      if (url.validate().startsWith(r"assets/")) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(
              radius ?? (circle ? (height / 2) : defaultRadius)),
          child: Image.asset(
            url,
            height: height,
            width: width ?? height,
            fit: fit ?? BoxFit.cover,
            color: color,
            alignment: alignment ?? Alignment.center,
            errorBuilder: (_, s, d) {
              return Stack(
                children: [
                  PlaceHolderWidget(
                    height: height,
                    width: width,
                    alignment: alignment ?? Alignment.center,
                  ),
                  child ?? const Offstage(),
                ],
              );
            },
          ),
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(
              radius ?? (circle ? (height.validate() / 2) : defaultRadius)),
          child: Image.file(
            File(url),
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            color: color,
            alignment: alignment ?? Alignment.center,
            errorBuilder: (_, s, d) {
              return Stack(
                children: [
                  PlaceHolderWidget(
                    height: height,
                    width: width,
                    alignment: alignment ?? Alignment.center,
                  ),
                  child ?? const Offstage(),
                ],
              );
            },
          ),
        );
      }
    }
  }
}
