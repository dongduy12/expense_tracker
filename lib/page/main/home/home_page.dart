import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Import Repository quản lý database
import 'package:expense_tracker/controls/spending_repository.dart';
import 'package:expense_tracker/models/spending.dart';
import 'package:expense_tracker/constants/function/extension.dart';
import 'package:expense_tracker/constants/function/get_data_spending.dart';
import 'package:expense_tracker/page/main/home/widget/item_spending_widget.dart';
import 'package:expense_tracker/page/main/home/view_list_spending_page.dart';

// Import Widget thẻ hiện đại (Nếu bạn chưa tạo file này, hãy dùng SummarySpending cũ)
import 'widget/modern_balance_card.dart';
// import 'widget/summary_spending.dart'; // Mở dòng này nếu muốn dùng giao diện cũ

import '../../../constants/app_styles.dart';
import '../../../setting/localization/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _monthController;
  List<DateTime> months = [];

  @override
  void initState() {
    super.initState();
    // Tạo danh sách 19 tháng (cho TabBar)
    _monthController = TabController(length: 19, vsync: this);
    _monthController.index = 17; // Mặc định chọn tháng hiện tại
    _monthController.addListener(() {
      setState(() {}); // Cập nhật UI khi vuốt tab
    });

    DateTime now = DateTime(DateTime.now().year, DateTime.now().month);
    months = [DateTime(now.year, now.month + 1), now];
    for (int i = 1; i < 19; i++) {
      now = DateTime(now.year, now.month - 1);
      months.add(now);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // --- THAY ĐỔI QUAN TRỌNG ---
        // Sử dụng ValueListenableBuilder để lắng nghe thay đổi từ Database Local
        child: ValueListenableBuilder<List<Spending>>(
          valueListenable: SpendingRepository.spendingNotifier,
          builder: (context, fullList, child) {

            // 1. Xác định tháng đang chọn
            final selectedMonth = months[18 - _monthController.index];

            // 2. Lọc danh sách chi tiêu thuộc tháng đó
            final filteredList = fullList
                .where((element) => isSameMonth(element.dateTime, selectedMonth))
                .toList();

            // 3. Tính toán tiền nong cho Thẻ Visa ảo
            double income = 0;
            double expense = 0;

            for (var item in filteredList) {
              if (item.type == 41) { // 41 là ID của Thu nhập (kiểm tra lại file list.dart)
                income += item.money;
              } else {
                expense += item.money;
              }
            }
            double totalBalance = income - expense;
            // Lưu ý: Đây là số dư CỦA THÁNG. Nếu muốn số dư TỔNG VÍ, bạn cần tính trên fullList.

            return Column(
              children: [
                const SizedBox(height: 10),
                // Thanh Tab chọn tháng
                SizedBox(
                  height: 40,
                  child: TabBar(
                    controller: _monthController,
                    isScrollable: true,
                    labelColor: Colors.black87,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    unselectedLabelColor: const Color.fromRGBO(45, 216, 198, 1),
                    unselectedLabelStyle: AppStyles.p,
                    indicatorColor: Colors.green,
                    tabs: List.generate(19, (index) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width / 4,
                        child: Tab(
                          text: index == 17
                              ? AppLocalizations.of(context).translate('this_month').capitalize()
                              : (index == 18
                              ? AppLocalizations.of(context).translate('next_month').capitalize()
                              : (index == 16
                              ? AppLocalizations.of(context).translate('last_month').capitalize()
                              : DateFormat("MM/yyyy").format(months[18 - index]))),
                        ),
                      );
                    }),
                  ),
                ),

                // --- WIDGET THẺ BALANCE ---
                // Dùng cái ModernBalanceCard mình đã hướng dẫn tạo trước đó
                ModernBalanceCard(
                  totalBalance: totalBalance,
                  income: income,
                  expense: expense,
                ),

                const SizedBox(height: 10),

                // Tiêu đề danh sách
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${AppLocalizations.of(context).translate('spending_list')} ${_monthController.index == 17 ? AppLocalizations.of(context).translate('this_month') : DateFormat("MM/yyyy").format(selectedMonth)}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      if (filteredList.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewListSpendingPage(spendingList: filteredList),
                              ),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context).translate('see_all'),
                            style: const TextStyle(fontSize: 14, color: Colors.blue),
                          ),
                        )
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Danh sách chi tiêu
                filteredList.isNotEmpty
                    ? Expanded(
                  child: ListView.builder(
                    // Chỉ hiển thị tối đa 5 item ở trang chủ cho gọn
                    itemCount: filteredList.length > 5 ? 5 : filteredList.length,
                    itemBuilder: (context, index) {
                      return ItemSpendingWidget(spending: filteredList[index]);
                    },
                  ),
                )
                    : Expanded(
                  child: Center(
                    child: Text(
                      "${AppLocalizations.of(context).translate('no_data')}!",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black45),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}