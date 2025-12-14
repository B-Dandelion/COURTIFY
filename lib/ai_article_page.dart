import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class AiArticlePage extends StatefulWidget {
  const AiArticlePage({super.key});

  @override
  State<AiArticlePage> createState() => _AiArticlePageState();
}

class _AiArticlePageState extends State<AiArticlePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isLoading = false;

  // ngrok 주소
  static const String _baseUrl =
      'https://interprismatic-moriah-championlike.ngrok-free.dev';

  // 서버 엔드포인트
  static const String _endpoint = '/summarize_input_text';

  // 앱에서 제한할 글자수(원하는 값으로)
  static const int _maxTitleChars = 60;
  static const int _maxNoteChars = 500;

  // 출력 길이(서버 모델이 받는 값)
  static const int _maxNewTokens = 400;

  // 결과 텍스트(기사 렌더링용)
  String _resultText = '';

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _generateDraft() async {
    final title = _titleController.text.trim();
    final note = _noteController.text.trim();

    if (title.isEmpty || note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 핵심 내용을 모두 입력해 주세요.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _resultText = '';
    });

    final uri = Uri.parse('$_baseUrl$_endpoint');
    final inputText = '제목: $title\n\n내용:\n$note';

    try {
      final res = await http
          .post(
        uri,
        headers: const {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'input_text': inputText,
          'max_new_tokens': _maxNewTokens,
        }),
      )
          .timeout(const Duration(seconds: 60));

      final bodyText = utf8.decode(res.bodyBytes);

      if (res.statusCode == 200) {
        final data = jsonDecode(bodyText) as Map<String, dynamic>;
        final summary = (data['summary'] ?? '').toString();

        if (summary.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('생성된 결과가 비어 있습니다.')),
          );
          return;
        }

        setState(() => _resultText = summary);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 오류 [${res.statusCode}] $bodyText')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('기사 생성 중 오류: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 결과를 "문단" 단위로 보기 좋게 쪼개기
  List<String> _splitParagraphs(String text) {
    final cleaned = text.replaceAll('\r\n', '\n').trim();
    if (cleaned.isEmpty) return const [];
    // 빈 줄 기준 문단 분리, 그래도 안 나뉘면 한 줄씩이라도 분리
    final paras = cleaned.split(RegExp(r'\n\s*\n'));
    if (paras.length > 1) {
      return paras.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    final lines = cleaned.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return lines.isNotEmpty ? lines : [cleaned];
  }

  @override
  Widget build(BuildContext context) {
    const mainRed = Color(0xFFb00000);

    final titleChars = _titleController.text.characters.length;
    final noteChars = _noteController.text.characters.length;

    final paragraphs = _splitParagraphs(_resultText);
    final lede = paragraphs.isNotEmpty ? paragraphs.first : '';
    final body = paragraphs.length > 1 ? paragraphs.sublist(1) : const <String>[];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: mainRed,
        title: const Text(
          'AI 기사 쓰기',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 제목 입력
            TextField(
              controller: _titleController,
              maxLength: _maxTitleChars,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              decoration: InputDecoration(
                labelText: '기사 제목',
                border: const OutlineInputBorder(),
                helperText: '$titleChars / $_maxTitleChars 글자',
              ),
            ),
            const SizedBox(height: 12),

            // 메모 입력
            TextField(
              controller: _noteController,
              maxLength: _maxNoteChars,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              maxLines: null,
              minLines: 6,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                labelText: '기사로 만들고 싶은 판결 내용 / 메모',
                border: const OutlineInputBorder(),
                helperText: '$noteChars / $_maxNoteChars 글자',
              ),
            ),
            const SizedBox(height: 12),

            // 생성 버튼
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateDraft,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text(
                  'AI로 기사 초안 생성',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 결과(기사 렌더링)
            _ArticlePreviewCard(
              headline: _titleController.text.trim(),
              lede: lede,
              bodyParagraphs: body,
              isEmpty: _resultText.trim().isEmpty && !_isLoading,
              onCopy: _resultText.trim().isEmpty
                  ? null
                  : () async {
                await Clipboard.setData(ClipboardData(text: _resultText));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('기사 내용을 복사했습니다.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticlePreviewCard extends StatelessWidget {
  final String headline;
  final String lede;
  final List<String> bodyParagraphs;
  final bool isEmpty;
  final VoidCallback? onCopy;

  const _ArticlePreviewCard({
    required this.headline,
    required this.lede,
    required this.bodyParagraphs,
    required this.isEmpty,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final h = headline.isEmpty ? '제목(입력값)' : headline;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isEmpty
            ? const Text(
          '여기에 생성된 기사 초안이 기사 형태로 표시됩니다.',
          style: TextStyle(color: Colors.black54),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              h,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 10),

            if (lede.trim().isNotEmpty)
              Text(
                lede.trim(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),

            if (bodyParagraphs.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),
              ...bodyParagraphs.map(
                    (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    p.trim(),
                    style: const TextStyle(fontSize: 15, height: 1.7),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('복사'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
