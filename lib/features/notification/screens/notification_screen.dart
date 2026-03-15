import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todone_frontend/core/constants/index.dart';
import 'package:todone_frontend/core/service/index.dart';
import '../widgets/index.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NotificationService _notificationService = NotificationService();
  final UserStorageService _userStorage = UserStorageService();

  List<NotificationModel> _notifications = [];
  bool _loading = true;
  String? _error;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    final user = await _userStorage.getUser();
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _userId = null;
        _notifications = [];
        _loading = false;
        _error = 'Please log in again';
      });
      return;
    }
    setState(() {
      _userId = user.userId;
      _loading = true;
      _error = null;
    });
    final result = await _notificationService.getNotifications(user.userId);
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(data: final list):
        setState(() {
          _notifications = list;
          _loading = false;
          _error = null;
        });
      case ApiFailure(message: final message):
        setState(() {
          _notifications = [];
          _loading = false;
          _error = message;
        });
    }
  }

  Future<void> _updateStatus(NotificationModel notification, String status) async {
    if (_userId == null) return;
    final result = await _notificationService.updateNotificationStatus(
      notification.id,
      _userId!,
      status,
    );
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(data: final updated):
        setState(() {
          final i = _notifications.indexWhere((n) => n.id == notification.id);
          if (i >= 0) _notifications[i] = updated;
        });
      case ApiFailure(message: final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
    }
  }

  List<NotificationModel> get _unreadNotifications =>
      _notifications.where((n) => n.status.toUpperCase() == 'DELIVERED').toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark
            ? const Color(0xFF0F172A).withOpacity(0.9)
            : Colors.white.withOpacity(0.9),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.arrow_back,
              color: isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
            ),
          ),
        ),
        title: Text(
          AppStrings.reminders,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
            ),
            onSelected: (value) async {
              if (value == 'clear_read' && _userId != null) {
                final result = await _notificationService
                    .clearAllReadNotifications(_userId!);
                if (!mounted) return;
                switch (result) {
                  case ApiSuccess():
                    _loadNotifications();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All read notifications deleted'),
                      ),
                    );
                  case ApiFailure(message: final message):
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear_read',
                child: Text(AppStrings.clearAllReadNotifications),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF4F46E5),
            unselectedLabelColor: isDark
                ? const Color(0xFF64748B)
                : const Color(0xFF94A3B8),
            indicatorColor: const Color(0xFF4F46E5),
            indicatorWeight: 3,
            tabs: [
              Tab(text: AppStrings.unread),
              Tab(text: AppStrings.all),
            ],
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _loadNotifications,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(isDark, _unreadNotifications, isUnreadTab: true),
                    _buildList(isDark, _notifications, isUnreadTab: false),
                  ],
                ),
    );
  }

  Widget _buildList(
    bool isDark,
    List<NotificationModel> list, {
    bool isUnreadTab = false,
  }) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          isUnreadTab
              ? AppStrings.noUnreadNotifications
              : AppStrings.noNotifications,
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? const Color(0xFF94A3B8)
                : const Color(0xFF64748B),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: list.length + 1,
        itemBuilder: (context, index) {
          if (index == list.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                AppStrings.swipeRightReadLeftUnread,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
              ),
            );
          }
          final notification = list[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Slidable(
              key: ValueKey(notification.id),
              startActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => _updateStatus(notification, 'READ'),
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    icon: Icons.done_all,
                    label: AppStrings.markRead,
                  ),
                ],
              ),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => _updateStatus(notification, 'DELIVERED'),
                    backgroundColor: const Color(0xFF64748B),
                    foregroundColor: Colors.white,
                    icon: Icons.mark_email_unread,
                    label: AppStrings.markUnread,
                  ),
                ],
              ),
              child: NotificationCard(
                notification: notification,
              ),
            ),
          );
        },
      ),
    );
  }
}
