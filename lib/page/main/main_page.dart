import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:expense_tracker/constants/function/on_will_pop.dart';
import 'package:expense_tracker/constants/function/route_function.dart';
import 'package:expense_tracker/page/add_spending/add_spending.dart';
import 'package:expense_tracker/page/main/analytic/analytic_page.dart';
import 'package:expense_tracker/page/main/calendar/calendar_page.dart';
import 'package:expense_tracker/page/main/chatbot/gemini_chat_page.dart';
import 'package:expense_tracker/page/main/home/home_page.dart';
import 'package:expense_tracker/page/main/profile/setting_page.dart';
import 'package:expense_tracker/page/main/widget/item_bottom_tab.dart';

import '../../setting/localization/app_localizations.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentTab = 0;
  List<Widget> screens = [
    const HomePage(),
    const CalendarPage(),
    const AnalyticPage(),
    const SettingPage()
  ];

  DateTime? currentBackPressTime;
  final PageStorageBucket bucket = PageStorageBucket();
  XFile? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WillPopScope(
            onWillPop: () => onWillPop(
              action: (now) => currentBackPressTime = now,
              currentBackPressTime: currentBackPressTime,
            ),
            child: PageStorage(
              bucket: bucket,
              child: screens[currentTab],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 90,
            child: _buildGeminiChatButton(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          Navigator.of(context).push(
            createRoute(screen: const AddSpendingPage()),
          );
        },
        child: Icon(
          Icons.add_rounded,
          color: Theme.of(context).colorScheme.background,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        // color: AppColors.whisperBackground,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  itemBottomTab(
                    text: AppLocalizations.of(context).translate('home'),
                    index: 0,
                    current: currentTab,
                    icon: FontAwesomeIcons.house,
                    action: () {
                      setState(() {
                        currentTab = 0;
                      });
                    },
                  ),
                  itemBottomTab(
                    text: AppLocalizations.of(context).translate('calendar'),
                    index: 1,
                    current: currentTab,
                    size: 28,
                    icon: Icons.calendar_month_outlined,
                    action: () {
                      setState(() {
                        currentTab = 1;
                      });
                    },
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  itemBottomTab(
                    text: AppLocalizations.of(context).translate('analytic'),
                    index: 2,
                    current: currentTab,
                    icon: FontAwesomeIcons.chartPie,
                    action: () {
                      setState(() {
                        currentTab = 2;
                      });
                    },
                  ),
                  itemBottomTab(
                    text: AppLocalizations.of(context).translate('setting'),
                    index: 3,
                    current: currentTab,
                    icon: currentTab == 3
                        ? FontAwesomeIcons.solidCircleUser
                        : FontAwesomeIcons.gear,
                    action: () {
                      setState(() => currentTab = 3);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeminiChatButton(BuildContext context) {
    return Tooltip(
      message: AppLocalizations.of(context).translate('gemini_assistant'),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            Navigator.of(context).push(
              createRoute(screen: const GeminiChatPage()),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const SizedBox(
              height: 52,
              width: 52,
              child: Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => this.image = image);
      }
    } on PlatformException catch (_) {}
  }
}
