import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

cachedImageLoader(String icon, double size){
  return CachedNetworkImage(
    imageUrl: "https://openweathermap.org/img/wn/$icon@2x.png",
    width: size, height: size, fit: BoxFit.cover,
    placeholder: (context, url) => Container(width: size, height: size, child: CircularProgressIndicator(),),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}