import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/market_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/ui_kit.dart';

/// 환율 계산기 — 원화와 외국 돈을 서로 바꿔보는 화면.
///
/// 아이가 "1달러가 얼마지?"를 직접 눌러보며 감을 잡게 하는 게 목적이다.
/// 환율은 야후 시세(`{통화}KRW=X`)라 API 키가 필요 없다.
class ExchangeCalculatorScreen extends ConsumerStatefulWidget {
  const ExchangeCalculatorScreen({super.key});

  @override
  ConsumerState<ExchangeCalculatorScreen> createState() =>
      _ExchangeCalculatorScreenState();
}

class _ExchangeCalculatorScreenState
    extends ConsumerState<ExchangeCalculatorScreen> {
  /// 지금 고른 통화 코드
  String _code = 'USD';

  /// 원화 칸과 외화 칸. 한쪽을 고치면 다른 쪽이 따라 바뀐다.
  final _krwController = TextEditingController();
  final _foreignController = TextEditingController();

  /// 되먹임(무한 갱신)을 막는 잠금. 코드로 값을 넣을 때만 true.
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _krwController.addListener(_onKrwChanged);
    _foreignController.addListener(_onForeignChanged);
  }

  @override
  void dispose() {
    _krwController.dispose();
    _foreignController.dispose();
    super.dispose();
  }

  ({String code, String flag, String name, int per}) get _currency =>
      kFxCurrencies.firstWhere((c) => c.code == _code);

  /// 1단위당 원. 아직 못 받아왔으면 null.
  double? get _rate => ref.read(fxRatesProvider).valueOrNull?[_code];

  double _parse(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '').trim()) ?? 0;

  void _onKrwChanged() {
    if (_syncing) return;
    final rate = _rate;
    if (rate == null || rate == 0) return;
    final krw = _parse(_krwController);
    _setText(_foreignController, krw == 0 ? '' : _trim(krw / rate));
  }

  void _onForeignChanged() {
    if (_syncing) return;
    final rate = _rate;
    if (rate == null) return;
    final foreign = _parse(_foreignController);
    _setText(_krwController, foreign == 0 ? '' : _trim(foreign * rate));
  }

  void _setText(TextEditingController c, String text) {
    _syncing = true;
    c.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _syncing = false;
  }

  /// 소수점이 길게 늘어지지 않게 다듬는다. 12.0 -> 12, 12.3456 -> 12.35
  String _trim(double v) {
    if (v.isNaN || v.isInfinite) return '';
    if (v == v.roundToDouble() && v.abs() < 1e12) {
      return v.toInt().toString();
    }
    return v.toStringAsFixed(2);
  }

  /// 통화를 바꾸면 원화 금액을 기준으로 외화를 다시 계산한다.
  void _selectCurrency(String code) {
    setState(() => _code = code);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onKrwChanged());
  }

  @override
  Widget build(BuildContext context) {
    final ratesAsync = ref.watch(fxRatesProvider);
    final palette = appPalette(context);
    final scheme = Theme.of(context).colorScheme;
    final cur = _currency;

    return Scaffold(
      appBar: AppBar(
        title: const Text('환율 계산기'),
        actions: [
          IconButton(
            tooltip: '환율 새로고침',
            onPressed: () => ref.invalidate(fxRatesProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ratesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorBody(onRetry: () => ref.invalidate(fxRatesProvider)),
        data: (rates) {
          final rate = rates[_code];
          if (rates.isEmpty) {
            return _ErrorBody(onRetry: () => ref.invalidate(fxRatesProvider));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppGap.lg,
              AppGap.md,
              AppGap.lg,
              AppGap.xxl,
            ),
            children: [
              // 통화 고르기
              Wrap(
                spacing: AppGap.sm,
                runSpacing: AppGap.sm,
                children: [
                  for (final c in kFxCurrencies)
                    if (rates.containsKey(c.code))
                      _CurrencyChip(
                        label: '${c.flag} ${c.name}',
                        selected: c.code == _code,
                        onTap: () => _selectCurrency(c.code),
                      ),
                ],
              ),
              const SizedBox(height: AppGap.lg),

              // 지금 환율
              if (rate != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppGap.lg),
                  decoration: BoxDecoration(
                    color: palette.savings.bg,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '지금 환율',
                        style: TextStyle(
                          fontSize: AppText.label,
                          color: palette.savings.fg,
                        ),
                      ),
                      const SizedBox(height: AppGap.xs),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${cur.per}${_unit(cur.code)} = ${_krwText(rate * cur.per)}원',
                          style: TextStyle(
                            fontSize: AppText.numMd,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: palette.savings.fg,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppGap.lg),

              // 원 → 외화 / 외화 → 원 (양방향)
              _MoneyField(
                label: '우리 돈',
                suffix: '원',
                controller: _krwController,
                emoji: '🇰🇷',
              ),
              const SizedBox(height: AppGap.sm),
              Center(
                child: Icon(Icons.swap_vert, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppGap.sm),
              _MoneyField(
                label: cur.name,
                suffix: _unit(cur.code),
                controller: _foreignController,
                emoji: cur.flag,
              ),

              const SizedBox(height: AppGap.lg),
              // 빠르게 눌러보는 금액들 — 아이가 감을 잡는 데 이게 제일 빠르다.
              Text(
                '눌러서 바로 계산해보기',
                style: TextStyle(
                  fontSize: AppText.label,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppGap.sm),
              Wrap(
                spacing: AppGap.sm,
                runSpacing: AppGap.sm,
                children: [
                  for (final amount in const [1000, 5000, 10000, 50000, 100000])
                    ActionChip(
                      label: Text(formatWon(amount)),
                      onPressed: () {
                        _setText(_krwController, '$amount');
                        _onKrwChanged();
                      },
                    ),
                ],
              ),

              const SizedBox(height: AppGap.xl),
              _KidNote(pair: palette.allowance, currency: cur, rate: rate),
            ],
          );
        },
      ),
    );
  }

  /// 화면에 붙이는 단위 글자
  String _unit(String code) => switch (code) {
    'USD' => '달러',
    'JPY' => '엔',
    'EUR' => '유로',
    'CNY' => '위안',
    _ => code,
  };

  String _krwText(double v) => NumberFormat('#,##0.##').format(v);
}

class _CurrencyChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CurrencyChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

/// 금액 입력 칸. 숫자만 받고, 소수점은 한 번만 허용한다.
class _MoneyField extends StatelessWidget {
  final String label;
  final String suffix;
  final String emoji;
  final TextEditingController controller;

  const _MoneyField({
    required this.label,
    required this.suffix,
    required this.emoji,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
      ],
      style: const TextStyle(
        fontSize: AppText.numMd,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      decoration: InputDecoration(
        labelText: '$emoji  $label',
        suffixText: suffix,
        hintText: '0',
      ),
    );
  }
}

/// 아이 눈높이 설명. 환율이 실제로 뭘 뜻하는지 한 번 더 짚어준다.
class _KidNote extends StatelessWidget {
  final PastelPair pair;
  final ({String code, String flag, String name, int per}) currency;
  final double? rate;

  const _KidNote({required this.pair, required this.currency, this.rate});

  @override
  Widget build(BuildContext context) {
    final r = rate;
    return Container(
      padding: const EdgeInsets.all(AppGap.lg),
      decoration: BoxDecoration(
        color: pair.bg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: AppText.numSm)),
              const SizedBox(width: AppGap.sm),
              Text(
                '환율은 왜 바뀔까?',
                style: TextStyle(
                  fontSize: AppText.titleLg,
                  fontWeight: FontWeight.w800,
                  color: pair.fg,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppGap.sm),
          Text(
            '환율도 값이에요. 달러를 사려는 사람이 많으면 달러가 비싸지고, '
            '적으면 싸져요. 그래서 매일 조금씩 움직여요.',
            style: TextStyle(
              fontSize: AppText.body,
              height: 1.5,
              color: pair.fg,
            ),
          ),
          if (r != null) ...[
            const SizedBox(height: AppGap.sm),
            Text(
              '지금은 ${currency.per}${_unitOf(currency.code)}를 사려면 '
              '${NumberFormat('#,##0').format(r * currency.per)}원이 필요해요. '
              '환율이 오르면 더 많은 원이 필요하고, 내리면 더 적게 들어요.',
              style: TextStyle(
                fontSize: AppText.body,
                height: 1.5,
                color: pair.fg,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _unitOf(String code) => switch (code) {
    'USD' => '달러',
    'JPY' => '엔',
    'EUR' => '유로',
    'CNY' => '위안',
    _ => code,
  };
}

class _ErrorBody extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorBody({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppGap.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌐', style: TextStyle(fontSize: AppEmoji.md)),
            const SizedBox(height: AppGap.md),
            const Text(
              '환율을 불러오지 못했어요.\n인터넷을 확인하고 다시 시도해 주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppText.body, height: 1.5),
            ),
            const SizedBox(height: AppGap.lg),
            FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }
}
