import 'dart:math';
import 'mystic_deck.dart';

/// 📦 Card Factory — 대규모 카드뭉치 생성 + LLM 업데이트
class CardFactory {
  static final CardFactory _i = CardFactory._();
  factory CardFactory() => _i;
  CardFactory._();

  // ─── 대규모 내장 덱 ────────────────────────────

  /// 영어단어 200+장
  static const english = [
    'abandon 버리다','ability 능력','abroad 해외로','absence 부재','absolute 절대적인',
    'absorb 흡수하다','abstract 추상적인','abundant 풍부한','academy 학원','accelerate 가속하다',
    'accept 받아들이다','access 접근','accompany 동반하다','accomplish 성취하다','account 계좌',
    'accurate 정확한','achieve 달성하다','acknowledge 인정하다','acquire 습득하다','adapt 적응하다',
    'adequate 충분한','adjust 조정하다','admire 감탄하다','admit 인정하다','adopt 채택하다',
    'advance 전진하다','advantage 이점','advertise 광고하다','affair 사건','afford 여유가있다',
    'aggressive 공격적인','agreement 동의','agriculture 농업','alarm 경보','alive 살아있는',
    'allocate 할당하다','allow 허락하다','ally 동맹','alter 바꾸다','alternative 대안',
    'amaze 놀라게하다','ambition 야망','analyze 분석하다','ancestor 조상','ancient 고대의',
    'anniversary 기념일','announce 발표하다','annual 연례의','anxiety 불안','apologize 사과하다',
    'apparent 명백한','appeal 호소하다','appetite 식욕','appliance 가전제품','apply 적용하다',
    'appoint 임명하다','appreciate 감사하다','approach 접근하다','appropriate 적절한','approve 승인하다',
    'arise 발생하다','arrange 정리하다','arrest 체포하다','artificial 인공의','assemble 모으다',
    'assert 주장하다','assess 평가하다','assign 할당하다','assist 돕다','associate 연관짓다',
    'assume 가정하다','atmosphere 분위기','attach 붙이다','attain 달성하다','attempt 시도',
    'attend 참석하다','attitude 태도','attract 끌다','audience 청중','authority 권위',
    'available 이용가능한','average 평균','avoid 피하다','aware 인식하는','awkward 어색한',
    'balance 균형','ban 금지하다','bare 벌거벗은','bargain 흥정','barrier 장벽',
    'bear 견디다','beat 이기다','behave 행동하다','belief 믿음','belong 속하다',
    'bend 구부리다','benefit 이익','bet 내기','betray 배신하다','bind 묶다',
    'bitter 쓴','blame 비난하다','blank 빈','blast 폭발','bleed 피흘리다',
    'blend 섞다','bless 축복하다','block 막다','bloom 꽃피다','board 탑승하다',
    'boast 자랑하다','bond 유대','boom 호황','border 국경','bore 지루하게하다',
    'borrow 빌리다','bother 괴롭히다','bound 경계','brave 용감한','breed 번식하다',
    'brief 짧은','brilliant 빛나는','broad 넓은','broadcast 방송','burden 부담',
    'burst 터지다','bury 묻다','calculate 계산하다','campaign 캠페인','capable 유능한',
    'capacity 용량','capture 포획하다','career 직업','cargo 화물','carve 조각하다',
    'catalog 목록','category 범주','cease 중단하다','celebrate 축하하다','challenge 도전',
    'champion 챔피언','channel 채널','chapter 장','character 성격','charity 자선',
    'charm 매력','chase 추격하다','cheat 속이다','chemical 화학의','cherish 소중히하다',
    'chief 주요한','circumstance 상황','citizen 시민','civil 시민의','claim 주장하다',
    'clarify 명확히하다','classic 고전','climate 기후','cling 달라붙다','collapse 붕괴',
    'colleague 동료','colony 식민지','combat 전투','combine 결합하다','command 명령',
    'commence 시작하다','comment 논평','commerce 상업','commit 저지르다','commodity 상품',
    'communicate 소통하다','companion 동반자','compensate 보상하다','compete 경쟁하다','complain 불평하다',
    'complex 복잡한','comply 따르다','compose 구성하다','compound 화합물','comprehend 이해하다',
    'conceal 숨기다','concentrate 집중하다','concept 개념','concern 우려','conclude 결론짓다',
    'concrete 구체적인','condition 상태','conduct 수행하다','conference 회의','confess 고백하다',
    'confidence 자신감','confine 제한하다','confirm 확인하다','conflict 갈등','confront 직면하다',
    'confuse 혼란시키다','congratulate 축하하다','connect 연결하다','conquer 정복하다','conscience 양심',
    'conscious 의식하는','consequence 결과','conservative 보수적인','consider 고려하다','consist 구성되다',
    'consistent 일관된','constant 지속적인','constitute 구성하다','construct 건설하다','consult 상담하다',
    'consume 소비하다','contact 접촉','contain 포함하다','contemporary 동시대의','content 내용',
    'contest 경연','context 문맥','contract 계약','contradict 모순되다','contrast 대조',
    'contribute 기여하다','convenient 편리한','convention 관습','convince 설득하다','cooperate 협력하다',
    'coordinate 조정하다','cope 대처하다','core 핵심','corporate 기업의','correct 올바른',
    'correspond 일치하다','corrupt 부패한','costume 의상','counsel 상담','counter 계산대',
    'courage 용기','craft 공예','crash 충돌','create 창조하다','creature 생물',
    'credit 신용','crew 승무원','crisis 위기','criterion 기준','critical 비판적인',
    'cruel 잔인한','cultivate 경작하다','cure 치료하다','curious 호기심많은','current 현재의',
    'custom 관습','damage 손상','debate 토론','debt 빚','decade 십년',
    'decay 부패','deceive 속이다','decent 괜찮은','declare 선언하다','decline 감소',
    'decorate 장식하다','decrease 감소','defeat 패배시키다','defend 방어하다','define 정의하다',
    'definite 분명한','degree 정도','delay 지연','delegate 대표','deliberate 고의의',
    'delicate 섬세한','deliver 배달하다','demand 요구','demonstrate 입증하다','deny 부정하다',
    'depart 출발하다','depend 의존하다','depict 묘사하다','deposit 예금','depress 우울하게하다',
    'derive 유래하다','descend 내려가다','describe 묘사하다','deserve 받을만하다','design 디자인',
    'desire 욕망','despair 절망','destination 목적지','destiny 운명','destroy 파괴하다',
    'detect 탐지하다','determine 결정하다','develop 발전하다','device 장치','devote 헌신하다',
    'dialogue 대화','differ 다르다','digest 소화하다','digital 디지털의','dignity 존엄',
    'dilemma 딜레마','dimension 차원','diminish 감소하다','diplomat 외교관','disappear 사라지다',
    'disaster 재앙','discipline 규율','disclose 공개하다','discourage 낙담시키다','discover 발견하다',
    'discrete 분리된','discriminate 차별하다','dismiss 해고하다','display 전시','dispose 처리하다',
    'dispute 분쟁','dissolve 용해하다','distinct 뚜렷한','distinguish 구별하다','distribute 분배하다',
    'district 지역','disturb 방해하다','diverse 다양한','divorce 이혼','document 문서',
    'domain 영역','domestic 국내의','dominate 지배하다','donate 기부하다','draft 초안',
    'dramatic 극적인','drastic 과감한','dread 두려워하다','drift 표류','durable 내구성있는',
    'dynamic 역동적인','eager 열망하는','earn 벌다','echo 메아리','economy 경제',
    'edition 판','educate 교육하다','effective 효과적인','efficient 효율적인','elaborate 정교한',
    'elect 선출하다','elegant 우아한','element 요소','eliminate 제거하다','embrace 포옹하다',
    'emerge 나타나다','emotion 감정','emphasis 강조','empire 제국','employ 고용하다',
    'enable 가능하게하다','encounter 만나다','encourage 격려하다','endure 견디다','engage 관여하다',
    'engine 엔진','enhance 향상시키다','enormous 거대한','ensure 보장하다','enterprise 기업',
    'entertain 즐겁게하다','enthusiasm 열정','entire 전체의','entitle 자격을주다','entry 입장',
    'environment 환경','episode 에피소드','equal 동등한','equip 장비를갖추다','equivalent 동등한',
    'era 시대','error 오류','escape 탈출','essential 필수의','establish 설립하다',
    'estate 재산','estimate 추정','evaluate 평가하다','eventually 결국','evidence 증거',
    'evident 분명한','evil 악','evolve 진화하다','exaggerate 과장하다','examine 조사하다',
    'exceed 초과하다','excel 뛰어나다','exceptional 예외적인','excess 초과','exchange 교환',
    'exclude 제외하다','execute 실행하다','exercise 운동','exhaust 고갈시키다','exhibit 전시하다',
    'exist 존재하다','expand 확장하다','expect 기대하다','expense 비용','experiment 실험',
    'expert 전문가','explain 설명하다','explicit 명시적인','exploit 착취하다','explore 탐험하다',
    'export 수출','expose 드러내다','extend 연장하다','extensive 광범위한','extent 정도',
    'external 외부의','extinct 멸종한','extraordinary 비범한','extreme 극단적인',
  ];

  /// 신조어/IT 50장
  static const slang = [
    '가심비 가격대비심리적만족도','스불재 스스로불러온재앙','중꺾마 꺾이지않는마음','킹받다 열받다','억텐 억지텐션',
    '점메추 점심메뉴추천','소확행 소소하지만확실한행복','혼밥 혼자밥먹기','혼술 혼자술마시기','플렉스 과시하기',
    '갑통알 갑자기통장을알려주다','팬아저 팬이아니라며저장','별다줄 별걸다줄인','좋못사 좋다못해사랑','오저치고 오늘저녁치킨고',
    '이생망 이번생은망했다','존버 존나버티기','현타 현실자각타임','비담 비주얼담당','꾸안꾸 꾸민듯안꾸민',
    'API 인터페이스','클라우드 원격저장소','블록체인 분산원장','IoT 사물인터넷','빅데이터 대규모데이터',
    '머신러닝 기계학습','딥러닝 심층학습','챗GPT 대화형AI','프롬프트 AI명령어','파인튜닝 미세조정',
    '오픈소스 공개소스','깃허브 코드저장소','도커 컨테이너기술','쿠버네티스 컨테이너관리','마이크로서비스 작은서비스',
    '리팩토링 코드개선','디버깅 오류수정','컴파일 코드변환','인터프리터 해석실행','프레임워크 개발도구',
  ];

  /// 유머 50장
  static const humor = [
    '세상에서가장쉬운AI 이보다더쉬운AI는없다','AI먼저말걸면 사람은그냥OX','코딩1도모르고만든앱 그게TikiTaka',
    '사용법3초 OX면끝','스마트폰보다쉬운앱 진짜입니다','OX만누르면되는데 왜다들어려워할까',
    '공부가이렇게쉬울수가 손가락만까딱','망각직전에복습시켜주는AI 감동','영어단어외우기OX로되나요 네',
    'AI가먼저톡 사람은그냥탭','아무생각없이누르다보면 100개외워짐','스트레스제로학습법 특허출원중',
    '시간만나면공부합시다 하루종일함께하는공부','치매예방 두뇌운동매일매일',
    '이어폰으로시력보호 눈대신귀로공부','골전도이어폰 시력청력동시보호',
    'OX만누르는뇌운동 당신의두뇌를깨워요','하루3분 평생가는두뇌습관',
    '운전하며공부 운전중에도OX','샤워하며공부 물소리대신영어',
    '고개끄덕이다보면 공부끝','뇌는OX만누르면되는데 왜필기하나요','시험공부이렇게해도되나 네',
    '당신의뇌를AI가관리합니다','망각을망각하게만드는앱','기억력 좋아지는비결 OX',
    '까먹을만하면다시물어봐주는AI','라이트너가만든마법상자','독일아저씨가발명한학습법 OX로업그레이드',
    '평생기억하고싶은것 OX로','단어장필요없음 OX만','내머릿속에AI들어있음',
    '공부잘하는척하기좋은앱','버스에서OX누르면 공부','지하철에서OX누르면 복습',
    '화장실에서OX누르면 암기','잠들기전OX누르면 망각방지','일어나서OX누르면 복습시작',
  ];

  /// 수학 30장
  static const math = [
    'E=mc² 에너지=질량×빛²','a²+b²=c² 피타고라스','F=ma 뉴턴제2법칙','π≈3.14 원주율',
    '√-1=i 허수단위','e≈2.718 자연상수','sin²+cos²=1 삼각함수항등식','log(xy)=logx+logy 로그법칙',
    'ΔxΔp≥ℏ/2 불확정성원리','V=IR 옴의법칙','F=GmM/r² 만유인력','E=hf 광자에너지',
    'PV=nRT 이상기체','S=klogW 엔트로피','c²=a²+b²-2abcosC 코사인법칙','sinA/a=sinB/b=sinC/c 사인법칙',
    'x=[-b±√(b²-4ac)]/2a 근의공식','d/dx(xⁿ)=nxⁿ⁻¹ 미분','∫xⁿdx=xⁿ⁺¹/(n+1)+C 적분',
    'e^(iπ)+1=0 오일러의등식','1+1=2 가장기본','0!=1 팩토리얼','∞ 무한대',
    'lim(1+1/n)ⁿ=e 자연상수정의','GCD(a,b)=d 최대공약수','LCM(a,b)=l 최소공배수','det(A) 행렬식',
  ];

  /// 영어듣기 20장
  static const listening = [
    'The weather is beautiful today.','Could you help me please?','I would like a cup of coffee.',
    'Where is the nearest station?','What time does it start?','How much does this cost?',
    'Nice to meet you.','See you tomorrow.','Would you like to join us?',
    'I have been waiting for an hour.','She goes to school every day.','He plays soccer on weekends.',
    'We are going to the movies tonight.','They have already left.','It has been raining all day.',
    'Could you repeat that please?','I do not understand.','Please speak more slowly.',
    'What do you recommend?','I will call you later.',
  ];

  /// 상식 20장
  static const facts = [
    '한글날 10월9일','광복절 8월15일','개천절 10월3일','세계물의날 3월22일','지구의날 4월22일',
    '세계환경의날 6월5일','한국전쟁 1950년','서울올림픽 1988년','월드컵4강 2002년','IMF외환위기 1997년',
    '한글창제 1443년','세종대왕 즉위 1418년','임진왜란 1592년','독립선언 1919년3월1일','제헌절 7월17일',
    'UNESCO세계유산 경주역사지구','한반도면적 약22만km²','독도 동도와서도로구성','백두산높이 2744m','한라산높이 1947m',
  ];

  /// 뉴스는 동적 생성 (RSS)
  static const newsMock = ['뉴스를 불러오는 중입니다 잠시만 기다려 주세요'];

  // ─── 덱 선택 ───────────────────────────────────

  static List<String> deckFor(String subject) => switch (subject) {
    '영어' => english, '신조어' => slang, '유머' => humor, '수학' => math,
    '영어듣기' => listening, '상식' => facts, '뉴스' => newsMock,
    'AI상식' => MysticDeck.aiTerms, '건강' => MysticDeck.health,
    '사주' => MysticDeck.saju, '별자리' => MysticDeck.zodiac,
    _ => english,
  };

  static int deckSize(String subject) => deckFor(subject).length;

  // ─── LLM 업데이트 파이프라인 ──────────────────

  /// Generate prompt for new content
  static String updatePrompt(String subject, int count) => switch (subject) {
    '영어' => 'Generate $count English-Korean word pairs. Format: "word meaning". Common SAT/TOEFL words. No duplicates.',
    '유머' => 'Generate $count short Korean jokes or funny observations. Each one line. No duplicates.',
    '신조어' => 'Generate $count latest Korean slang or IT terms with definitions. Format: "term definition". 2025-2026. No duplicates.',
    _ => 'Generate $count items about $subject. Format: "front back". No duplicates.',
  };

  /// This would be called by the LLM pipeline daily
  static Future<List<String>> generateFromLLM(String subject, int count) async {
    // Placeholder — replace with actual LLM call via OpenRouter proxy
    return [];
  }
}
