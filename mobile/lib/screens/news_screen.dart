import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/municipal_news.dart';
import '../models/news.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/section_app_bar.dart';
import 'news_detail_screen.dart';

class NewsScreen extends StatelessWidget {
  final AuthService authService;
  const NewsScreen({super.key, required this.authService});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF2F7F6),
    appBar: sectionAppBar(
      context,
      'Haberler',
      actions: [
        if (!authService.isLoggedIn)
          IconButton(
            tooltip: 'Yönetici girişi',
            onPressed: () => context.push('/login'),
            icon: const Icon(Icons.login_rounded),
          ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
      children: [
        const _MunicipalNewsTab(),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Divider(height: 1),
        ),
        _ManagedNewsTab(authService: authService),
      ],
    ),
  );
}

class _MunicipalNewsTab extends StatefulWidget {
  const _MunicipalNewsTab();

  @override
  State<_MunicipalNewsTab> createState() => _MunicipalNewsTabState();
}

class _MunicipalNewsTabState extends State<_MunicipalNewsTab> {
  final _api = ApiService();
  late Future<List<MunicipalNews>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getMunicipalNews();
  }

  void _refresh() {
    setState(() {
      _future = _api.getMunicipalNews();
    });
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<MunicipalNews>>(
    future: _future,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return _NewsErrorView(
          message: snapshot.error.toString(),
          onRetry: _refresh,
        );
      }
      final items = snapshot.data ?? [];
      if (items.isEmpty) {
        return _EmptyNewsView(
          icon: Icons.newspaper_outlined,
          message: 'Belediye sitesinde şu anda haber bulunamadı.',
          onRefresh: _refresh,
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _NewsSectionHeading(
            title: 'Bandırma Belediyesi’nden',
            subtitle: 'Belediye sitesinden güncel olarak alınan haberler',
            icon: Icons.rss_feed_rounded,
            onRefresh: _refresh,
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MunicipalNewsCard(item: item),
            ),
          ),
        ],
      );
    },
  );
}

class _ManagedNewsTab extends StatefulWidget {
  final AuthService authService;
  const _ManagedNewsTab({required this.authService});

  @override
  State<_ManagedNewsTab> createState() => _ManagedNewsTabState();
}

class _ManagedNewsTabState extends State<_ManagedNewsTab> {
  final _api = ApiService();
  late Future<List<News>> _future;

  bool get _isAdmin => widget.authService.isAdmin;

  @override
  void initState() {
    super.initState();
    _future = _api.getNews(includeUnpublished: _isAdmin);
  }

  void _refresh() {
    setState(() {
      _future = _api.getNews(includeUnpublished: _isAdmin);
    });
  }

  Future<void> _editNews({News? news}) async {
    if (!_isAdmin) return;
    final saved = await showDialog<bool>(
      context: context,
      builder:
          (_) => _NewsFormDialog(authService: widget.authService, news: news),
    );
    if (saved == true && mounted) {
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(news == null ? 'Haber eklendi.' : 'Haber güncellendi.'),
        ),
      );
    }
  }

  Future<void> _deleteNews(News news) async {
    if (!_isAdmin) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Haberi sil'),
            content: Text('“${news.title}” haberini silmek istiyor musun?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Vazgeç'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sil'),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final token = widget.authService.current?.token;
      if (token == null) throw Exception('Yeniden giriş yapman gerekiyor.');
      await _api.deleteNews(news.id, token: token);
      if (!mounted) return;
      _refresh();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Haber silindi.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<News>>(
    future: _future,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return _NewsErrorView(
          message: snapshot.error.toString(),
          onRetry: _refresh,
        );
      }

      final items = snapshot.data ?? [];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _NewsSectionHeading(
            title: 'Uygulama veritabanındaki haberler',
            subtitle: 'Yönetilen ve yayınlanan haber kayıtları',
            icon: Icons.storage_rounded,
            onRefresh: _refresh,
            trailing:
                _isAdmin
                    ? FilledButton.icon(
                      onPressed: () => _editNews(),
                      icon: const Icon(Icons.add),
                      label: const Text('Haber ekle'),
                    )
                    : null,
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: _EmptyNewsView(
                icon: Icons.storage_outlined,
                message:
                    _isAdmin
                        ? 'Veritabanında henüz yönetilen haber yok.'
                        : 'Henüz yayınlanmış haber yok.',
                onRefresh: _refresh,
              ),
            )
          else
            ...items.map(
              (news) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ManagedNewsCard(
                  news: news,
                  isAdmin: _isAdmin,
                  onEdit: () => _editNews(news: news),
                  onDelete: () => _deleteNews(news),
                ),
              ),
            ),
        ],
      );
    },
  );
}

class _NewsSectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onRefresh;
  final Widget? trailing;

  const _NewsSectionHeading({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onRefresh,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: const Color(0xFF147D9A)),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Color(0xFF536B77)),
            ),
          ],
        ),
      ),
      if (trailing != null) trailing!,
      IconButton(
        tooltip: 'Yenile',
        onPressed: onRefresh,
        icon: const Icon(Icons.refresh_rounded),
      ),
    ],
  );
}

class _MunicipalNewsCard extends StatelessWidget {
  final MunicipalNews item;
  const _MunicipalNewsCard({required this.item});

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap:
          () => showDialog<void>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text(item.title),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.source,
                          style: const TextStyle(
                            color: Color(0xFF147D9A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (item.summary?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 12),
                          Text(item.summary!),
                        ],
                        if (item.url.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const Text(
                            'Haber bağlantısı',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          SelectableText(item.url),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    if (item.url.isNotEmpty)
                      TextButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: item.url),
                          );
                          if (context.mounted) Navigator.pop(context);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Haber bağlantısı kopyalandı.'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('Bağlantıyı kopyala'),
                      ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Kapat'),
                    ),
                  ],
                ),
          ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.rss_feed_rounded,
                  size: 17,
                  color: Color(0xFF147D9A),
                ),
                const SizedBox(width: 6),
                Text(
                  item.source,
                  style: const TextStyle(
                    color: Color(0xFF147D9A),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const Text(
                  'Güncel',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              item.title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Color(0xFF18364B),
              ),
            ),
            if (item.summary?.isNotEmpty ?? false) ...[
              const SizedBox(height: 7),
              Text(
                item.summary!,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(height: 1.4, color: Color(0xFF536B77)),
              ),
            ],
            const SizedBox(height: 9),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Özeti görüntüle  ›',
                style: TextStyle(
                  color: Color(0xFF147D9A),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ManagedNewsCard extends StatelessWidget {
  final News news;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ManagedNewsCard({
    required this.news,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat(
      'dd MMM yyyy, HH:mm',
      'tr',
    ).format(news.publishedAt.toLocal());
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap:
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => NewsDetailScreen(newsId: news.id),
              ),
            ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.storage_rounded,
                    size: 16,
                    color: Color(0xFF147D9A),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      news.source ?? 'Yönetilen haber',
                      style: const TextStyle(
                        color: Color(0xFF147D9A),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (!news.isPublished)
                    const Chip(
                      label: Text('Taslak'),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                news.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Color(0xFF18364B),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                news.content,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(height: 1.4, color: Color(0xFF536B77)),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 14, color: Colors.blueGrey),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      date,
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  if (isAdmin) ...[
                    IconButton(
                      tooltip: 'Düzenle',
                      onPressed: onEdit,
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF176B88),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Sil',
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                    ),
                  ] else
                    const Text(
                      'Haberi oku  ›',
                      style: TextStyle(
                        color: Color(0xFF147D9A),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsFormDialog extends StatefulWidget {
  final AuthService authService;
  final News? news;
  const _NewsFormDialog({required this.authService, this.news});

  @override
  State<_NewsFormDialog> createState() => _NewsFormDialogState();
}

class _NewsFormDialogState extends State<_NewsFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _sourceController = TextEditingController();
  final _api = ApiService();
  bool _isPublished = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final news = widget.news;
    _titleController.text = news?.title ?? '';
    _contentController.text = news?.content ?? '';
    _sourceController.text = news?.source ?? 'Yönetici Paneli';
    _isPublished = news?.isPublished ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final token = widget.authService.current?.token;
    if (token == null || !widget.authService.isAdmin) {
      setState(() => _error = 'Bu işlem için yönetici girişi gerekiyor.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final item = News(
      id: widget.news?.id ?? 0,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      publishedAt: widget.news?.publishedAt ?? DateTime.now(),
      source:
          _sourceController.text.trim().isEmpty
              ? 'Yönetici Paneli'
              : _sourceController.text.trim(),
      isPublished: _isPublished,
    );
    try {
      if (widget.news == null) {
        await _api.createNews(item, token: token);
      } else {
        await _api.updateNews(item, token: token);
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.news == null ? 'Haber ekle' : 'Haberi düzenle'),
    content: SizedBox(
      width: 480,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                maxLength: 200,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'Başlık zorunludur.';
                  }
                  if (text.length > 200) {
                    return 'Başlık en fazla 200 karakter olabilir.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentController,
                minLines: 4,
                maxLines: 8,
                maxLength: 5000,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'İçerik',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'Haber içeriği zorunludur.';
                  }
                  if (text.length > 5000) {
                    return 'İçerik en fazla 5000 karakter olabilir.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sourceController,
                maxLength: 150,
                decoration: const InputDecoration(
                  labelText: 'Kaynak (isteğe bağlı)',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        (value?.trim().length ?? 0) > 150
                            ? 'Kaynak en fazla 150 karakter olabilir.'
                            : null,
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Yayında'),
                subtitle: Text(
                  _isPublished
                      ? 'Haber okuyuculara görünür.'
                      : 'Haber taslak olarak saklanır.',
                ),
                value: _isPublished,
                onChanged:
                    _saving
                        ? null
                        : (value) => setState(() => _isPublished = value),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context, false),
        child: const Text('Vazgeç'),
      ),
      FilledButton.icon(
        onPressed: _saving ? null : _save,
        icon:
            _saving
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(Icons.save_outlined),
        label: Text(_saving ? 'Kaydediliyor' : 'Kaydet'),
      ),
    ],
  );
}

class _EmptyNewsView extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback onRefresh;
  const _EmptyNewsView({
    required this.icon,
    required this.message,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 52, color: const Color(0xFF7B929C)),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
          label: const Text('Yenile'),
        ),
      ],
    ),
  );
}

class _NewsErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _NewsErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.blueGrey),
          const SizedBox(height: 12),
          const Text(
            'Haber servisine ulaşılamadı.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            message.replaceFirst('Exception: ', ''),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Yeniden dene'),
          ),
        ],
      ),
    ),
  );
}
