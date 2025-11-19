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
      title: 'Courtify',
      theme: ThemeData(
        primaryColor: const Color(0xFFb00000),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFb00000)),
        fontFamily: 'SUIT',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontWeight: FontWeight.w300
          ),
          bodyLarge: TextStyle(
            fontWeight: FontWeight.w700
          )
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      // TODO: 실제 로그인 로직
      // 지금은 그냥 홈 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MyHomePage(title: 'COURTIFY'),
        ),
      );
    }
  }

  void _onSignUp() {
    // TODO: 회원가입 화면 따로 만들면 여기에서 네비게이션
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('회원가입 기능은 추후 추가 예정입니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const mainRed = Color(0xFFb00000);

    return Scaffold(
      backgroundColor: mainRed,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔴 로고 영역 - 여기 나중에 이미지로 교체하면 됨
              Column(
                children: [
                  // TODO: 여기 Image.asset(...)으로 로고 넣으면 됨
                  // 예: Image.asset('assets/courtify_logo.png', height: 80),
                  const Icon(
                    Icons.gavel_rounded,
                    size: 72,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'COURTIFY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 로그인 카드
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '로그인',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 이메일 입력
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: '이메일',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이메일을 입력해 주세요.';
                          }
                          if (!value.contains('@')) {
                            return '올바른 이메일 형식을 입력해 주세요.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // 비밀번호 입력
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: '비밀번호',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '비밀번호를 입력해 주세요.';
                          }
                          if (value.length < 6) {
                            return '비밀번호는 최소 6자 이상이어야 합니다.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // 로그인 버튼
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _onLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainRed,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '로그인',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 회원가입 버튼
                      TextButton(
                        onPressed: _onSignUp,
                        child: const Text(
                          '이메일로 회원가입',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              // 추가 텍스트(선택)
              const Text(
                '법원·판결문 기반 AI 뉴스 서비스',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600
                ),
              ),
            ],
          ),
        ),
      ),
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
