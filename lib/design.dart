import 'package:flutter/material.dart';

const brand = Color(0xff6941c6);
const darkInk = Color(0xff302747);
const mint = Color(0xffdaf3e8);
const peach = Color(0xffffe4d5);
const lavender = Color(0xffeee5ff);

ThemeData sinalizaTheme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xfffaf8f5),
  colorScheme: ColorScheme.fromSeed(seedColor: brand, surface: Colors.white),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(color: darkInk, fontWeight: FontWeight.w800, letterSpacing: -1, height: 1.2),
    bodyMedium: TextStyle(color: darkInk, fontSize: 15, height: 1.5),
    bodyLarge: TextStyle(color: darkInk, height: 1.5),
  ),
  filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
    backgroundColor: brand, foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 23),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  )),
  outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
    foregroundColor: darkInk, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
    side: const BorderSide(color: Color(0xffded5ec)),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  )),
  cardTheme: CardThemeData(color: Colors.white, elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Color(0xffeee8f1)))),
  progressIndicatorTheme: const ProgressIndicatorThemeData(color: brand, linearTrackColor: lavender),
);

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Scaffold(body: Stack(children: [
    const Positioned(top: -150, right: -100, child: _Blob(color: Color(0xffeee5fa), size: 500)),
    const Positioned(bottom: -220, left: -160, child: _Blob(color: Color(0xffe2f2e9), size: 480)),
    SafeArea(child: Column(children: [
      Container(
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .82), border: const Border(bottom: BorderSide(color: Color(0xffeee8f1)))),
        child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1160), child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Row(children: [
            if (Navigator.of(context).canPop()) ...[IconButton(tooltip: 'Voltar', onPressed: () => Navigator.of(context).maybePop(), icon: const Icon(Icons.arrow_back_rounded)), const SizedBox(width: 8)],
            Container(width: 42, height: 42, decoration: BoxDecoration(color: brand, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.waving_hand_rounded, color: Colors.white, size: 25)),
            const SizedBox(width: 12),
            const Text('sinaliza', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, letterSpacing: -1, color: darkInk)),
            const Spacer(),
            if (MediaQuery.sizeOf(context).width > 520) const Text('Pequenos gestos. Novas conexões.', style: TextStyle(color: Color(0xff716780), fontSize: 13)),
            const SizedBox(width: 16),
            const Pill(label: 'LIBRAS', color: lavender),
          ]),
        ))),
      ),
      Expanded(child: SingleChildScrollView(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1160),
        child: Padding(padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 20 : 36), child: Column(children: [
          child,
          const SizedBox(height: 42),
          const Divider(color: Color(0xffe7dfeb)),
          const SizedBox(height: 16),
          const Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, spacing: 8, children: [
            Icon(Icons.favorite_rounded, color: Color(0xffc16984), size: 15),
            Text('Aprender também é uma forma de se conectar.', style: TextStyle(fontSize: 12, color: Color(0xff786e86))),
          ]),
        ])),
      )))),
    ])),
  ]));
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});
  @override
  Widget build(BuildContext context) => IgnorePointer(child: Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle)));
}

class Pill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const Pill({super.key, required this.label, this.color = lavender, this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(30)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon, size: 16, color: darkInk), const SizedBox(width: 7)],
      Flexible(child: Text(label, style: const TextStyle(color: darkInk, fontSize: 12, fontWeight: FontWeight.w700))),
    ]),
  );
}

class WelcomePanel extends StatelessWidget {
  final VoidCallback onStart, onHistory;
  const WelcomePanel({super.key, required this.onStart, required this.onHistory});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    LayoutBuilder(builder: (context, box) {
      final intro = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Pill(label: 'UM NOVO JEITO DE SE CONECTAR', color: mint, icon: Icons.auto_awesome_rounded),
        const SizedBox(height: 24),
        Text.rich(const TextSpan(children: [TextSpan(text: 'Grandes conexões.\n'), TextSpan(text: 'Um sinal ', style: TextStyle(color: brand)), TextSpan(text: 'de\ncada vez.')]), style: TextStyle(fontSize: box.maxWidth < 600 ? 39 : 52, fontWeight: FontWeight.w900, height: 1.08, letterSpacing: -2, color: darkInk)),
        const SizedBox(height: 22),
        const Text('Descubra a beleza da Libras com pequenos treinos.\nObserve, experimente e aprenda no seu ritmo.', style: TextStyle(fontSize: 17, color: Color(0xff73677f), height: 1.7)),
        const SizedBox(height: 28),
        Wrap(spacing: 12, runSpacing: 12, children: [
          FilledButton.icon(onPressed: onStart, icon: const Icon(Icons.arrow_forward_rounded, size: 20), label: const Text('Vamos praticar')),
          OutlinedButton.icon(onPressed: onHistory, icon: const Icon(Icons.insights_rounded, size: 20), label: const Text('Meu desempenho')),
        ]),
        const SizedBox(height: 20),
        const Row(children: [Icon(Icons.check_circle_rounded, size: 16, color: Color(0xff397e64)), SizedBox(width: 7), Flexible(child: Text('Sem pressa, sem cronômetro. Só aprendizado.', style: TextStyle(fontSize: 12, color: Color(0xff73677f))))]),
      ]);
      if (box.maxWidth < 820) return Column(children: [intro, const SizedBox(height: 30), const SizedBox(height: 300, child: ConnectionArt())]);
      return Row(children: [Expanded(flex: 6, child: intro), const SizedBox(width: 32), const Expanded(flex: 5, child: SizedBox(height: 390, child: ConnectionArt()))]);
    }),
    const SizedBox(height: 38),
    Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: darkInk, borderRadius: BorderRadius.circular(24)), child: Wrap(spacing: 28, runSpacing: 20, crossAxisAlignment: WrapCrossAlignment.center, children: [
      const Icon(Icons.bolt_rounded, color: Color(0xffffcc83), size: 36),
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Seu treino de hoje', style: TextStyle(fontSize: 21, color: Colors.white, fontWeight: FontWeight.w700)), SizedBox(height: 4), Text('Um pequeno passo que faz diferença.', style: TextStyle(color: Color(0xffd4cbe3), fontSize: 13))]),
      const Pill(label: '5 sinais do cotidiano', color: Color(0xffffe4b9), icon: Icons.sign_language_rounded),
      const Pill(label: '3 opções por sinal', color: mint, icon: Icons.touch_app_rounded),
      const Pill(label: 'No seu ritmo', color: lavender, icon: Icons.spa_rounded),
    ])),
    const SizedBox(height: 36),
    const Text('Aprender pode ser leve.', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -.7)),
    const SizedBox(height: 6),
    const Text('Três passos para começar a reconhecer novos sinais.', style: TextStyle(color: Color(0xff786e86))),
    const SizedBox(height: 20),
    LayoutBuilder(builder: (context, box) {
      final width = box.maxWidth < 650 ? box.maxWidth : (box.maxWidth - 32) / 3;
      return Wrap(spacing: 16, runSpacing: 16, children: [
        SizedBox(width: width, child: const StepCard(number: '01', title: 'Olhe com atenção', text: 'Assista ao vídeo e perceba os movimentos e as expressões.', icon: Icons.play_circle_outline_rounded, color: lavender)),
        SizedBox(width: width, child: const StepCard(number: '02', title: 'Confie na sua escolha', text: 'Escolha o significado. Errar também faz parte de aprender.', icon: Icons.touch_app_outlined, color: peach)),
        SizedBox(width: width, child: const StepCard(number: '03', title: 'Celebre cada avanço', text: 'Veja seus acertos e descubra quais sinais vale revisar.', icon: Icons.auto_awesome_rounded, color: mint)),
      ]);
    }),
    const SizedBox(height: 26),
    const Text('Vídeos: Dicionário de Libras do INES / Acessibilidade Brasil.\nEste treino de reconhecimento não substitui um curso de Libras.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, height: 1.7, color: Color(0xff786e86))),
  ]);
}

/// Composição decorativa. Os sinais didáticos continuam nos vídeos do INES.
class ConnectionArt extends StatelessWidget {
  const ConnectionArt({super.key});
  @override
  Widget build(BuildContext context) => ExcludeSemantics(child: LayoutBuilder(builder: (context, box) => Stack(alignment: Alignment.center, children: [
    Container(width: 310, height: 310, decoration: const BoxDecoration(color: Color(0xffe7dcf9), shape: BoxShape.circle)),
    Transform.rotate(angle: -.13, child: Container(width: 220, height: 235, decoration: BoxDecoration(color: brand, borderRadius: BorderRadius.circular(65), boxShadow: [BoxShadow(color: brand.withValues(alpha: .2), blurRadius: 32, offset: const Offset(0, 18))]), child: const Center(child: Icon(Icons.waving_hand_rounded, size: 120, color: Color(0xffffd798))))),
    Positioned(top: 12, right: 6, child: Transform.rotate(angle: .10, child: const _ArtNote(text: 'Olá, novas conexões!', icon: Icons.chat_bubble_rounded, color: mint))),
    Positioned(bottom: 10, left: 2, child: Transform.rotate(angle: -.06, child: const _ArtNote(text: 'Todo gesto importa.', icon: Icons.favorite_rounded, color: peach))),
    const Positioned(top: 50, left: 10, child: Icon(Icons.auto_awesome, size: 42, color: Color(0xffde9c46))),
    const Positioned(bottom: 58, right: 10, child: Icon(Icons.star_rounded, size: 46, color: Color(0xffa18acb))),
    Positioned(top: box.maxHeight * .6, left: 12, child: Container(width: 17, height: 17, decoration: const BoxDecoration(color: Color(0xff97c9b5), shape: BoxShape.circle))),
  ])));
}
class _ArtNote extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  const _ArtNote({required this.text, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: color, border: Border.all(color: Colors.white, width: 3), borderRadius: BorderRadius.circular(19)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 21, color: darkInk), const SizedBox(width: 10), Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))]));
}

class StepCard extends StatelessWidget {
  final String number, title, text;
  final IconData icon;
  final Color color;
  const StepCard({super.key, required this.number, required this.title, required this.text, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(23), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .7), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: darkInk, size: 25)), const Spacer(), Text(number, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: darkInk.withValues(alpha: .25)))]),
    const SizedBox(height: 18), Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)), const SizedBox(height: 8), Text(text, style: const TextStyle(fontSize: 14, color: Color(0xff665b73), height: 1.6)),
  ]));
}

class ExerciseStage extends StatelessWidget {
  final Widget video, choices;
  const ExerciseStage({super.key, required this.video, required this.choices});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
    final visual = Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: lavender, borderRadius: BorderRadius.circular(28)), child: Column(children: [
      const Row(children: [Pill(label: 'OBSERVE O SINAL', color: Colors.white, icon: Icons.visibility_outlined), Spacer(), Icon(Icons.auto_awesome_rounded, color: brand, size: 22)]),
      const SizedBox(height: 16), ClipRRect(borderRadius: BorderRadius.circular(20), child: AspectRatio(aspectRatio: 4 / 3, child: video)),
      const SizedBox(height: 14), const Text('Pode dar play de novo. Aqui, quem dita o ritmo é você.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xff665b73))),
      const SizedBox(height: 8), const Text('Vídeo: INES / Acessibilidade Brasil', style: TextStyle(fontSize: 11, color: Color(0xff665b73))),
    ]));
    if (box.maxWidth < 780) return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [visual, const SizedBox(height: 24), choices]);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 6, child: visual), const SizedBox(width: 28), Expanded(flex: 5, child: choices)]);
  });
}

class AnswerTile extends StatelessWidget {
  final int index;
  final String label;
  final bool selected, confirmed, correct;
  final VoidCallback onTap;
  const AnswerTile({super.key, required this.index, required this.label, required this.selected, required this.confirmed, required this.correct, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final success = confirmed && correct;
    final wrong = confirmed && selected && !correct;
    final color = success ? const Color(0xff327858) : wrong ? const Color(0xffa13e56) : brand;
    final active = selected || success;
    return Semantics(selected: selected, child: AnimatedContainer(
      duration: const Duration(milliseconds: 180), margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: success ? mint : wrong ? const Color(0xffffe6e9) : selected ? lavender : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: active ? color : const Color(0xffe6dfec), width: active ? 2 : 1)),
      child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(20), onTap: confirmed ? null : onTap, child: Padding(padding: const EdgeInsets.all(17), child: Row(children: [
        Container(width: 38, height: 38, alignment: Alignment.center, decoration: BoxDecoration(color: active ? color : const Color(0xfff3eff8), borderRadius: BorderRadius.circular(12)), child: Text(String.fromCharCode(65 + index), style: TextStyle(fontWeight: FontWeight.w800, color: active ? Colors.white : brand))),
        const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)), if (success || wrong) Text(success ? 'Resposta correta' : 'Sua escolha', style: TextStyle(fontSize: 12, color: color))])),
        if (active) Icon(success ? Icons.check_circle_rounded : wrong ? Icons.cancel_rounded : Icons.radio_button_checked_rounded, color: color, size: 22),
      ])))),
    ));
  }
}

class ResultCelebration extends StatelessWidget {
  final int score, total;
  const ResultCelebration({super.key, required this.score, required this.total});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(30), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xff7045c3), Color(0xff493178)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(30)),
    child: Column(children: [
      const Pill(label: 'MAIS UM PASSO NA SUA JORNADA', color: Color(0xffffdfae), icon: Icons.auto_awesome),
      const SizedBox(height: 26),
      TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: score / total), duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 800), builder: (context, value, child) => SizedBox(width: 156, height: 156, child: Stack(alignment: Alignment.center, children: [
        SizedBox.expand(child: CircularProgressIndicator(value: value, strokeWidth: 9, backgroundColor: Colors.white.withValues(alpha: .18), color: const Color(0xffffd58d), strokeCap: StrokeCap.round)),
        Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.emoji_events_rounded, color: Color(0xffffd58d), size: 34), Text('$score/$total', style: const TextStyle(fontSize: 39, fontWeight: FontWeight.w900, color: Colors.white)), const Text('acertos', style: TextStyle(color: Color(0xffe4d8f5)))]),
      ]))),
      const SizedBox(height: 24), const Text('Treino concluído!', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w800, color: Colors.white)),
      const SizedBox(height: 8), Text(score == total ? 'Você reconheceu todos os sinais. Que conquista!' : 'Cada tentativa é uma oportunidade de aprender.', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xffece3fa), fontSize: 15)),
    ]),
  );
}

class HistorySummary extends StatelessWidget {
  final int count, hits, total;
  const HistorySummary({super.key, required this.count, required this.hits, required this.total});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
    final width = box.maxWidth < 600 ? box.maxWidth : (box.maxWidth - 24) / 3;
    return Wrap(spacing: 12, runSpacing: 12, children: [
      for (final item in [('$count', 'treinos registrados', lavender, Icons.school_outlined), ('$hits', 'sinais reconhecidos', mint, Icons.check_circle_outline), ('${total == 0 ? 0 : (hits / total * 100).round()}%', 'de acertos nesses treinos', peach, Icons.trending_up_rounded)])
        SizedBox(width: width, child: Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: item.$3, borderRadius: BorderRadius.circular(22)), child: Row(children: [Icon(item.$4, size: 30, color: darkInk), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.$1, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)), Text(item.$2, style: const TextStyle(fontSize: 12))]))]))),
    ]);
  });
}
