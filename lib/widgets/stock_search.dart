import 'dart:async';
import 'package:flutter/material.dart';
import '../services/stock_search_service.dart';

/// 회사명(한글/영어)이나 티커로 종목을 검색해 하나 고르는 모달.
/// 선택하면 StockQuote를 반환, 취소하면 null.
Future<StockQuote?> showStockSearch(BuildContext context) {
  return showModalBottomSheet<StockQuote>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: const SizedBox(height: 520, child: _StockSearchBody()),
    ),
  );
}

class _StockSearchBody extends StatefulWidget {
  const _StockSearchBody();
  @override
  State<_StockSearchBody> createState() => _StockSearchBodyState();
}

class _StockSearchBodyState extends State<_StockSearchBody> {
  final _controller = TextEditingController();
  final _service = const StockSearchService();
  Timer? _debounce;
  List<StockQuote> _results = const [];
  bool _loading = false;
  bool _error = false;
  String _lastQuery = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _run(v));
  }

  Future<void> _run(String query) async {
    final q = query.trim();
    _lastQuery = q;
    if (q.isEmpty) {
      setState(() {
        _results = const [];
        _loading = false;
        _error = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final res = await _service.search(q);
      if (!mounted || q != _lastQuery) return; // 오래된 응답 무시
      setState(() {
        _results = res;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('종목 검색',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: _onChanged,
            onSubmitted: _run,
            decoration: InputDecoration(
              hintText: '회사명 또는 티커 (예: 삼성전자, apple, TSLA)',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        _run('');
                      },
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildResults(scheme)),
        ],
      ),
    );
  }

  Widget _buildResults(ColorScheme scheme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('검색 중 문제가 생겼어요. 인터넷 연결을 확인하거나 잠시 후 다시 시도해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant)),
        ),
      );
    }
    if (_controller.text.trim().isEmpty) {
      return Center(
        child: Text('찾을 회사 이름을 입력해보세요.',
            style: TextStyle(color: scheme.onSurfaceVariant)),
      );
    }
    if (_results.isEmpty) {
      final hasHangul = RegExp(r'[가-힣]').hasMatch(_controller.text);
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
              hasHangul
                  ? '한글로 안 나올 때는 영어 이름(예: samsung)이나 종목 코드(예: 005930)로 검색해보세요.'
                  : '검색 결과가 없어요. 다른 이름/티커로 시도해보세요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant)),
        ),
      );
    }
    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final q = _results[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: _StockLogo(quote: q),
          title: Text(q.name, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('${q.symbol}${q.exchange.isNotEmpty ? ' · ${q.exchange}' : ''}',
              style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
          trailing: q.isKorea
              ? const Text('🇰🇷', style: TextStyle(fontSize: 16))
              : const Text('🇺🇸', style: TextStyle(fontSize: 16)),
          onTap: () => Navigator.pop(context, q),
        );
      },
    );
  }
}

/// 로고 이미지(있으면) → 실패 시 티커 배지로 대체.
class _StockLogo extends StatelessWidget {
  final StockQuote quote;
  const _StockLogo({required this.quote});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // 한국 종목은 로고가 거의 없으니 바로 배지로 표시(깜빡임 방지)
    final badge = CircleAvatar(
      radius: 20,
      backgroundColor: scheme.secondaryContainer,
      child: Text(
        quote.baseSymbol.characters.take(3).toString().toUpperCase(),
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w800, color: scheme.onSecondaryContainer),
      ),
    );
    if (quote.isKorea) return badge;
    return ClipOval(
      child: Image.network(
        quote.logoUrl,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => badge,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : badge,
      ),
    );
  }
}
