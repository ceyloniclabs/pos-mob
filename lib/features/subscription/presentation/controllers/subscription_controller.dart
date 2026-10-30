import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/current_subscription_data_entity.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/usecases/get_current_subscription_use_case.dart';
import '../../domain/usecases/get_subscription_history_use_case.dart';

class SubscriptionController extends GetxController {
  final GetCurrentSubscriptionUseCase _getCurrentSubscriptionUseCase;
  final GetSubscriptionHistoryUseCase _getSubscriptionHistoryUseCase;

  SubscriptionController({
    required this._getCurrentSubscriptionUseCase,
    required this._getSubscriptionHistoryUseCase,
  });

  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxnString errorMessage = RxnString();

  final Rxn<CurrentSubscriptionDataEntity> currentData =
      Rxn<CurrentSubscriptionDataEntity>();
  final RxList<SubscriptionEntity> historyList = <SubscriptionEntity>[].obs;
  final RxString selectedHistoryFilter = 'all'.obs;

  void setHistoryFilter(String filter) {
    selectedHistoryFilter.value = filter;
  }

  List<SubscriptionEntity> get filteredHistoryList {
    final filter = selectedHistoryFilter.value.toLowerCase();
    if (filter == 'all') return historyList;
    if (filter == 'active') {
      return historyList.where((s) => s.isActive && !s.isExpired).toList();
    }
    if (filter == 'upcoming') {
      return historyList.where((s) => s.isUpcoming).toList();
    }
    if (filter == 'expired') {
      return historyList.where((s) => s.isStatusExpired).toList();
    }
    return historyList;
  }

  List<SubscriptionEntity> get recentHistoryPreview =>
      historyList.take(3).toList();

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData({bool isRefresh = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }
    errorMessage.value = null;

    try {
      final results = await Future.wait([
        _getCurrentSubscriptionUseCase.execute(),
        _getSubscriptionHistoryUseCase.execute(),
      ]);

      currentData.value = results[0] as CurrentSubscriptionDataEntity;
      historyList.assignAll(results[1] as List<SubscriptionEntity>);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  SubscriptionEntity? get activeSubscription => currentData.value?.subscription;

  int get daysRemaining =>
      currentData.value?.daysRemaining ??
      activeSubscription?.daysRemaining ??
      0;

  bool get isExpired =>
      currentData.value?.isExpired ??
      activeSubscription?.isExpired ??
      false;

  bool get isExpiringSoon => !isExpired && daysRemaining > 0 && daysRemaining <= 14;

  String formatCurrency(double amount, String currency) {
    final formatter = NumberFormat('#,##0.00');
    return '$currency ${formatter.format(amount)}';
  }

  String formatDate(DateTime? date, {String fallback = '—'}) {
    if (date == null) return fallback;
    return DateFormat('MMM dd, yyyy').format(date.toLocal());
  }

  String formatDateTime(DateTime? dateTime, {String fallback = '—'}) {
    if (dateTime == null) return fallback;
    return DateFormat('MMM dd, yyyy · hh:mm a').format(dateTime.toLocal());
  }
}
