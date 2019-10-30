import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:auto_size_text/auto_size_text.dart';

greyTextView (BuildContext context, String text, double textSize) {
  return RichText(
    text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(
              text: text,
              style: TextStyle(
                  fontSize: textSize,
                  color: Colors.grey[800]
              )
          )
        ]
    ),
  );
}

greyAutoSizedTextView (BuildContext context, String text, double textSize) {
  return AutoSizeText.rich(
      TextSpan(text: text),
      style: TextStyle(fontSize: textSize,
          color: Colors.grey[800]),
      minFontSize: textSize,
      maxLines: 1,
      overflow: TextOverflow.ellipsis
  );
}

greyTextViewForForecast (String text, double textSize) {
  return RichText(
    text: TextSpan(
        children: [
          TextSpan(
              text: text,
              style: TextStyle(
                  fontSize: textSize,
                  color: Colors.grey[800]
              )
          )
        ]
    ),
  );
}

clickableGreyTextView (BuildContext context, String text, double textSize) {
  return RichText(
    text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(
              text: text,
              recognizer: new TapGestureRecognizer() .. onTap = () => print('Tap Here onTap'),
              style: TextStyle(
                  fontSize: textSize,
                  color: Colors.grey[800]
              )
          )
        ]
    ),
  );
}