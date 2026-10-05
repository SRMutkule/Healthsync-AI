import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/insight.dart';
import '../providers/health_provider.dart';
import '../providers/profile_provider.dart';
import '../services/ai_service.dart';
import '../utils/status.dart';
import '../widgets/common.dart';

class AiHealthScreen extends StatelessWidget {
  const AiHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(children: const [
        TabBar(tabs: [
          Tab(icon: Icon(Icons.analytics), text: 'Analysis'),
          Tab(icon: Icon(Icons.lightbulb), text: 'Tips'),
          Tab(icon: Icon(Icons.chat), text: 'Ask'),
        ]),
        Expanded(
          child: TabBarView(children: [
            _AnalysisTab(),
            _RecommendationsTab(),
            _AskTab(),
          ]),
        ),
      ]),
    );
  }
}

class _AnalysisTab extends StatelessWidget {
  const _AnalysisTab();

  @override
  Widget build(BuildContext context) {
    final h = context.watch<HealthProvider>();
    final p = context.watch<ProfileProvider>();
    final List<Insight> items = AiService.analyze(h, p);
    return ListView(padding: const EdgeInsets.all(16), children: [
      for (final i in items)
        Card(
          child: ListTile(
            leading: Icon(
              i.level == Level.good ? Icons.check_circle : Icons.warning_amber_rounded,
              color: levelColor(i.level),
            ),
            title: Text(i.title),
            subtitle: Text(i.detail),
          ),
        ),
      const Disclaimer(),
    ]);
  }
}

class _RecommendationsTab extends StatelessWidget {
  const _RecommendationsTab();

  @override
  Widget build(BuildContext context) {
    final h = context.watch<HealthProvider>();
    final p = context.watch<ProfileProvider>();
    final tips = AiService.recommendations(h, p);
    return ListView(padding: const EdgeInsets.all(16), children: [
      for (final t in tips)
        Card(
          child: ListTile(
            leading: const Icon(Icons.tips_and_updates, color: Colors.amber),
            title: Text(t),
          ),
        ),
      const Disclaimer(),
    ]);
  }
}

class _Msg {
  final String text;
  final bool user;
  _Msg(this.text, this.user);
}

class _AskTab extends StatefulWidget {
  const _AskTab();

  @override
  State<_AskTab> createState() => _AskTabState();
}

class _AskTabState extends State<_AskTab> with AutomaticKeepAliveClientMixin {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [
    _Msg('Hi! Ask me about your heart rate, SpO₂, blood pressure, activity, sleep or diet.', false),
  ];

  @override
  bool get wantKeepAlive => true;

  void _send([String? preset]) {
    final q = (preset ?? _ctrl.text).trim();
    if (q.isEmpty) return;
    final h = context.read<HealthProvider>();
    final p = context.read<ProfileProvider>();
    setState(() {
      _msgs.add(_Msg(q, true));
      _msgs.add(_Msg(AiService.answer(q, h, p), false));
      _ctrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cs = Theme.of(context).colorScheme;
    const suggestions = ['Is my heart rate normal?', 'How is my blood pressure?', 'Tips for better sleep', 'Am I active enough?'];
    return Column(children: [
      SizedBox(
        height: 52,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          children: [
            for (final s in suggestions)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(label: Text(s), onPressed: () => _send(s)),
              ),
          ],
        ),
      ),
      Expanded(
        child: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.all(12),
          itemCount: _msgs.length,
          itemBuilder: (_, i) {
            final m = _msgs[i];
            return Align(
              alignment: m.user ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(12),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                decoration: BoxDecoration(
                  color: m.user ? cs.primaryContainer : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(m.text),
              ),
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: const InputDecoration(hintText: 'Ask a health question…', isDense: true),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(onPressed: _send, icon: const Icon(Icons.send)),
        ]),
      ),
    ]);
  }
}
