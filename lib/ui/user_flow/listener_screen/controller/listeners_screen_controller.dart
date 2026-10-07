import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/all_listeners_screen/api/all_listeners_api.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/api/talk_topic_api.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/model/talk_topic_model.dart';
import 'package:talk_in/utils/constant.dart';

class ListenersScreenController extends GetxController {
  int selectedIndex = 0;
  // int selectedTopic = 0;
  List<int> selectedTopics = [];

  List<TalkTopic> talkTopic = [];
  List<TopListeners> allListener = [];
  List<String> allLanguages = [];
  List<String> selectedLanguages = [];
  TalkTopicsModel? talkTopicsModel;
  TopListenersModel? topListenersModel;
  String languageSearchQuery = '';
  ScrollController scrollController = ScrollController();
  bool isPaginationLoading = false;
  bool isBackProfile = false;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool isSearching = false;

  bool isLoading = false;

  // ── Auto-refresh every 3 seconds ──────────────────────────────────────
  Timer? _autoRefreshTimer;
  bool _isAutoRefreshing = false;
  static const Duration _autoRefreshInterval = Duration(seconds: 3);

  @override
  void onInit() {
    init();
    _startAutoRefresh();
    super.onInit();
  }

  init() {
    log("Enter In  listeners screen Controller");
    scrollController.addListener(onTopListenersPagination);

    AllListenersApi.startPagination = 0;
    allListeners();
    loadAllLanguages();
    getTalkTopic();
  }

  Future<void> searchListeners(String query) async {
    try {
      searchQuery = query;

      // Empty hoy to normal list load karo
      if (query.trim().isEmpty) {
        onRefresh();
        return;
      }

      isLoading = true;
      isSearching = true;
      update([Constant.idAllListener]);

      AllListenersApi.startPagination = 0;

      final data = await AllListenersApi.callApi(
        searchString: query, // 🔥 API search param
      );

      topListenersModel = data;
      allListener = data?.data ?? [];

      log("Search result => ${allListener.length}");
    } catch (e, st) {
      log('Search listener error: $e\n$st');
    } finally {
      isLoading = false;
      update([Constant.idAllListener]);
    }
  }


  /// all listeners get
  allListeners() async {
    isLoading = true;
    update([Constant.idAllListener]);

    topListenersModel = await AllListenersApi.callApi(searchString: "All");
    allListener.addAll(topListenersModel?.data ?? []);
    log(" ::::: $allListener");

    isLoading = false;
    update([Constant.idAllListener]);
  }

  /// all language get
  Future<void> loadAllLanguages() async {
    try {
      final String response = await rootBundle.loadString('assets/all_language.json');
      final Map<String, dynamic> data = json.decode(response);

      allLanguages = data.values.map<String>((e) => e.toString()).toList();

      update();
    } catch (e, st) {
      log('Error loading languages: $e\n$st');
    }
  }

  /// selected language
  bool isSelected(String language) {
    return selectedLanguages.contains(language);
  }

  /// selected ui update
  void toggleLanguage(String language) {
    if (selectedLanguages.contains(language)) {
      selectedLanguages.remove(language);
    } else {
      selectedLanguages.add(language);
    }
    update();
  }

  /// search language
  List<String> get filteredLanguages {
    if (languageSearchQuery.isEmpty) return allLanguages;
    return allLanguages.where((lang) => lang.toLowerCase().contains(languageSearchQuery.toLowerCase())).toList();
  }

  void updateLanguageSearchQuery(String query) {
    languageSearchQuery = query;
    update();
  }

  void clearSelectedLanguages() {
    selectedLanguages.clear();
    update();
  }

  /// filter by language api
  void filterListenerByLanguage() async {
    try {
      isLoading = true;
      update([Constant.idAllListener]);

      log('Selected Languages: ${selectedLanguages.join(', ')}');
      AllListenersApi.startPagination = 0;

      var data = await AllListenersApi.callApi(
        language: selectedLanguages.join(', '),
      );

      topListenersModel = data;
      allListener = data?.data ?? [];
      log("language filter  :: $allListener");
      for (var listener in allListener) {
        log('language filter Listener: ${listener.name}');
      }

      update([Constant.idAllListener]);
    } catch (e, st) {
      log('filter Listener By Listener error: $e\n$st');
    } finally {
      isLoading = false;
      update();
      log('filter Listener By Listener finally');
    }
  }

  /// get talk topic
  void getTalkTopic() async {
    try {
      isLoading = true;
      update([Constant.talkAboutTopic]);
      var data = await TalkTopicApi.callApi();
      talkTopicsModel = data;

      talkTopic = data?.talkTopics ?? [];

      update([Constant.talkAboutTopic]);
    } catch (e, st) {
      log('getTalkTopicApi error: $e\n$st');
    } finally {
      isLoading = false;
      update([Constant.talkAboutTopic]);
      log('getTalkTopicApi finally');
    }
  }

  /// select talk topic
  // void selectTopic(int index) {
  //   selectedTopic = index;
  //   log("talkTopic[selectedTopic].name  :: ${talkTopic[selectedTopic].name}");
  //   update([Constant.talkAboutTopic]);
  // }

  void selectTopic(int index) {
    if (selectedTopics.contains(index)) {
      selectedTopics.remove(index);
    } else {
      selectedTopics.add(index);
    }
    update([Constant.talkAboutTopic]);
  }

  void clearSelectedTopics() {
    selectedTopics.clear();
    update([Constant.talkAboutTopic]);
  }

  /// filter by talk topic api
  // void filterListenerByTalkTopic() async {
  //   try {
  //     isLoading = true;
  //     update([Constant.idAllListener]);
  //     AllListenersApi.startPagination = 0;
  //
  //     var data = await AllListenersApi.callApi(
  //       talkTopic: talkTopic[selectedTopic].name,
  //     );
  //
  //     topListenersModel = data;
  //     allListener = data?.data ?? [];
  //     log('talk about filter Listener: $allListener');
  //
  //     for (var listener in allListener) {
  //       log('talk about filter Listener: ${listener.name}');
  //     }
  //   } catch (e, st) {
  //     log('filterListenerByTalkTopic error: $e\n$st');
  //   } finally {
  //     isLoading = false; // <-- Make sure to set loading false here
  //     update([Constant.idAllListener]);
  //     log('filterListenerByTalkTopic finally');
  //   }
  // }

  void filterListenerByTalkTopic() async {
    try {
      isLoading = true;
      update([Constant.idAllListener]);

      AllListenersApi.startPagination = 0;

      // Collect topic names
      List<String> selectedTopicNames = selectedTopics.map((i) => talkTopic[i].name).whereType<String>().toList();

      var data = await AllListenersApi.callApi(
        talkTopic: selectedTopicNames.join(', '), // Send as comma-separated
      );

      topListenersModel = data;
      allListener = data?.data ?? [];

      log('Talk topic filter result: $allListener');
    } catch (e, st) {
      log('filterListenerByTalkTopic error: $e\n$st');
    } finally {
      isLoading = false;
      update([Constant.idAllListener]);
    }
  }

  Future<void> onTopListenersPagination() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {

      isPaginationLoading = true;
      update([Constant.idPaginationListener]);

      topListenersModel = await AllListenersApi.callApi(
        searchString: isSearching ? searchQuery : "All",
      );

      allListener.addAll(topListenersModel?.data ?? []);

      isPaginationLoading = false;
      update([Constant.idPaginationListener, Constant.idAllListener]);
    }
  }


  Future<void> onRefresh() async {
    searchController.clear();
    searchQuery = '';
    isSearching = false;

    AllListenersApi.startPagination = 0;
    allListener.clear();
    update([Constant.idAllListener]);

    await allListeners();
  }

  // ── Auto-refresh every 3 seconds ──────────────────────────────────────
  // Updates listener statuses/entries in place instead of clearing the
  // list, so there's no flicker and the user's scroll position is never
  // disturbed. Respects the current search/filter query instead of
  // silently resetting it back to "All". Skips itself if a call is
  // already in flight so requests never overlap/pile up.
  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(_autoRefreshInterval, (_) {
      _autoRefreshSilently();
    });
  }

  Future<void> _autoRefreshSilently() async {
    if (_isAutoRefreshing) return;
    _isAutoRefreshing = true;

    final savedPagination = AllListenersApi.startPagination;
    AllListenersApi.startPagination = 0;

    try {
      final freshData = await AllListenersApi.callApi(
        searchString: isSearching ? searchQuery : "All",
      );

      if (freshData?.data == null) return;

      final freshList = freshData!.data!;
      bool didChange = false;

      final freshById = {
        for (final l in freshList)
          if (l.id != null) l.id!: l,
      };

      // Update existing entries in place if anything about them changed.
      for (int i = 0; i < allListener.length; i++) {
        final current = allListener[i];
        final updated = freshById[current.id];
        if (updated != null && updated.statusLabel != current.statusLabel) {
          allListener[i] = updated;
          didChange = true;
        }
      }

      // Add any brand-new listeners not yet in the list.
      final existingIds = allListener.map((l) => l.id).toSet();
      final newOnes = freshList.where((l) => l.id != null && !existingIds.contains(l.id)).toList();
      if (newOnes.isNotEmpty) {
        allListener.addAll(newOnes);
        didChange = true;
      }

      if (didChange) {
        update([Constant.idAllListener]);
      }
    } catch (e) {
      log("Listeners auto-refresh error: $e");
      // Silent failure — don't disrupt the UI for a background refresh issue.
    } finally {
      AllListenersApi.startPagination = savedPagination;
      _isAutoRefreshing = false;
    }
  }

  @override
  void onClose() {
    _autoRefreshTimer?.cancel();
    scrollController.removeListener(onTopListenersPagination);
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

}