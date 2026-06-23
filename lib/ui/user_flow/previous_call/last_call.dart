// import 'package:flutter/material.dart';
// import 'package:talk_in/ui/host_flow/host_calling_screen/model/host_calling_history_model.dart';
// import 'package:talk_in/ui/user_flow/previous_call/previous_call.dart';
//
// import '../../host_flow/host_calling_screen/api/host_calling_history_api.dart';
//
//
// /// Drop this into the home screen, e.g. inside your Column/ListView:
// ///
// ///   const LastCallSection(),
// ///
// /// It fetches the most recent call on mount and renders nothing at all
// /// (SizedBox.shrink) until a real last call is found — so the card never
// /// flashes empty/placeholder data, and stays hidden forever for a user
// /// who has never made a call.
// class LastCallSection extends StatefulWidget {
//   const LastCallSection({super.key});
//
//   @override
//   State<LastCallSection> createState() => _LastCallSectionState();
// }
//
// class _LastCallSectionState extends State<LastCallSection> {
//   _LastCallInfo? _lastCall;
//   bool _loading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadLastCall();
//   }
//
//   Future<void> _loadLastCall() async {
//     final model = await HostCallingHistoryApi.getLastCall();
//     final info = _extractLastCallInfo(model);
//     if (!mounted) return;
//     setState(() {
//       _lastCall = info;
//       _loading = false;
//     });
//   }
//
//   // ─────────────────────────────────────────────────────────────────
//   // Mapped to the real HostCallHistory class:
//   //   fullName  -> listener's display name
//   //   userId    -> listener's id (used to repeat the call)
//   //   createdAt -> already a DateTime in the model, so _parseCallTime
//   //                just returns it as-is — no parsing needed.
//   // ─────────────────────────────────────────────────────────────────
//   _LastCallInfo? _extractLastCallInfo(HostCallingHistoryModel? model) {
//     if (model == null) return null;
//
//     final list = model.data;
//     if (list == null || list.isEmpty) return null;
//
//     final first = list.first; // most recent call (assumes API returns newest first)
//
//     return _LastCallInfo(
//       listenerName: first.fullName ?? 'Listener',
//       listenerId: first.userId ?? '',
//       callTime: _parseCallTime(first.createdAt),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_loading || _lastCall == null) {
//       return const SizedBox.shrink();
//     }
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: ContinueConversationCard(
//         listenerName: _lastCall!.listenerName,
//         timeLabel: _formatTimeAgo(_lastCall!.callTime),
//         onRepeatCall: () {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Listener Busy"),backgroundColor: Colors.red,),);
//
//         },
//       ),
//     );
//   }
// }
//
// class _LastCallInfo {
//   final String listenerName;
//   final String listenerId;
//   final DateTime callTime;
//
//   _LastCallInfo({
//     required this.listenerName,
//     required this.listenerId,
//     required this.callTime,
//   });
// }
//
// /// Parses `createdAt` regardless of whether the API/model gives it to you
// /// as an epoch int (seconds or millis), an ISO date string, or already a
// /// DateTime — this is what was causing the 'Object can't be assigned to
// /// String' error.
// DateTime _parseCallTime(dynamic raw) {
//   if (raw == null) return DateTime.now();
//   if (raw is DateTime) return raw;
//   if (raw is int) {
//     // Treat 10-digit-or-fewer numbers as seconds, otherwise milliseconds.
//     return raw < 9999999999
//         ? DateTime.fromMillisecondsSinceEpoch(raw * 1000)
//         : DateTime.fromMillisecondsSinceEpoch(raw);
//   }
//   if (raw is String) {
//     final asInt = int.tryParse(raw);
//     if (asInt != null) return _parseCallTime(asInt);
//     return DateTime.tryParse(raw) ?? DateTime.now();
//   }
//   return DateTime.now();
// }
//
// String _formatTimeAgo(DateTime dateTime) {
//   final now = DateTime.now();
//   final diff = now.difference(dateTime);
//
//   if (diff.inDays <= 0) {
//     return 'today';
//   } else if (diff.inDays == 1) {
//     return 'yesterday';
//   } else if (diff.inDays < 7) {
//     return '${diff.inDays} days ago';
//   } else if (diff.inDays < 30) {
//     final weeks = (diff.inDays / 7).floor();
//     return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
//   } else {
//     return '${dateTime.day.toString().padLeft(2, '0')}/'
//         '${dateTime.month.toString().padLeft(2, '0')}/'
//         '${dateTime.year}';
//   }
// }