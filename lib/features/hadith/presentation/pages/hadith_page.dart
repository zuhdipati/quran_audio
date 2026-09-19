import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_audio/core/routes/route_paths.dart';
import 'package:quran_audio/core/themes/app_colors.dart';
import 'package:quran_audio/core/utils/arabic_number_utils.dart';
import 'package:quran_audio/core/widgets/entrance.dart';
import 'package:quran_audio/core/widgets/night_scaffold.dart';
import 'package:quran_audio/core/widgets/search_field.dart';
import 'package:quran_audio/core/widgets/state_views.dart';
import 'package:quran_audio/core/widgets/surface_card.dart';
import 'package:quran_audio/features/hadith/domain/entities/hadith_entity.dart';
import 'package:quran_audio/features/hadith/presentation/bloc/hadith_bloc.dart';
import 'package:quran_audio/features/hadith/presentation/widgets/marked_text.dart';
import 'package:quran_audio/features/hadith/presentation/widgets/narrator_bottom_sheet.dart';
import 'package:quran_audio/core/locale/l10n.dart';
import 'package:quran_audio/core/widgets/translation_language_note.dart';

class HadithPage extends StatefulWidget {
  const HadithPage({super.key});

  @override
  State<HadithPage> createState() => _HadithPageState();
}

class _HadithPageState extends State<HadithPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<HadithBloc>();
    if (bloc.state.status == HadithStatus.initial) {
      bloc.add(const HadithsRequested());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toTop() {
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  void _goTo(int page) {
    _toTop();
    context.read<HadithBloc>().add(HadithPageRequested(page));
  }

  Future<void> _pickNarrator(HadithState state) async {
    final chosen = await NarratorBottomSheet.show(
      context,
      collections: state.collections,
      current: state.selected,
    );
    if (chosen == null || !mounted) return;
    context.read<HadithBloc>().add(HadithCollectionSelected(chosen));
    _toTop();
  }

  Future<void> _pickPage(HadithPageEntity page) async {
    final chosen = await showDialog<int>(
      context: context,
      builder: (_) => _PageDialog(current: page.page, last: page.totalPages),
    );
    if (chosen != null && chosen != page.page && mounted) _goTo(chosen);
  }

  @override
  Widget build(BuildContext context) {
    return NightScaffold(
      title: context.l10n.hadithTitle,
      body: BlocBuilder<HadithBloc, HadithState>(
        builder: (context, state) {
          if (state.status == HadithStatus.error && state.collections.isEmpty) {
            return MessageView(
              message: state.message == null
                  ? context.l10n.unableToLoadHadith
                  : context.l10n.errorMessage(state.message!),
              actionLabel: context.l10n.tryAgain,
              onAction: () =>
                  context.read<HadithBloc>().add(const HadithsRequested()),
            );
          }

          final selected = state.selected;
          if (selected == null) return const LoadingView();

          final page = state.page;

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: _Header(
                          state: state,
                          collection: selected,
                          onPickNarrator: () => _pickNarrator(state),
                          onSearchChanged: (query) {
                            _toTop();
                            context.read<HadithBloc>().add(
                              HadithSearchChanged(query),
                            );
                          },
                        ),
                      ),
                    ),
                    ..._content(context, state),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
              if (page != null && page.totalPages > 1)
                _Pager(
                  pageNumber: state.pageNumber,
                  totalPages: page.totalPages,
                  enabled: state.status != HadithStatus.loading,
                  onPage: _goTo,
                  onPick: () => _pickPage(page),
                ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _content(BuildContext context, HadithState state) {
    final page = state.page;

    if (state.status == HadithStatus.error) {
      return [_errorSliver(context, state)];
    }

    if (state.status == HadithStatus.loading || page == null) {
      return const [
        SliverFillRemaining(hasScrollBody: false, child: LoadingView()),
      ];
    }

    if (page.hadiths.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: MessageView(message: context.l10n.noHadithFound),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList.separated(
          itemCount: page.hadiths.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) => StaggeredEntrance(
            index: index,
            child: HadithTile(
              hadith: page.hadiths[index],
              showSource: state.searching && state.searchAll,
            ),
          ),
        ),
      ),
    ];
  }

  Widget _errorSliver(BuildContext context, HadithState state) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: MessageView(
        message: state.message == null
            ? context.l10n.unableToLoadHadith
            : context.l10n.errorMessage(state.message!),
        actionLabel: context.l10n.tryAgain,
        onAction: () => context.read<HadithBloc>().add(
          HadithPageRequested(state.pageNumber),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final HadithState state;
  final HadithCollectionEntity collection;
  final VoidCallback onPickNarrator;
  final ValueChanged<String> onSearchChanged;

  const _Header({
    required this.state,
    required this.collection,
    required this.onPickNarrator,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final summary = _summary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _NarratorSelector(collection: collection, onTap: onPickNarrator),
        const SizedBox(height: 12),
        SearchField(
          hintText: context.l10n.searchHadithHint,
          onChanged: onSearchChanged,
        ),
        const TranslationLanguageNote(
          padding: EdgeInsets.fromLTRB(4, 10, 4, 0),
        ),
        if (state.searching) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ScopeChip(
                label: collection.name,
                selected: !state.searchAll,
                onTap: () => context.read<HadithBloc>().add(
                  const HadithSearchScopeChanged(searchAll: false),
                ),
              ),
              _ScopeChip(
                label: context.l10n.searchScopeAll,
                selected: state.searchAll,
                onTap: () => context.read<HadithBloc>().add(
                  const HadithSearchScopeChanged(searchAll: true),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        if (summary != null) ...[
          Text(
            summary,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  /// "Hadith 41–60 of 7,008", or the result count while searching.
  String? _summary(BuildContext context) {
    final page = state.page;
    if (state.status != HadithStatus.loaded || page == null) return null;

    if (state.searching) {
      return context.l10n.hadithResultCount(
        '${thousands(page.total)}${page.capped ? '+' : ''}',
      );
    }
    if (page.hadiths.isEmpty) return null;
    return context.l10n.hadithRange(
      thousands(page.hadiths.first.number),
      thousands(page.hadiths.last.number),
      thousands(page.total),
    );
  }
}

class _ScopeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ScopeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primarySoft : AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: selected ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _NarratorSelector extends StatelessWidget {
  final HadithCollectionEntity collection;
  final VoidCallback onTap;

  const _NarratorSelector({required this.collection, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.narratorLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  collection.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${context.l10n.hadithCount(thousands(collection.total))} · '
                  '${collection.narrator}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.unfold_more_rounded,
            size: 20,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

/// Previous / next, with the page label opening a jump to any page.
class _Pager extends StatelessWidget {
  final int pageNumber;
  final int totalPages;
  final bool enabled;
  final ValueChanged<int> onPage;
  final VoidCallback onPick;

  const _Pager({
    required this.pageNumber,
    required this.totalPages,
    required this.enabled,
    required this.onPage,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        6,
        12,
        6 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.skyMiddle,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            color: AppColors.primary,
            onPressed: enabled && pageNumber > 1
                ? () => onPage(pageNumber - 1)
                : null,
          ),
          Expanded(
            child: TextButton(
              onPressed: enabled ? onPick : null,
              child: Text(
                context.l10n.pageOf(
                  thousands(pageNumber),
                  thousands(totalPages),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            color: AppColors.primary,
            onPressed: enabled && pageNumber < totalPages
                ? () => onPage(pageNumber + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

class _PageDialog extends StatefulWidget {
  final int current;
  final int last;

  const _PageDialog({required this.current, required this.last});

  @override
  State<_PageDialog> createState() => _PageDialogState();
}

class _PageDialogState extends State<_PageDialog> {
  late final _controller = TextEditingController(text: '${widget.current}');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final page = int.tryParse(_controller.text.trim());
    if (page == null) return;
    Navigator.of(context).pop(page.clamp(1, widget.last));
  }

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);

    return AlertDialog(
      backgroundColor: AppColors.skyMiddle,
      title: Text(context.l10n.goToPage),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textInputAction: TextInputAction.go,
        decoration: InputDecoration(hintText: '1–${widget.last}'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(material.cancelButtonLabel),
        ),
        TextButton(onPressed: _submit, child: Text(material.okButtonLabel)),
      ],
    );
  }
}

class HadithTile extends StatelessWidget {
  final HadithEntity hadith;

  /// Name the collection too, for results that span several.
  final bool showSource;

  const HadithTile({super.key, required this.hadith, this.showSource = false});

  @override
  Widget build(BuildContext context) {
    // only Arbain has titles, so the rest lead with the translation
    final heading = hadith.title;
    final bodyStyle = TextStyle(
      fontSize: heading == null ? 14 : 13,
      height: 1.45,
      color: heading == null ? AppColors.textPrimary : AppColors.textSecondary,
    );
    final snippet = hadith.snippet;

    return SurfaceCard(
      onTap: () => context.push(RoutePaths.hadithDetail, extra: hadith),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              ArabicNumberUtils.convert(hadith.number),
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 16,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showSource && hadith.source != null) ...[
                  Text(
                    hadith.source!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (heading != null) ...[
                  Text(
                    heading,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                if (snippet != null)
                  MarkedText(
                    snippet,
                    maxLines: 4,
                    style: bodyStyle,
                    highlightStyle: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else
                  Text(
                    hadith.translation,
                    maxLines: heading == null ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: bodyStyle,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
