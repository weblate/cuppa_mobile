/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea_button.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa tea timer button

import 'package:cuppa_mobile/common/colors.dart';
import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/text_styles.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Widget defining a tea brew start button
class TeaButton extends StatelessWidget {
  const TeaButton({
    super.key,
    required this.tea,
    required this.fade,
    this.onPressed,
  });

  final Tea tea;
  final bool fade;
  final ValueChanged<bool>? onPressed;

  void _handleTap() {
    if (onPressed != null) {
      onPressed!(!tea.isActive);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: noPadding,
      elevation: tea.isActive ? 0.0 : 1.0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          color: tea.isActive ? tea.getColor() : null,
        ),
        child: IgnorePointer(
          ignoring: onPressed == null,
          child: InkWell(
            onTap: _handleTap,
            child: AnimatedOpacity(
              opacity: fade ? fadeOpacity : noOpacity,
              duration: longAnimationDuration,
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 106.0,
                  minWidth: 88.0,
                ),
                margin: largeDefaultPadding,
                // Timer icon with tea name
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tea.teaIcon,
                      color: tea.isActive ? activeColor : tea.getColor(),
                      size: 64.0,
                    ),
                    Text(
                      tea.buttonName,
                      style: textStyleButton.copyWith(
                        color: tea.isActive ? activeColor : tea.getColor(),
                      ),
                    ),
                    // Optional extra info: brew time and temp display
                    Selector<AppProvider, bool>(
                      selector: (_, provider) => provider.showExtra,
                      builder: (context, showExtra, child) => Visibility(
                        visible: showExtra,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Brew time
                            Container(
                              padding: rowPadding,
                              child: Text(
                                formatTimer(tea.brewTime),
                                style: textStyleButtonSecondary.copyWith(
                                  color: tea.isActive
                                      ? activeColor
                                      : tea.getColor(),
                                ),
                              ),
                            ),
                            // Brew temperature
                            Container(
                              padding: rowPadding,
                              child: Text(
                                tea.getTempDisplay(
                                  useCelsius: Provider.of<AppProvider>(
                                    context,
                                    listen: false,
                                  ).useCelsius,
                                ),
                                style: textStyleButtonSecondary.copyWith(
                                  color: tea.isActive
                                      ? activeColor
                                      : tea.getColor(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
