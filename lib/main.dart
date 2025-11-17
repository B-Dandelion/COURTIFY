import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: const Color(0xFFb00000),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'COURTIFY'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  // 임시 더미 기사 데이터
  final List<Map<String, String>> articles = const [
    {
      'title': '헌재, 테러단체 가입 선동 처벌 조항 합헌 결정',
      'summary': '헌법재판소는 테러방지법상 \'가입선동조항\'이 표현의 자유를 침해하지 않는다고 판시함.',
      'date': '2025.10.26',
      'content':
      '헌법재판소는 테러단체 가입을 선동한 행위를 처벌하는 테러방지법 조항에 대해 합헌 결정을 내렸다. '
          '재판부는 “국민의 생명과 안전을 보호하기 위한 공익이 크며, 표현의 자유를 과도하게 제한하지 않는다”고 밝혔다.'
    },
    {
      'title': '서울고법, 손해배상 청구 일부 인용',
      'summary': '법원은 피고가 계약상 의무를 이행하지 않아 발생한 손해의 일부 배상 책임을 인정함.',
      'date': '2025.10.20',
      'content':
      '서울고등법원은 손해배상 소송에서 피고의 일부 책임을 인정하고 원고에게 1,300만원 지급을 명했다. '
          '법원은 “계약 해지 이전 발생한 채무는 소멸되지 않는다”고 판시했다.'
    },
    {
      'title': '대법원, 환경오염 피해자 손해배상 청구 인용',
      'summary': '대법원은 화학물질 누출로 피해를 입은 주민들에게 기업의 손해배상 책임을 인정함.',
      'date': '2025.09.30',
      'content':
      '대법원은 화학물질 누출로 인한 피해 사건에서 “기업은 환경보호 의무를 다하지 않아 피해가 발생한 만큼 손해배상 책임이 있다”고 판시했다.'
    },
    {
      'title': '헌재, 불법촬영물 유포 방조죄 첫 합헌 결정',
      'summary': '헌법재판소는 불법촬영물 방조 행위를 처벌하는 조항이 헌법에 위배되지 않는다고 결정함.',
      'date': '2025.09.25',
      'content':
      '헌법재판소는 불법촬영물 방조죄에 대해 “표현의 자유보다 성적 자기결정권 보호의 공익이 크다”며 합헌 결정을 내렸다.'
    },
    {
      'title': '부산지법, 근로자 부당해고 판결…복직 명령',
      'summary': '법원은 해고 사유가 정당하지 않다며 근로자의 복직을 명령함.',
      'date': '2025.09.18',
      'content':
      '부산지방법원은 A기업이 직원 B씨를 정당한 사유 없이 해고했다며, 원직 복직 및 해고 기간 임금 지급을 명령했다.'
    },
    {
      'title': '서울중앙지법, 주택임대차보호법 관련 첫 판결',
      'summary': '임차인 보호 강화 조항 위반에 대한 첫 법원 판단이 내려짐.',
      'date': '2025.09.10',
      'content':
      '서울중앙지방법원은 임대인이 계약 갱신 요구를 부당하게 거절한 사건에서 “임차인의 권리를 침해했다”고 판시했다.'
    },
    {
      'title': '대전지법, 의료과실 손해배상 일부 인정',
      'summary': '법원은 의료진의 일부 과실을 인정하되, 원고 청구액 전부는 받아들이지 않음.',
      'date': '2025.09.05',
      'content':
      '대전지방법원은 수술 중 합병증으로 인한 손해배상 소송에서 “의료진의 일부 주의의무 위반이 인정된다”며 일부 배상만 명했다.'
    },
    {
      'title': '인천지법, 불법주차 사고 배상 책임 판결',
      'summary': '법원은 불법주차 차량이 사고 발생의 원인이 되었다고 판단함.',
      'date': '2025.08.29',
      'content':
      '인천지방법원은 불법주차 차량이 보행자 사고를 유발한 사건에서 차량 소유주에게 70%의 과실 책임을 인정했다.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFb00000),
        title: const Text(
          'COURTIFY',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 1.0,
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(
                article['title']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                '${article['summary']!}\n${article['date']}',
                style: const TextStyle(height: 1.5),
              ),
              isThreeLine: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewsDetailPage(article: article),
                  ),
                );
              },
            ),
          );
        }
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFEEF4EE),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: const Color(0xFFb00000),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.account_circle, color: Colors.white, size: 60),
                SizedBox(height: 10),
                Text(
                  'User',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  'law-ai@cortify.app',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('홈'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_outline),
            title: const Text('저장된 기사'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('저장된 기사 기능 준비 중입니다.')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('AI 기사쓰기'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('저장된 기사 기능 준비 중입니다.')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('설정'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('설정 페이지는 추후 추가 예정입니다.')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_outlined, color: Colors.red),
            title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class NewsDetailPage extends StatelessWidget {
  final Map<String, String> article;
  const NewsDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFb00000),
        title: Text(article['title']!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Text(
            article['content']!,
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
        ),
      ),
    );
  }
}
