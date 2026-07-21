/// 경제왕 퀴즈 한 문제.
/// 초등 저학년(2학년) 눈높이 — 짧은 문장, 보기 3개, 해설은 생활 속 비유로.
class QuizQuestion {
  final String id;
  final String topic; // 저축 / 이자 / 물가 / 주식 / 환율 / 기회비용 / 용돈 / 은행
  final String question;
  final List<String> options;
  final int answerIndex;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.topic,
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.explanation,
  });

  String get answerText => options[answerIndex];
}

/// 앱에 내장된 문제은행. 한 번 푼 문제는 다시 나오지 않으므로,
/// 남은 문제가 적어지면 부모에게 알려 새 문제를 추가하도록 안내한다.
const List<QuizQuestion> kQuizBank = [
  // ---------------- 저축 ----------------
  QuizQuestion(
    id: 'q_sav_01',
    topic: '저축',
    question: '용돈을 쓰지 않고 모아두는 것을 뭐라고 할까요?',
    options: ['저축', '소비', '낭비'],
    answerIndex: 0,
    explanation: '쓰지 않고 차곡차곡 모아두는 것이 저축이에요. 반대로 돈을 쓰는 건 소비라고 해요.',
  ),
  QuizQuestion(
    id: 'q_sav_02',
    topic: '저축',
    question: '저축을 하면 좋은 점은 무엇일까요?',
    options: ['나중에 더 큰 것을 살 수 있어요', '돈이 저절로 없어져요', '숙제가 줄어들어요'],
    answerIndex: 0,
    explanation: '작은 돈도 모으면 큰 돈이 돼요. 지금 참으면 나중에 더 갖고 싶던 걸 살 수 있어요.',
  ),
  QuizQuestion(
    id: 'q_sav_03',
    topic: '저축',
    question: '매주 3,000원씩 4주를 모으면 얼마가 될까요?',
    options: ['12,000원', '7,000원', '3,000원'],
    answerIndex: 0,
    explanation: '3,000원 × 4주 = 12,000원이에요. 조금씩이라도 꾸준히 모으면 금방 커져요.',
  ),
  QuizQuestion(
    id: 'q_sav_04',
    topic: '저축',
    question: '갖고 싶은 것이 생겼을 때 가장 좋은 방법은?',
    options: ['얼마인지 알아보고 목표를 정해 모아요', '무조건 바로 사요', '그냥 포기해요'],
    answerIndex: 0,
    explanation: '목표를 정하면 모으는 게 훨씬 쉬워져요. 얼마가 필요한지 아는 것이 첫걸음이에요.',
  ),
  QuizQuestion(
    id: 'q_sav_05',
    topic: '저축',
    question: '저금통에 돈을 넣어두면 좋은 이유는?',
    options: ['쓰고 싶은 마음을 참기 쉬워요', '돈이 두 배가 돼요', '돈이 사라져요'],
    answerIndex: 0,
    explanation: '눈앞에 돈이 없으면 쓰고 싶은 마음이 줄어들어요. 그래서 모으기가 쉬워져요.',
  ),

  // ---------------- 이자 / 금리 ----------------
  QuizQuestion(
    id: 'q_int_01',
    topic: '이자',
    question: '은행에 돈을 맡기면 고맙다고 얹어주는 돈을 뭐라고 할까요?',
    options: ['이자', '세금', '벌금'],
    answerIndex: 0,
    explanation: '돈을 맡겨줘서 고맙다는 뜻으로 은행이 더 얹어주는 돈이 이자예요.',
  ),
  QuizQuestion(
    id: 'q_int_02',
    topic: '이자',
    question: '이자를 더 많이 받으려면 어떻게 해야 할까요?',
    options: ['더 많이, 더 오래 모아요', '빨리 다 써버려요', '돈을 숨겨요'],
    answerIndex: 0,
    explanation: '이자는 모아둔 돈에서 나와요. 많이 모을수록, 오래 둘수록 이자가 커져요.',
  ),
  QuizQuestion(
    id: 'q_int_03',
    topic: '이자',
    question: '10,000원의 10%는 얼마일까요?',
    options: ['1,000원', '100원', '10원'],
    answerIndex: 0,
    explanation: '10%는 10조각으로 나눈 것 중 1조각이에요. 10,000원을 10조각 내면 1,000원이에요.',
  ),
  QuizQuestion(
    id: 'q_int_04',
    topic: '이자',
    question: '금리(이자율)가 오르면 저축하는 사람은 어떻게 될까요?',
    options: ['이자를 더 많이 받아요', '이자를 덜 받아요', '아무 변화가 없어요'],
    answerIndex: 0,
    explanation: '금리는 이자의 크기를 정하는 숫자예요. 금리가 오르면 받는 이자도 커져요.',
  ),
  QuizQuestion(
    id: 'q_int_05',
    topic: '이자',
    question: '받은 이자에 또 이자가 붙어 눈덩이처럼 커지는 것을 뭐라 할까요?',
    options: ['복리', '반값', '할인'],
    answerIndex: 0,
    explanation: '이자에 다시 이자가 붙는 걸 복리라고 해요. 오래 둘수록 눈덩이처럼 불어나요.',
  ),

  // ---------------- 물가 ----------------
  QuizQuestion(
    id: 'q_inf_01',
    topic: '물가',
    question: '작년에 1,000원이던 과자가 올해 1,200원이 됐어요. 이런 것을 뭐라고 할까요?',
    options: ['물가가 올랐다', '물가가 내렸다', '돈이 늘었다'],
    answerIndex: 0,
    explanation: '물건 값이 전체적으로 오르는 것을 "물가가 올랐다"고 해요.',
  ),
  QuizQuestion(
    id: 'q_inf_02',
    topic: '물가',
    question: '물가가 오르면 같은 돈으로 살 수 있는 물건은?',
    options: ['줄어들어요', '늘어나요', '똑같아요'],
    answerIndex: 0,
    explanation: '값이 비싸지면 같은 1,000원으로 살 수 있는 게 적어져요. 돈의 힘이 약해지는 거예요.',
  ),
  QuizQuestion(
    id: 'q_inf_03',
    topic: '물가',
    question: '물가가 계속 오르는데 돈을 그냥 두기만 하면?',
    options: ['돈의 가치가 조금씩 줄어요', '돈이 저절로 늘어요', '아무 일도 없어요'],
    answerIndex: 0,
    explanation: '그래서 이자를 받거나 투자를 해서 물가가 오르는 속도를 따라잡으려고 해요.',
  ),

  // ---------------- 주식 ----------------
  QuizQuestion(
    id: 'q_stk_01',
    topic: '주식',
    question: '회사를 아주 작게 나눈 조각을 뭐라고 할까요?',
    options: ['주식', '동전', '쿠폰'],
    answerIndex: 0,
    explanation: '회사를 작은 조각으로 나눈 것이 주식이에요. 그 조각을 사면 회사의 작은 주인이 돼요.',
  ),
  QuizQuestion(
    id: 'q_stk_02',
    topic: '주식',
    question: '어떤 회사의 주식을 사면 나는 그 회사의 무엇이 될까요?',
    options: ['아주 작은 주인', '직원', '손님'],
    answerIndex: 0,
    explanation: '주식을 가지면 그 회사의 작은 주인이 돼요. 회사가 잘되면 내 몫도 커져요.',
  ),
  QuizQuestion(
    id: 'q_stk_03',
    topic: '주식',
    question: '주식의 가격은 어떻게 될까요?',
    options: ['오르기도 하고 내리기도 해요', '항상 올라요', '항상 내려요'],
    answerIndex: 0,
    explanation: '주식은 오를 수도 내릴 수도 있어요. 그래서 잃을 수도 있다는 걸 꼭 알아야 해요.',
  ),
  QuizQuestion(
    id: 'q_stk_04',
    topic: '주식',
    question: '코스피는 무엇일까요?',
    options: ['우리나라 주식들의 평균 성적표', '은행 이름', '과자 이름'],
    answerIndex: 0,
    explanation: '코스피는 우리나라 회사들의 주식 값을 모아 평균 낸 숫자예요. 오르면 대체로 잘되고 있다는 뜻이에요.',
  ),
  QuizQuestion(
    id: 'q_stk_05',
    topic: '주식',
    question: '투자할 때 가장 좋은 습관은 무엇일까요?',
    options: ['잘 알아보고 조금씩 나눠서', '친구 말만 듣고 전부', '아무거나 빨리'],
    answerIndex: 0,
    explanation: '잘 아는 것에, 한 번에 다 넣지 않고 나눠서 하는 게 안전해요.',
  ),

  // ---------------- 환율 ----------------
  QuizQuestion(
    id: 'q_fx_01',
    topic: '환율',
    question: '1달러를 사려면 우리 돈이 얼마나 필요한지 알려주는 것은?',
    options: ['환율', '금리', '물가'],
    answerIndex: 0,
    explanation: '나라마다 돈이 달라요. 우리 돈과 다른 나라 돈을 바꾸는 비율이 환율이에요.',
  ),
  QuizQuestion(
    id: 'q_fx_02',
    topic: '환율',
    question: '환율이 오르면 달러를 살 때 어떻게 될까요?',
    options: ['우리 돈이 더 많이 필요해요', '더 적게 필요해요', '똑같아요'],
    answerIndex: 0,
    explanation: '환율이 오르면 달러가 비싸진 거예요. 같은 1달러를 사는 데 원화가 더 들어요.',
  ),
  QuizQuestion(
    id: 'q_fx_03',
    topic: '환율',
    question: '미국 회사의 주식을 사려면 어떤 돈이 필요할까요?',
    options: ['달러', '엔화', '원화 그대로'],
    answerIndex: 0,
    explanation: '미국에서는 달러를 써요. 그래서 원화를 달러로 바꿔서 사야 해요.',
  ),

  // ---------------- 기회비용 ----------------
  QuizQuestion(
    id: 'q_opp_01',
    topic: '기회비용',
    question: '3,000원으로 아이스크림을 사면 그 돈으로 못 사게 된 다른 것을 뭐라 할까요?',
    options: ['기회비용', '이자', '용돈'],
    answerIndex: 0,
    explanation: '하나를 고르면 다른 하나는 포기해야 해요. 그 포기한 것이 기회비용이에요.',
  ),
  QuizQuestion(
    id: 'q_opp_02',
    topic: '기회비용',
    question: '갖고 싶은 게 둘인데 돈은 하나만큼일 때 좋은 방법은?',
    options: ['더 오래 좋아할 것을 골라요', '둘 다 사요', '둘 다 포기해요'],
    answerIndex: 0,
    explanation: '돈은 한정돼 있어요. 금방 질리는 것보다 오래 좋아할 것을 고르는 게 현명해요.',
  ),
  QuizQuestion(
    id: 'q_opp_03',
    topic: '기회비용',
    question: '돈이 한정되어 있을 때 가장 먼저 할 일은?',
    options: ['무엇이 더 중요한지 정해요', '눈에 보이는 대로 사요', '아무것도 안 해요'],
    answerIndex: 0,
    explanation: '중요한 것부터 순서를 정하면 후회 없이 쓸 수 있어요.',
  ),

  // ---------------- 용돈 관리 ----------------
  QuizQuestion(
    id: 'q_mny_01',
    topic: '용돈',
    question: '용돈기입장(가계부)을 쓰면 좋은 점은?',
    options: ['어디에 얼마 썼는지 알 수 있어요', '돈이 저절로 늘어요', '숙제가 줄어요'],
    answerIndex: 0,
    explanation: '적어두면 내가 어디에 많이 쓰는지 보여요. 그래야 아껴야 할 곳을 알 수 있어요.',
  ),
  QuizQuestion(
    id: 'q_mny_02',
    topic: '용돈',
    question: '예산이란 무엇일까요?',
    options: ['미리 정해둔, 쓸 수 있는 돈', '저금통 이름', '은행 이름'],
    answerIndex: 0,
    explanation: '이번 주에 이만큼만 쓰자고 미리 정해두는 것이 예산이에요.',
  ),
  QuizQuestion(
    id: 'q_mny_03',
    topic: '용돈',
    question: '계획 없이 갑자기 사고 싶어져서 사는 것을 뭐라 할까요?',
    options: ['충동구매', '저축', '예산'],
    answerIndex: 0,
    explanation: '충동구매는 나중에 후회하기 쉬워요. 하루만 참고 다시 생각해보면 좋아요.',
  ),
  QuizQuestion(
    id: 'q_mny_04',
    topic: '용돈',
    question: '용돈을 받으면 가장 먼저 하면 좋은 일은?',
    options: ['얼마를 저축할지 먼저 떼어놔요', '전부 다 써요', '숨겨둬요'],
    answerIndex: 0,
    explanation: '쓰고 남은 걸 모으면 잘 안 모여요. 먼저 저축할 몫을 떼어놓는 게 좋아요.',
  ),

  // ---------------- 은행 / 대출 ----------------
  QuizQuestion(
    id: 'q_bnk_01',
    topic: '은행',
    question: '은행이 하는 일이 아닌 것은?',
    options: ['과자를 만들어요', '돈을 맡아줘요', '돈을 빌려줘요'],
    answerIndex: 0,
    explanation: '은행은 돈을 맡아주고, 필요한 사람에게 빌려주는 일을 해요.',
  ),
  QuizQuestion(
    id: 'q_bnk_02',
    topic: '은행',
    question: '은행은 사람들이 맡긴 돈으로 무엇을 할까요?',
    options: ['필요한 사람에게 빌려줘요', '그냥 버려요', '땅에 묻어요'],
    answerIndex: 0,
    explanation: '빌려주고 이자를 받아요. 그 이자의 일부를 돈을 맡긴 사람에게 나눠주는 거예요.',
  ),
  QuizQuestion(
    id: 'q_bnk_03',
    topic: '은행',
    question: '돈을 빌렸을 때 꼭 지켜야 할 것은?',
    options: ['약속한 날까지 갚아요', '안 갚아도 돼요', '더 빌려요'],
    answerIndex: 0,
    explanation: '빌린 돈은 반드시 갚아야 해요. 늦으면 이자를 더 내야 해서 손해예요.',
  ),
  QuizQuestion(
    id: 'q_bnk_04',
    topic: '은행',
    question: '은행이 문을 닫아도 맡긴 돈을 일정 금액까지 지켜주는 제도는?',
    options: ['예금자보호', '충동구매', '기회비용'],
    answerIndex: 0,
    explanation: '나라가 정한 예금자보호 제도가 있어서, 은행에 문제가 생겨도 정해진 금액까지는 돌려받을 수 있어요.',
  ),

  // ---------------- 마무리 / 종합 ----------------
  QuizQuestion(
    id: 'q_mix_01',
    topic: '저축',
    question: '목표를 정하고 모으면 좋은 점은?',
    options: ['끝까지 모으기 쉬워져요', '돈이 두 배가 돼요', '이자가 사라져요'],
    answerIndex: 0,
    explanation: '"자전거 사기"처럼 목표가 있으면 참는 힘이 생겨요.',
  ),
  QuizQuestion(
    id: 'q_mix_02',
    topic: '주식',
    question: '원금(처음 넣은 돈)이 줄어들 수도 있는 것은?',
    options: ['주식', '저금통', '용돈봉투'],
    answerIndex: 0,
    explanation: '주식은 값이 내려가면 처음보다 줄어들 수 있어요. 그래서 잘 알아보고 해야 해요.',
  ),
  QuizQuestion(
    id: 'q_mix_03',
    topic: '용돈',
    question: '친구가 비싼 장난감을 샀다고 나도 꼭 사야 할까요?',
    options: ['내게 정말 필요한지 먼저 생각해요', '무조건 따라 사요', '더 비싼 걸 사요'],
    answerIndex: 0,
    explanation: '남을 따라 사면 후회하기 쉬워요. 내 기준으로 필요한지 생각하는 게 중요해요.',
  ),
];
