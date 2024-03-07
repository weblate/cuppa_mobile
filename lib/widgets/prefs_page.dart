/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    prefs_page.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa Preferences page
// - Build prefs interface and interactivity

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/dialogs.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/common/icons.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/separators.dart';
import 'package:cuppa_mobile/common/text_styles.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/stats.dart';
import 'package:cuppa_mobile/widgets/about_page.dart';
import 'package:cuppa_mobile/widgets/page_header.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';
import 'package:cuppa_mobile/widgets/stats_page.dart';
import 'package:cuppa_mobile/widgets/tea_settings_list.dart';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Cuppa Preferences page
class PrefsWidget extends StatelessWidget {
  const PrefsWidget({super.key});

  // Build Prefs page
  @override
  Widget build(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context, listen: false);

    // Determine layout based on device size
    bool layoutColumns = getDeviceSize(context).isLargeDevice;

    return Scaffold(
      appBar: PlatformAdaptiveNavBar(
        isPoppable: true,
        title: AppString.prefs_title.translate(),
        // Button to navigate to About page
        actionIcon: getPlatformAboutIcon(),
        actionRoute: const AboutWidget(),
        // Button to navigate to Stats page
        secondaryActionIcon:
            provider.collectStats ? getPlatformStatsIcon() : null,
        secondaryActionRoute:
            provider.collectStats ? const StatsWidget() : null,
      ),
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Tea settings
                  const TeaSettingsList(),
                  const SliverToBoxAdapter(child: smallSpacerWidget),
                  // Other settings inline
                  SliverOffstage(
                    offstage: layoutColumns,
                    sliver: _otherSettingsList(context),
                  ),
                ],
              ),
            ),
            // Other settings in second column
            Visibility(
              visible: layoutColumns,
              child: Expanded(
                child: CustomScrollView(
                  slivers: [
                    _otherSettingsList(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // List of other settings with pinned header
  Widget _otherSettingsList(BuildContext context) {
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        pageHeader(
          context,
          title: AppString.settings_title.translate(),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              // Setting: collect timer usage stats
              _collectStatsSetting(context),
              listDivider,
              // Setting: show extra info on buttons
              _showExtraSetting(context),
              listDivider,
              // Setting: hide timer increment buttons
              _hideIncrementsSetting(context),
              listDivider,
              // Setting: stacked timer button view
              Selector<AppProvider, bool>(
                selector: (_, provider) =>
                    provider.teaCount > stackedViewTeaCount,
                builder: (context, showStackedView, child) {
                  return Visibility(
                    visible: showStackedView,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _stackedViewSetting(context),
                        listDivider,
                      ],
                    ),
                  );
                },
              ),
              // Setting: default to Celsius or Fahrenheit
              _useCelsiusSetting(context),
              listDivider,
              // Setting: app theme selection
              _appThemeSetting(context),
              listDivider,
              // Setting: app language selection
              _appLanguageSetting(context),
              listDivider,
              // Notification info
              _notificationLink(),
            ],
          ),
        ),
      ],
    );
  }

  // Setting: collect timer usage stats
  Widget _collectStatsSetting(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return SwitchListTile.adaptive(
      title: Text(
        AppString.stats_enable.translate(),
        style: textStyleTitle,
      ),
      value: provider.collectStats,
      // Save collectStats setting to prefs
      onChanged: (bool newValue) async {
        AppProvider provider = Provider.of<AppProvider>(context, listen: false);

        // Show a prompt with more information
        if (await showConfirmDialog(
          context: context,
          body: Text(
            provider.collectStats
                ? AppString.stats_confirm_disable.translate()
                : AppString.stats_confirm_enable.translate(),
          ),
          bodyExtra: Text(AppString.confirm_continue.translate()),
          isDestructiveAction: provider.collectStats,
        )) {
          // Update setting
          provider.collectStats = newValue;

          // Clear usage data if collection gets disabled
          if (!provider.collectStats) {
            Stats.clearStats();
          }
        }
      },
      contentPadding: listTilePadding,
      dense: true,
    );
  }

// Setting: show extra info on buttons
  Widget _showExtraSetting(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return SwitchListTile.adaptive(
      title: Text(
        AppString.prefs_show_extra.translate(),
        style: textStyleTitle,
      ),
      value: provider.showExtra,
      // Save showExtra setting to prefs
      onChanged: (bool newValue) {
        provider.showExtra = newValue;
      },
      contentPadding: listTilePadding,
      dense: true,
    );
  }

  // Setting: hide timer increment buttons
  Widget _hideIncrementsSetting(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return SwitchListTile.adaptive(
      title: Text(
        AppString.prefs_hide_increments.translate(),
        style: textStyleTitle,
      ),
      subtitle: provider.hideIncrements
          ? Text(
              AppString.prefs_hide_increments_info.translate(),
              style: textStyleSubtitle,
            )
          : null,
      value: provider.hideIncrements,
      // Save hideIncrements setting to prefs
      onChanged: (bool newValue) {
        provider.hideIncrements = newValue;
      },
      contentPadding: listTilePadding,
      dense: true,
    );
  }

  // Setting: stacked timer button view
  Widget _stackedViewSetting(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return SwitchListTile.adaptive(
      title: Text(
        AppString.prefs_stacked_view.translate(),
        style: textStyleTitle,
      ),
      value: provider.stackedView,
      // Save stackedView setting to prefs
      onChanged: (bool newValue) {
        provider.stackedView = newValue;
      },
      contentPadding: listTilePadding,
      dense: true,
    );
  }

  // Setting: default to Celsius or Fahrenheit
  Widget _useCelsiusSetting(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return SwitchListTile.adaptive(
      title: Text(
        AppString.prefs_use_celsius.translate(),
        style: textStyleTitle,
      ),
      value: provider.useCelsius,
      // Save useCelsius setting to prefs
      onChanged: (bool newValue) {
        provider.useCelsius = newValue;
      },
      contentPadding: listTilePadding,
      dense: true,
    );
  }

  // Setting: app theme selection
  Widget _appThemeSetting(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return ListTile(
      title: Text(
        AppString.prefs_app_theme.translate(),
        style: textStyleTitle,
      ),
      trailing: Text(
        provider.appTheme.localizedName,
        style: textStyleTitle.copyWith(
          color: Theme.of(context).textTheme.bodySmall!.color!,
        ),
      ),
      // Open app theme dialog
      onTap: () => openPlatformAdaptiveSelectList(
        context: context,
        titleText: AppString.prefs_app_theme.translate(),
        buttonTextCancel: AppString.cancel_button.translate(),
        itemList: AppTheme.values,
        itemBuilder: _appThemeItem,
        separatorBuilder: separatorDummy,
      ),
      contentPadding: listTilePadding,
      dense: true,
    );
  }

  // App theme option
  Widget _appThemeItem(BuildContext context, int index) {
    AppProvider provider = Provider.of<AppProvider>(context, listen: false);
    AppTheme value = AppTheme.values.elementAt(index);

    return RadioListTile.adaptive(
      contentPadding: radioTilePadding,
      dense: true,
      useCupertinoCheckmarkStyle: true,
      value: value,
      groupValue: provider.appTheme,
      // Theme name
      title: Text(
        value.localizedName,
        style: textStyleTitle,
      ),
      // Save appTheme to prefs
      onChanged: (_) {
        provider.appTheme = value;
        Navigator.of(context).pop(true);
      },
    );
  }

  // Setting: app language selection
  Widget _appLanguageSetting(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);

    return ListTile(
      title: Text(AppString.prefs_language.translate(), style: textStyleTitle),
      trailing: Text(
        provider.appLanguage != followSystemLanguage &&
                supportedLocales
                    .containsKey(parseLocaleString(provider.appLanguage))
            ? supportedLocales[parseLocaleString(provider.appLanguage)]!
            : AppString.theme_system.translate(),
        style: textStyleTitle.copyWith(
          color: Theme.of(context).textTheme.bodySmall!.color!,
        ),
      ),
      // Open app language dialog
      onTap: () => openPlatformAdaptiveSelectList(
        context: context,
        titleText: AppString.prefs_language.translate(),
        buttonTextCancel: AppString.cancel_button.translate(),
        itemList: languageOptions,
        itemBuilder: _appLanguageItem,
        separatorBuilder: separatorDummy,
      ),
      contentPadding: listTilePadding,
      dense: true,
    );
  }

  // App language option
  Widget _appLanguageItem(BuildContext context, int index) {
    AppProvider provider = Provider.of<AppProvider>(context, listen: false);
    String value = languageOptions[index];

    return RadioListTile.adaptive(
      contentPadding: radioTilePadding,
      dense: true,
      useCupertinoCheckmarkStyle: true,
      value: value,
      groupValue: provider.appLanguage,
      // Language name
      title: Text(
        value != followSystemLanguage &&
                supportedLocales.containsKey(parseLocaleString(value))
            ? supportedLocales[parseLocaleString(value)]!
            : AppString.theme_system.translate(),
        style: textStyleTitle,
      ),
      // Save appLanguage to prefs
      onChanged: (_) {
        provider.appLanguage = value;
        Navigator.of(context).pop(true);
      },
    );
  }

  // Notification settings info text and link
  Widget _notificationLink() {
    return InkWell(
      child: ListTile(
        minLeadingWidth: 30.0,
        leading: const SizedBox(
          height: double.infinity,
          child: infoIcon,
        ),
        horizontalTitleGap: 0.0,
        title: Text(
          AppString.prefs_notifications.translate(),
          style: textStyleSubtitle,
        ),
        trailing: const SizedBox(height: double.infinity, child: launchIcon),
        onTap: () =>
            AppSettings.openAppSettings(type: AppSettingsType.notification),
        contentPadding: listTilePadding,
        dense: true,
      ),
    );
  }
}
