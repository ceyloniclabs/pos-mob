import 'dart:collection';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? nextPageUrl;
  final bool hasNextPageLink;

  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.nextPageUrl,
    this.hasNextPageLink = false,
  });

  bool get hasMore {
    if (hasNextPageLink) {
      return nextPageUrl != null &&
          nextPageUrl!.isNotEmpty &&
          nextPageUrl != 'null';
    }
    return currentPage < lastPage;
  }

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> metaMap = json;

    if (json['meta'] is Map<String, dynamic>) {
      metaMap = json['meta'] as Map<String, dynamic>;
    } else if (json['pagination'] is Map<String, dynamic>) {
      metaMap = json['pagination'] as Map<String, dynamic>;
    } else if (json['data'] is Map<String, dynamic>) {
      final dataMap = json['data'] as Map<String, dynamic>;
      if (dataMap['meta'] is Map<String, dynamic>) {
        metaMap = dataMap['meta'] as Map<String, dynamic>;
      } else if (dataMap['pagination'] is Map<String, dynamic>) {
        metaMap = dataMap['pagination'] as Map<String, dynamic>;
      } else if (dataMap['current_page'] != null) {
        metaMap = dataMap;
      }
    }

    final currentPage =
        _parseInt(metaMap['current_page'] ?? json['current_page']) ?? 1;
    final perPage =
        _parseInt(metaMap['per_page'] ?? json['per_page']) ?? 10;
    final total = _parseInt(metaMap['total'] ?? json['total']) ?? 0;

    int lastPage =
        _parseInt(metaMap['last_page'] ?? json['last_page']) ?? 1;
    if (lastPage <= 1 && total > perPage) {
      lastPage = (total / perPage).ceil();
    }

    String? nextPageUrl;
    bool hasNextPageLink = false;
    if (json['links'] is Map && (json['links'] as Map).containsKey('next')) {
      hasNextPageLink = true;
      nextPageUrl = (json['links'] as Map)['next']?.toString();
    } else if (metaMap['links'] is Map &&
        (metaMap['links'] as Map).containsKey('next')) {
      hasNextPageLink = true;
      nextPageUrl = (metaMap['links'] as Map)['next']?.toString();
    }

    return PaginationMeta(
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: perPage,
      total: total,
      nextPageUrl: nextPageUrl,
      hasNextPageLink: hasNextPageLink,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class PaginatedList<T> with ListMixin<T> {
  final List<T> _items;
  final PaginationMeta? meta;

  PaginatedList(this._items, {this.meta});

  /// If the server did not provide pagination metadata, this was an unpaginated
  /// response containing the full collection, so there are no more pages.
  bool get hasMore => meta != null ? meta!.hasMore : false;

  /// Whether this response is truly paginated by the server.
  bool get isPaginated => meta != null;

  @override
  int get length => _items.length;

  @override
  set length(int newLength) => _items.length = newLength;

  @override
  T operator [](int index) => _items[index];

  @override
  void operator []=(int index, T value) => _items[index] = value;
}

class BaseGetListResponseModel<T> {
  final bool success;
  final List<T> data;
  final String? message;
  final PaginationMeta? meta;

  BaseGetListResponseModel({
    required this.success,
    required this.data,
    this.message,
    this.meta,
  });

  factory BaseGetListResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    List rawList = [];
    if (json['data'] != null) {
      if (json['data'] is List) {
        rawList = json['data'] as List;
      } else if (json['data'] is Map &&
          (json['data'] as Map)['data'] is List) {
        rawList = (json['data'] as Map)['data'] as List;
      }
    }

    PaginationMeta? meta;
    final bool hasPaginationInfo = json['meta'] != null ||
        json['links'] != null ||
        json['pagination'] != null ||
        json['current_page'] != null ||
        (json['data'] is Map &&
            ((json['data'] as Map)['current_page'] != null ||
                (json['data'] as Map)['meta'] != null ||
                (json['data'] as Map)['pagination'] != null));

    if (hasPaginationInfo) {
      meta = PaginationMeta.fromJson(json);
    }

    final parsedItems = rawList
        .map((item) => fromJsonT(item is Map<String, dynamic>
            ? item
            : Map<String, dynamic>.from(item as Map)))
        .toList();

    return BaseGetListResponseModel(
      success: json['success'] ?? false,
      message: json['message']?.toString(),
      meta: meta,
      data: PaginatedList<T>(parsedItems, meta: meta),
    );
  }
}

/// Common extension to safely append paginated results across all controllers.
///
/// Automatically determines if this is the last page (using [PaginatedList]
/// metadata or unpaginated collection detection) and guarantees that duplicate
/// records are never appended when the server re-sends previously fetched data.
extension PagingControllerExt<T> on PagingController<int, T> {
  void appendPageResult({
    required List<T> newItems,
    required int currentPageKey,
    int? defaultPageSize,
    dynamic Function(T item)? idSelector,
  }) {
    if (newItems.isEmpty) {
      appendLastPage([]);
      return;
    }

    // 1. Determine if this is the last page
    bool isLastPage = false;
    if (newItems is PaginatedList) {
      final meta = (newItems as PaginatedList).meta;
      if (meta != null) {
        isLastPage = !meta.hasMore;
      } else {
        // Unpaginated endpoint returning the whole dataset -> no more pages!
        isLastPage = true;
      }
    } else {
      if (defaultPageSize != null && newItems.length < defaultPageSize) {
        isLastPage = true;
      }
    }

    // 2. Deduplication guard against repeated items
    final currentItems = itemList;
    List<T> itemsToAppend = newItems;

    if (currentItems != null && currentItems.isNotEmpty && idSelector != null) {
      final existingIds = currentItems.map(idSelector).toSet();
      itemsToAppend = newItems
          .where((item) => !existingIds.contains(idSelector(item)))
          .toList();

      // If the server re-sent items that were already fetched, stop pagination!
      if (itemsToAppend.isEmpty) {
        appendLastPage([]);
        return;
      }
    }

    // 3. Append to PagingController
    if (isLastPage) {
      appendLastPage(itemsToAppend);
    } else {
      final nextPageKey = currentPageKey + 1;
      appendPage(itemsToAppend, nextPageKey);
    }
  }
}
