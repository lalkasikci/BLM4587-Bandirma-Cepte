import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

AppBar sectionAppBar(
  BuildContext context,
  String title, {
  List<Widget>? actions,
  PreferredSizeWidget? bottom,
}) => AppBar(
  leading: IconButton(
    tooltip: 'Ana sayfaya dön',
    icon: const Icon(Icons.arrow_back_rounded),
    onPressed: () => context.go('/'),
  ),
  title: Text(title),
  backgroundColor: const Color(0xFF123B5D),
  foregroundColor: Colors.white,
  actions: actions,
  bottom: bottom,
);

class AsyncListView<T> extends StatelessWidget {
  final Future<List<T>> future;
  final String emptyMessage;
  final IconData emptyIcon;
  final Widget Function(BuildContext, T) itemBuilder;
  final VoidCallback onRetry;

  const AsyncListView({
    super.key,
    required this.future,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.itemBuilder,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) => FutureBuilder<List<T>>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  size: 48,
                  color: Colors.blueGrey,
                ),
                const SizedBox(height: 12),
                Text(
                  snapshot.error.toString().replaceFirst('Exception: ', ''),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Yeniden Dene'),
                ),
              ],
            ),
          ),
        );
      }
      final items = snapshot.data ?? [];
      if (items.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(emptyIcon, size: 52, color: const Color(0xFF7B929C)),
              const SizedBox(height: 12),
              Text(emptyMessage),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () async => onRetry(),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) => itemBuilder(context, items[index]),
        ),
      );
    },
  );
}
