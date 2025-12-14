import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ai_article_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _goToHome();
    } on FirebaseAuthException catch (e) {
      String msg = '로그인에 실패했습니다.';
      if (e.code == 'user-not-found') {
        msg = '가입되지 않은 이메일입니다.';
      } else if (e.code == 'wrong-password') {
        msg = '비밀번호가 올바르지 않습니다.';
      }
      _showError(msg);
    }
  }

  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _goToHome();
    } on FirebaseAuthException catch (e) {
      String msg = '회원가입에 실패했습니다.';
      if (e.code == 'email-already-in-use') {
        msg = '이미 가입된 이메일입니다.';
      }
      _showError(msg);
    }
  }

  Future<void> _signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
      _goToHome();
    } catch (_) {
      _showError('게스트 로그인 중 오류가 발생했습니다.');
    }
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MyHomePage(title: 'COURTIFY'),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const mainRed = Color(0xFFb00000);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 로고 영역 - 여기 나중에 이미지로 교체하면 됨
              Column(
                children: [
                  Image.asset(
                    'Assets/Images/Logo_white.png', // 실제 경로 이름 맞게
                    height: 130,
                  ),
                  // const Icon(
                  //   Icons.gavel_rounded,
                  //   size: 72,
                  //   color: Colors.white,
                  // ),
                  const SizedBox(height: 12),
                  const Text(
                    'COURTIFY',
                    style: TextStyle(
                      color: mainRed,
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
                          onPressed: _signInWithEmail,
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
                        onPressed: _signUpWithEmail,
                        child: const Text(
                          '이메일로 회원가입',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),


                      const Divider(),
                      const SizedBox(height: 8),

                      // 익명 로그인 (게스트 모드)
                      TextButton(
                        onPressed: _signInAnonymously,
                        child: const Text('로그인 없이 둘러보기'),
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
  final List<Map<String, String>> articles = const [
    {
      'title': '헌재, 테러단체 가입 선동 처벌 조항 합헌',
      'summary': '헌법재판소는 테러단체 가입을 선동하는 행위를 처벌하는 규정이 과잉금지원칙에 위배되지 않는다고 판단했다.',
      'date': '2025.10.26',
      'content':
      '헌법재판소는 테러단체 가입을 선동하는 행위를 처벌하도록 한 규정에 대해 합헌 결정을 내렸다. '
          '재판부는 국민의 생명·신체 보호라는 공익이 크고, 선동 행위의 처벌 범위도 일정한 한계 내에서 구성돼 표현의 자유를 과도하게 침해하지 않는다고 봤다.\n\n'
          '쟁점은 “선동”이라는 개념이 지나치게 넓어 광범위한 표현 활동까지 위축시키는지 여부였다. '
          '청구인 측은 인터넷 게시글·집회 발언 등 다양한 형태의 표현이 처벌 위험에 놓일 수 있다고 주장했지만, '
          '재판부는 구성요건이 ‘구체적 가입 유도’라는 방향으로 해석될 수 있고, 수사·재판 단계에서 고의와 목적성 등을 종합해 제한적으로 적용될 여지가 있다고 설명했다.\n\n'
          '결정은 국가안보·공공안전 관련 범죄의 구성요건이 어디까지 허용되는지에 대한 기준을 다시 확인한 것으로 평가된다. '
          '다만 일부 재판관은 표현의 자유 위축 가능성을 지적하며, ‘선동’ 판단 기준을 더 명확히 할 필요가 있다는 취지의 보충의견을 덧붙였다.\n\n'
          '법조계에서는 이번 결정을 계기로 유사 규정의 합헌성 판단에서 “구체적 위험”과 “적용의 엄격성”이 핵심 기준으로 반복될 것으로 보고 있다.',
    },
    {
      'title': '서울고법, 손해배상 청구 일부 인용',
      'summary': '항소심 법원은 계약 불이행으로 인한 손해의 일부를 인정하면서도, 손해액 전부에 대한 입증은 부족하다고 봤다.',
      'date': '2025.10.20',
      'content':
      '서울고등법원은 계약 불이행을 이유로 제기된 손해배상 소송에서 피고의 책임을 일부 인정해 원고에게 일정 금액을 지급하라고 판결했다. '
          '다만 원고가 주장한 손해액 전부를 그대로 인정하기에는 객관적 자료가 부족하다며 일부는 기각했다.\n\n'
          '재판부는 계약서상 의무의 내용과 이행 시기, 이행 지체가 거래 관계에 미친 영향 등을 종합해 피고에게 귀책사유가 있다고 판단했다. '
          '특히 계약 해지 이전에 이미 발생한 채무의 효력은 별도 사정이 없는 한 소멸하지 않는다는 점을 전제로, '
          '손해 발생과 인과관계가 인정되는 범위에서 배상 책임을 인정했다.\n\n'
          '다만 손해액 산정과 관련해 원고가 제시한 산출 근거가 일관되지 않거나, 추정에 기댄 부분이 많다고 봤다. '
          '재판부는 실제 지출 내역·매출 감소 자료·대체 거래 비용 등 객관적 자료를 기준으로 손해액을 제한적으로 산정했다.\n\n'
          '이번 판결은 “책임 인정”과 “손해액 입증”을 분리해 심사한 전형적인 사례로, 항소심에서 손해 산정 기준이 얼마나 촘촘해질 수 있는지를 보여준다.',
    },
    {
      'title': '대법원, 환경오염 피해 손해배상 책임 인정',
      'summary': '대법원은 화학물질 누출로 인한 주민 피해 사건에서 기업의 주의의무 위반과 손해 사이 인과관계를 일부 인정했다.',
      'date': '2025.09.30',
      'content':
      '대법원은 화학물질 누출로 피해를 입었다고 주장한 주민들이 제기한 손해배상 소송에서 기업의 배상 책임을 일부 인정한 원심 판단을 대체로 유지했다. '
          '재판부는 시설 관리·안전 조치 의무를 다하지 못한 사정이 확인되는 만큼, 기업에 상당한 주의의무 위반이 있다고 봤다.\n\n'
          '주요 쟁점은 (1) 누출 사실과 오염 범위가 어느 정도인지, (2) 주민들의 건강 피해가 누출과 상당인과관계가 있는지, (3) 손해액을 어떻게 산정할지였다. '
          '대법원은 과학적 인과관계가 완전히 확정되지 않더라도, 사고 전후 정황과 환경 측정 자료, 의료 기록 등 간접사실을 종합해 인과관계를 인정할 수 있다고 설명했다.\n\n'
          '다만 모든 손해를 전부 인정한 것은 아니다. 재판부는 개별 피해의 정도가 사람마다 다르고, 기존 질환·생활 환경 등 다른 요인의 영향도 배제하기 어렵다며 '
          '개별 주민별로 인정 범위를 달리했다.\n\n'
          '판결은 환경 분쟁에서 “관리 책임”과 “인과관계 입증”의 기준을 정리했다는 점에서 의미가 있다. '
          '기업의 안전 관리 시스템과 사후 대응 체계가 손해배상 책임 판단에 직접 반영될 수 있음을 보여준다.',
    },
    {
      'title': '헌재, 불법촬영물 유포 방조 처벌 규정 합헌',
      'summary': '헌재는 불법촬영물 유포를 돕는 행위를 처벌하는 규정이 성적 자기결정권 보호를 위한 정당한 제한이라고 판단했다.',
      'date': '2025.09.25',
      'content':
      '헌법재판소는 불법촬영물 유포를 방조한 행위를 처벌하도록 한 규정에 대해 합헌 결정을 내렸다. '
          '재판부는 피해 확산 속도와 회복 불가능한 2차 피해를 고려할 때, 방조 행위에 대한 규율도 필요하다고 밝혔다.\n\n'
          '쟁점은 “방조” 개념이 지나치게 넓어 정보 유통·플랫폼 운영 등 일반적 활동까지 형사처벌 위험을 높이는지였다. '
          '헌재는 방조는 단순한 방치가 아니라 범행을 용이하게 하는 실질적 도움을 의미하고, 고의와 구체적 행위 태양을 따져 제한적으로 적용될 수 있다고 설명했다.\n\n'
          '재판부는 표현의 자유나 영업의 자유가 중요하더라도, 디지털 성범죄 피해자의 권리 보호라는 공익이 매우 중대하다고 봤다. '
          '또한 수사기관이 적용을 확대할 우려가 있다면 입법·해석 지침을 통해 기준을 명확히 하는 방식으로 보완할 수 있다고 했다.\n\n'
          '법조계는 이번 결정을 계기로 플랫폼 책임 논의가 “의무의 범위”와 “고의 판단”을 중심으로 더 구체화될 것으로 보고 있다.',
    },
    {
      'title': '부산지법, 부당해고 인정…원직 복직 명령',
      'summary': '법원은 회사가 제시한 해고 사유가 객관적으로 확인되지 않는다며 근로자 복직과 임금 상당액 지급을 명령했다.',
      'date': '2025.09.18',
      'content':
      '부산지방법원은 회사가 근로자를 해고한 처분이 부당하다고 판단하고 원직 복직을 명령했다. '
          '법원은 해고가 정당하려면 징계 사유가 구체적이고 객관적으로 입증돼야 하며, 절차도 적법해야 한다는 원칙을 확인했다.\n\n'
          '사건의 쟁점은 근로자의 업무상 과실이 해고에 이를 정도로 중대한지, 그리고 회사가 징계 절차를 적법하게 거쳤는지였다. '
          '법원은 회사가 제시한 내부 보고서·진술서만으로는 중대한 과실이 인정된다고 보기 어렵고, '
          '사전에 충분한 소명 기회를 제공했는지도 불명확하다고 봤다.\n\n'
          '재판부는 근로관계는 생계와 직결되므로, 해고는 가장 중한 제재인 만큼 엄격한 심사가 필요하다고 설명했다. '
          '결과적으로 법원은 복직과 함께 해고 기간 중 임금 상당액을 지급하라고 판결했다.\n\n'
          '노동 분야에서는 이번 판결을 두고 “사유의 구체화”와 “절차 준수”가 해고 분쟁의 핵심이라는 점을 다시 보여준 사례로 평가한다.',
    },
    {
      'title': '서울중앙지법, 임대차 갱신거절 분쟁에서 임차인 손 들어줘',
      'summary': '법원은 임대인의 갱신 거절 사유가 충분히 소명되지 않았다며 임차인 보호 취지에 맞춰 판단했다.',
      'date': '2025.09.10',
      'content':
      '서울중앙지방법원은 임대인이 임차인의 계약갱신 요구를 거절한 사안에서, 거절 사유가 충분히 입증되지 않았다며 임차인의 주장을 받아들였다. '
          '법원은 주택임대차보호법이 임차인의 주거 안정을 위한 강행규정 성격을 갖는다는 점을 강조했다.\n\n'
          '쟁점은 임대인이 주장한 “정당한 갱신 거절 사유”가 실제로 존재하는지 여부였다. '
          '임대인은 실거주 필요 등을 사유로 들었으나, 법원은 제출된 자료만으로는 거절 사유가 구체적·객관적으로 확인된다고 보기 어렵다고 판단했다.\n\n'
          '재판부는 임대차 분쟁에서 당사자의 주장만으로 결론을 내리기 어렵고, 실제 거주 계획, 가족관계, 기존 주거 상황 등 구체적 사정을 종합해 판단해야 한다고 설명했다. '
          '또한 임차인의 권리 행사가 남용에 이르렀다고 볼 자료도 부족하다고 봤다.\n\n'
          '판결은 임차인 보호 규정의 취지를 다시 확인한 것으로, 향후 갱신 거절 사유 입증의 기준이 보다 엄격해질 수 있다는 전망이 나온다.',
    },
    {
      'title': '대전지법, 의료과실 손해배상 일부 인정',
      'summary': '법원은 의료진의 설명의무·주의의무 위반이 일부 인정된다며 손해배상 책임을 제한적으로 인정했다.',
      'date': '2025.09.05',
      'content':
      '대전지방법원은 수술 과정에서 합병증이 발생한 사건과 관련해 의료진의 과실을 일부 인정하면서도, 원고가 주장한 손해 전부를 받아들이지는 않았다. '
          '재판부는 의료행위의 특성과 당시 의료 환경을 고려해 과실 여부를 구체적으로 심사했다.\n\n'
          '법원은 진료 기록과 감정 결과 등을 토대로 수술 전 설명이 충분했는지, 합병증 발생 가능성을 예견하고 대비했는지 여부를 주요 판단 요소로 삼았다. '
          '그 결과 일부 과정에서 설명의무 또는 주의의무 위반이 인정된다고 봤다.\n\n'
          '다만 합병증의 원인이 전적으로 의료진 과실로 단정되기 어렵고, 환자 측 기왕증·신체 조건 등 다양한 요인이 영향을 미쳤을 가능성도 있다고 판단했다. '
          '이에 따라 손해액은 제한적으로 산정됐다.\n\n'
          '의료소송에서는 “감정 결과의 설득력”과 “기록의 충실성”이 승패를 좌우하는 경우가 많다. '
          '이번 판결도 진료기록과 설명 과정의 객관적 증빙이 얼마나 중요한지 보여주는 사례로 꼽힌다.',
    },
    {
      'title': '인천지법, 불법주차 차량에 과실 책임 인정',
      'summary': '법원은 불법주차가 사고 위험을 높였다고 보고, 사고 발생에 기여한 정도만큼 과실을 인정했다.',
      'date': '2025.08.29',
      'content':
      '인천지방법원은 도로 가장자리에 불법주차된 차량이 시야를 가려 사고가 발생한 사건에서 차량 소유주 측의 과실을 일부 인정했다. '
          '재판부는 불법주차 자체가 곧바로 전적인 책임을 의미하진 않지만, 사고 위험을 높였다면 그 기여도에 따라 과실을 부담할 수 있다고 밝혔다.\n\n'
          '사건에서는 사고 차량의 운전 행태, 제한속도 준수 여부, 보행자 또는 상대방의 주의 의무 이행 여부 등 다양한 요소가 함께 문제 됐다. '
          '법원은 블랙박스 영상과 현장 사진, 사고 재현 자료 등을 종합해 불법주차가 시야 확보를 어렵게 했고 회피 시간을 줄였다고 판단했다.\n\n'
          '다만 사고 운전자 측에도 전방 주시 의무 위반 등 과실이 일부 존재한다고 보아, 책임을 일정 비율로 나누어 판단했다. '
          '결국 배상액은 과실비율에 따라 조정됐다.\n\n'
          '교통사고 분쟁에서 “불법주차 과실”은 자주 다뤄지지만, 법원은 사안마다 사고와의 인과관계 및 위험 기여도를 구체적으로 따져 과실비율을 정한다는 점이 다시 확인됐다.',
    },
  ];
  final mainRed = Color(0xFFb00000);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: mainRed,
        ),
        title: Text(
          'COURTIFY',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: mainRed,
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
    final mainRed = const Color(0xFFb00000);
    // 현재 로그인한 유저 정보
    final user = FirebaseAuth.instance.currentUser;

    // 표시할 이름/이메일(또는 게스트)
    late final String displayName;
    late final String displaySub;

    if (user == null) {
      // 안전빵
      displayName = 'User';
      displaySub = '';
    } else if (user.isAnonymous) {
      displayName = 'Guest';
      displaySub = '게스트';
    } else {
      displayName = user.displayName ?? 'User';
      displaySub = user.email ?? '';
    }

    return Drawer(
      backgroundColor: const Color(0xFFEEF4EE),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // const 빼줘야 함 (runtime 값 사용)
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.account_circle, color: Colors.white, size: 60),
                const SizedBox(height: 10),
                Text(
                  displayName,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  displaySub,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          // 현재로서는 홈 화면으로 되돌아올 일이 없으므로 주석 처리
          // ListTile(
          //   leading: const Icon(Icons.home_outlined),
          //   title: const Text('홈'),
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.bookmark_outline),
          //   title: const Text('저장된 기사'),
          //   onTap: () {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(content: Text('저장된 기사 기능 준비 중입니다.')),
          //     );
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('AI 기사쓰기'),
            onTap: () {
              Navigator.pop(context); // 서랍 닫고
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AiArticlePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('설정'),
            onTap: () {
              Navigator.pop(context); // 서랍 닫고
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_outlined, color: const Color(0xFFb00000)),
            title: const Text('로그아웃', style: TextStyle(color: const Color(0xFFb00000))),
            onTap: () async {
              // Firebase 로그아웃
              await FirebaseAuth.instance.signOut();

              // 로그인 화면으로 돌아가면서 뒤로가기 스택 싹 비우기
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
              );
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

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final User? _user = FirebaseAuth.instance.currentUser;
  late final TextEditingController _nicknameController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nicknameController =
        TextEditingController(text: _user?.displayName ?? '');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _saveNickname() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인한 계정에서만 닉네임을 수정할 수 있습니다.')),
      );
      return;
    }

    final nick = _nicknameController.text.trim();
    if (nick.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임을 입력해 주세요.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await user.updateDisplayName(nick);
      await user.reload();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임이 저장되었습니다.')),
      );
      setState(() {}); // 화면 재빌드용
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임 저장 중 오류가 발생했습니다.')),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _contact() async {
    final uri = Uri.parse(
      'https://forms.gle/6RXicDjabjdmajzbA', // 설문 링크
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('브라우저를 열 수 없습니다.')),
      );
    }
  }


  // Future<void> _contact() async {
  //   final uri = Uri(
  //     scheme: 'mailto',
  //     path: 'jinbabging@gmail.com', // 문의용 이메일 주소
  //     query: Uri.encodeQueryComponent(
  //       'subject = Courtify 문의 &body=앱 버전 / 문의 내용을 적어 주세요.',
  //     ),
  //   );
  //
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('메일 앱을 열 수 없습니다.')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    const mainRed = Color(0xFFb00000);

    final String emailText;
    final String emailSub;

    if (_user == null) {
      emailText = '로그인 정보 없음';
      emailSub = '로그인된 계정이 없습니다.';
    } else if (_user!.isAnonymous) {
      emailText = '게스트';
      emailSub = '게스트 계정은 이메일이 없습니다.';
    } else {
      emailText = _user!.email ?? '이메일 정보 없음';
      emailSub = '로그인한 이메일입니다.';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Colors.black,
        foregroundColor: mainRed,
        iconTheme: const IconThemeData(color: Color(0xFFb00000)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 계정 정보 (읽기 전용)
            Text(
              '계정 정보',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    emailText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    emailSub,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 닉네임 수정
            Text(
              '닉네임',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '앱에서 표시될 이름을 입력하세요',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveNickname,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text(
                  '닉네임 저장',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const Spacer(),

            // 문의하기 버튼
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: _contact,
                icon: const Icon(Icons.mail_outline),
                label: const Text('문의하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

