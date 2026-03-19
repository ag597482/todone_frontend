import 'package:flutter/material.dart';
import 'package:todone_frontend/core/constants/index.dart';
import 'package:todone_frontend/core/service/index.dart';

/// Lists task groups and FAB to create; calls [onGroupsChanged] after successful create.
class TaskGroupsManageTab extends StatefulWidget {
  const TaskGroupsManageTab({super.key, required this.onGroupsChanged});

  final VoidCallback onGroupsChanged;

  @override
  State<TaskGroupsManageTab> createState() => _TaskGroupsManageTabState();
}

class _TaskGroupsManageTabState extends State<TaskGroupsManageTab> {
  final TaskGroupService _taskGroupService = TaskGroupService();
  final UserStorageService _userStorage = UserStorageService();

  List<TaskGroupModel> _groups = [];
  bool _loading = true;
  String? _error;
  bool _creating = false;
  String? _editingGroupId;
  String? _deletingGroupId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await _userStorage.getUser();
    if (!mounted) return;
    if (user == null) {
      setState(() {
        _loading = false;
        _error = AppStrings.pleaseLogInAgain;
        _groups = [];
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _taskGroupService.getTaskGroups(user.userId);
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(data: final list):
        setState(() {
          _groups = list;
          _loading = false;
          _error = null;
        });
      case ApiFailure(message: final message):
        setState(() {
          _groups = [];
          _loading = false;
          _error = message;
        });
    }
  }

  Future<void> _showCreateDialog() async {
    final user = await _userStorage.getUser();
    if (!mounted) return;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.pleaseLogInAgain)),
      );
      return;
    }

    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.taskGroupsTab),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: AppStrings.taskGroupNameHint,
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              final t = controller.text.trim();
              if (t.isEmpty) return;
              Navigator.pop(ctx, t);
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
    controller.dispose();

    if (name == null || name.isEmpty || !mounted) return;

    setState(() => _creating = true);
    final result = await _taskGroupService.createTaskGroup(
      name: name,
      authorId: user.userId,
    );
    if (!mounted) return;
    setState(() => _creating = false);

    switch (result) {
      case ApiSuccess(data: _):
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.taskGroupCreated)),
        );
        await _load();
        widget.onGroupsChanged();
      case ApiFailure(:final message):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _showEditDialog(TaskGroupModel group) async {
    if (_editingGroupId != null || _deletingGroupId != null) return;
    setState(() => _editingGroupId = group.taskGroupId);

    final user = await _userStorage.getUser();
    if (!mounted || user == null) {
      setState(() => _editingGroupId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.pleaseLogInAgain)),
      );
      return;
    }

    final controller = TextEditingController(text: group.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.taskGroupEdit),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: AppStrings.taskGroupEditNameHint,
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          minLines: 1,
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              final t = controller.text.trim();
              if (t.isEmpty) return;
              Navigator.pop(ctx, t);
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
    controller.dispose();

    if (!mounted) return;
    if (newName == null || newName.isEmpty) {
      setState(() => _editingGroupId = null);
      return;
    }

    final result = await _taskGroupService.updateTaskGroup(
      taskGroupId: group.taskGroupId,
      name: newName,
      userId: user.userId,
    );

    if (!mounted) return;
    setState(() => _editingGroupId = null);

    switch (result) {
      case ApiSuccess(data: _):
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.taskGroupUpdated)),
        );
        await _load();
        widget.onGroupsChanged();
      case ApiFailure(message: final message):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _confirmDelete(TaskGroupModel group) async {
    if (_deletingGroupId != null || _editingGroupId != null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.taskGroupDelete),
        content: Text(AppStrings.taskGroupDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirmed != true) return;

    final user = await _userStorage.getUser();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.pleaseLogInAgain)),
      );
      return;
    }

    setState(() => _deletingGroupId = group.taskGroupId);
    final result = await _taskGroupService.deleteTaskGroup(
      taskGroupId: group.taskGroupId,
      userId: user.userId,
    );
    if (!mounted) return;
    setState(() => _deletingGroupId = null);

    switch (result) {
      case ApiSuccess():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.taskGroupDeleted)),
        );
        await _load();
        widget.onGroupsChanged();
      case ApiFailure(message: final message):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : _error != null
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 48),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              )
            : _groups.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 48),
                  Text(
                    AppStrings.taskGroupsEmpty,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: _groups.length,
                itemBuilder: (context, index) {
                  final g = _groups[index];
                  final isBusy =
                      _editingGroupId == g.taskGroupId ||
                      _deletingGroupId == g.taskGroupId;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    child: ListTile(
                      title: Text(
                        g.name.isNotEmpty ? g.name : g.taskGroupId,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: isDark
                                  ? const Color(0xFFD1D5DB)
                                  : const Color(0xFF475569),
                            ),
                            onPressed: isBusy ? null : () => _showEditDialog(g),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                              color: const Color(0xFFDC2626),
                            ),
                            onPressed: isBusy ? null : () => _confirmDelete(g),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _creating ? null : _showCreateDialog,
        backgroundColor: const Color(0xFF4F46E5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
