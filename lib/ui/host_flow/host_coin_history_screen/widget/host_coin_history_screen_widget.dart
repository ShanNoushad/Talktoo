import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/custom/range_picker/custom_range_picker.dart';
import 'package:talk_in/ui/host_flow/host_coin_history_screen/controller/host_coin_history_screen_controller.dart';
import 'package:talk_in/ui/user_flow/coin_history_screen/shimmer/coin_history_shimmer.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class HostCoinHistoryScreenAppBar extends StatelessWidget {
  const HostCoinHistoryScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: CustomAppBar(
        appBarColor: AppColors.black,
        title: EnumLocale.txtHistory.name.tr,
        textColor: AppColors.white,
        showLeadingIcon: true,
      ),
    );
  }
}

class HostCoinHistoryScreenTabBar extends StatelessWidget {
  const HostCoinHistoryScreenTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostCoinHistoryScreenController>(
      id: Constant.idTabChange,
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              height: Get.height * 0.06,
              decoration: BoxDecoration(
                color: AppColors.black,
                border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.changeTab(0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: controller.tabIndex == 0
                              ? AppColors.white.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          EnumLocale.txtCoin.name.tr,
                          style: controller.tabIndex == 0
                              ? AppFontStyle.fontStyleW600(
                            fontSize: 14,
                            fontColor: AppColors.white,
                          )
                              : AppFontStyle.fontStyleW500(
                            fontSize: 14,
                            fontColor: AppColors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ).paddingAll(controller.tabIndex == 0 ? 2 : 0),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.changeTab(1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: controller.tabIndex == 1
                              ? AppColors.white.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          EnumLocale.txtWithdraw.name.tr,
                          style: controller.tabIndex == 1
                              ? AppFontStyle.fontStyleW600(
                            fontSize: 14,
                            fontColor: AppColors.white,
                          )
                              : AppFontStyle.fontStyleW500(
                            fontSize: 14,
                            fontColor: AppColors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ).paddingAll(controller.tabIndex == 1 ? 2 : 0),
                    ),
                  ),
                ],
              ),
            ),
            10.height,
            Row(
              children: [
                Text(
                  EnumLocale.txtSelectDate.name.tr,
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 14,
                    fontColor: AppColors.white,
                  ),
                ),
                const Spacer(),
                GetBuilder<HostCoinHistoryScreenController>(
                  id: Constant.idTabChange,
                  builder: (controller) {
                    String displayText = EnumLocale.txtAll.name.tr;

                    if (controller.tabIndex == 1 &&
                        controller.selectedWithdrawDateRange != null) {
                      final range = controller.selectedWithdrawDateRange!;
                      displayText =
                      "${Utils.formatShortDate(range.start)} - ${Utils.formatShortDate(range.end)}";
                    } else if (controller.tabIndex == 0 &&
                        controller.selectedCoinDateRange != null) {
                      final range = controller.selectedCoinDateRange!;
                      displayText =
                      "${Utils.formatShortDate(range.start)} - ${Utils.formatShortDate(range.end)}";
                    }

                    return GestureDetector(
                      onTap: () async {
                        final picked = await CustomRangePicker.onShow(
                          context,
                          controller.tabIndex == 1
                              ? controller.selectedWithdrawDateRange
                              : controller.selectedCoinDateRange,
                        );
                        if (picked != null) {
                          controller.applyDateFilter(
                              picked.start, picked.end);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.15)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text(
                              displayText,
                              style: AppFontStyle.fontStyleW500(
                                fontSize: 14,
                                fontColor: AppColors.white,
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down_rounded,
                                size: 20, color: AppColors.white),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                12.width,
                Visibility(
                  visible: (controller.tabIndex == 1 &&
                      controller.selectedWithdrawDateRange != null) ||
                      (controller.tabIndex == 0 &&
                          controller.selectedCoinDateRange != null),
                  child: GestureDetector(
                    onTap: () => controller.clearDateFilter(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.15)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(
                        AppAsset.filterClearIcon,
                        height: 20,
                        width: 20,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                )
              ],
            ).paddingSymmetric(horizontal: 16),
            16.height,
          ],
        );
      },
    );
  }
}

class HostCoinHistoryScreenTabBarScreen extends StatelessWidget {
  const HostCoinHistoryScreenTabBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostCoinHistoryScreenController>(
      id: Constant.idTabChange,
      builder: (controller) {
        return Expanded(
          child: controller.tabIndex == 0
              ? controller.coinHistoryModel?.data?.isEmpty == true
              ? SizedBox(
            height: 100,
            child: Image.asset(AppAsset.noHistoryFound),
          ).paddingAll(90)
              : receiveCoinList(controller)
              : controller.withdrawalRecordModel?.data?.isEmpty == true
              ? SizedBox(
            height: 100,
            child: Image.asset(AppAsset.noHistoryFound),
          ).paddingAll(90)
              : withdrawAmount(controller),
        );
      },
    );
  }

  Widget receiveCoinList(HostCoinHistoryScreenController controller) {
    return GetBuilder<HostCoinHistoryScreenController>(
      id: Constant.idTabChange,
      builder: (controller) {
        return controller.isLoading
            ? const CoinHistoryShimmer()
            : Container(
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.4),
                offset: const Offset(0, 0),
                blurRadius: 14,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    EnumLocale.txtDetails.name.tr,
                    style: AppFontStyle.fontStyleW500(
                      fontSize: 12,
                      fontColor: AppColors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    EnumLocale.txtCoin.name.tr,
                    style: AppFontStyle.fontStyleW500(
                      fontSize: 12,
                      fontColor: AppColors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ).paddingSymmetric(horizontal: 14, vertical: 14),
              Divider(
                  color: AppColors.white.withValues(alpha: 0.1),
                  height: 0),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async =>
                      controller.refreshHostCoinHistory(),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: controller.scrollController,
                          itemCount:
                          controller.hostCoinHistoryList.length,
                          itemBuilder: (context, index) {
                            final item =
                            controller.hostCoinHistoryList[index];
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: 40,
                                            width: 40,
                                            child: ClipOval(
                                              child: CustomProfileImage(
                                                image:
                                                item.profilePic ?? '',
                                              ),
                                            ),
                                          ).paddingOnly(right: 5),
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.type == 1 ||
                                                    item.type == 2
                                                    ? Database
                                                    .loginUserName
                                                    : item.fullName ?? '',
                                                style: AppFontStyle
                                                    .fontStyleW700(
                                                  fontSize: 13,
                                                  fontColor:
                                                  AppColors.white,
                                                ),
                                              ).paddingOnly(bottom: 3),
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    item.type == 2
                                                        ? AppAsset
                                                        .coinPurchaseIcon
                                                        : item.type == 3
                                                        ? AppAsset
                                                        .callIcon
                                                        : item.type ==
                                                        4
                                                        ? AppAsset
                                                        .videoCallIcon
                                                        : item.type ==
                                                        5
                                                        ? AppAsset
                                                        .callIcon
                                                        : item.type ==
                                                        6
                                                        ? AppAsset
                                                        .videoCallIcon
                                                        : AppAsset
                                                        .loginBonusIcon,
                                                    color: AppColors.white
                                                        .withValues(
                                                        alpha: 0.5),
                                                    height: 12,
                                                    width: 12,
                                                    fit: BoxFit.fill,
                                                  ).paddingOnly(right: 4),
                                                  Text(
                                                    item.type == 2
                                                        ? "Coin Purchase"
                                                        : item.type == 3
                                                        ? "Private audio call"
                                                        : item.type ==
                                                        4
                                                        ? "Private video call"
                                                        : item.type ==
                                                        5
                                                        ? "Random audio call"
                                                        : item.type ==
                                                        6
                                                        ? "Random video call"
                                                        : "Log In Bonus",
                                                    style: AppFontStyle
                                                        .fontStyleW500(
                                                      fontSize: 11,
                                                      fontColor: AppColors
                                                          .white
                                                          .withValues(
                                                          alpha: 0.5),
                                                    ),
                                                  ).paddingOnly(right: 6),
                                                  Text(
                                                    textAlign:
                                                    TextAlign.center,
                                                    item.type == 1 ||
                                                        item.type == 2
                                                        ? ""
                                                        : item.duration ==
                                                        null
                                                        ? ''
                                                        : "${item.duration}",
                                                    style: AppFontStyle
                                                        .fontStyleW600(
                                                      fontSize: 11,
                                                      fontColor: AppColors
                                                          .darkOrange,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          textAlign: TextAlign.center,
                                          "+ ${item.listenerCoin}",
                                          style:
                                          AppFontStyle.fontStyleW700(
                                            fontSize: 13,
                                            fontColor: AppColors.green,
                                          ),
                                        ).paddingOnly(bottom: 4),
                                        Text(
                                          item.date.toString(),
                                          style:
                                          AppFontStyle.fontStyleW500(
                                            fontSize: 10,
                                            fontColor: AppColors.white
                                                .withValues(alpha: 0.4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ).paddingOnly(
                                    right: 14,
                                    bottom: 14,
                                    top: 14,
                                    left: 10),
                                Divider(
                                    color: AppColors.white
                                        .withValues(alpha: 0.08),
                                    height: 0),
                              ],
                            );
                          },
                        ),
                      ),
                      GetBuilder<HostCoinHistoryScreenController>(
                        id: Constant.idPaginationListener,
                        builder: (controller) => Visibility(
                          visible: controller.isPaginationLoading,
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).paddingOnly(left: 10, right: 10, top: 8);
      },
    );
  }

  Widget withdrawAmount(HostCoinHistoryScreenController controller) {
    return GetBuilder<HostCoinHistoryScreenController>(
      id: Constant.idTabChange,
      builder: (controller) {
        final itemCount = controller.withdrawalRecordList.isNotEmpty == true
            ? controller.withdrawalRecordList.length
            : 0;

        if (controller.isExpandedList.length != itemCount) {
          controller.initializeExpansionState(itemCount);
        }

        if (controller.withdrawalRecordModel?.data == null ||
            controller.isExpandedList.length != itemCount) {
          return const CoinHistoryShimmer();
        }

        return controller.isLoading
            ? const CoinHistoryShimmer()
            : Container(
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.4),
                offset: const Offset(0, 0),
                blurRadius: 14,
              ),
            ],
          ),
          child: RefreshIndicator(
            onRefresh: () async => controller.onRefresh(),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: controller.scrollController1,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      final item =
                      controller.withdrawalRecordList[index];
                      final isItemExpanded =
                      (index < controller.isExpandedList.length)
                          ? controller.isExpandedList[index]
                          : false;

                      return Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color:
                              AppColors.white.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  EnumLocale.txtCoin.name.tr,
                                  style: AppFontStyle.fontStyleW800(
                                    fontSize: 18,
                                    fontColor: AppColors.white,
                                  ),
                                ),
                                Text(
                                  "${item.coin ?? ''}",
                                  style: AppFontStyle.fontStyleW800(
                                    fontSize: 18,
                                    fontColor: AppColors.red,
                                  ),
                                ),
                              ],
                            ).paddingOnly(bottom: 16),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  EnumLocale.txtAmount.name.tr,
                                  style: AppFontStyle.fontStyleW600(
                                    fontSize: 12,
                                    fontColor: AppColors.white
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                Text(
                                  "${Database.settingApiModel?.data?.currency?.symbol}${item.amount ?? ''}",
                                  style: AppFontStyle.fontStyleW700(
                                    fontSize: 12,
                                    fontColor: AppColors.white,
                                  ),
                                ),
                              ],
                            ).paddingOnly(bottom: 16),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  EnumLocale.txtWithdrawalID.name.tr,
                                  style: AppFontStyle.fontStyleW600(
                                    fontSize: 12,
                                    fontColor: AppColors.white
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                Text(
                                  item.uniqueId ?? '',
                                  style: AppFontStyle.fontStyleW700(
                                    fontSize: 12,
                                    fontColor: AppColors.white,
                                  ),
                                ),
                              ],
                            ).paddingOnly(bottom: 16),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  EnumLocale.txtPaymentMethod.name.tr,
                                  style: AppFontStyle.fontStyleW600(
                                    fontSize: 12,
                                    fontColor: AppColors.white
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                Text(
                                  item.paymentGateway ?? '',
                                  style: AppFontStyle.fontStyleW700(
                                    fontSize: 12,
                                    fontColor: AppColors.white,
                                  ),
                                ),
                              ],
                            ).paddingOnly(bottom: 16),
                            if (isItemExpanded) ...[
                              Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    EnumLocale.txtPaymentDetails.name.tr,
                                    style: AppFontStyle.fontStyleW600(
                                      fontSize: 12,
                                      fontColor: AppColors.white
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                    children: item.paymentDetails?.details
                                        ?.entries
                                        .map((entry) {
                                      return Text(
                                        entry.value.toString(),
                                        style: AppFontStyle
                                            .fontStyleW700(
                                          fontSize: 12,
                                          fontColor:
                                          AppColors.white,
                                        ),
                                      ).paddingOnly(bottom: 2);
                                    }).toList() ??
                                        [],
                                  ),
                                ],
                              ).paddingOnly(bottom: 16),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    EnumLocale.txtRequestDate.name.tr,
                                    style: AppFontStyle.fontStyleW600(
                                      fontSize: 12,
                                      fontColor: AppColors.white
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  Text(
                                    item.requestDate ?? '',
                                    style: AppFontStyle.fontStyleW700(
                                      fontSize: 12,
                                      fontColor: AppColors.white,
                                    ),
                                  ),
                                ],
                              ).paddingOnly(bottom: 16),
                              if (item.status != 1)
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      EnumLocale
                                          .txtAcceptDeclineDate.name.tr,
                                      style: AppFontStyle.fontStyleW600(
                                        fontSize: 12,
                                        fontColor: AppColors.white
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                    Text(
                                      item.acceptOrDeclineDate ?? '',
                                      style: AppFontStyle.fontStyleW700(
                                        fontSize: 12,
                                        fontColor: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ).paddingOnly(bottom: 16),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${EnumLocale.txtStatus.name.tr} :",
                                    style: AppFontStyle.fontStyleW600(
                                      fontSize: 12,
                                      fontColor: AppColors.white
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(4),
                                      color: item.status == 1
                                          ? AppColors.lightYellow
                                          : item.status == 2
                                          ? AppColors.lightPurple
                                          : AppColors.lightRed,
                                    ),
                                    child: Text(
                                      item.status == 1
                                          ? EnumLocale.txtPending.name.tr
                                          : item.status == 2
                                          ? EnumLocale
                                          .txtApproved.name.tr
                                          : EnumLocale
                                          .txtRejected.name.tr,
                                      style: AppFontStyle.fontStyleW600(
                                        fontSize: 12,
                                        fontColor: item.status == 1
                                            ? AppColors.orange
                                            : item.status == 2
                                            ? AppColors.green
                                            : AppColors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}